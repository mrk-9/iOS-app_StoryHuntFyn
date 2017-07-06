//
//  AvatarView.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 28/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "AvatarView.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
@interface AvatarView()
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) UIButton *playPauseButton;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIImageView *speechBubble;
@property (nonatomic, assign) NSInteger nextImage;
@property (nonatomic, assign) BOOL autoPlay;
@end

@implementation AvatarView

- (id) initWithFrame:(CGRect)frame andImages:(NSArray *)images soundEnabled:(BOOL) soundEnabled autoPlayAvatars:(BOOL)autoPlay
{
    if (IS_IPAD)
    {
        if (frame.size.width != 284)
        {
            frame.size.width = 284;
        }
        if (frame.size.height != 420)
        {
            frame.size.height = 420;
        }
    }
    else
    {
        if (frame.size.width != 142)
        {
            frame.size.width = 142;
        }
        if (frame.size.height != 210)
        {
            frame.size.height = 210;
        }
    }
    self = [super initWithFrame:frame];
    if (self)
    {
        self.images = images;
        
        self.nextImage = 0;
        
        [self addSubview:self.avatarImageView];
        if (soundEnabled)
        {
            [self addSubview:self.speechBubble];
            [self addSubview:self.playPauseButton];
        }
        
        self.soundEnabled = soundEnabled;
        
        self.autoPlay = autoPlay;
        if (!soundEnabled)
        {
            self.autoPlay = NO;
        }
        
        if (self.autoPlay)
        {
            self.state = AvatarViewButtonStatePlay;
            self.playPauseButton.selected = YES;
        }
        else
        {
            self.state = AvatarViewButtonStatePause;
            self.playPauseButton.selected = NO;
        }
        
        [self changeImage];
    }
    return self;
}


- (void) changeImage
{
    
    if (self.state == AvatarViewButtonStatePause)
    {
        return;
    }
    [UIView transitionWithView:self.avatarImageView
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.avatarImageView.image = [UIImage imageWithData:[self.images objectAtIndex:self.nextImage]];
                    } completion:^(BOOL finished) {
                        self.nextImage = (self.nextImage + 1) % [self.images count];
                        if (self.state == AvatarViewButtonStatePlay)
                        {
                            // Repeat after x second
                            [self performSelector:@selector(changeImage) withObject:nil afterDelay:0.5f];
                        }
                    }];
}

#pragma mark - properties

- (void) setState:(AvatarViewButtonState)state
{
    _state = state;
    
    self.playPauseButton.selected = (_state == AvatarViewButtonStatePlay);
    
}

- (UIImageView *) avatarImageView
{
    if (!_avatarImageView)
    {
        CGRect frame;
        if (IS_IPAD)
        {
            frame = CGRectMake(0, 26, 282, 394);
        }
        else
        {
            frame = CGRectMake(0, 13, 142, 197);
        }
        
        
        _avatarImageView = [[UIImageView alloc] initWithFrame:frame];
        [_avatarImageView setImage:[UIImage imageWithData:[self.images objectAtIndex:0]]];
    }
    return _avatarImageView;
}

- (UIImageView *) speechBubble
{
    if (!_speechBubble)
    {
        CGRect frame;
        if (IS_IPAD)
        {
            frame = CGRectMake(130, 0, 112, 90);
        }
        else
        {
            frame = CGRectMake(65, 0, 56, 45);
        }
        _speechBubble = [[UIImageView alloc] initWithFrame:frame];
        _speechBubble.image = [UIImage imageNamed:IS_IPAD ? @"speech-bubble-ipad.png" :  @"speech-bubble.png"];
    }
    return _speechBubble;
}

- (UIButton *) playPauseButton
{
    if (!_playPauseButton)
    {
        CGRect frame;
        if (IS_IPAD)
        {
            frame = CGRectMake(164, 8, 44, 54);
        }
        else
        {
            frame = CGRectMake(82, 4, 22, 27);
        }
        _playPauseButton = [[UIButton alloc] initWithFrame:frame];
        [_playPauseButton setImage:[UIImage imageNamed:IS_IPAD ? @"speech-bubble-pause-ipad.png" : @"speech-bubble-pause.png"] forState:UIControlStateHighlighted];
        [_playPauseButton setImage:[UIImage imageNamed:IS_IPAD ? @"speech-bubble-pause-ipad.png" : @"speech-bubble-pause.png"] forState:UIControlStateSelected];
        [_playPauseButton setImage:[UIImage imageNamed:IS_IPAD ? @"speech-bubble-play-ipad.png" : @"speech-bubble-play.png"] forState:UIControlStateNormal];
        [_playPauseButton addTarget:self action:@selector(playPauseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _playPauseButton.selected = NO;
    }
    return _playPauseButton;
}

- (void) playPauseButtonPressed:(id) sender
{
    if (self.playPauseButton.selected)
    {
        self.playPauseButton.selected = NO;
        self.state = AvatarViewButtonStatePause;
    }
    else
    {
        self.state = AvatarViewButtonStatePlay;
        self.playPauseButton.selected = YES;
        
    }
    [self changeImage];
    if (self.delegate)
    {
        [self.delegate avatarView:self buttonPressWithState:self.state];
    }
    
}



@end
