//
//  SoundHelper.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 27/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>

#import "SoundHelper.h"
@interface SoundHelper()
@property SystemSoundID buttonSound;
@property SystemSoundID pageflipSound;
@property SystemSoundID getPointSound;
@property SystemSoundID percentageCompleteSound;
@end
@implementation SoundHelper
@synthesize buttonSound;
@synthesize pageflipSound;
@synthesize getPointSound;
@synthesize percentageCompleteSound;
#pragma mark - singleton
+ (instancetype)sharedInstance
{
    static SoundHelper *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      sharedInstance = [[SoundHelper alloc] init];
                  });
    return sharedInstance;
}

#pragma mark - init

- (id) init
{
    self = [super self];
    if (self)
    {
        // Button sound
        NSString* path = [[NSBundle mainBundle] pathForResource:@"button" ofType:@"aif"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &buttonSound);
        
        // Pageflip sound
        NSString* pageflipSoundPath = [[NSBundle mainBundle] pathForResource:@"Book_Page_Turn" ofType:@"aif"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:pageflipSoundPath], &pageflipSound);
        
        // Get point
        NSString* getPointSoundPath = [[NSBundle mainBundle] pathForResource:@"get_point" ofType:@"aif"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:getPointSoundPath], &getPointSound);
        
        // Percentage complete
        NSString* percentageCompletePath = [[NSBundle mainBundle] pathForResource:@"get_point_with_bonus" ofType:@"aif"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:percentageCompletePath], &percentageCompleteSound);
        
    }
    return self;
}

- (void) playGetPointSound
{
    AudioServicesPlaySystemSound(getPointSound);
}

- (void) playPageTurnSound
{
    AudioServicesPlaySystemSound(pageflipSound);
}

- (void)playTapSound
{
    AudioServicesPlaySystemSound(buttonSound);
}

- (void)playPercentageCompleteSound
{
    AudioServicesPlaySystemSound(percentageCompleteSound);
}

- (void) vibrate
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}
@end
