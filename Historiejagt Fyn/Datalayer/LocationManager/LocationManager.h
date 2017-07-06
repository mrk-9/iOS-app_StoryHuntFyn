//
//  LocationManager.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 27/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@protocol LocationManagerDelegate;

@interface LocationManager : NSObject <CLLocationManagerDelegate>
+ (instancetype) sharedInstance;
- (void) addLocationManagerDelegate:(id<LocationManagerDelegate>) delegate;
- (void) removeLocationManagerDelegate:(id<LocationManagerDelegate>) delegate;
@property (nonatomic, readonly) NSInteger maxRadius;
@property (nonatomic, readonly) CLLocation *userLocation;
@property (nonatomic, readonly) CLCircularRegion *currentMetaRegion;

/**! Sets an array of CLGeoRegions to monitor
 * Due to a restriction of 20 concurrent monitored regions only the 19 first elements in the array is used.
 * The last free region is used as a meta region encapsulating all the others. That one is used to determinate when to ask for new regions.
 */
- (void) updateGeoRegionsToMonitor:(NSArray *) regions forLocation:(CLLocation *)location coveringRadius:(double) radius;
@end


@protocol LocationManagerDelegate <NSObject>
- (void) locationManager:(LocationManager *) locationManager didUpdateLocation:(CLLocation *)location;

@optional
- (void) locationManager:(LocationManager *) locationManager didEnterGeoRegion:(CLRegion *) region;
/**!
 * Called when the meta region encapsulating the monitored regions is left/exited
 **/
- (void) newRegionsIsNeededForLocationManager:(LocationManager *) locationManager;


@end
