//
//  LocationManager.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 27/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "LocationManager.h"

@interface LocationManager()
@property (strong, nonatomic) CLLocationManager* manager;
@property (strong, nonatomic) NSMutableArray *observers;
@property (strong, nonatomic) CLCircularRegion *metaRegion;
@property (strong, nonatomic) CLLocation *currentLocation;
@end

@implementation LocationManager
static int errorCount = 0;
// The nunber of times requesting the location can fail...
#define MAX_LOCATION_ERROR 10

#pragma mark singleton pattern used for this class
+ (instancetype) sharedInstance
{
    static LocationManager *sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - initializer
- (id) init
{
    self = [super init];
    if (self)
    {
        if ([self.manager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            [self.manager requestAlwaysAuthorization];
        }

    }
    //NSLog(@"self.locManager.maximumRegionMonitoringDistance: %f", self.manager.maximumRegionMonitoringDistance);

    return self;
}


#pragma mark - add remove delegate selectors
- (void) addLocationManagerDelegate:(id<LocationManagerDelegate>)delegate
{
    //NSLog(@"Tries to add %@ as delegate", delegate);
    if (![self.observers containsObject:delegate])
    {
        //NSLog(@"Not set as delegate - do it");
        [self.observers addObject:delegate];
    }
    [self.manager startUpdatingLocation];
}

- (void) removeLocationManagerDelegate:(id<LocationManagerDelegate>)delegate
{
    if ([self.observers containsObject:delegate])
    {
        [self.observers removeObject:delegate];
    }
}


#pragma mark - updater for the monitored regions
- (void) clearMonitoredRegions
{
    // stop monitoring for active regions
    for (CLRegion *r in [self.manager monitoredRegions])
    {
        [self.manager stopMonitoringForRegion:r];
    }
    [self.manager stopMonitoringSignificantLocationChanges];
}
- (void) updateGeoRegionsToMonitor:(NSArray *) regions forLocation:(CLLocation *)location coveringRadius:(double) radius;
{
    // Clear active regions
    [self clearMonitoredRegions];
    // Create a meta region covering all of the regions to be monitored
    self.metaRegion = [[CLCircularRegion alloc] initWithCenter:location.coordinate radius:radius identifier:@"metaRegion"];
    [self.manager startMonitoringForRegion:self.metaRegion];
    for (CLCircularRegion *r in regions)
    {
        //NSLog(@"Starts monitoring %@", r);
        [self.manager startMonitoringForRegion:r];
    }
    [self.manager startMonitoringSignificantLocationChanges];
}

#pragma mark - public properties
- (NSInteger) maxRadius
{
    return self.manager.maximumRegionMonitoringDistance;
}

- (CLCircularRegion *) currentMetaRegion
{
    return self.metaRegion;
}


#pragma mark - private properties

- (CLLocation *) userLocation
{
    return self.currentLocation;
}

- (CLLocationManager *) manager
{
    if (!_manager)
    {
        _manager = [[CLLocationManager alloc] init];
        _manager.delegate = self;
        _manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _manager.distanceFilter = 1;//kCLDistanceFilterNone;
    }
    return _manager;
}

- (NSMutableArray *) observers
{
    if (!_observers)
    {
        _observers = [[NSMutableArray alloc] init];
    }
    return _observers;
}

#pragma mark - Location Manager Delegate


-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
   // NSLog(@"Started monitoring for region: %@ - %f", [region description], region.radius);
    [manager requestStateForRegion:region]; // check if already inside region
}

-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Failed to start monitoring for region: %@ with error %@", [region description], [error localizedDescription]);
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    [self locationManager:manager didEnterRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    //if (!self.currentLocation || [[locations lastObject] distanceFromLocation:self.currentLocation] > 1.0)
    {
        for(id<LocationManagerDelegate> observer in self.observers)
        {
            if (observer)
            {
                [observer locationManager:self didUpdateLocation:[locations lastObject]];
            }
        }
        self.currentLocation = [locations lastObject];
    }
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    errorCount += 1;
    if(errorCount >= MAX_LOCATION_ERROR)
    {
        [self.manager stopUpdatingLocation];
        errorCount = 0;
    }
}

- (void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    
    //NSLog(@"Did exit reguin: %@", region.identifier);
    // We exited a region -
    // Check if it is equal to our covering meta region.
    if ([region.identifier isEqualToString:@"metaRegion"])
    {
        // We need new regions
        // Clear monitored regions and request new regions
        self.metaRegion = nil;
        for(id<LocationManagerDelegate> observer in self.observers)
        {
            if (observer && [observer respondsToSelector:@selector(newRegionsIsNeededForLocationManager:)])
            {
               // NSLog(@"Tell observer: %@", observer);
                [observer newRegionsIsNeededForLocationManager:self];
            }

        }
    }
    else
    {
        // A normal region - stop monitoring it
        [self.manager stopMonitoringForRegion:region];
    }
}

- (void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //NSLog(@"Did enter region: %@", region);
    if ([region.identifier isEqualToString:@"metaRegion"])
    {
        // Our meta region - we dont care....
        return;
    }
    // It's not the meta region so we need to be completely sure that we are inside the triggering range...
    
    if ([(CLCircularRegion *)region containsCoordinate:self.currentLocation.coordinate])
    {
        for(id<LocationManagerDelegate> observer in self.observers)
        {
            if (observer && [observer respondsToSelector:@selector(locationManager:didEnterGeoRegion:)])
            {
                [observer locationManager:self didEnterGeoRegion:region];
            }
            
        }

    }
}


- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    //Must check authorizationStatus before initiating a CLLocationManager
    if (status == kCLAuthorizationStatusRestricted && status == kCLAuthorizationStatusDenied)
    {
        NSLog(@"Location manger request failed");
        //! TODO: send message so we can tell the user to enable location updates
    }
    else
    {
        //NSLog(@"Location manager request ok");
        [self.manager startUpdatingLocation];
    }
    if (status == kCLAuthorizationStatusNotDetermined)
    {
        NSLog(@"Location manager request not determined");
        //Must check if selector exists before messaging it
        if ([self.manager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
            NSLog(@"Request always authorization");
            [self.manager requestAlwaysAuthorization];
            
        }
    }
//    NSLog(@"authorizationStatus: %@", CLLocationManager.authorizationStatus ? @"Y" : @"N");
//    NSLog(@"locationServicesEnabled: %@", CLLocationManager.locationServicesEnabled ? @"Y" : @"N");
//    NSLog(@"deferredLocationUpdatesAvailable: %@", CLLocationManager.deferredLocationUpdatesAvailable ? @"Y" : @"N");
//    NSLog(@"significantLocationChangeMonitoringAvailable: %@", CLLocationManager.significantLocationChangeMonitoringAvailable ? @"Y" : @"N");
//    NSLog(@"headingAvailable: %@", CLLocationManager.headingAvailable ? @"Y" : @"N");
//    NSLog(@"isRangingAvailable: %@", CLLocationManager.isRangingAvailable ? @"Y" : @"N");
}








@end
