//
//  SoundHelper.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 27/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SoundHelper : NSObject
+ (instancetype)sharedInstance;
- (void) playTapSound;
- (void) playPageTurnSound;
- (void) playGetPointSound;
- (void) playPercentageCompleteSound;
- (void) vibrate;
@end
