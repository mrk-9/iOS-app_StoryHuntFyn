//
//  GeofencingManager.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 27/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "GeofencingManager.h"
#import "LocationManager.h"
#import "Datalayer.h"
#import "PointOfInterest.h"
#import "datalayernotificationsstrings.h"
#import "SoundHelper.h"
#import  <uidevice-segmentation-ios/UIDevice+Segmentation.h>
@interface GeofencingManager() <LocationManagerDelegate>
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *lastManualCheckLocation;
@property (atomic, assign) BOOL hasSorted;
@property (atomic, assign) BOOL isSorting;
@property (atomic, assign) BOOL regionsIsRequested;
//!
@property (atomic, assign) BOOL coolDownOfPreviousInProgress;
@end

@implementation GeofencingManager

+ (instancetype) sharedInstance
{
    static GeofencingManager *sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        // set the default state as unsorted
        self.hasSorted = NO;
        // By settting this to YES the first time a location update is received the location manager will be updated with the regions to monitor
        self.regionsIsRequested = YES;
        // Make sure we are allowed to sort the first time
        self.isSorting = NO;
        
        // No previous geofence regions found - so we can show a notification right away
        self.coolDownOfPreviousInProgress = NO;
        // Set our self as delegate for the location manager
        [[LocationManager sharedInstance] addLocationManagerDelegate:self];
    }
    return self;
}

/**!
 * Sort Pois according to distance to last known user location
 */
- (void) sortPois
{
    // Check if location is known - early return
    if (!self.currentLocation)
    {
        return;
    }
    
    
    // Check if sorting is in progress - if so, return otherwise setup guard
    if (self.isSorting)
    {
        return;
    }
    self.isSorting = YES;
    CLLocation *location = self.currentLocation;
    // Dispatch a async progress sorting
    dispatch_queue_t queue = dispatch_get_global_queue(IS_IPAD ? DISPATCH_QUEUE_PRIORITY_LOW : DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    
    dispatch_async(queue, ^{

        NSMutableArray *arr = [[NSMutableArray alloc] init];
        // Iterate the pois and update it with information
        NSMutableArray *pois = [[Datalayer sharedInstance] pointOfInterests];
        for (PointOfInterest *poi in pois)
        {

            // Distance update - the current distance to this point
            CLLocationCoordinate2D coord = poi.coordinates;
            CLLocation *anotLocation = [[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
            NSInteger distanceToLocation = [location distanceFromLocation:anotLocation];
            
            // If closer than the auto - range set distance to distance...
            if (distanceToLocation < poi.autoRange)
            {
                poi.lastKnownDistanceToUser = distanceToLocation;
            }
            else
            {
                // Otherwise set it to the fence of the object
                poi.lastKnownDistanceToUser = [location distanceFromLocation:anotLocation] - poi.autoRange;
            }
        
            // Unlock update
            if (poi.unlockPOI && !poi.unlocked)
            {
                poi.unlocked = [[Datalayer sharedInstance] hasVisitedPointOfInterestWithObjectId:poi.unlockPOI];
            }
            else
            {
                poi.unlocked = YES;
            }
            
            [arr addObject:poi];
        }
        // Sort the pois to get the closest
        pois = [[NSMutableArray alloc] initWithArray:[arr sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                     {
                         PointOfInterest *aP = (PointOfInterest *) a;
                         PointOfInterest *bP = (PointOfInterest *) b;
                         BOOL aUnlocked = [aP unlocked];
                         BOOL bUnlocked = [bP unlocked];
                         // Both are unlocked or not unlockable - sort by distance
                         if (aUnlocked && bUnlocked)
                         {
                            NSNumber *first = [NSNumber numberWithDouble:[aP lastKnownDistanceToUser]];
                             NSNumber *second = [NSNumber numberWithDouble:[bP lastKnownDistanceToUser]];
                             return [first compare:second];
                         }
                         // A is unlocked or not unlockable - this is smaller than b which is locked
                         if (aUnlocked)
                         {
                             return NSOrderedAscending;
                         }
                         // A was locked so b is returned.
                         return NSOrderedDescending;
                     }]];
        // Update datalayer with sorted point of interests
        [[Datalayer sharedInstance] setPointOfInterests:pois];
        // If needed - update the location manager with regions
        // Also check manually
        // Take the first 19 (or count if count below 19)
        NSInteger count = MIN(19, pois.count);
        NSArray *first = [[pois valueForKeyPath:@"geoRegion"] subarrayWithRange:NSMakeRange(0, count)];
        [self checkClosest:first];
        
        if (self.regionsIsRequested)
        {
            
            NSInteger coveringRadius = 200;
            [[LocationManager sharedInstance] updateGeoRegionsToMonitor:first forLocation:location coveringRadius:MIN([[LocationManager sharedInstance] maxRadius], coveringRadius)];
            self.regionsIsRequested = NO;
        }
        // Clear guard
        self.hasSorted = YES;
        self.isSorting = NO;
    });
}


#define DEBUG_COOLDOWN_DISABLED NO
#ifndef DEBUG
#define DEBUG_COOLDOWN_DISABLED NO
#endif
- (void) handleEnteredRegion:(CLRegion *) region
{
    //NSLog(@"Did find location: %@", region.identifier);
    
    if (self.coolDownOfPreviousInProgress)
    {
        //NSLog(@"Waits 5 seconds more and tries again");
        [self performSelector:@selector(handleEnteredRegion:) withObject:region afterDelay:5];
        return;
    }
    self.coolDownOfPreviousInProgress = YES;

    // Find poi for the region
    PointOfInterest *poi = [[Datalayer sharedInstance] pointOfInterestWithObjectId:region.identifier];

    // Add to point system if member of one
    NSString *rpId = [[Datalayer sharedInstance] pointOfInterestBelongsToPointSystem:poi.objectId];
    if (rpId)
    {
        NSMutableSet *foundPois = [NSMutableSet setWithArray:[[NSUserDefaults standardUserDefaults] arrayForKey:rpId]];
        [foundPois addObject:poi.objectId];
        [[NSUserDefaults standardUserDefaults] setObject:[foundPois allObjects] forKey:rpId];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    


    
    // Check cool down for this poi
    BOOL cooledDown = YES;
    NSString *key = [NSString stringWithFormat:@"notifications.poi.%@", poi.objectId];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key])
    {
        NSDate *lastReported = [[NSUserDefaults standardUserDefaults] valueForKey:key];
        cooledDown = ((int)([lastReported timeIntervalSinceNow]) < -300); // 5 minutes
        //NSLog(@"Visited %@ before: %@ - cooldown time for now: %d", poi.title, lastReported.description, (int)[lastReported timeIntervalSinceNow]);
    }
    if (DEBUG_COOLDOWN_DISABLED || cooledDown)
    {
        //NSLog(@"Cooled down");
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[Datalayer sharedInstance] registerVisitOfPointOfInterestWithObjectId:poi.objectId];
        
        // Send out notification for active app use...
        dispatch_async(dispatch_get_main_queue(), ^{
            //NSLog(@"Tell about this poi: %@", poi.title);
            [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerPointOfInterestFound object:nil userInfo:@{@"pointOfInterest" : poi.objectId}];
        });

        // If no push is send in the last 30 minutes. Also send push...
        BOOL globalCoolDown = YES;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"globalCoolDown"])
        {
            NSDate *lastReported = [[NSUserDefaults standardUserDefaults] valueForKey:@"globalCoolDown"];
            globalCoolDown = ((int)([lastReported timeIntervalSinceNow]) < -1800); // 30 minutes
            //NSLog(@"Global cool down %@ - cooldown time from now: %d", lastReported.description, (int)[lastReported timeIntervalSinceNow]);
        }
        if (DEBUG_COOLDOWN_DISABLED || globalCoolDown)
        {
            // Update time for last push alert
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"globalCoolDown"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Local notification for background alerting
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            NSTimeZone* timezone = [NSTimeZone defaultTimeZone];
            notification.timeZone = timezone;
            notification.fireDate = [NSDate date];
            notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"Du har fundet et punkt: %@", @"The message to send as local notification"), poi.title ];
            notification.alertAction = @"Show";
            notification.soundName = UILocalNotificationDefaultSoundName;
            
            NSDictionary* poiInfo = [NSDictionary dictionaryWithObjectsAndKeys: poi.objectId, @"pointOfInterest", nil];
            [notification setUserInfo:poiInfo];
            //NSLog(@"Local alert: %@", poi.title);
            [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        }
        // Prevent any new notification for the next 15 seconds
        //NSLog(@"Queue disabling of cooldown");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(disableCoolDown) withObject:nil afterDelay:15];
        });
    }
    else
    {
        [self disableCoolDown];
    }

}

- (void) disableCoolDown
{
    //NSLog(@"disables cooldown");
    self.coolDownOfPreviousInProgress = NO;
}

- (void) checkPois
{
    //self.regionsIsRequested = YES;
    [self sortPois];
    
}

- (void) checkClosest:(NSArray *) closest
{
    //NSLog(@"checking closest");
    for (CLCircularRegion *r in closest)
    {
        
        if ([r containsCoordinate:self.currentLocation.coordinate])
        {
            //NSLog(@"%@ Contains",r);
#ifdef DEBUG
           // [[SoundHelper sharedInstance] playGetPointSound];
#endif
            [self handleEnteredRegion:r];
        }
    }
}


- (void) locationManager:(LocationManager *)locationManager didEnterGeoRegion:(CLRegion *)region
{
#ifdef DEBUG
//    [[SoundHelper sharedInstance] playGetPointSound];
#endif
    [self handleEnteredRegion:region];
}

- (void) newRegionsIsNeededForLocationManager:(LocationManager *)locationManager
{
#ifdef DEBUG
//    [[SoundHelper sharedInstance] playPercentageCompleteSound];
#endif
    self.regionsIsRequested = YES;
    [self sortPois];
}

- (void) locationManager:(LocationManager *)locationManager didUpdateLocation:(CLLocation *)location
{
    self.currentLocation = location;
    if (self.regionsIsRequested)
    {
        [self sortPois];
    }
    
    if (!self.lastManualCheckLocation)
    {
        self.lastManualCheckLocation = location;
    }
    NSInteger minDistance = (IS_IPAD ? 10 : 5);
    CLLocationDirection distance = [location distanceFromLocation:self.lastManualCheckLocation];
    if ((NSInteger)distance > minDistance)
    {
   //     NSLog(@"distance greater than 5");
#ifdef DEBUG
 //       [[SoundHelper sharedInstance] vibrate];
#endif
        self.lastManualCheckLocation = location;
        [self checkPois];
    }
    
}

@end
