//
//  ParseApi.h
//  Historiejagten Fyn
//
//  Created by Gert Lavsen on 13/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Language.h"
#import "Info.h"
#import "Route.h"
#import "PointOfInterest.h"
#import "Avatar.h"

@interface ParseApi : NSObject

- (id) init;

/*!
 *  get languages
 */
- (void) getLanguagesWithCompletionBlock:(void (^) (NSArray *languages,NSError *error)) completionBlock;

/*!
 *  update language from a list of existing object ids
 *
 *  @param existingObject existing object ids
 */
- (void) updateLanguages:(NSArray *)existingObject withCompletionBlock:(void (^) (NSArray *, NSError *error)) completionBlock;

/*!
 *  get info on given language or the next highest prioritied
 *
 *  @param language language to get info on
 */
- (void) getInfoForLanguage:(Language *)language withCompletionBlock:(void (^) (Info *info, NSError *error)) completionBlock;

/*!
 *  Update existing routes from a list of object ids
 *
 *  @param existingObjects list of existing routes
 *  @param language        language to get content in
 */
- (void) updateRoutes:(NSDictionary *)existingObjects forLanguage:(Language *)language withCompletionBlock:(void (^) (NSArray *updated, NSArray*deleted, NSError *error)) completionBlock;

/*!
 *  Updatee Points of interests from list of existing object ids
 *
 *  @param existingObjects list of existing routes
 *  @param language        language to get content in
 */
- (void) updatePointOfInterests:(NSDictionary *)existingObjects forLanguage:(Language *)language withCompletionBlock:(void (^) (NSArray *updated, NSArray*deleted, NSError *error)) completionBlock;

/*!
 *  Updates point of interests connections
 */
- (void) updatePointOfInterestConnectionsWithCompletionBlock:(void (^) (NSArray *connections, NSError *error)) completionBlock;

/*!
 *  gets point systems in given language
 *
 *  @param language language to prefer content in
 */
- (void) getRoutePointsForLanguage:(Language *)language withCompletionBlock:(void (^) (NSArray *routePoints, NSError *error)) completionBlock;

/*!
 *  Register parse models
 */
+ (void) registerParseModels;

/*!
 * Update POIs with objectid
 * @param objectId - object id for poi to update
 * @param completionBlock block to execute on response
 */
- (void) updatePointOfInterestWithObjectId:(NSString *)objectId withCompletionBlock:(void (^) (PointOfInterest *poi, NSError *error)) completionBlock;

/*!
 * Get updatable pois
 * @param existingObjects object id of already known pois
 * @param completionBlock block to execute on response
 */
- (void) getUpdatablePointOfInterestFromExisting:(NSDictionary *)existingObjects withCompletionBlock:(void (^)(NSArray *updatable, NSArray*deleted, NSError *error)) completionBlock;

/*!
 * Get quizzes
 * @param existingObjects existing objectids
 * @param completionBlock block to execute on response
 */
- (void) updateQuizzes:(NSDictionary *)existingObjects withCompletionBlock:(void (^) (NSArray *updated, NSArray*deleted, NSError *error)) completionBlock;

/*!
 * Update route
 * @param objectId id of route to update
 * @param completionBlock block to execute on response
 */
- (void) updateRouteWithObjectId:(NSString *)objectId withCompletionBlock:(void (^) (Route *route, NSError *error)) completionBlock;

/*!
 * Update route
 * @param existingObjects existing objectids
 * @param completionBlock block to execute on response
 */
- (void) getUpdatableRouteFromExisting:(NSDictionary *)existingObjects withCompletionBlock:(void (^)(NSArray *updatable, NSArray*deleted, NSError *error)) completionBlock;

/*!
 * Update avatars
 * @param existingObjects existing objectids
 * @param completionBlock block to execute on response
 */
- (void) updateAvatarsFromExisting:(NSDictionary *)existingObjects withCompletionBlock:(void (^)(NSArray *updated, NSError *error)) completionBlock;


@end
