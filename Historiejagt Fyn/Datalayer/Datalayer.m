//
//  Datalayer.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 21/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "Datalayer.h"
#import "databasekeys.h"
#import "datalayernotificationsstrings.h"
#import "ParseApi.h"
#import <YapDatabase/YapDatabase.h>
#import <YapDatabase/YapDatabaseView.h>
#import <DateTools/DateTools.h>
#include<unistd.h>
#include<netdb.h>
#include "LocationManager.h"
#import "Route.h"
#import "PointOfInterest.h"
#import "PointOfInterestConnection.h"
#import "Avatar.h"
#import "Info.h"
#import "Language.h"
#import "RoutePoint.h"
#import "Quiz.h"
#import "GeofencingManager.h"
#import "MKPolyline+MKPolyline_NSCoding.h"

#define MS_API_KEY    @"fdn5rcbfzsinrj0lgnpb"
#define MS_API_SECRET @"4Hx9cwttr98hUAJm"

#pragma - mark internal notification names
#define kDatalayerInternalFailedUpdating @"historiejagt.fyn.datalayer.internal.update.failed"
#define kDatalayerInternalFailedSingleUpdating @"historiejagt.fyn.datalayer.internal.update.failed.single"
#define kDatalayerInternalLanguageUpdated @"historiejagt.fyn.datalayer.internal.language.updated"
#define kDatalayerInternalInfoUpdated @"historiejagt.fyn.datalayer.internal.info.updated"
#define kDatalayerInternalRoutesUpdated @"historiejagt.fyn.datalayer.internal.routes.updated"
#define kDatalayerInternalPOIsUpdated @"historiejagt.fyn.datalayer.internal.pois.updated"
#define kDatalayerInternalAvatarsUpdated @"historiejagt.fyn.datalayer.internal.avatars.updated"
#define kDatalayerInternalPOIConnectionsUpdated @"historiejagt.fyn.datalayer.internal.poi.connections..updated"
#define kDatalayerInternalRoutePointSystemUpdated @"historiejagt.fyn.datalayer.internal.routepoints.updated"
#define kDatalayerInternalQuizzesUpdated @"historiejagt.fyn.datalayer.internal.quizzes.updated"

@interface Datalayer()

#pragma mark Database stuff
@property (nonatomic, strong) YapDatabase *database;
@property (nonatomic, strong) YapDatabaseConnection *writeConnection;
@property (nonatomic, strong) YapDatabaseConnection *readConnection;
@property (nonatomic, strong) YapDatabaseView *routesView;

#pragma mark parse api
@property (nonatomic, strong) ParseApi *parseApi;
#pragma mark info
@property (nonatomic, strong) NSString *infoKey;

@end

@implementation Datalayer

#pragma mark - main thread notification
- (void) notifiyMainThreadWithNotificationNamed:(NSString *) name userInfo:userInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:userInfo];
    });
}
#pragma mark - singleton
+ (instancetype)sharedInstance
{
    static Datalayer *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[Datalayer alloc] init];
                  });
    return sharedInstance;
}
#pragma mark - initialization
- (id) init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(datalayerUpdated)
                                                     name:kDatalayerReady object:nil];

        [self startScanner];
    }
    return self;
}
#pragma mark notfication update chain
- (void) setupUpdateNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateError:) name:kDatalayerInternalFailedUpdating object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateError:) name:kDatalayerInternalFailedSingleUpdating object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo) name:kDatalayerInternalLanguageUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRoutes) name:kDatalayerInternalInfoUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePointOfInterests) name:kDatalayerInternalRoutesUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAvatars:) name:kDatalayerInternalPOIsUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePOIConnections) name:kDatalayerInternalAvatarsUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRoutePointSystem) name:kDatalayerInternalPOIConnectionsUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQuizzes) name:kDatalayerInternalRoutePointSystemUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFinished) name:kDatalayerInternalQuizzesUpdated object:nil];
}
- (void) datalayerUpdated
{
    // Activate Geofenching
    [self.readConnection beginLongLivedReadTransaction];
    [GeofencingManager sharedInstance];
}
- (void) updateError:(NSNotification *) note
{
    NSError *error = [note object];
    NSLog(@"Error: %@", error);
    [self notifiyMainThreadWithNotificationNamed:kDatalayerErrorOccured userInfo:@{@"error" : error}];
}
- (void) updateDatalayer
{
    BOOL hasData = [self setupDatabase];
    BOOL update = NO;
    BOOL networkAvailable = [self networkAvailable];

    if (!hasData)
    {
        NSLog(@"No data");
        // Case one
        // we preloaded data - we need to update it if possible.
        if (!networkAvailable)
        {
            NSLog(@"No data - offline");
            // We are offline - inform gui that no data is present and we need net to load it.
            [self notifiyMainThreadWithNotificationNamed:kDatalayeOfflineWithoutData userInfo:nil];
            return;
        }
        update = YES;
    }
    else
    {
        NSLog(@"checks last update time:");
         //Case two
         //The database existed - so we check the time since last update
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"lastUpdated"])
        {
            // The database has been update before - check if more than 12 hours ago
            NSDate *lastReported = [[NSUserDefaults standardUserDefaults] valueForKey:@"lastUpdated"];
            update = ([[lastReported dateByAddingHours:12] isEarlierThan:[NSDate date]]);
            NSLog(@"%@ %@", lastReported, update ? @"Y" : @"N");
        }
        else
        {
            NSLog(@"Not updated before");
            // Never updated - do it.
            update  =YES;
        }
    }
    if (update)
    {
        if (!networkAvailable)
        {
            // Update of existing data wanted but no net - inform user and return
            [self.readConnection beginLongLivedReadTransaction];
            [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
             {
//                 [self.databaseMapping updateWithTransaction:transaction];
             }];
            [self notifiyMainThreadWithNotificationNamed:kDatalayeOfflineWithData userInfo:nil];
            
        }
        else
        {
            // Update needed and net present.
            [self updating];
        }
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastUpdated"];
        [[NSUserDefaults standardUserDefaults] synchronize];
       }
    else
    {
        // No need for updating - tell the gui to continue loading
        [self.readConnection beginLongLivedReadTransaction];
        [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
         {
//             [self.databaseMapping updateWithTransaction:transaction];
         }];
        [self notifiyMainThreadWithNotificationNamed:kDatalayerReady userInfo:nil];
        [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
         {
            ////NSLog(@"routePointSystem: %@", routePointSystem);
         }];
    }
}
- (void) updateFinished
{
    NSLog(@"HERE");
    [self notifiyMainThreadWithNotificationNamed:kDatalayerReady userInfo:nil];
    [self.writeConnection vacuum];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDatabaseFile];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
#pragma mark - update selectors
- (void) updating
{
    // Inform gui that updating has started
    [self setupUpdateNotifications];
    [self notifiyMainThreadWithNotificationNamed:kDatalayerUpdateStarted userInfo:nil];
    [self updateLanguages];
    //[self notifiyMainThreadWithNotificationNamed:kDatalayerReady userInfo:nil];
}
- (void) updateLanguages
{
    [self notifiyMainThreadWithNotificationNamed:kDatalayerUpdateInProgress  userInfo:@{kDatalayerUpdateProgressTitleKey: @"Opdaterer indstillinger", kDatalayerUpdateProgressTotalKey: @2, kDatalayerUpdateProgressAmountKey:@1}];
    [self.parseApi getLanguagesWithCompletionBlock:^(NSArray *languages, NSError *error)
    {
        if (!error)
        {
            [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction)
            {
                [transaction removeAllObjectsInCollection:kLanguagesCollection];
                self.language = (Language *)[languages firstObject];
                
                for (Language *lang in languages)
                {
                    if ([[lang.code uppercaseString] isEqualToString:[self languageCode]])
                    {
                        self.language = lang;
                    }
                    [transaction setObject:lang forKey:lang.objectId inCollection:kLanguagesCollection];
                }
                [[NSUserDefaults standardUserDefaults] setValue:self.language.objectId forKey:@"languageCode"];
                [[NSUserDefaults standardUserDefaults] synchronize];

            } completionBlock:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalLanguageUpdated object:nil];
            }];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalFailedUpdating object:error];
        }
    }];
}
- (void) updateInfo
{
    [self notifiyMainThreadWithNotificationNamed:kDatalayerUpdateInProgress userInfo:@{kDatalayerUpdateProgressTitleKey: @"Opdaterer indstillinger", kDatalayerUpdateProgressTotalKey: @2, kDatalayerUpdateProgressAmountKey:@2}];
    [self.parseApi getInfoForLanguage:self.language withCompletionBlock:^(Info *info, NSError *error)
     {
         if (!error)
         {
             [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction)
             {
                 [transaction setObject:info forKey:info.objectId inCollection:kInfoCollection];
                 self.info = info;
                 self.infoKey = info.objectId;
                 [[NSUserDefaults standardUserDefaults] setValue:self.info.objectId forKey:@"infoKey"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
             } completionBlock:^{
                 [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalInfoUpdated object:nil];
             }];
         }
         else
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalFailedUpdating object:error];
         }
     }];
}
- (void) updateRoutes
{
    [self.readConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        
        NSArray *keys = [transaction allKeysInCollection:kRoutesCollection];
        NSMutableDictionary *existing = [[NSMutableDictionary alloc]init];
        for (NSString *key in keys)
        {
            Route * route = [transaction objectForKey:key inCollection:kRoutesCollection];
            [existing setObject:route.updatedAt forKey:key];
        }
        
        [self.parseApi getUpdatableRouteFromExisting:existing withCompletionBlock:^(NSArray *updatable, NSArray *deleted, NSError *error)
        {
            if (error)
            {
                //NSLog(@"Error updating routes %@", error);
                [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalFailedUpdating object:error];
                return;
            }
            __block NSInteger countDown = [updatable count];
            __block long total = countDown;
            if (countDown == 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalRoutesUpdated object:nil];
                return;
            }
            for (NSString *objectId in updatable)
            {
                [self.parseApi updateRouteWithObjectId:objectId withCompletionBlock:^(Route *route, NSError *error)
                 {
                     
                     countDown--;
                     [self notifiyMainThreadWithNotificationNamed:kDatalayerUpdateInProgress
                                                                       userInfo:@{kDatalayerUpdateProgressTitleKey: @"Opdaterer ruter", kDatalayerUpdateProgressTotalKey: [NSNumber numberWithInteger:total], kDatalayerUpdateProgressAmountKey:[NSNumber numberWithInteger:total-countDown]}];
                     if (!error)
                     {
                         [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction)
                          {
                              [transaction setObject:route forKey:route.objectId inCollection:kRoutesCollection];
                          }];
                     }
                     else
                     {
                         [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalFailedSingleUpdating object:error];
                     }
                     if (countDown == 0)
                     {
                         [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction)
                          {
                              [transaction removeObjectsForKeys:deleted inCollection:kRoutesCollection];
                              [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalRoutesUpdated object:nil];
                          }];
                     }
                 }];
            }

        }];
    }];
}
- (void) updatePointOfInterests
{
    [self.readConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSArray *keys = [transaction allKeysInCollection:kPointOfInterestsCollection];
        NSMutableDictionary *existing = [[NSMutableDictionary alloc]init];
        for (NSString *key in keys)
        {
            PointOfInterest * poi = [transaction objectForKey:key inCollection:kPointOfInterestsCollection];
            [existing setObject:poi.updatedAt forKey:key];
        }
        NSLog(@"Existing POIs: %@", existing);
        [self.parseApi getUpdatablePointOfInterestFromExisting:existing withCompletionBlock:^(NSArray *updatable, NSArray *deleted, NSError *error)
         {
             if (error)
             {
                 NSLog(@"Error updating pointofinterests %@", error);
                 [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalFailedUpdating object:error];
                 return;
             }
             
             __block NSInteger countDown = [updatable count];
             __block long total = countDown;
             if (countDown == 0)
             {
                 [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalPOIsUpdated object:nil];
                 return;
             }
             
             for (NSString *objectId in updatable)
             {
                 [self.parseApi updatePointOfInterestWithObjectId:objectId withCompletionBlock:^(PointOfInterest *poi, NSError *error)
                  {
                      NSLog(@"mangler %ld", (long)countDown);
                      countDown--;
                      [self notifiyMainThreadWithNotificationNamed:kDatalayerUpdateInProgress
                                                                        userInfo:@{kDatalayerUpdateProgressTitleKey: @"Opdaterer lokationer", kDatalayerUpdateProgressTotalKey: [NSNumber numberWithInteger:total], kDatalayerUpdateProgressAmountKey:[NSNumber numberWithInteger:total-countDown]}];
                      if (!error)
                      {
                          [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction)
                           {
                               NSLog(@"Saving Poi: %@ %@", poi.title, poi.objectId);
                               [transaction setObject:poi forKey:poi.objectId inCollection:kPointOfInterestsCollection];
                           }];
                      }
                      else
                      {
                          [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalFailedSingleUpdating object:error];
                      }
                      if (countDown == 0)
                      {
                          [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction)
                           {
                               [transaction removeObjectsForKeys:deleted inCollection:kPointOfInterestsCollection];
                           
                               [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalPOIsUpdated object:nil];
                           }];
                      }
                      
                  }];
                 
             }
         }];
        
    }];
}

- (void) updateAvatars:(void (^) (NSError *error)) completionBlock
{
    [self notifiyMainThreadWithNotificationNamed:kDatalayerUpdateInProgress userInfo:@{kDatalayerUpdateProgressTitleKey:@"Opdaterer grafik", kDatalayerUpdateProgressTotalKey: @1, kDatalayerUpdateProgressAmountKey:@1}];
    [self.readConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSArray *keys = [transaction allKeysInCollection:kAvatarCollection];
        
        NSMutableDictionary *existing = [[NSMutableDictionary alloc]init];
        for (NSString *key in keys)
        {
            Avatar *avatar = [transaction objectForKey:key inCollection:kAvatarCollection];
            [existing setObject:avatar.updatedAt forKey:key];
        }
        [self.parseApi updateAvatarsFromExisting:existing withCompletionBlock:^(NSArray *updated, NSError *error)
        {
            if (error)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalFailedUpdating object:error];
            }
            [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                for (Avatar *avatar in updated)
                {
                    [transaction setObject:avatar forKey:avatar.objectId inCollection:kAvatarCollection];
                }
            } completionBlock:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalAvatarsUpdated object:nil];

            }];
        }];
    }];
}
- (void) updatePOIConnections
{
    [self notifiyMainThreadWithNotificationNamed:kDatalayerUpdateInProgress userInfo:@{kDatalayerUpdateProgressTitleKey: @"Opdaterer forbindelser", kDatalayerUpdateProgressTotalKey: @1, kDatalayerUpdateProgressAmountKey:@1}];
    [self.parseApi updatePointOfInterestConnectionsWithCompletionBlock:^(NSArray *connections, NSError *error) {
        if (error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalFailedUpdating object:error];
            return;
        }
        [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [transaction removeAllObjectsInCollection:kPointOfInterestConnectionsCollection];
            for (PointOfInterestConnection *pc in connections)
            {
                [transaction setObject:pc forKey:pc.sourceId inCollection:kPointOfInterestConnectionsCollection];
            }
        } completionBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalPOIConnectionsUpdated object:nil];
        }];
    }];
}
- (void) updateRoutePointSystem
{
    [self notifiyMainThreadWithNotificationNamed:kDatalayerUpdateInProgress userInfo:@{kDatalayerUpdateProgressTitleKey: @"Opdaterer point", kDatalayerUpdateProgressTotalKey: @1, kDatalayerUpdateProgressAmountKey:@1}];
    [self.parseApi getRoutePointsForLanguage:self.language withCompletionBlock:^(NSArray *routePoints, NSError *error) {
        if (error)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalFailedUpdating object:error];
            return;
        }
        [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
            [transaction removeAllObjectsInCollection:kRoutePointCollection];
            for (RoutePoint *rp in routePoints)
            {
                //NSLog(@"RoutePoint: %@", rp.objectId);
                [transaction setObject:rp forKey:rp.objectId inCollection:kRoutePointCollection withMetadata:rp.routeId];
            }
        } completionBlock:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalRoutePointSystemUpdated object:nil];
        }];
    }];
}
- (void) updateQuizzes
{
    [self.readConnection asyncReadWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSArray *keys = [transaction allKeysInCollection:kQuizCollection];
        NSMutableDictionary *existing = [[NSMutableDictionary alloc]init];
        for (NSString *key in keys)
        {
            Quiz *quiz = [transaction objectForKey:key inCollection:kQuizCollection];
            [existing setObject:quiz.updatedAt forKey:key];
        }
        [self.parseApi updateQuizzes:existing withCompletionBlock:^(NSArray *updated, NSArray *deleted, NSError *error) {
            if (error)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalFailedUpdating object:error];
                return;
            }
            [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
                for (Quiz *quiz in updated)
                {
                    [transaction setObject:quiz forKey:quiz.objectId inCollection:kQuizCollection];
                }

                [transaction removeObjectsForKeys:deleted inCollection:kQuizCollection];
                
            } completionBlock:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerInternalQuizzesUpdated object:nil];
            }];
        }];
     }];
}
#pragma mark - private helpers
- (NSString *) languageCode
{
    return [[[NSLocale preferredLanguages] objectAtIndex:0] uppercaseString];
}

- (BOOL) networkAvailable
{
    char *hostname;
    struct hostent *hostinfo;
    hostname = "parse.com";
    hostinfo = gethostbyname (hostname);
    if (hostinfo == NULL)
    {
        NSLog(@"-> no connection!\n");
        return NO;
    }
    else
    {
        NSLog(@"-> connection established!\n");
        return YES;
    }
}
- (NSString *)filePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:kDatabaseFile];
}
#define kFORCE_GENERATE_DB NO
- (BOOL) setupDatabase
{
    // Comment out the following line to enable preloading of database.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSString *filePath = [self filePath];
    BOOL returnValue = YES;
    NSLog(@"Filepath = %@", filePath);
    if (kFORCE_GENERATE_DB)
    {
        returnValue = NO;
    }
    else
    {
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kDatabaseFile])
        {
            NSLog(@"Not existing");
            NSString *resourcePath = [[NSBundle mainBundle] pathForResource:kDatabaseFileName ofType:kDatabaseFileExt];
            if ([fileManager fileExistsAtPath:resourcePath])
            {
                ////NSLog(@"Has one");
                [fileManager removeItemAtPath:filePath error:&error];
                [fileManager copyItemAtPath:resourcePath toPath:filePath error:&error];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDatabaseFile];
                [[NSUserDefaults standardUserDefaults] synchronize];
                self.readConnection = nil;
                self.writeConnection = nil;
                self.database = nil;
                //[self.database registerExtension:self.routesView withName:kRoutesView];
                
                return NO;
            }
            else
            {
                returnValue = NO;
            }
        }
    }
    // Listen to changes on the the database
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(yapDatabaseModified:)
                                                 name:YapDatabaseModifiedNotification
                                               object:self.database];
    [self.readConnection beginLongLivedReadTransaction];
    //NSLog(@"ReturnValue %d", returnValue);
    return returnValue;
}

#pragma mark - private properties

#pragma mark parse
- (ParseApi *) parseApi
{
    if (!_parseApi)
    {
        _parseApi = [[ParseApi alloc] init];
    }
    return _parseApi;
}
#pragma mark - database stuff
- (void)yapDatabaseModified:(NSNotification *)notification
{
    NSLog(@"Notification: %@", notification);
    [self.readConnection beginLongLivedReadTransaction];
}
- (YapDatabase *) database
{
    if (!_database)
    {
        _database = [[YapDatabase alloc] initWithPath:[self filePath]];
    }
    return _database;
}
- (YapDatabaseConnection *) readConnection
{
    if (!_readConnection)
    {
        _readConnection = [self.database newConnection];
        [_readConnection beginLongLivedReadTransaction];
    }
    return _readConnection;
}

- (YapDatabaseConnection *) writeConnection
{
    if (!_writeConnection)
    {
        _writeConnection = [self.database newConnection];
    }
    return _writeConnection;
}
- (YapDatabaseView *) routesView
{
    if (!_routesView) {
        YapDatabaseViewGrouping *grouping = [YapDatabaseViewGrouping withObjectBlock:^NSString *(YapDatabaseReadTransaction *transaction, NSString *collection, NSString *key, id object) {
            if ([collection isEqualToString:kRoutesCollection]) {
                return @"routes";
            }
            return nil;
        }];
        YapDatabaseViewSorting *sorting = [YapDatabaseViewSorting withObjectBlock:^NSComparisonResult(YapDatabaseReadTransaction *transaction, NSString *group, NSString *collection1, NSString *key1, id object1, NSString *collection2, NSString *key2, id object2) {
            Route *route1 = object1;
            Route *route2 = object2;
            return [route1.name compare:route2.name options:NSNumericSearch range:NSMakeRange(0, route1.name.length)];
        }];
        _routesView = [[YapDatabaseView alloc] initWithGrouping:grouping sorting:sorting];
    }
    return _routesView;
}
#pragma mark - scanner stuff
- (void) startScanner
{
    // Create the progression and completion blocks:
    void (^completionBlock)(MSSync *, NSError *) = ^(MSSync *op, NSError *error) {
        if (error)
        {
            NSLog(@"Sync failed with error: %@", [error ms_message]);
        }
        else
        {
            NSLog(@"Sync succeeded (%li images(s))", (long)[_scanner count:nil]);
        }
    };
    
    void (^progressionBlock)(NSInteger) = ^(NSInteger percent) {
        //NSLog(@"Sync progressing: %li%%", (long)percent);
    };
     [self.scanner syncInBackgroundWithBlock:completionBlock progressBlock:progressionBlock];
}
#pragma mark - Public API
- (MSScanner *) scanner
{
    if (!_scanner)
    {
        NSString *path = [MSScanner cachesPathFor:@"scanner.db"];
        _scanner = [[MSScanner alloc] init];
        [_scanner openWithPath:path key:MS_API_KEY secret:MS_API_SECRET error:nil];
        
    }
    return _scanner;
}
- (Language *) language
{
    if (!_language)
    {
        NSString *objectId = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"languageCode"];
        __block Language *lang = nil;
        [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
         {
             lang = [transaction objectForKey:objectId inCollection:kLanguagesCollection];
         }];
        _language = lang;
    }
    return _language;
}
- (Info *) info
{
    if (!_info)
    {
        NSString *objectId = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"infoKey"];
        __block Info *tmp = nil;
        [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
         {
             tmp = [transaction objectForKey:objectId inCollection:kInfoCollection];
         }];
        _info = tmp;
    }
    return _info;
}
- (NSInteger) numberOfRoutes
{
    // FIX no routes on first run
    __block NSInteger count = 0;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        count = [transaction numberOfKeysInCollection:kRoutesCollection];
    }];
    return count;
}
- (Route *) routeAtIndex:(NSUInteger) index
{
    Route *route = [[self allRoutes] objectAtIndex:index];
    return route;
}
- (NSMutableArray *) pointOfInterests
{
    if (!_pointOfInterests)
    {
        __block NSMutableArray *results = [[NSMutableArray alloc ]init];
        [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
         {
             NSArray *array = [transaction allKeysInCollection:kPointOfInterestsCollection];
             for (NSString *key in array)
             {
                 PointOfInterest *poi = [transaction objectForKey:key inCollection:kPointOfInterestsCollection];
                 [results addObject:poi];
             }
         }];
        _pointOfInterests = results;
    }
    return _pointOfInterests;
}
- (BOOL) hasVisitedPointOfInterestWithObjectId:(NSString *)objectId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:[NSString stringWithFormat:@"poi_visited_%@", objectId]] ? YES : NO;
}
- (void) registerVisitOfPointOfInterestWithObjectId:(NSString *)objectId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@YES forKey:[NSString stringWithFormat:@"poi_visited_%@", objectId]];
    [defaults synchronize];
}
- (PointOfInterest *) pointOfInterestWithObjectId:(NSString *) objectId
{
    __block PointOfInterest *poi;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
    {
        poi = [transaction objectForKey:objectId inCollection:kPointOfInterestsCollection];
    }];
    return poi;
}
- (Route *) routeContainingPointOfInterestWithObjectId:(NSString *)objectId
{
    __block Route* route = nil;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
     {
         NSArray *array = [transaction allKeysInCollection:kRoutesCollection];
         for (NSString *key in array)
         {
             Route *r = [transaction objectForKey:key inCollection:kRoutesCollection];
             if ([r.pointOfInterestIds containsObject:objectId])
             {
                 route = r;
                 break;
             }
         }
         
     }];
    return route;
}
- (BOOL) anyIdentifierOn:(NSArray *) identifiers
{
    BOOL result = NO;
    for (NSString *identifier in identifiers)
    {
        BOOL thisValue = [self boolSettingWithIdentifier:identifier defaultValue:NO];
        result = result || thisValue;
    }
    return result;
}
- (BOOL) boolSettingWithIdentifier:(NSString *)identifier
{
    return [self boolSettingWithIdentifier:identifier defaultValue:NO];
}
- (BOOL) boolSettingWithIdentifier:(NSString *)identifier defaultValue:(BOOL) defaultValue
{
    NSNumber *savedSetting = [[NSUserDefaults standardUserDefaults] objectForKey:identifier];
    return savedSetting ? [savedSetting boolValue] : defaultValue;
}
- (void) setBoolSetting:(BOOL) b forIdentifier:(NSString *)identifier
{
    [[NSUserDefaults standardUserDefaults] setBool:b forKey:identifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void) toggleBoolSettingWithIdentifier:(NSString *)identifier
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    BOOL old = NO;
    if ([def objectForKey:identifier])
    {
        old = [def boolForKey:identifier];
    }
    [def setBool:!old forKey:identifier];
    [def synchronize];
}
- (Quiz *) quizForPOIWithObjectId:(NSString *)objectId
{
    __block Quiz *quiz = nil;
    PointOfInterest *poi = [self pointOfInterestWithObjectId:objectId];
    if (poi)
    {
        [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
         {
             quiz = [transaction objectForKey:poi.quizId inCollection:kQuizCollection];
         }];
    }
    return quiz;
}
- (BOOL) anyDefaultRoute
{
    __block NSArray *routeIdentifiers;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        routeIdentifiers = [transaction allKeysInCollection:kRoutesCollection];
    }];
    BOOL result = NO;
    for (NSString *identifier in routeIdentifiers)
    {
        BOOL thisValue = [self boolSettingWithIdentifier:[NSString stringWithFormat:@"settings_route_%@", identifier] defaultValue:NO];
        result = result || thisValue;
    }
    return result;
}
- (NSArray *) allRoutes
{
    __block NSMutableArray *results = [[NSMutableArray alloc ]init];
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
     {
         NSArray *array = [transaction allKeysInCollection:kRoutesCollection];
         for (NSString *key in array)
         {
             Route *route = [transaction objectForKey:key inCollection:kRoutesCollection];
             [results addObject:route];
         }
     }];
    return [results sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        Route *r1 = (Route *) obj1;
        Route *r2 = (Route *) obj2;
        NSString *name1 = r1.name;
        NSString *name2 = r2.name;
        NSLog(@"Compares %@ with %@ = %ld", name1, name2, (long)[name1 compare:name2 options:NSNumericSearch]);
        return [name1 compare:name2 options:NSNumericSearch];
    }];
}
- (NSArray *) drawableRoutePartsForRouteWithObjectId:(NSString *)objectId
{
    __block NSMutableArray *drawableRoutes = [[NSMutableArray alloc] init];
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        Route *route = [transaction objectForKey:objectId inCollection:kRoutesCollection];
        NSArray *keys = route.pointOfInterestIds;
        for (NSString *key in keys)
        {
            if ([transaction hasObjectForKey:key inCollection:kPointOfInterestConnectionsCollection])
            {
                PointOfInterestConnection *connection = [transaction objectForKey:key inCollection:kPointOfInterestConnectionsCollection];
                [drawableRoutes addObject:connection];
            }
        }
    }];
    return drawableRoutes;
}
- (CLLocationCoordinate2D) coordinateForPointOfInterestWithObjectId:(NSString *)objectId
{
    __block PointOfInterest *poi = nil;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
    {
        poi = [transaction objectForKey:objectId inCollection:kPointOfInterestsCollection];
    }];
    return poi.coordinates;
}
- (NSArray *) pointOfInterestsForRoute:(Route *)route
{
   __block NSArray *result = nil;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[route.pointOfInterestIds count]];
        for (NSString *poiId in route.pointOfInterestIds)
        {
            PointOfInterest *poi = [transaction objectForKey:poiId inCollection:kPointOfInterestsCollection];
            if (poi)
            {
                [array addObject:poi];
            }
        }
        result = array;
    }];
    return result;
}
#define kFunenNorthLat 55.693779f
#define kFunenSouthLat 54.717970f
#define kFunenWestLng 9.629520f
#define kFunenEastLng 11.125034f
- (MKCoordinateRegion) regionForFunen
{
    MKCoordinateRegion region;
    region.center.latitude = kFunenNorthLat - (kFunenNorthLat - kFunenSouthLat) * 0.5f;
    region.center.longitude = kFunenWestLng - (kFunenWestLng - kFunenEastLng) * 0.5f;
    region.span.latitudeDelta = fabs(kFunenNorthLat - kFunenSouthLat) * 1.1;
    region.span.longitudeDelta = fabs(kFunenEastLng - kFunenWestLng) * 1.1;
    return region;
}
-(BOOL)isCoordinate:(CLLocationCoordinate2D)coordinate insideRegion:(MKCoordinateRegion)region {
    CLLocationCoordinate2D center   = region.center;
    CLLocationCoordinate2D northWestCorner, southEastCorner;
    
    northWestCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
    southEastCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0);
    
    return(coordinate.latitude  >= northWestCorner.latitude &&
           coordinate.latitude  <= southEastCorner.latitude &&
           coordinate.longitude >= northWestCorner.longitude &&
           coordinate.longitude <= southEastCorner.longitude
           );
}
- (MKCoordinateRegion) regionForRouteWithObjectId:(NSString *)routeId;
{
    if (!routeId)
    {
        //NSLog(@"No routeID");
        return [self regionForFunen];
    }
    __block Route *route = nil;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
     {
         route = [transaction objectForKey:routeId inCollection:kRoutesCollection];
     }];
    NSLog(@"Route: %@", route);
    if (route)
    {
        CLLocation *userLoc = [[LocationManager sharedInstance] userLocation];
        //NSLog(@"Setting coords");
        MKCoordinateRegion region;
        NSArray *pois = [self pointOfInterestsForRoute:route];
        CLLocationCoordinate2D topLeftCoord;
        topLeftCoord.latitude = -90;
        topLeftCoord.longitude = 180;
        
        CLLocationCoordinate2D bottomRightCoord;
        bottomRightCoord.latitude = 90;
        bottomRightCoord.longitude = -180;
        
        if (userLoc && [self isCoordinate:userLoc.coordinate insideRegion:self.regionForFunen])
        {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, userLoc.coordinate.longitude);
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, userLoc.coordinate.latitude);
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, userLoc.coordinate.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, userLoc.coordinate.latitude);
        }
        for (PointOfInterest *poi in pois)
        {
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, poi.coordinates.longitude);
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, poi.coordinates.latitude);
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, poi.coordinates.longitude);
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, poi.coordinates.latitude);
            //NSLog(@"%f %f %f %f", topLeftCoord.latitude, topLeftCoord.longitude, bottomRightCoord.latitude, bottomRightCoord.longitude);
        }
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4f;
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4f;
        
        NSLog(@"%f %f %f %f", region.center.latitude, region.center.longitude, region.span.latitudeDelta, region.span.longitudeDelta);
        
        return region;
    }
    else
    {
        NSLog(@"No route");
        return [self regionForFunen];
    }
}
- (NSString *) pointOfInterestBelongsToPointSystem:(NSString *) objectId
{
    Route *route = [self routeContainingPointOfInterestWithObjectId:objectId];
    __block NSString* routePointId = nil;
     [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
      {
          NSArray *routePointSystem = [transaction allKeysInCollection:kRoutePointCollection];
          for (NSString *key in routePointSystem)
          {
              if ([[transaction metadataForKey:key inCollection:kRoutePointCollection] isEqualToString:route.objectId])
              {
                  RoutePoint *routePoint = [transaction objectForKey:key inCollection:kRoutePointCollection];
                  if ([routePoint.pointOfInterestIds containsObject:objectId])
                  {
                      routePointId = key;
                      break;
                  }
              }
          }
      }];
    return routePointId;
}
- (float) calculatePercentageCompletedForRouteWithObjectId:(NSString *)objectId
{
    if (!objectId)
    {
        return -1;
    }
    __block float percentage = 0.0f;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableSet *foundPois = [NSMutableSet setWithArray:[defaults arrayForKey:objectId]];
    
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
    {
       RoutePoint *routePoint = [transaction objectForKey:objectId inCollection:kRoutePointCollection];
        NSSet *allPois = [NSSet setWithArray:routePoint.pointOfInterestIds];
        if (allPois.count > 0)
        {
            [foundPois intersectSet:allPois];
            percentage = ((float)[foundPois count]) / ((float)[allPois count]);
        }
        else
        {
            percentage = -1;
        }
    }];
   NSLog(@"Percentage:%f", percentage);
    return percentage;
}
- (RoutePointPercentageBlock) percentageBlockForPercentage:(float) percentage
{
    if (percentage > 0.99)
    {
        return kPercentage100;
    }
    else if (percentage > 0.749)
    {
        return kPercentage75;
    }
    else if (percentage > 0.499)
    {
        return kPercentage50;
    }
    else if (percentage > 0.249)
    {
        return kPercentage25;
    }
    return kPercentage0;
}
- (RoutePointPercentageBlock) percentageCompletedForRouteWithObjectId:(NSString *)objectId
{
    float percentage = [self calculatePercentageCompletedForRouteWithObjectId:objectId];
    if (percentage > 0.99)
    {
        return kPercentage100;
    }
    else if (percentage > 0.749)
    {
        return kPercentage75;
    }
    else if (percentage > 0.499)
    {
        return kPercentage50;
    }
    else if (percentage > 0.249)
    {
        return kPercentage25;
    }
    return kPercentage0;
}
- (NSString *) textForPercentageBlock:(RoutePointPercentageBlock) block completedForRouteWithObjectId:(NSString *) objectId
{
    __block RoutePoint * rp = nil;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
     {
         rp = [transaction objectForKey:objectId inCollection:kRoutePointCollection];
     }];
    NSLog(@"RP: %@ == %@ %@ %@", rp.objectId, objectId, rp.text25s, rp.text25);
    switch (block)
    {
        case kPercentage25:
            return rp.text25;
        case kPercentage50:
            return rp.text50;
        case kPercentage75:
            return rp.text75;
        case kPercentage100:
            return rp.text100;
        case kPercentage0:
        default:
            return @"";
    }
    return @"";
}
- (Route *) routeForRoutePointWithObjectId:(NSString *) objectId
{
    __block Route *route = nil;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
    {
         NSString *routeId = [transaction metadataForKey:objectId inCollection:kRoutePointCollection];
        route = [transaction objectForKey:routeId inCollection:kRoutesCollection];
    }];
    return route;
}
- (NSString *) bestLanguageCodeFromArrayOfCodes:(NSArray *)codes
{
    __block NSString *best = nil;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction)
     {
         BOOL found = false;
         for (NSString *key in [self.language priority])
         {
             if (found)
             {
                 break;
             }
             Language *lang = [transaction objectForKey:key inCollection:kLanguagesCollection];
             if ([codes containsObject:lang.code])
             {
                 best = lang.code;
                 found = YES;
             }
         }
     }];
    return best;
}
- (void) addPolyline:(MKPolyline *) polyline withIdentifier:(NSString *) identifier toRouteWithObjectId:(NSString *) objectId
{
    __block Route *route = nil;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        route = [transaction objectForKey:objectId inCollection:kRoutesCollection];
    }];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:route.routeCoordinates];
    NSArray *arr = [polyline arrayValue];
    [dict setObject:arr forKey:identifier];
    route.routeCoordinates = dict;
    [self.writeConnection asyncReadWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        [transaction setObject:route forKey:route.objectId inCollection:kRoutesCollection];
    }];
}
- (MKPolyline *) polylineWithIdentifer:(NSString *) identifier forRouteWithObjectId:(NSString *) objectId
{
    // 1) Fetch route with objectId;
    __block Route *route = nil;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        route = [transaction objectForKey:objectId inCollection:kRoutesCollection];
    }];
    // 2) Get array
    NSArray * arr = [route.routeCoordinates valueForKeyPath:identifier];
    if (arr)
    {
        return [MKPolyline instanceWithPointArray:arr];
    }
    return nil;
}
@end
