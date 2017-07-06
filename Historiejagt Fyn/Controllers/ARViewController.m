//
//  ARViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 25/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "ARViewController.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
#import "HOCARView.h"
#import "HOCPoiView.h"
#import "Datalayer.h"
#import "DialogViewController.h"
#import "AlertViewController.h"
#import "StoryboardHelper.h"
#import "SoundHelper.h"
#import "Flurry.h"
@interface ARViewController () <HOCARViewDatasource, HOCPoiViewDelegate, HOCPoiViewDataSource, DialogViewControllerDelegate, AlertViewControllerDelegate, PointBarDelegate>
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) HOCARView *arView;
@property (nonatomic, strong) NSMutableDictionary *poisViews;
@property (nonatomic, strong) AlertViewController *alertViewController;
@property (nonatomic, strong) DialogViewController *dialogViewController;
@property (nonatomic, strong) PointBar *pointBar;

@end

@implementation ARViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logEvent:kFlurryShowARViewEventName withParameters:nil timed:YES];
    
    __block UIFont *font = [UIFont fontWithName:@"MarkerFelt-Thin" size:22];
    [UIDevice executeOnIphone5:^{
        font = [UIFont fontWithName:@"MarkerFelt-Thin" size:24];
    }];
    [UIDevice executeOnIphone4:^{
        font = [UIFont fontWithName:@"MarkerFelt-Thin" size:24];
    }];
    
    [UIDevice executeOnIphone6:^{
        font = [UIFont fontWithName:@"MarkerFelt-Thin" size:28];
    }];
    
    [UIDevice executeOnIphone6Plus:^{
        font = [UIFont fontWithName:@"MarkerFelt-Thin" size:30];
    }];
    [UIDevice executeOnIpad:^{
        font = [UIFont fontWithName:@"MarkerFelt-Thin" size:34];
    }];
    [self.titleLabel setFont:font];

    [self.preview addSubview:self.arView];

   
    [self.view addSubview:self.pointBar];

}

- (void) updateViewConstraints
{
    [super updateViewConstraints];
    
    [UIDevice executeOnIphone5:^{
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pointBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:20]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pointBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:100]];

    }];
    [UIDevice executeOnIphone4:^{
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pointBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:20]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pointBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:100]];

    }];
    
    [UIDevice executeOnIphone6:^{
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pointBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:20]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pointBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:120]];

    }];
    
    [UIDevice executeOnIphone6Plus:^{
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pointBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:20]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pointBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:120]];

    }];
    [UIDevice executeOnIpad:^{
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pointBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:120]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pointBar attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0 constant:40]];
    }];

    
    

    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pointBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:self.leftPageOffset + 20]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.pointBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-(self.leftPageOffset+self.rightPageOffset)]];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pointBar.delegate = self;
    [self.pointBar updatePoints];
    [self.arView start];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.pointBar.delegate = nil;
    [self.arView stop];
    [self.arView removeFromSuperview];
    self.arView = nil;
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:kFlurryShowARViewEventName withParameters:nil];
}

- (HOCARView *) arView
{
    //return nil;
    if (!_arView)
    {
        _arView = [[HOCARView alloc] initWithFrame:self.preview.frame];
        _arView.pois = [[Datalayer sharedInstance] pointOfInterests];
        _arView.datasource = self;
    }
    return _arView;
}

- (NSMutableDictionary *) poisViews
{
    if (!_poisViews)
    {
        _poisViews = [[NSMutableDictionary alloc] init];
    }
    return _poisViews;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.dialogViewController presentInParentViewController:self withTitle:pointOfInterest.title andText:pointOfInterest.info andIdentifier:pointOfInterest.objectId];
    
  //  [self.arView stop];
}

- (BOOL) canTapPoiWithIdentifier:(NSString *)identifier
{
    return [[Datalayer sharedInstance] hasVisitedPointOfInterestWithObjectId:identifier];
}

- (HOCPoiView *) viewForPoiWithIdentifier:(NSString *)identifier
{

    if (![self.poisViews valueForKey:identifier])
    {
        PointOfInterest *poi = [[Datalayer sharedInstance] pointOfInterestWithObjectId:identifier];
        Route *route = [[Datalayer sharedInstance] routeContainingPointOfInterestWithObjectId:identifier];
        BOOL active = YES;
        if (self.routeId && ![route.objectId isEqualToString:self.routeId])
        {
            active = NO;
        }
        UIImage *image = [UIImage imageWithData:active ? route.arPin : route.arPinInactive scale:1];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        CLLocationDistance dist = poi.arRange > 0 ? poi.arRange : 10;
       // NSLog(@"Dist: %f", dist);
        HOCPoiView *poiView = [[HOCPoiView alloc] initWithSubView:imageView identifier:identifier visibleWithinDistance:dist tapDistance:poi.clickRange];
        poiView.delegate = self;
        [self.poisViews setObject:poiView forKey:identifier];
    }
    return [self.poisViews valueForKey:identifier];
}

- (void) tappedPoiView:(HOCPoiView *)poiView
{
    //NSLog(@"Did tap poi view with identifier: %@", poiView.identifier);
    PointOfInterest *poi = [[Datalayer sharedInstance] pointOfInterestWithObjectId:poiView.identifier];
    [self presentDialogForPointOfInterest:poi];
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

- (void) buttonPressedAtAlertViewController:(AlertViewController *)vc
{
    if ([vc.identifier isEqualToString:@"pointsystem"])
    {
        NSDictionary *dict = self.alertViewController.userInfo;
        NSString *objectId = [dict valueForKeyPath:@"objectId"];
        RoutePointPercentageBlock level = [[dict valueForKeyPath:@"level"] integerValue];
        [self.pointBar registerHasShownDialogForPointLevel:level forRouteWithObjectId:objectId];
    }
   // [self resetARView];
}

- (void) okButtonPressedAtDialogViewController:(DialogViewController *)vc withIdentifier:(NSString *)identifier
{
    [Flurry endTimedEvent:kFlurryUserTappedOnPOI withParameters:nil];
    [self showPoiWithObjectId:identifier];
    
}

- (void) cancelButtonPressedAtDialogViewController:(DialogViewController *)vc withIdentifier:(NSString *)identifier
{
    [Flurry endTimedEvent:kFlurryUserTappedOnPOI withParameters:nil];
 //   [self resetARView];
}
- (void) resetARView
{
    [self.arView removeFromSuperview];
    self.arView = nil;
    [self.preview addSubview:self.arView];
    [self.arView start];

}

#define DISABLE_LOCK NO
- (void) showPoiWithObjectId:(NSString *)objectId
{
    
    PointOfInterest *poi = [[Datalayer sharedInstance] pointOfInterestWithObjectId:objectId];
    CLLocationDirection distance = [self.arView.currentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:poi.coordinates.latitude longitude:poi.coordinates.longitude]];
    BOOL visited = [[Datalayer sharedInstance] hasVisitedPointOfInterestWithObjectId:objectId];
    if (DISABLE_LOCK ||visited || poi.clickRange == 0 || poi.clickRange > (NSInteger)distance)
    {
        [[Datalayer sharedInstance] registerVisitOfPointOfInterestWithObjectId:poi.objectId];
        
        // Send out notification for active app use...
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"Tell about this poi: %@", poi.title);
            [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerPointOfInterestClickedManually object:nil userInfo:@{@"pointOfInterest" : poi.objectId}];
        });
        if (self.delegate)
        {
            [self.delegate viewController:self requestsShowing:ViewControllerItemInfo withUserInfo:@{@"poiId" : objectId}];
        }
        
    }
    else
    {
        NSString * content = NSLocalizedString(@"Besøg stedet, for at åbne for denne historie.", @"Text for alert view telling that the user must be closer to this poi to see info");
        [self.alertViewController presentInParentViewController:self withTitle:poi.title andText:content];
    }
    
}

- (void) pointBar:(PointBar *)pointBar registeredPointLevel:(RoutePointPercentageBlock)level forRouteWithObjectId:(NSString *)objectId
{
    //NSLog(@"YO YO YO: %@", objectId);
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

- (PointBar *) pointBar
{
    if (!_pointBar)
    {
        _pointBar = [[PointBar alloc] init];
        _pointBar.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _pointBar;
}

- (void) prepareStop
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.pointBar.delegate = nil;
    [self.arView stop];
    [self.arView removeFromSuperview];
    self.arView = nil;
    [self.preview removeFromSuperview];
}

@end
