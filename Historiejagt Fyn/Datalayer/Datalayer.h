//
//  Datalayer.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 21/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "datalayernotificationsstrings.h"
#import "Info.h"
#import "Route.h"
#import "PointOfInterest.h"
#import "Language.h"
#import "Quiz.h"
#import "Moodstocks/Moodstocks.h"

// FlurrySDK events
#define kFlurryShowWelcomeViewEventName @"Velkomst vises"
#define kFlurryShowARViewEventName @"AR aabnet"
#define kFlurryUserTappedOnPOI @"Tryk paa point of interest"
#define kFlurryShowQuizViewEventName @"Quiz aabnet"
#define kFlurryShowRouteDetailViewEventName @"Rute vises"
#define kFlurryShowRoutesViewEventName @"Ruteoversigt vises"
#define kFlurryShowScanViewEventName @"Scanner aabnet"
#define kFlurryScannerFoundMatchOpenedDialog @"Scanner Match fundet - Viser Popup"

/*!
 *  Percentages blocks for route points.
 */
typedef NS_ENUM(NSUInteger, RoutePointPercentageBlock)
{
    kPercentage0 = 0,
    kPercentage25 = 25,
    kPercentage50 = 50,
    kPercentage75 = 75,
    kPercentage100 = 100
};



@interface Datalayer : NSObject

+ (instancetype) sharedInstance;
@property (nonatomic, strong) NSString *pointOfInterestNotificationObjectId;

@property (nonatomic, strong) MSScanner *scanner;

@property (nonatomic, strong) Language *language;
@property (nonatomic, strong) Info *info;
/**!
 * Updates the datalayer - downloads new data if possible and send notification kDatalayerUpdated when ready
 * Sends kDatalayerUpdateInProgress notification doing download and kDatalayeOfflineWithoutData if no connection and no offline data available
 */
- (void) updateDatalayer;

- (NSString *) bestLanguageCodeFromArrayOfCodes:(NSArray *) codes;

/**! 
 * Return the number of routes
 **/
@property (nonatomic, readonly) NSInteger numberOfRoutes;

/**!
 * Return a route at the given index 
 **/
- (Route *) routeAtIndex:(NSUInteger) index;


/**!
 * Return all pois
 **/
@property (nonatomic, strong) NSMutableArray *pointOfInterests;

/*!
 *  Tell if a given point of interest is visited before
 *
 *  @param objectId object id for point of interest
 *
 *  @return YES if visisted, otherwise NO
 */
- (BOOL) hasVisitedPointOfInterestWithObjectId:(NSString *)objectId;

/*!
 *  Register point of interest as visised
 *  @param objectId object id for point of interest visisted
 */
- (void) registerVisitOfPointOfInterestWithObjectId:(NSString *)objectId;

/*!
 * Looks up a point of interest based on its object id
 * @param objectId object id for point of interest to look up
 * @return point of interest with the given object id
 */
- (PointOfInterest *) pointOfInterestWithObjectId:(NSString *) objectId;

/*!
 * Return a route containing a point of interest with the given object id
 * @param objectId object id of the point of interest
 * @return route containg the point of interest
 */
- (Route *) routeContainingPointOfInterestWithObjectId:(NSString *)objectId;

/*! 
 * Return true if any identifiers in the given array is boolean true
 * @param identifiers identifers of booleans to lookup in the nsuserdefaults.
 * @return YES if any of the booleans was YES otherwise NO.
 */
- (BOOL) anyIdentifierOn:(NSArray *) identifiers;

/*!
 * Return the boolean value of a ns userdefault with the given identifer
 * @param identifier the identifer to look up
 * @return the boolean value of the identifer. No if not set
 */
- (BOOL) boolSettingWithIdentifier:(NSString *)identifier;

/*!
 * Return the boolean value of a ns userdefault with the given identifer and defaults to a given boolean value
 * @param identifier the identifer to look up
 * @param defaultValue the default value of the identifer if not set
 * @return the boolean value of the identifer. Return the given defaultvalue if not existing.
 */
- (BOOL) boolSettingWithIdentifier:(NSString *)identifier defaultValue:(BOOL) defaultValue;

/*!
 * sets a boolean value in nsuserdefaults for the given identifier
 * @param b boolean value to set
 * @param identifer identifier to set
 */
- (void) setBoolSetting:(BOOL) b forIdentifier:(NSString *)identifier;

/*!
 * Toggles the boolean value of the given identifier in nsuserdefaults. If not existing it is set to true
 * @param identifier the identifier key to toggle
 */
- (void) toggleBoolSettingWithIdentifier:(NSString *)identifier;

/* Return true if any routes is set as default route in settings */
@property (nonatomic, readonly) BOOL anyDefaultRoute;

/*!
 *  Return a quiz with the given poi object id
 *
 *  @param objectId object id for a poi holding the quiz
 *
 *  @return a quiz instance
 */
- (Quiz *) quizForPOIWithObjectId:(NSString *)objectId;

/*!
 *  Return an array of all routes
 *
 *  @return array of WKRoute objects
 */
- (NSArray *) allRoutes;

/*!
 *  Return parts for a route
 *
 *  @param objectId object id for the route
 *
 *  @return an array of WKPointOfInterestConnection objects
 */
- (NSArray *) drawableRoutePartsForRouteWithObjectId:(NSString *)objectId;

/*!
 *  return a coordinate set for a point of interest with the given object id
 *
 *  @param objectId object id for the point of interest
 *
 *  @return coordinate set
 */
- (CLLocationCoordinate2D) coordinateForPointOfInterestWithObjectId:(NSString *)objectId;

/*!
 @description get points of interests for a given route
 @param route route to get pois for
 @return array of PointOfInterest objects
 */
- (NSArray *) pointOfInterestsForRoute:(Route *)route;

/*!
 *  Return the percentage block for the point system belong to the given route
 *
 *  @param objectId object id for the route
 *
 *  @return return the block
 */
- (RoutePointPercentageBlock) percentageCompletedForRouteWithObjectId:(NSString *) objectId;

/*!
 *  Calculate the percentage completed for a given route
 *
 *  @param objectId object id of route
 *
 *  @return percentage of route completed (0.0-1.0)
 */
- (float) calculatePercentageCompletedForRouteWithObjectId:(NSString *)objectId;

/*!
 * Return objectid for routepointSystem if a point of interest belongs to a point system
 * @param objectId object id of point of interest to check
 * @return object of RoutePoint if contained in point system
 */
- (NSString *) pointOfInterestBelongsToPointSystem:(NSString *) objectId;


/*!
 *  get the percentage block (0-25-50-75-100%) corresponding to a given percentage
 *
 *  @param percentage percentage to get block from
 *
 *  @return a RoutePointPercentageBlock
 */
- (RoutePointPercentageBlock) percentageBlockForPercentage:(float) percentage;

/*!
 *  Return the text for a given routes point system
 *
 *  @param block    The percentage block to get the text for.
 *  @param objectId The route object id
 *
 *  @return String with the text to show
 */
- (NSString *) textForPercentageBlock:(RoutePointPercentageBlock) block completedForRouteWithObjectId:(NSString *) objectId;

/*!
 * Gets the route a route point object with a given objectid belongs to
 *
 * @param objectId Id of the route point object
 * @return The route it belongs to
 */
- (Route *) routeForRoutePointWithObjectId:(NSString *) objectId;

/*! 
 * Return a coordinate region covering Funen
 * @return coordinate region covering Funen
 */
- (MKCoordinateRegion) regionForFunen;

/*!
 * Return a coordinate region covering a route with a given id and if possible the current user location
 * @param routeId the object id for the route to cover
 * @return region covering user location if possible and the the route with the given id
 */
- (MKCoordinateRegion) regionForRouteWithObjectId:(NSString *)routeId;

/*!
 * Stores a polyline describing a pointOfInterestConnection, with a given identifier (the start POI objectId), on a route with the given objectId
 * @param polyline the polyline to store
 * @param identifier Identifier of the polyline. This is equal  to the source POI objectId.
 * @param objectId the objectId for the route to store it on.
 */
- (void) addPolyline:(MKPolyline *) polyline withIdentifier:(NSString *) identifier toRouteWithObjectId:(NSString *) objectId;

/*!
 * Return, if possible a polyline describing the the POIConnection with the given identifier for a route with the given objectId.
 * @param identifer The identifier of the polyline to retrieve
 * @param object Id for the route it belongs
 * @return the polyline if found or nil if not found
 */
- (MKPolyline *) polylineWithIdentifer:(NSString *) identifier forRouteWithObjectId:(NSString *) objectId;

@end
