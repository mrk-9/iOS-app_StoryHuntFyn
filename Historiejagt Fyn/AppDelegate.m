//
//  AppDelegate.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 21/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "AppDelegate.h"
#import "Datalayer.h"
#import <HOCReachabilityHelper-ios/HOCReachabilityHelper.h>
#import "Flurry.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [[NSURLCache sharedURLCache] setMemoryCapacity:1024*1024*100];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:settings];
    }
    
    [HOCReachabilityHelper sharedHOCReachabilityHelper];

    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    
    NSURL *docsDirURL = [NSURL fileURLWithPath:docsDir];
    [self addSkipBackupAttributeToItemAtURL:docsDirURL];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSLog(@"path = %@", documentsDirectory);
    
    return YES;
}

- (BOOL) addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success)
    {
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //NSLog(@"Local message:%@", notification);
    NSDictionary *dict = [notification userInfo];
    id obj = [dict objectForKey:@"pointOfInterest"];
    NSString *objectId = (NSString *)obj;
    if ([application applicationState] != UIApplicationStateActive)
    {
       // Starts app
        [[Datalayer sharedInstance] setPointOfInterestNotificationObjectId:objectId];
    }
    else
    {
        // Running - notify
        
     //   [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerPointOfInterestFound object:nil userInfo:@{@"pointOfInterest" : objectId}];
    }
}

@end
