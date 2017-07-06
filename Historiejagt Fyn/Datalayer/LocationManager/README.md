# Location Manager and Geofencing Manager
This document tries to describe the two classes handling updating the current location and geofencing
### Location Manager class - LocationManager
The Location Managers core function is to delegate the users current location to the listeners and to monitor an array of regions (in this context - the region describing a PointOfInterest object)

##### The class is implemented by the singleton pattern:
``` objective-c
[LocationManager sharedInstance];
```
##### The class has two main selectors that must be called by the delegates (classes implementing the LocationManagerDelegate methods):
``` objective-c
- (void) addLocationManagerDelegate:(id<LocationManagerDelegate>) delegate;
- (void) removeLocationManagerDelegate:(id<LocationManagerDelegate>) delegate;
```
##### The class has a method for updating the monitored regions.
``` objective-c
/**! Sets an array of CLGeoRegions to monitor for a location
* Due to a restriction of 20 concurrent monitored regions only the 19 first elements in the array is used.
* The last free region is used as a meta region encapsulating all the others. That one is used to determinate when to ask for new regions.
*/
- (void) updateGeoRegionsToMonitor:(NSArray *) regions forLocation:(CLLocation *)location;
```
#### Starting the location manager
* The manager starts monitoring the location the first time the singleton is called.
* The manager starts monitoring for geofence regions the first time the updateGeoRegionsToMonitor method is called.

### Geofence Manager class - GeofenceManager
The Geofence Manager has two purposes:
* To pick the PointOfInterests to monitor according to their distance to the current position
* To handle when a region covering a Point of interest is visited.

