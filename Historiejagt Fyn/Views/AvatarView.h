//
//  AvatarView.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 28/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, AvatarViewButtonState)
{
    AvatarViewButtonStatePause = 0,
    AvatarViewButtonStatePlay = 1
};
@protocol AvatarViewDelegate;
@interface AvatarView : UIView
@property (nonatomic, weak) id<AvatarViewDelegate> delegate;
@property (nonatomic, assign) BOOL soundEnabled;
@property (nonatomic, assign) AvatarViewButtonState state;
- (id) initWithFrame:(CGRect)frame andImages:(NSArray *)images soundEnabled:(BOOL) soundEnabled autoPlayAvatars:(BOOL)autoPlay;
@end

@protocol AvatarViewDelegate <NSObject>
- (void) avatarView:(AvatarView *)avatarView buttonPressWithState:(AvatarViewButtonState) state;
- (void) avatarView:(AvatarView *)avatarView changedImageToImage:(NSInteger) imageNumber;
@end