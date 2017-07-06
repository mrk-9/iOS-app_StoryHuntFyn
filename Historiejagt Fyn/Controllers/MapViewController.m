//
//  MapViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 25/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//


#ifndef DEBUG
//#define MAP_DEBUG
#endif

#import "MapViewController.h"
#import "CachingTileOverlay.h"
#import "MKMapView+MKMapView_AttributionView.h"
//#import "MKMapView+ZoomLevel.h"
#import "AnnotationView.h"
#import "Annotation.h"
#import "Datalayer.h"
#import "Route.h"
#import "PointOfInterest.h"
#import "PointOfInterestConnection.h"
#import "SoundHelper.h"
#import "AlertViewController.h"
#import "DialogViewController.h"
#import "StoryboardHelper.h"
#import "PointBar.h"
#import <Canvas/Canvas.h>
#import "LocationManager.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
#import <MapKit/MapKit.h>
#import "GeofencingManager.h"
#import "Flurry.h"
#define ZOOM_LEVEL_ROUTE (IS_IPAD ? 2.4f : 1.2f)
#define ZOOM_LEVEL_CHILDREN (IS_IPAD ? 0.40f : 0.20f)
// Used for creating a geocoordiante frame around Denmark to be used if the mapview goes astray
#define DENMARK_GEOFRAME_UPPER_LEFT_LAT 57.794258
#define DENMARK_GEOFRAME_UPPER_LEFT_LONG 7.634109
#define DENMARK_GEOFRAME_LOWER_RIGHT_LAT 54.402117
#define DENMARK_GEOFRAME_LOWER_RIGHT_LONG 13.259109

@interface MapViewController () <MKMapViewDelegate, AlertViewControllerDelegate, DialogViewControllerDelegate, PointBarDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *texture;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet CSAnimationView *settingsButtonAnimation;
@property (weak, nonatomic) IBOutlet CSAnimationView *userLocatorAnimation;
@property (weak, nonatomic) IBOutlet PointBar *pointBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pointBarRightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapRightConstraint;


@property (nonatomic, readonly) NSArray *fakeVisits;

@property (nonatomic, strong) CachingTileOverlay *tileOverlay;
@property (nonatomic, assign) NSInteger currentZoomlevel;
@property (nonatomic, assign) BOOL routesFetched;
@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) Route *route;
@property (nonatomic, strong) NSMutableArray *routeOverlays;
@property (nonatomic, strong) NSMutableArray *inactiveRouteOverlays;
@property (nonatomic, assign) NSInteger countForRoutesWithAnnotations;
@property (nonatomic, strong) CLLocation *lastKnownLocation;

@property (nonatomic, assign) BOOL initRouteCheck;
@property (nonatomic, assign) BOOL routeDrawn;
@property (nonatomic, assign) BOOL hideRouteDetails;
@property (nonatomic, assign) BOOL hideRoute;
@property (nonatomic, assign) BOOL hideChildrenPoints;
//@property (nonatomic, assign) RoutePointPercentageBlock activeRoutePercentage;
//@property (nonatomic, assign) float percentage;

@property (nonatomic, strong) AlertViewController *alertViewController;
@property (nonatomic, strong) DialogViewController *dialogViewController;
@property (nonatomic, assign) MKCoordinateRegion defaultRegion;

@property (nonatomic, strong) MKCircle *metaRegion;

@property (atomic, assign) BOOL fetchingRouteParts;

@property (nonatomic, strong) NSMutableDictionary *parentPoints;
@property (nonatomic, strong) NSMutableArray *lineSegments;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.defaultRegion = [[Datalayer sharedInstance] regionForFunen];
    // Do any additional setup after loading the view.
    
    //Mask out the map to fit into page
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = self.view.frame;
    
    // Set background depending on the device type and size
    // Set masking of map
    
    [UIDevice executeOnIphone4:^{
        [self.texture setImage:[UIImage imageNamed:@"page-texture-3.5.png"]];
        maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"page-3.5.png"] CGImage];
    }];
    [UIDevice executeOnIphonesExceptIphone4:^{
        [self.texture setImage:[UIImage imageNamed:@"page-texture-4.png"]];
        maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"page-4.png"] CGImage];
    }];
    [UIDevice executeOnIpad:^{
        [self.texture setImage:[UIImage imageNamed:@"page-texture-ipad.png"]];
        self.texture.contentMode = UIViewContentModeTopLeft;
        maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"page-ipad.png"] CGImage];
    }];
    
    // Apply the mask to your uiview layer
    self.mapView.layer.mask = maskLayer;
    
    // Reset the map view if the user has either newer opened the map before or the last save of the map view is too far in the past
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawMapContent) name:@"MapSettingsChanged" object:nil];
    
    self.countForRoutesWithAnnotations = 0;
    self.routeDrawn = NO;
    self.initRouteCheck = YES;
    self.routesFetched = NO;
 //   self.settingsButtonAnimation.hidden = YES;
//    self.userLocatorAnimation.hidden = YES;

    [self configureDefaultSettings];
}

- (void)configureDefaultSettings {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"show_route_setting"]) {
        [[Datalayer sharedInstance] setBoolSetting:YES forIdentifier:@"show_route_setting"];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"automatic_sound_setting"]) {
        [[Datalayer sharedInstance] setBoolSetting:YES forIdentifier:@"automatic_sound_setting"];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.pointBar.delegate = nil;
    [self saveMapPosition];
    [super viewWillDisappear:animated];
//    self.settingsButtonAnimation.hidden = YES;
//    self.userLocatorAnimation.hidden = YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"view did appear");
    [super viewDidAppear:animated];
    // Delegate
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    // Move attribution view to visible area
    UIView *attributionView = [self.mapView attributionView];
    CGRect frame = attributionView.frame;
    frame.origin.y -= 30;
    attributionView.frame = frame;
    // Reset the map view if the user has either newer opened the map before or the last save of the map view is too far in the past
    
    self.pointBar.delegate = self;
    [self.pointBar updatePoints];
    NSDate* lastMapSavedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"map.location.lastSavedDate"];
    if (!self.returnFromContentView && (lastMapSavedDate == nil || ([lastMapSavedDate timeIntervalSinceNow] < -2 * 60 * 60)))
    {
        NSLog(@"first place");
        [self resetMapToDefaultView];
    }
    else
    {
        NSLog(@"not first place");
        [self loadStoredMapPosition];
    }
   
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
    if (!self.routesFetched)
    {
        if (!self.returnFromContentView)
        {
            NSLog(@"second place");
            [self resetMapToDefaultView];
        }
        else
        {
            [self loadStoredMapPosition];
        }
        self.initRouteCheck = YES;
    
        // Add open street view tiles as overlay
        [self.mapView addOverlay:self.tileOverlay level:MKOverlayLevelAboveLabels];
        
        self.mapView.rotateEnabled = NO;
        self.mapView.showsUserLocation = YES;
        [self fetchRoutes];
        self.routesFetched = YES;
    }
//    [self.settingsButtonAnimation startCanvasAnimation];
//    [self.settingsButtonAnimation setHidden:NO];
#ifdef DEBUG
//   [self sendFakePost:@0];
#endif
    
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //[self.mapView removeOverlay:self.tileOverlay];
    [self removeRoute];
    self.mapView.delegate = nil;
}

- (void) updateViewConstraints
{
    [super updateViewConstraints];
    self.pointBarRightConstraint.constant = self.leftPageOffset;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"MEMORY WARNING MAP");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.mapView removeOverlay:self.tileOverlay];
    [self.mapView removeOverlays:self.routeOverlays];
    [self.mapView removeOverlays:self.inactiveRouteOverlays];
    self.tileOverlay = nil;
    self.routes = nil;
    self.routeOverlays = nil;
    self.inactiveRouteOverlays = nil;
    self.routesFetched = NO;
    self.mapView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
}
#pragma mark - public properties

- (void) setRouteId:(NSString *)routeId
{
    //NSLog(@"Sets routeID: %@ - old was: %@", routeId, _routeId);
    if (![_routeId isEqualToString:routeId])
    {
        self.routesFetched = NO;
        self.countForRoutesWithAnnotations = 0;
        self.route = nil;
        self.initRouteCheck = NO;
        [self.mapView removeOverlays:self.routeOverlays];
        [self.mapView removeOverlays:self.inactiveRouteOverlays];
        self.routeOverlays = nil;
        self.inactiveRouteOverlays = nil;
        [self.mapView removeAnnotations:self.mapView.annotations];

    }
    _routeId = routeId;
}

#pragma mark - private selectors
- (IBAction)userLocatorPressed:(id)sender
{
//    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    self.mapView.showsUserLocation = YES;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate];
//    self.userLocatorAnimation.hidden = YES;
}

- (IBAction)settingsPressed:(id)sender
{
    if (self.delegate)
    {
        [self saveMapPosition];
        [self.delegate viewController:self requestsShowing:ViewControllerItemMapSettings withUserInfo:nil];
    }
}


/*!
 *  Reset map view to the default coorinates and zoom level
 */
-(void)resetMapToDefaultView
{
    NSLog(@"sets default view");
    [self.mapView setRegion:self.defaultRegion];
   // [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(55.351012309685515, 10.3656005859375) zoomLevel:6 animated:NO];
}

- (void) saveMapPosition
{
    NSLog(@"Save mapposition");
    [self saveMapPositionForRegion:self.mapView.region];
}

- (void) saveMapPositionForRegion:(MKCoordinateRegion) region
{
  
    if ([self coordinateIsWithinValidRegion:region.center])
    {

        [[NSUserDefaults standardUserDefaults] setDouble:region.center.latitude forKey:@"map.location.center.latitude"];
        [[NSUserDefaults standardUserDefaults] setDouble:region.center.longitude forKey:@"map.location.center.longitude"];
        [[NSUserDefaults standardUserDefaults] setDouble:region.span.latitudeDelta forKey:@"map.location.span.latitude"];
        [[NSUserDefaults standardUserDefaults] setDouble:region.span.longitudeDelta forKey:@"map.location.span.longitude"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"map.location.lastSavedDate"];
        [[NSUserDefaults standardUserDefaults] synchronize];
//        NSLog(@"GEMMER locationdata [ Center lat %f long %f ] [ Span lat %f long %f ]", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta );
    }
}

- (void) loadStoredMapPosition
{

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"map.location.center.latitude"])
    {
        NSLog(@"Loads stored map position");
        
        MKCoordinateRegion region;

        region.center.latitude  = [[NSUserDefaults standardUserDefaults] doubleForKey:@"map.location.center.latitude"];
        region.center.longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:@"map.location.center.longitude"];
        region.span.latitudeDelta  = [[NSUserDefaults standardUserDefaults] doubleForKey:@"map.location.span.latitude"] * 0.99f;
        region.span.longitudeDelta = [[NSUserDefaults standardUserDefaults] doubleForKey:@"map.location.span.longitude"] * 0.99f;
        NSLog(@"Loaded region: [ Center lat %f long %f ] [ Span lat %f long %f ]", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta );
        [self.mapView setRegion:region];

    }
    else
    {
        //[self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate zoomLevel:6 animated:YES];
        NSLog(@"load - > sets default");
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
        [self.mapView setRegion:self.defaultRegion];
    }
}

-(BOOL)coordinateIsWithinValidRegion:(CLLocationCoordinate2D)coordinate
{
    // Check if a coordinate is within the permitted area (Denmark)
    if (coordinate.latitude < DENMARK_GEOFRAME_LOWER_RIGHT_LAT || coordinate.latitude > DENMARK_GEOFRAME_UPPER_LEFT_LAT || coordinate.longitude < DENMARK_GEOFRAME_UPPER_LEFT_LONG  || coordinate.longitude > DENMARK_GEOFRAME_LOWER_RIGHT_LONG)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)filterAnnotationsForCurrentZoom
{
    int newZoomLevel = (int)(log( self.mapView.visibleMapRect.size.width / self.mapView.frame.size.width ) / log(2));
    self.currentZoomlevel = newZoomLevel;

    //NSLog(@"Zoom level %f (%ld)", self.mapView.region.span.latitudeDelta,self.currentZoomlevel);

    for (Annotation *annotation in self.mapView.annotations)
    {
        if ([annotation isKindOfClass:[Annotation class]])
        {
            BOOL show = (annotation.pointOfInterest.zoomLevelMin <= self.currentZoomlevel && annotation.pointOfInterest.zoomLevelMax >= self.currentZoomlevel);
            [[self.mapView viewForAnnotation:annotation] setHidden:!show];
            [[self.mapView viewForAnnotation:annotation] setEnabled:show];
            [[self.mapView viewForAnnotation:annotation] setNeedsDisplay];
            [self markLineSegmentForRouteWithId:annotation.route.objectId withPoi:annotation.pointOfInterest asVisible:show];
        }
    }
    [self redrawLineSegments];
    [self.mapView setNeedsDisplay];
}


- (void) redrawMapContent
{
    //[self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.routeOverlays];
    [self.mapView removeOverlays:self.inactiveRouteOverlays];
    [self fetchRoutes:YES];
    [self showHideRoute];
}


/*!
 *  Fetch routes from datalayer and draw them on the map
 */
- (void) fetchRoutes
{

    if (!self.returnFromContentView)
    {
    
    self.defaultRegion = [[Datalayer sharedInstance] regionForRouteWithObjectId:self.routeId];
 //   [self saveMapPositionForRegion:self.defaultRegion];
    [self.mapView setRegion:self.defaultRegion];
    }
    [self fetchRoutes:YES];
}


- (void) fetchRoutes:(BOOL) drawAnnotations
{
    // Routes
    self.routes = [[Datalayer sharedInstance] allRoutes];

    for (Route *route in self.routes)
    {
        if (self.routeId && [route.objectId isEqualToString:self.routeId])
        {
            if ([[Datalayer sharedInstance] boolSettingWithIdentifier:[NSString stringWithFormat:@"show_route_setting"] defaultValue:YES])
            {
                self.route = route;
                // make route
                [self createRouteOverlayForRouteWithObjectId:route.objectId];
                [self.lineSegments addObject:[self lineSegmentBlobFor:route active:YES]];
            }
        }
        else  if ([[Datalayer sharedInstance] boolSettingWithIdentifier:[NSString stringWithFormat:@"settings_route_%@", route.objectId] defaultValue:NO])
        {
            [self createRouteOverlayForRouteWithObjectId:route.objectId];
            [self.lineSegments addObject:[self lineSegmentBlobFor:route active:YES]];
        }
        else
        {
            [self.lineSegments addObject:[self lineSegmentBlobFor:route active:NO]];
        }
       if ([[Datalayer sharedInstance] boolSettingWithIdentifier:[NSString stringWithFormat:@"show_route_setting"] defaultValue:YES])
//        {
//            // If route is the current active route draw the route
//            if (self.routeId && [route.objectId isEqualToString:self.routeId])
//            {
//                self.route = route;
//                // make route
//                [self createRouteOverlayForRouteWithObjectId:route.objectId];
//            }
//            else
//            {
//                //NSLog(@"Route: %@ - show %@", route.name, [[Datalayer sharedInstance] boolSettingWithIdentifier:[NSString stringWithFormat:@"settings_route_%@", route.objectId] defaultValue:NO] ? @"YES" : @"NO");
//                if ([[Datalayer sharedInstance] boolSettingWithIdentifier:[NSString stringWithFormat:@"settings_route_%@", route.objectId] defaultValue:NO])
//                {
//                    [self createRouteOverlayForRouteWithObjectId:route.objectId];
//                }
//            }
//        }
//
//        
        
        if (drawAnnotations)
        {
            // Draw annotations for the points of interests belonging to the route
            [self drawAnnotationsForRoute:route];
        }
    }
}

- (void) addPolyline:(MKPolyline *) polyline withTitle:(NSString *) title
{
    [polyline setTitle:title];
    [self.mapView addOverlay:polyline level:MKOverlayLevelAboveLabels];
    if ([title isEqualToString:self.routeId])
    {
        [self.routeOverlays addObject:polyline];
    }
    else
    {
        [self.inactiveRouteOverlays addObject:polyline];
    }
}

/*!
 *  Draw the visible route on map
 *
 *  @param objectId Objectid for route to draw visible route for
 */
- (void) createRouteOverlayForRouteWithObjectId:(NSString *)objectId
{
    
    
    NSArray *routeParts = [[Datalayer sharedInstance] drawableRoutePartsForRouteWithObjectId:objectId];
    
    for (PointOfInterestConnection *routePart in routeParts)
    {
        [self generatePolylineForRoutePart:routePart forRouteWithObjectId:objectId];
    }
}

- (void) retryGeneratePolyline:(NSDictionary *) userInfo
{
    if (self.fetchingRouteParts)
    {
        [self performSelector:@selector(retryGeneratePolyline:) withObject:userInfo afterDelay:2];
    }
    else
    {
        PointOfInterestConnection *routePart = [userInfo valueForKey:@"routePart"];
        NSString *objectId = [userInfo valueForKey:@"objectId"];
        [self generatePolylineForRoutePart:routePart forRouteWithObjectId:objectId];
    }
    
}

- (void) generatePolylineForRoutePart:(PointOfInterestConnection *) routePart forRouteWithObjectId:(NSString *) objectId
{

    MKPolyline *polyline = [[Datalayer sharedInstance] polylineWithIdentifer:routePart.sourceId  forRouteWithObjectId:objectId];
    
    if (polyline)
    {
        NSLog(@"Cached polyline found");
        [self addPolyline:polyline withTitle:objectId];
        self.fetchingRouteParts = NO;
    }
    else
    {
        if (self.fetchingRouteParts)
        {
            [self performSelector:@selector(retryGeneratePolyline:) withObject:@{@"routePart" : routePart, @"objectId" : objectId } afterDelay:1];
            return;
        }
        else
        {
            self.fetchingRouteParts = YES;
        
            //NSLog(@"Fetches route parts from directions");
            CLLocationCoordinate2D source = [[Datalayer sharedInstance] coordinateForPointOfInterestWithObjectId:routePart.sourceId];
            CLLocationCoordinate2D dest = [[Datalayer sharedInstance] coordinateForPointOfInterestWithObjectId:routePart.destId];
            
            MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
            MKPlacemark *sourceMark = [[MKPlacemark alloc] initWithCoordinate:source addressDictionary:nil];
            MKMapItem *sourceItem = [[MKMapItem alloc] initWithPlacemark:sourceMark];
            MKPlacemark *destMark = [[MKPlacemark alloc] initWithCoordinate:dest addressDictionary:nil];
            MKMapItem *destItem = [[MKMapItem alloc] initWithPlacemark:destMark];
            
            request.source = sourceItem;
            request.destination = destItem;
            request.requestsAlternateRoutes = NO;
            MKDirections *directions =[[MKDirections alloc] initWithRequest:request];
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
             {
                 if (error)
                 {
                     NSLog(@"Error:%@", error);
                     // Handle Error
                     [self performSelector:@selector(retryGeneratePolyline:) withObject:@{@"routePart" : routePart, @"objectId" : objectId } afterDelay:25];
                     self.fetchingRouteParts = NO;
                 } else
                 {
                     MKPolyline *polyline = ((MKRoute*)response.routes[0]).polyline;
                     [self addPolyline:polyline withTitle:objectId];
                     [[Datalayer sharedInstance] addPolyline:polyline withIdentifier:routePart.sourceId toRouteWithObjectId:objectId];
                     self.fetchingRouteParts = NO;
                 }
             }];
        }
    }
}


/*!
 *  Draw the annotations for a route to the map
 *
 *  @param route route to draw annotations for
 */
- (void) drawAnnotationsForRoute:(Route *)route
{
    //NSLog(@"Draw annotations for route: %@", route.name);
    // Get POIs for route
    NSArray *pointOfInterests = [[Datalayer sharedInstance] pointOfInterestsForRoute:route];
    BOOL defaultActive = [[Datalayer sharedInstance] boolSettingWithIdentifier:[NSString stringWithFormat:@"settings_route_%@", route.objectId] defaultValue:NO];
    
    BOOL active = NO;
    if (self.routeId != nil)
    {
        active = ([self.routeId isEqualToString:route.objectId]) || defaultActive;
    }
    else
    {
        BOOL activateAll = ![[Datalayer sharedInstance] anyDefaultRoute];

        active = activateAll || defaultActive;
    }
   //         NSLog(@"drawAnnotationForRoute: %d", active);
    // add annotations
    for (PointOfInterest *poi in pointOfInterests)
    {
        Annotation *annotation = [[Annotation alloc] initWithPointOfInterest:poi forRoute:route active:active];
        //NSLog(@"Adding %@", poi.title);
        [self.mapView addAnnotation:annotation];
#ifdef MAP_DEBUG
        MKCircle *c = [MKCircle circleWithCenterCoordinate:poi.coordinates radius: poi.autoRange];
        //NSLog(@"Adds %@ - %ld",c, poi.autoRange);
        [self.mapView addOverlay:c];
#endif
    }
    
    // Make annotation for route
    Annotation *annotation = [[Annotation alloc] initWithPointOfInterest:nil forRoute:route active:active];
    [self.mapView addAnnotation:annotation];
    self.countForRoutesWithAnnotations++;
    // All routes drawn - handle showing/hidding
    if (self.countForRoutesWithAnnotations == [self.routes count])
    {
        //NSLog(@"update showHide for annotations for all %ld routes", (unsigned long)[self.routes count]);
        [self prepareStackAnnotations];
        
        if (self.route && !self.returnFromContentView)
        {
//            [self.mapView setCenterCoordinate:self.route.centerCoordinates zoomLevel:7 animated:NO];
            [self resetMapToDefaultView];
            [self saveMapPosition];
        }
        else
        {
            NSLog(@"Loads stored position");
            [self loadStoredMapPosition];
        }
        
    }
}


/*!
 * Iterate the annotations and hide them if nessesary.
 *
 * KRB Changes:
 * - Any active annotations will be put in on a list.
 * - The list will be augmented with stacks.
 * - The list will be assigned to the map.
 *
 * To keep the changes local, the mapview is still used as annotation store.
 *
 */
- (void) prepareStackAnnotations {

    // Create cull and show lists.
    NSMutableArray* cull_list = [NSMutableArray array];
    NSMutableArray* poi_list = [NSMutableArray array];
    for (Annotation* annotation in self.mapView.annotations)
    {
        if ([annotation isKindOfClass:[Annotation class]])
        {
            if ( annotation.pointOfInterest.isStack )
            {
                [cull_list addObject:annotation];
            }
            else
            {
                if ( ![self hideAnnotation:annotation] && annotation.pointOfInterest)
                {
                    [poi_list addObject:annotation.pointOfInterest];
                }
            }
        }
    }
    [self.mapView removeAnnotations:cull_list];

    // Update the show list for zoom levels and add stack annotations.
    [self generateZoomLevelPinsInArray:poi_list];

    // Set annotation visibility based on the current zoom level.
    [self filterAnnotationsForCurrentZoom];
}

/*!
 *  Decide if an annotation is to be shown or hidden
 *
 *  @param annotation annotation to evaluate
 *
 *  @return true if to be shown false if to be hidden
 *
 *
 * KRB: This has been changed to:
 * 2) Always show the route.
 * 3) POIs are must be eligible to be shown. I'm not sure the the mechanics, but "unlockPOI" is used for this.
 */
-(BOOL) hideAnnotation:(Annotation *)annotation
{
    if (annotation.pointOfInterestAnnotation)
    {
        
        BOOL eligible = YES;
        if (annotation.pointOfInterest.unlockPOI && ![[Datalayer sharedInstance] hasVisitedPointOfInterestWithObjectId:annotation.pointOfInterest.unlockPOI])
        {
            eligible = NO;
        }
        if (annotation.pointOfInterest.objectId && ![[Datalayer sharedInstance] hasVisitedPointOfInterestWithObjectId:annotation.pointOfInterest.objectId])
        {
            // 3) poi have not yet been shown and the distance to the user location is greater than the defined mapRange.
            CLLocationDirection distance = [self.mapView.userLocation.location distanceFromLocation:[[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude]];
            if (annotation.pointOfInterest.mapRange > 0 && (NSInteger)distance > annotation.pointOfInterest.mapRange)
            {
                //NSLog(@"not visisted and distance %f greater than %ld", distance, (long)annotation.pointOfInterest.mapRange);
                eligible = NO;
            }
        }
        return !eligible;
    }
    
    if (annotation.routeAnnotation )
    {
        
        return NO;
    }
    
    // Otherwise - show the annotation.
    return NO;
}

/*!
 *  check route and show or hide it depending on zoom level and if it is active
 */
- (void) showHideRoute
{
    // Non active routes are always hidden
//    if (!self.routeId)
//    {
//        return;
//    }

    self.hideRoute = YES;//(self.mapView.region.span.latitudeDelta > ZOOM_LEVEL_ROUTE) || [[Datalayer sharedInstance] boolSettingWithIdentifier:@"show_route_setting"];
    // decide if a check is nessasary - first call will always be triggered
    self.initRouteCheck = YES;
    if (self.initRouteCheck /*|| self.hideRoute != hidden*/)
    {
        self.initRouteCheck = NO;
        if (self.hideRouteDetails)
        {
            // Remove route
            [self removeRoute];
        }
        else
        {
            // Draw route
            //			[self createRouteOverlayForRouteWithObjectId:self.routeId];
//            for (MKPolyline *polyline in self.routeOverlays)
//            {
//                [self.mapView insertOverlay:polyline atIndex:0 level:MKOverlayLevelAboveLabels];
//            }
            [self.mapView addOverlays:self.routeOverlays  level:MKOverlayLevelAboveLabels];

//            for (MKPolyline *polyline in self.routeOverlays)
//            {
//                [self.mapView insertOverlay:polyline atIndex:1 level:MKOverlayLevelAboveLabels];
//            }
            [self.mapView addOverlays:self.inactiveRouteOverlays level:MKOverlayLevelAboveLabels];
        }
    }
}

- (void)generateZoomLevelPinsInArray:(NSMutableArray*)array {
    // First, initialize zoom filtering attributes on all pins
    for (PointOfInterest* poi in array)
    {
        poi.zoomLevelMin = 0;
        poi.zoomLevelMax = 20;
        if ( poi.active )
        {
            poi.weight_active = 1;
        }
        else
        {
            poi.weight_inactive = 1;
        }
    }
    //NSLog(@"Annotations before collapse: %ld", [array count]);

    float grid_spacing = 80; // Grid spacing, origo is lat=0,lon=0;

    for ( int level = 2; level <=20; level++ )
    {

        // Bin pins
        NSMutableDictionary *bins = [NSMutableDictionary dictionary];
        for( PointOfInterest *poi in [self poisForLevel:level withPOIs:array])
        {

            MKMapPoint p = MKMapPointForCoordinate(poi.coordinates);

            CGPoint bin_p = CGPointMake(round(p.x / grid_spacing), round(p.y / grid_spacing));
            NSMutableArray *list = [bins objectForKey:[NSValue valueWithCGPoint:bin_p]];
            if ( !list )
            {
                list = [NSMutableArray arrayWithCapacity:1];
                [bins setObject:list forKey:[NSValue valueWithCGPoint:bin_p]];
            }
            [list addObject:poi];
        }

        // Sort bins according to weight
        NSMutableDictionary *weights = [NSMutableDictionary dictionaryWithCapacity:[bins count]];

        for ( NSValue *v in bins )
        {
            CGPoint bin_p = [v CGPointValue];
            int count = 0;
            int hits = 0;
            for(int y=-1;y<=1;y++)
            {
                for(int x=-1;x<=1;x++) {
                    NSArray *a = [bins objectForKey:[NSValue valueWithCGPoint:CGPointMake((float)((int)bin_p.x+x), (float)((int)bin_p.y+y))]];
                    for(PointOfInterest *poi in a)
                    {
                        count += poi.weight;
                        hits ++;
                    }
                }
            }
            if (hits > 1 )
            {
                // Only add weight if more than one pin exists
                [weights setObject:[NSNumber numberWithInt:count] forKey:v];
            }
        }

        // Collapse bins as needed.
        for ( NSValue *v in [weights keysSortedByValueUsingComparator: ^(id obj1, id obj2)
        {
            if ([obj1 integerValue] < [obj2 integerValue])
            {
                return (NSComparisonResult)NSOrderedDescending;
            }
            if ([obj1 integerValue] > [obj2 integerValue])
            {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
        }])
        {
            int count = [[weights objectForKey:v] intValue];
            if ( count > 1 && [bins objectForKey:v]) { // Must have more than one pin and may not have been collapsed already
                // Collapse around current bin
                double acc_x = 0.0;
                double acc_y = 0.0;
                int   count_active = 0;
                int   count_inactive = 0;

                CGPoint bin_p = [v CGPointValue];
                for(int y=-1;y<=1;y++) {
                    for(int x=-1;x<=1;x++) {
                        NSValue *key = [NSValue valueWithCGPoint:CGPointMake((float)((int)bin_p.x+x), (float)((int)bin_p.y+y))];
                        NSArray *a = [bins objectForKey:key];
                        for(PointOfInterest *poi in a) {
                            MKMapPoint p2 = MKMapPointForCoordinate(poi.coordinates);
                            count_active += poi.weight_active;
                            count_inactive += poi.weight_inactive;
                            acc_x += (float)(poi.weight) * p2.x;
                            acc_y += (float)(poi.weight) * p2.y;
                            poi.zoomLevelMax = level-1;
                        }
                        [bins removeObjectForKey:key];
                    }
                }

                CLLocationCoordinate2D ccl = MKCoordinateForMapPoint(MKMapPointMake((float)acc_x/count, acc_y/(float)count));
                PointOfInterest *newP = [[PointOfInterest alloc] init];
                newP.isStack      = YES;
                newP.coordinates  = CLLocationCoordinate2DMake(ccl.latitude, ccl.longitude);
                newP.zoomLevelMin = level;
                newP.zoomLevelMax = 20;
                newP.weight_active   = count_active;
                newP.weight_inactive = count_inactive;
                newP.routeId      = ((PointOfInterest*)array.firstObject).routeId;
                [array addObject:newP];
                Annotation *annotation = [[Annotation alloc] initWithPointOfInterest:newP forRoute:nil active:YES];

                //CLLocationCoordinate2D topLeft = CLLocationCoordinate2DMake(55.693779f, 9.629520f);
                //CLLocationCoordinate2D bottomRight = CLLocationCoordinate2DMake(54.717970f, 11.125034f);
                //if (ccl.latitude < topLeft.latitude && ccl.latitude > bottomRight.latitude && ccl.longitude > topLeft.longitude && ccl.longitude < bottomRight.longitude)
                {
                    [self.mapView addAnnotation:annotation];
                }
            }
        }

//        NSLog(@"Annotations after collapse: %ld", [array count]);
        grid_spacing *= 2;
    }
    for (id<MKAnnotation> annotation in self.mapView.annotations){
        MKAnnotationView* view = [self.mapView viewForAnnotation: annotation];
        if (view)
        {
            if ([view isKindOfClass:[AnnotationView class]])
            {
                if (!view.hidden)
                {
                    [[view superview] bringSubviewToFront:view];
                }
                else
                {
                    [[view superview] sendSubviewToBack:view];
                    
                }
            }

            
        }
    }
    [self redrawLineSegments];
    [self.mapView setNeedsDisplay];

}

- (NSArray*)poisForLevel:(NSInteger)level withPOIs:(NSArray*)pois
{
    NSMutableArray* ret = [NSMutableArray array];
    for (PointOfInterest* poi in pois)
    {
        if ( poi.zoomLevelMin<=level && poi.zoomLevelMax>=level )
        {
            [ret addObject:poi];
        }
    }
    return ret;
}

/*!
 *  Remove route from map
 */
- (void)removeRoute
{
    // For all types of poly line overlay - remove them from the map
    for (id<MKOverlay> overlayToRemove in self.mapView.overlays)
    {
        if ([overlayToRemove isKindOfClass:[MKPolyline class]])
        {
            [self.mapView removeOverlay:overlayToRemove];
        }
    }
}

/*!
 *  Shows a popup dialog instead of the normal call out for a POI.
 *
 *  @param pointOfInterest point of interest to show content for
 */
- (void) presentDialogForPointOfInterest:(PointOfInterest *)pointOfInterest;
{
    NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                  pointOfInterest.title, @"Point of interest",
                                  nil
                                  ];
    [Flurry logEvent:kFlurryUserTappedOnPOI withParameters:flurryParams timed:YES];
    [self saveMapPosition];
    [self.dialogViewController presentInParentViewController:self withTitle:pointOfInterest.title andText:pointOfInterest.info andIdentifier:pointOfInterest.objectId];

    NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
    for (Annotation *annotation in selectedAnnotations)
    {
        [self.mapView deselectAnnotation:annotation animated:YES];
            }
}
//#define DISABLE_LOCK NO
- (void) showPoiWithObjectId:(NSString *)objectId
{

    PointOfInterest *poi = [[Datalayer sharedInstance] pointOfInterestWithObjectId:objectId];
    CLLocationDirection distance = [self.mapView.userLocation.location distanceFromLocation:[[CLLocation alloc] initWithLatitude:poi.coordinates.latitude longitude:poi.coordinates.longitude]];
    BOOL visited = [[Datalayer sharedInstance] hasVisitedPointOfInterestWithObjectId:objectId];
    if (visited || poi.clickRange == 0 || poi.clickRange > (NSInteger)distance)
    {
        [[Datalayer sharedInstance] registerVisitOfPointOfInterestWithObjectId:poi.objectId];
        
        // Send out notification for active app use...
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"Tell about this poi: %@", poi.title);
            [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerPointOfInterestClickedManually object:nil userInfo:@{@"pointOfInterest" : poi.objectId}];
        });

        
        
        if (self.delegate)
        {
            [self saveMapPosition];

            [self.delegate viewController:self requestsShowing:ViewControllerItemInfo withUserInfo:@{@"poiId" : objectId}];
        }
        
    }
    else
    {
        NSString * content = NSLocalizedString(@"Besøg stedet, for at åbne for denne historie.", @"Text for alert view telling that the user must be closer to this poi to see info");
        [self.alertViewController presentInParentViewController:self withTitle:poi.title andText:content];
    }

}


#pragma mark - private properties

- (CachingTileOverlay *) tileOverlay
{

    if (!_tileOverlay)
    {
        _tileOverlay = [[CachingTileOverlay alloc] init];
        _tileOverlay.canReplaceMapContent = YES;
    }
    return _tileOverlay;
}

- (NSMutableArray *) routeOverlays
{
    if (!_routeOverlays)
    {
        _routeOverlays = [[NSMutableArray alloc] init];
    }
    return _routeOverlays;
}

- (NSMutableArray *) inactiveRouteOverlays
{
    if (!_inactiveRouteOverlays)
    {
        _inactiveRouteOverlays = [[NSMutableArray alloc] init];
    }
    return _inactiveRouteOverlays;
}



- (AlertViewController *) alertViewController
{
    if (!_alertViewController)
    {
        _alertViewController = [StoryboardHelper getViewControllerWithId:IS_IPAD ? @"iPadAlertViewController" : @"alertViewController"];
        _alertViewController.delegate = self;
    }
    return _alertViewController;
}

- (DialogViewController *) dialogViewController
{
    if (!_dialogViewController)
    {
        _dialogViewController = [StoryboardHelper getViewControllerWithId: IS_IPAD ? @"iPadDialogViewController" : @"dialogViewController"];
        _dialogViewController.delegate = self;
    }
    return _dialogViewController;
}


- (void) showUserLocationButton
{
    //NSLog(@"showUserLocationButton");
    if (!self.mapView.userLocationVisible && self.lastKnownLocation)
    {
        if (self.mapView.userTrackingMode == MKUserTrackingModeNone)
        {
            [self.userLocatorAnimation startCanvasAnimation];
            [self.userLocatorAnimation setHidden:NO];
        }
    }
    else
    {
    }
}


#pragma mark - PointBar delegate
- (void) pointBar:(PointBar *)pointBar registeredPointLevel:(RoutePointPercentageBlock)level forRouteWithObjectId:(NSString *)objectId
{
    // Show pop up if percentage fitting any of the following ranges
    NSString *content = [[Datalayer sharedInstance] textForPercentageBlock:level completedForRouteWithObjectId:objectId];
    Route *route = [[Datalayer sharedInstance] routeForRoutePointWithObjectId:objectId];
    if ([content length] > 0)
    {
        //NSLog(@"Content not null");
        [[SoundHelper sharedInstance] playPercentageCompleteSound];
        [self.alertViewController presentInParentViewController:self withTitle:route.name andText:content andUserInfo:@{@"level" : [NSNumber numberWithInteger:level], @"objectId" : objectId} andIdentifier:@"pointsystem"];
    }
}

#pragma mark - Alert View Controller Delegate
- (void) buttonPressedAtAlertViewController:(AlertViewController *)vc
{
    if ([vc.identifier isEqualToString:@"pointsystem"])
    {
        NSDictionary *dict = self.alertViewController.userInfo;
        NSString *objectId = [dict valueForKeyPath:@"objectId"];
        RoutePointPercentageBlock level = [[dict valueForKeyPath:@"level"] integerValue];
        [self.pointBar registerHasShownDialogForPointLevel:level forRouteWithObjectId:objectId];
    }
}

#pragma mark - Dialog View Controller Delegate
- (void) okButtonPressedAtDialogViewController:(DialogViewController *)vc withIdentifier:(NSString *)identifier
{
    [Flurry endTimedEvent:kFlurryUserTappedOnPOI withParameters:nil];
    //NSLog(@"Yo %@", identifier);
    [self showPoiWithObjectId:identifier];
}

- (void) cancelButtonPressedAtDialogViewController:(DialogViewController *)vc withIdentifier:(NSString *)identifier
{
    [Flurry endTimedEvent:kFlurryUserTappedOnPOI withParameters:nil];
}

#pragma mark - MapView delegate

- (void) mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
    NSLog(@"MAPVIEW FAILEDED: %@", error);
}


-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    
    if([overlay isKindOfClass:[MKTileOverlay class]])
    {
        //NSLog(@"Ever in here?");
        return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
    }
    else if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolyline *pl = (MKPolyline *)overlay;
        MKPolylineRenderer* v = [[MKPolylineRenderer alloc] initWithPolyline:pl];
        if ([pl.title isEqualToString:@"lineSegment"])
        {
            v.lineWidth = 1.0f;
            v.strokeColor = [UIColor colorWithRed:158.0/255.0 green:127.0/255.0 blue:127.0/255.0 alpha:0.9];
        }
        else if ([pl.title isEqualToString:@"activeLineSegment"])
        {
            v.lineWidth = 1.0f;
            v.strokeColor = [UIColor colorWithRed:158.0/255.0 green:61.0/255.0 blue:61.0/255.0 alpha:0.9];
        }
        else
        {
        
            if (self.routeId && ![self.routeId isEqualToString:pl.title])
            {
                v.strokeColor = [UIColor colorWithRed:158.0/255.0 green:127.0/255.0 blue:127.0/255.0 alpha:0.9];
            }
            else
            {
                v.strokeColor = [UIColor colorWithRed:158.0/255.0 green:61.0/255.0 blue:61.0/255.0 alpha:0.9];
            }
            v.lineWidth = 3;
        }
        return v;
    }
    else if ([overlay isKindOfClass:[MKCircle class]])
    {
#ifdef MAP_DEBUG

        MKCircle *c = (MKCircle *)overlay;
        MKCircleRenderer * circleView = [[MKCircleRenderer alloc] initWithCircle:c];
        if ([c.title isEqualToString:@"metadata"])
        {

            circleView.fillColor = [UIColor redColor];
        }
        else
        {
            circleView.fillColor = [UIColor greenColor];
        }
        circleView.strokeColor = [UIColor blueColor];
        circleView.alpha = 0.1;
        return circleView;
#endif

    }
    return nil;
}



- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{

    // Tjeck if the view showing map outside of Denmark
    // TODO tjeck wheter the user interacted with the map within the last second
//    if ([self coordinateIsWithinValidRegion:self.mapView.region.center])
//    {
//        [self saveMapPosition];
//    }
//    else
//    {
//        [self loadStoredMapPosition];
//    }
    [self saveMapPosition];
    [self filterAnnotationsForCurrentZoom];
    [self showHideRoute];
    
 //   [self showUserLocationButton];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        MKAnnotationView *a = [mapView dequeueReusableAnnotationViewWithIdentifier:@"user"];
        if (a)
        {
            return a;
        }
        else
        {
            MKAnnotationView *a = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"user"];
            a.image = [UIImage imageNamed:@"map-position.png"];
            a.canShowCallout = NO;
            a.layer.zPosition = 100000;
            return a;
        }
        return nil;
    }
    
    //static NSString* AnnotationIdentifier = @"AnnotationIdentifier";

    if ([annotation isKindOfClass:[Annotation class]]) {
        Route *route = [(Annotation *)annotation route];
        Annotation *a = (Annotation *)annotation;
        BOOL defaultActive = [[Datalayer sharedInstance] boolSettingWithIdentifier:[NSString stringWithFormat:@"settings_route_%@", route.objectId] defaultValue:NO];

        a.active = NO;
        if (self.routeId != nil)
        {
            a.active = ([self.routeId isEqualToString:route.objectId]) || defaultActive;
        }
        else
        {
            BOOL activateAll = ![[Datalayer sharedInstance] anyDefaultRoute];
            
            BOOL defaultActive = [[Datalayer sharedInstance] boolSettingWithIdentifier:[NSString stringWithFormat:@"settings_route_%@", route.objectId] defaultValue:NO];
            
            a.active = activateAll || defaultActive;
        }
        
        //NSLog(@"viewForAnnotation: %d", a.active);
        
        NSString *objectId;
        if (a.pointOfInterestAnnotation)
        {
            objectId = a.pointOfInterest.objectId;
        }
        else
        {
            objectId = a.route.objectId;
        }

        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier: objectId];
        if (annotationView)
        {
            return annotationView;
        }
        else
        {
            AnnotationView *annotationView = [[AnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:objectId];
            BOOL active = [a active];

            UIImage* image = nil;
            if ( a.pointOfInterest.isStack )
            {
                if ( a.pointOfInterest.weight_inactive == 0 )
                {
                    image = [UIImage imageNamed:@"collect-pins-active.png"];
                }
                else if ( a.pointOfInterest.weight_active == 0 )
                {
                    image = [UIImage imageNamed:@"collect-pins-inactive.png"];
                }
                else if ( a.pointOfInterest.weight_active < a.pointOfInterest.weight_inactive )
                {
                    image = [UIImage imageNamed:@"collect-pins-active-1.png"];
                }
                else
                {
                    image = [UIImage imageNamed:@"collect-pins-inactive-1.png"];
                }
                annotationView.groupPin = YES;
            }
            else
            {
                annotationView.groupPin = NO;
                
                image = [UIImage imageWithData:(active ? route.pin : route.pinInactive) scale: a.pointOfInterest.parentPoint ? 1.6 : 2.0];
            }
            annotationView.image = image;
            annotationView.draggable = NO;
            annotationView.active = active;

            annotationView.pointOfInterest = [a pointOfInterest];
            annotationView.route = route;
            return annotationView;
        }
    }
    return nil;
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
   

    
    if (IS_IPAD)
    {
        CLLocationDirection distance = [userLocation.location distanceFromLocation:self.lastKnownLocation];
        if (!self.lastKnownLocation || (NSInteger)distance > 5)
        {
            self.lastKnownLocation = userLocation.location;
        }
    }
    else
    {
        [self filterAnnotationsForCurrentZoom];
        [self showHideRoute];

    }
    if (!self.lastKnownLocation)
    {
        self.lastKnownLocation = userLocation.location;
    }
    

}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    for (MKAnnotationView * view in views)
    {
        if ([view isKindOfClass:[AnnotationView class]])
        {
            if (!view.hidden && ((AnnotationView *)view).groupPin)
            {
                [[view superview] bringSubviewToFront:view];
            }
            else
            {
                [[view superview] sendSubviewToBack:view];

            }
        }
    }
    
}

- (void) mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{

    for (UIView  *v in [view subviews])
    {
        [v removeFromSuperview];
    }
    // remove any subvies
}


- (void) zoomIn:(Annotation*) annotation
{
    // Tries to zoom in on a annotation
    // Really not working on ios 7/8 especially large screen
    CLLocationCoordinate2D coord = annotation.coordinate;
    MKCoordinateRegion region = self.mapView.region;
    
    MKCoordinateSpan span = self.mapView.region.span;
    span.latitudeDelta /= 2.5;
    span.longitudeDelta /= 2.5;
    region.span = span;
//    if (region.span.latitudeDelta < .003f)
//    {
//        region.span.latitudeDelta = .003f;
//    }
//    if (!region.span.longitudeDelta < .003f)
//    {
//        region.span.longitudeDelta = .003f;
//    }
////    if (self.currentZoomlevel < 5)
////    {
////        region = MKCoordinateRegionMakeWithDistance(coord, 10, 10$);
////    }
    
    region.center = coord;
   
    [self.mapView setRegion:region animated:YES];
//
}

- (void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
  //  NSLog(@"did select: %@", [view class]);
    
    
    
    if ([view isKindOfClass:[AnnotationView class]])
    {
        AnnotationView *av = (AnnotationView *)view;
        PointOfInterest *pointOfInterest = [(AnnotationView *)view pointOfInterest];
        //[[SoundHelper sharedInstance] playTapSound];
        //  [mapView setCenterCoordinate:[pointOfInterest coordinates] zoomLevel:22 animated:YES];
        if (pointOfInterest.isStack == NO)
        {
            [self presentDialogForPointOfInterest:av.pointOfInterest];
        }
        else
        {
          //  [mapView setCenterCoordinate:av.annotation.coordinate zoomLevel:mapView.zoomLevel+2 animated:YES];
            [self zoomIn:av.annotation];
            [mapView deselectAnnotation:view.annotation animated:NO];
        }
    }
    
}

#pragma mark - test area
// Used for faking
- (NSArray *) fakeVisits
{
    return @[
             @"qkCfVXX60F",
             @"unCBZbZ5lx",
             @"BMIlW5GKFT",
             @"C4Xoi22dqc",
             @"SQlKrcA7YO",
             @"nm1hSpU8b8",
             @"hmL4wACJiW",
             @"OTwBn3QLTT",
             @"QmguAFUSnV",
             @"2pdyp5Pnx2",
             @"Az7dEtXV4h",
             @"lRygWwvsxN",
             @"2fs5O7z2We",
             @"PH9Qeii5rf",
             @"hQeYvD6XHY",
             @"z1SXOhRB4b",
             @"mSTk0eiMT7",
             @"BMIlW5GKFT",
             @"QLkpsBIlYN",
             @"KiiIaeGyiH",
             @"sAQUGGmCYP",
             @"ukIEnrJCom",
             @"p8MpDTiOVF",
             @"DODO6tLjqc",
             @"pigwM2UnYe",
             @"MOopAipk0t",
             ];
}

- (void) sendFakePost:(NSNumber*) number
{
    if ([number intValue] < self.fakeVisits.count)
    {
        NSString *poiId = [self.fakeVisits objectAtIndex:number.intValue];
        NSString *rpId = [[Datalayer sharedInstance] pointOfInterestBelongsToPointSystem:poiId];
        if (rpId)
        {
            if (number.intValue == 0)
            {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:rpId];

                    [[NSUserDefaults standardUserDefaults] synchronize];

            }
            NSMutableSet *foundPois = [NSMutableSet setWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:rpId]];
            [foundPois addObject:poiId];
            [[NSUserDefaults standardUserDefaults] setObject:[foundPois allObjects] forKey:rpId];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerPointOfInterestFound object:nil userInfo:@{@"pointOfInterest" : poiId}];
        [self performSelector:@selector(sendFakePost:) withObject:[NSNumber numberWithInt:[number intValue] + 1] afterDelay:5];
                                                                                                                        
                                                                                                                        
                                                                                                                        
    }
}


- (void) prepareStop
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.pointBar.delegate = nil;
    [self.mapView removeFromSuperview];
    self.mapView.delegate = nil;
    self.mapView = nil;
}


#pragma mark - line segments between parent point and pois

- (NSMutableDictionary *) parentPoints
{
    if (!_parentPoints)
    {
        _parentPoints = [NSMutableDictionary new];
    }
    return _parentPoints;
}

- (NSMutableArray *) lineSegments
{
    if (!_lineSegments)
    {
        _lineSegments = [NSMutableArray new];
    }
    return _lineSegments;
}

- (void) addParentPointToList:(NSString *) parentPoint visible:(BOOL) visible
{
    [self.parentPoints setObject:[NSNumber numberWithBool:visible] forKey:parentPoint];
}

- (BOOL) parentPointVisible:(NSString *)parentPoint
{
    return [[self.parentPoints valueForKey:parentPoint] boolValue];
}

- (NSMutableDictionary *) lineSegmentBlobFor:(Route *) route active:(BOOL) active
{
    NSMutableArray *points = [NSMutableArray new];
    NSArray *routePOIs = [[Datalayer sharedInstance] pointOfInterestsForRoute:route];
    for (PointOfInterest *p in routePOIs)
    {
        if (p.parentPoint)
        {
            [self addParentPointToList:p.objectId visible:NO];
        }
        if (p.parentPOI)
        {
            NSInteger i = [routePOIs indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                PointOfInterest *poi = obj;
                return  ([poi.objectId isEqualToString:p.parentPOI]);
            }];
            NSLog(@"Parent point: %@ -> %ld", p.parentPOI, (long)i);
            if (i != NSNotFound)
            {
                PointOfInterest *poi = [routePOIs objectAtIndex:i];
                NSMutableDictionary *point = [NSMutableDictionary new];
                [point setObject:[NSNumber numberWithBool:NO] forKey:@"visible"];
                [point setObject:[NSNumber numberWithBool:active] forKey:@"active"];
                [point setObject:p forKey:@"poi1"];
                [point setObject:poi forKey:@"poi2"];
                [points addObject:point];
            }
        }
    }
    if (points.count > 0)
    {
        NSMutableDictionary *d = [NSMutableDictionary new];
        [d setObject:[NSNumber numberWithBool:NO] forKey:@"visible"];
        [d setObject:route.objectId forKey:@"route"];
        [d setObject:points forKey:@"lines"];
        return d;
    }
    return [NSMutableDictionary new];
}

- (void) markLineSegmentForRouteWithId:(NSString *) routeId withPoi:(PointOfInterest *) poi asVisible:(BOOL ) visible
{
    if (poi.parentPoint)
    {
        [self addParentPointToList:poi.objectId visible:visible];
    }
    for (NSMutableDictionary *d in self.lineSegments)
    {
        if ([[d valueForKey:@"route"] isEqualToString:routeId])
        {
            NSMutableArray *points = [d valueForKey:@"lines"];
            for (NSMutableDictionary *pd in points)
            {
                PointOfInterest *p1 = [pd valueForKey:@"poi1"];
                PointOfInterest *p2 = [pd valueForKey:@"poi2"];
                BOOL pVisible = NO;
                if (visible)
                {
                    pVisible = [self parentPointVisible:p2.objectId];
                }
                
                if ([p1.objectId isEqualToString:poi.objectId] || [p2.objectId isEqualToString:poi.objectId])
                {
                    [pd setObject:[NSNumber numberWithBool:pVisible] forKey:@"visible"];
                }
            }
            
        }
    }
}

- (void) removeLineSegments
{
    NSMutableArray *toRemove = [NSMutableArray new];
    for (id<MKOverlay> v in self.mapView.overlays)
    {
        if ([v isKindOfClass:[MKPolyline class]])
        {
            MKPolyline *p = (MKPolyline *)v;
            if ([p.title isEqualToString:@"lineSegment"] || [p.title isEqualToString:@"activeLineSegment"])
            {
                [toRemove addObject:p];
            }
        }
    }
    [self.mapView removeOverlays:toRemove];
}

- (void) setupLineSegments
{
    NSMutableArray *toAdd = [NSMutableArray new];
    for (NSMutableDictionary *routeSegment in self.lineSegments)
    {
        BOOL found = YES;
        NSArray *points = [routeSegment objectForKey:@"lines"];
        NSLog(@"points: %@", points);
        if (found && points)
        {
            for (NSDictionary *p in points)
            {
                if (p && [[p objectForKey:@"visible"] boolValue])
                {
                    PointOfInterest *poi1 = [p objectForKey:@"poi1"];
                    PointOfInterest *poi2 = [p objectForKey:@"poi2"];
                    CLLocationCoordinate2D coords[2]={poi1.coordinates, poi2.coordinates};
                    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:2];
                    if ([[p valueForKey:@"active"] boolValue])
                    {
                        [polyline setTitle:@"activeLineSegment"];
                    }
                    else
                    {
                        [polyline setTitle:@"lineSegment"];
                    }
                    [toAdd addObject:polyline];
                }
            }
        }
    }
    [self.mapView addOverlays:toAdd level:MKOverlayLevelAboveLabels];
}

- (void) redrawLineSegments
{
    [self removeLineSegments];
    [self setupLineSegments];
}


//- (NSMutableArray *) lineSegments
//{
//    if (!_lineSegments)
//    {
//        _lineSegments = [NSMutableArray new];
//    }
//    return _lineSegments;
//}
//
//- (NSMutableDictionary *) lineSegmentBlobFor:(Route *) route
//{
//    PointOfInterest *parentPoint = nil;
//    NSMutableArray *points = [NSMutableArray new];
//    for (PointOfInterest *p in [[Datalayer sharedInstance] pointOfInterestsForRoute:route])
//    {
//        if (p.parentPoint)
//        {
//            parentPoint = p;
//         
//        }
//        else
//        {
//            NSMutableDictionary *point = [NSMutableDictionary new];
//            [point setObject:[NSNumber numberWithBool:NO] forKey:@"visible"];
//            [point setObject:p forKey:@"poi"];
//            [points addObject:point];
//        }
//    }
//    if (parentPoint)
//    {
//        NSMutableDictionary *d = [NSMutableDictionary new];
//        [d setObject:[NSNumber numberWithBool:NO] forKey:@"visible"];
//        [d setObject:route.objectId forKey:@"route"];
//        [d setObject:parentPoint forKey:@"center"];
//        [d setObject:points forKey:@"points"];
//        return d;
//    }
//    return [NSMutableDictionary new];
//}
//
//- (void) markLineSegmentForRouteWithId:(NSString *) routeId withPoi:(PointOfInterest *) poi asVisible:(BOOL ) visible
//{
//    for (NSMutableDictionary *d in self.lineSegments)
//    {
//
//        if ([[d valueForKey:@"route"] isEqualToString:routeId])
//        {
//            PointOfInterest *parent = [d valueForKey:@"center"];
//            if ([parent.objectId isEqualToString:poi.objectId])
//            {
//                [d setObject:[NSNumber numberWithBool:visible] forKey:@"visible"];
//            }
//            else
//            {
//                NSMutableArray *points = [d valueForKey:@"points"];
//                for (NSMutableDictionary *pd in points)
//                {
//                    PointOfInterest *pdp = [pd valueForKey:@"poi"];
//                    if ([pdp.objectId isEqualToString:poi.objectId])
//                    {
//                        NSLog(@"Poi: %@ = %@", poi.title, visible ? @"YES" : @"NO");
//                        [pd setObject:[NSNumber numberWithBool:visible] forKey:@"visible"];
//                    }
//                }
//            }
//        }
//    }
//}
//
//- (void) removeLineSegments
//{
//    NSMutableArray *toRemove = [NSMutableArray new];
//    for (id<MKOverlay> v in self.mapView.overlays)
//    {
//        if ([v isKindOfClass:[MKPolyline class]])
//        {
//            MKPolyline *p = (MKPolyline *)v;
//            if ([p.title isEqualToString:@"lineSegment"])
//            {
//                [toRemove addObject:p];
//            }
//        }
//    }
//    [self.mapView removeOverlays:toRemove];
//}
//
//- (void) setupLineSegments
//{
//    NSMutableArray *toAdd = [NSMutableArray new];
//    for (NSMutableDictionary *routeSegment in self.lineSegments)
//    {
//        if (![[routeSegment valueForKey:@"visible"] boolValue]) {
//            continue;
//        }
//        BOOL found = NO;
//        CLLocationCoordinate2D center;
//        if ([routeSegment objectForKey:@"center"])
//        {
//            PointOfInterest *p = [routeSegment objectForKey:@"center"];
//            center = p.coordinates;
//            found = YES;
//        }
//        NSArray *points = [routeSegment objectForKey:@"points"];
//        if (found && points)
//        {
//            for (NSDictionary *p in points)
//            {
//                if (p && [p objectForKey:@"visible"])
//                {
//                    PointOfInterest *poi = [p objectForKey:@"poi"];
//                    CLLocationCoordinate2D coords[2]={center, poi.coordinates};
//                    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:2];
//                    [polyline setTitle:@"lineSegment"];
//                    [toAdd addObject:polyline];
//                }
//            }
//        }
//    }
//    [self.mapView addOverlays:toAdd level:MKOverlayLevelAboveLabels];
//}
//
//- (void) redrawLineSegments
//{
//    [self removeLineSegments];
//    [self setupLineSegments];
//}

@end