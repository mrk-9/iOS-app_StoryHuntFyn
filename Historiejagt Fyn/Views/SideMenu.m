//
//  SideMenu.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 29/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "SideMenu.h"
#import <Canvas/Canvas.h>
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
@interface SideMenu()
@property (nonatomic, assign) CGFloat contentWidth;
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) CGFloat factWidth;
@property (nonatomic, assign) CGFloat factHeight;

@property (nonatomic, assign) CGFloat quizWidth;
@property (nonatomic, assign) CGFloat quizHeight;
@property (nonatomic, assign) CGFloat factTop;
@property (nonatomic, assign) CGFloat quizTop;

@property (nonatomic, strong) CSAnimationView *contentAnimation;
@property (nonatomic, strong) CSAnimationView *factAnimation;
@property (nonatomic, strong) CSAnimationView *quizAnimation;

@property (nonatomic, strong) UIButton *contentButton;
@property (nonatomic, strong) UIButton *factButton;
@property (nonatomic, strong) UIButton *quizButton;

@end
@implementation SideMenu
- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void) setup
{
    [self setupConstants];
    [self.contentAnimation addSubview:self.contentButton];
    [self.factAnimation addSubview:self.factButton];
    [self.quizAnimation addSubview:self.quizButton];
    [self addSubview:self.contentAnimation];
    [self addSubview:self.factAnimation];
    [self addSubview:self.quizAnimation];
//    [self updateConstraints];
}
    
- (void) setupConstants
{
    BOOL showFacts = (self.poi && self.poi.facts && self.poi.facts.length > 0);
    BOOL showQuiz = (self.poi && self.poi.quizId  && self.poi.quizId.length > 0);
    BOOL showContent = showFacts || showQuiz;
//    NSLog(@"Show facts: %@", showFacts ? @"YES" : @"NO");
//    NSLog(@"Show quiz: %@ - %@", showQuiz ? @"YES" : @"NO", self.poi.quizId);
//    NSLog(@"Show info: %@", showContent ? @"YES" : @"NO");
    if (!showContent)
    {
        self.contentHeight = 0;
        self.factHeight = 0;
        self.quizHeight = 0;
        self.factTop = 0;
        self.quizTop = 0;
        self.contentWidth = 0;
        self.factWidth = 0;
        self.quizWidth = 0;
        self.quizAnimation.hidden = YES;
        self.factAnimation.hidden = YES;
        self.contentAnimation.hidden = YES;
        
    }
    else
    {
        if (IS_IPAD)
        {
            self.contentWidth = 112;
            self.contentHeight = 92;
         
            if (showFacts)
            {
                self.factTop = 50;
                self.factWidth = 110.5;
                self.factHeight = 87;
                self.quizTop = 101;
            }
            else
            {
                self.factWidth = 0;
                self.factHeight = 0;
                self.quizTop = 58;
            }
            
            if (showQuiz)
            {
                self.quizWidth = 112.5;
                self.quizHeight = 91;
            }
            else
            {
                self.quizWidth = 0;
                self.quizHeight = 0;
            }

        }
        else
        {
            self.contentWidth = 65;
            self.contentHeight = 64;
            
            if (showFacts)
            {
                self.factTop = 43;
                self.factWidth = 65;
                self.factHeight = 65;
                self.quizTop = 98;

            }
            else
            {
                self.factWidth = 0;
                self.factHeight = 0;
                self.quizTop = 47;
            }
            
            if (showQuiz)
            {
                self.quizWidth = 65;
                self.quizHeight = 64;
            }
            else
            {
                self.quizWidth = 0;
                self.quizHeight = 0;
            }
        }
      //  NSLog(@"Quiz: %fx%f, %f", self.quizWidth, self.quizHeight, self.quizTop);
        self.quizAnimation.hidden = !showQuiz;
        self.factAnimation.hidden = !showFacts;
        self.contentAnimation.hidden = !showContent;
    }

    CGRect frame;
    
    frame = CGRectMake(self.frame.size.width-self.contentWidth, 0, self.contentWidth, self.contentHeight);
    self.contentAnimation.frame = frame;
    frame.origin.x = 0;
    self.contentButton.frame = frame;
    
    if (showFacts)
    {
        frame = CGRectMake(self.frame.size.width - self.factWidth, self.factTop, self.factWidth, self.factHeight);
        self.factAnimation.frame = frame;
        
        frame.origin.x = 0;
        frame.origin.y = 0;
        self.factButton.frame = frame;
    }
    else
    {
     //   [self.factAnimation removeFromSuperview];
    }
    
    if (showQuiz)
    {
        frame = CGRectMake(self.frame.size.width - self.quizWidth, self.quizTop, self.quizWidth, self.quizHeight);
        self.quizAnimation.frame = frame;
    
        frame.origin.x = 0;
        frame.origin.y = 0;
        self.quizButton.frame = frame;
    }
    else
    {
       // [self.quizAnimation removeFromSuperview];
    }
}


//- (void) updateConstraints
//{
//    [super updateConstraints];
//    [self setupConstants];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentAnimation
//                                                     attribute:NSLayoutAttributeHeight
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:nil
//                                                     attribute:0
//                                                    multiplier:1.0
//                                                      constant:self.contentHeight]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.factAnimation
//                                                     attribute:NSLayoutAttributeHeight
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:nil
//                                                     attribute:0
//                                                    multiplier:1.0
//                                                      constant:self.factHeight]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.quizAnimation
//                                                     attribute:NSLayoutAttributeHeight
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:nil
//                                                     attribute:0
//                                                    multiplier:1.0
//                                                      constant:self.quizHeight]];
//
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentAnimation
//                                                     attribute:NSLayoutAttributeWidth
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:nil
//                                                     attribute:0
//                                                    multiplier:1.0
//                                                      constant:self.contentWidth]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.factAnimation
//                                                     attribute:NSLayoutAttributeWidth
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:nil
//                                                     attribute:0
//                                                    multiplier:1.0
//                                                      constant:self.factWidth]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.quizAnimation
//                                                     attribute:NSLayoutAttributeWidth
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:nil
//                                                     attribute:0
//                                                    multiplier:1.0
//                                                      constant:self.quizWidth]];
//    
//    
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentButton
//                                                     attribute:NSLayoutAttributeTop
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.contentAnimation
//                                                     attribute:NSLayoutAttributeTop
//                                                    multiplier:1.0
//                                                      constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.factButton
//                                                     attribute:NSLayoutAttributeTop
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.factAnimation
//                                                     attribute:NSLayoutAttributeTop
//                                                    multiplier:1.0
//                                                      constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.quizButton
//                                                     attribute:NSLayoutAttributeTop
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.quizAnimation
//                                                     attribute:NSLayoutAttributeTop
//                                                    multiplier:1.0
//                                                      constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentButton
//                                                     attribute:NSLayoutAttributeLeading
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.contentAnimation
//                                                     attribute:NSLayoutAttributeLeading
//                                                    multiplier:1.0
//                                                      constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.factButton
//                                                     attribute:NSLayoutAttributeLeading
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.factAnimation
//                                                     attribute:NSLayoutAttributeLeading
//                                                    multiplier:1.0
//                                                      constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.quizButton
//                                                     attribute:NSLayoutAttributeLeading
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.quizAnimation
//                                                     attribute:NSLayoutAttributeLeading
//                                                    multiplier:1.0
//                                                      constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentButton
//                                                     attribute:NSLayoutAttributeTrailing
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.contentAnimation
//                                                     attribute:NSLayoutAttributeTrailing
//                                                    multiplier:1.0
//                                                      constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.factButton
//                                                     attribute:NSLayoutAttributeTrailing
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.factAnimation
//                                                     attribute:NSLayoutAttributeTrailing
//                                                    multiplier:1.0
//                                                      constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.quizButton
//                                                     attribute:NSLayoutAttributeTrailing
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.quizAnimation
//                                                     attribute:NSLayoutAttributeTrailing
//                                                    multiplier:1.0
//                                                      constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentButton
//                                                     attribute:NSLayoutAttributeBottom
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.contentAnimation
//                                                     attribute:NSLayoutAttributeBottom
//                                                    multiplier:1.0
//                                                      constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.factButton
//                                                     attribute:NSLayoutAttributeBottom
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.factAnimation
//                                                     attribute:NSLayoutAttributeBottom
//                                                    multiplier:1.0
//                                                      constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.quizButton
//                                                     attribute:NSLayoutAttributeBottom
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self.quizAnimation
//                                                     attribute:NSLayoutAttributeBottom
//                                                    multiplier:1.0
//                                                      constant:0]];
//    
//
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentAnimation
//                                                     attribute:NSLayoutAttributeTrailing
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeTrailing
//                                                    multiplier:1.0
//                                                      constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.factAnimation
//                                                     attribute:NSLayoutAttributeTrailing
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeTrailing
//                                                    multiplier:1.0
//                                                      constant:0]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.quizAnimation
//                                                     attribute:NSLayoutAttributeTrailing
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeTrailing
//                                                    multiplier:1.0
//                                                      constant:0]];
//    
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.contentAnimation
//                                                     attribute:NSLayoutAttributeTop
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeTop
//                                                    multiplier:1.0
//                                                      constant:0]];
//
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.factAnimation
//                                                     attribute:NSLayoutAttributeTop
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeTop
//                                                    multiplier:1.0
//                                                      constant:self.factTop]];
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.quizAnimation
//                                                     attribute:NSLayoutAttributeTop
//                                                     relatedBy:NSLayoutRelationEqual
//                                                        toItem:self
//                                                     attribute:NSLayoutAttributeTop
//                                                    multiplier:1.0
//                                                      constant:self.quizTop]];
//}

- (void) setPoi:(PointOfInterest *)poi
{
    _poi = poi;
    [self setupConstants];
}

- (void) startAnimations
{
    [self.contentAnimation startCanvasAnimation];
    [self.factAnimation startCanvasAnimation];
    [self.quizAnimation startCanvasAnimation];
}

- (IBAction) buttonPressed:(id)sender
{
    if (sender == self.contentButton)
    {
        self.selectedItem = SideMenuItemContent;
    }
    else if (sender == self.factButton)
    {
        self.selectedItem = SideMenuItemFacts;
    }
    else if (sender == self.quizButton)
    {
        self.selectedItem = SideMenuItemQuiz;
    }
    if (self.delegate)
    {
        //NSLog(@"Hello %ld", self.selectedItem);
        [self.delegate sideMenu:self didSelectItem:self.selectedItem];
    }
}

#pragma mark - properties

- (CSAnimationView *) contentAnimation
{
    if (!_contentAnimation)
    {
        _contentAnimation = [[CSAnimationView alloc] init];
        _contentAnimation.translatesAutoresizingMaskIntoConstraints = YES;
        _contentAnimation.backgroundColor = [UIColor clearColor];
//        _contentAnimation.type = CSAnimationTypeBounceLeft;
//        _contentAnimation.duration = 1.0f;
//        _contentAnimation.delay = 0.25;
//        
//        _contentAnimation.pauseAnimationOnAwake = YES;
    }
    return _contentAnimation;
}

- (CSAnimationView *) factAnimation
{
    if (!_factAnimation)
    {
        _factAnimation = [[CSAnimationView alloc] init];
        _factAnimation.translatesAutoresizingMaskIntoConstraints = YES;
        _factAnimation.backgroundColor = [UIColor clearColor];
//        _factAnimation.type = CSAnimationTypeBounceLeft;
//        _factAnimation.duration = 1.0f;
//        _factAnimation.delay = 0.5f;
//        _factAnimation.pauseAnimationOnAwake = YES;
    }
    return _factAnimation;
}

- (CSAnimationView *) quizAnimation
{
    if (!_quizAnimation)
    {
        _quizAnimation = [[CSAnimationView alloc] init];
        _quizAnimation.translatesAutoresizingMaskIntoConstraints = YES;
        _quizAnimation.backgroundColor = [UIColor clearColor];
//        _quizAnimation.type = CSAnimationTypeBounceLeft;
//        _quizAnimation.duration = 1.0f;
//        _quizAnimation.delay = 1.0f;
//        _quizAnimation.pauseAnimationOnAwake = YES;
    }
    return _quizAnimation;
}

- (UIButton *) contentButton
{
    if (!_contentButton)
    {
        _contentButton = [[UIButton alloc] init];
        _contentButton.translatesAutoresizingMaskIntoConstraints = YES;
        [_contentButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-content-ipad.png" : @"sidemenu-content.png")] forState:UIControlStateNormal];
        [_contentButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-content-ipad.png" : @"sidemenu-content.png")] forState:UIControlStateSelected];
        [_contentButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-content-ipad.png" : @"sidemenu-content.png")] forState:UIControlStateHighlighted];
        [_contentButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-content-ipad.png" : @"sidemenu-content.png")] forState:UIControlStateDisabled];
        [_contentButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-content-ipad.png" : @"sidemenu-content.png")] forState:UIControlStateNormal];
        [_contentButton setImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-content-inactive-ipad.png": @"sidemenu-content-icon.png")] forState:UIControlStateNormal];
        [_contentButton setImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-content-active-ipad.png": @"sidemenu-content-icon-active.png")] forState:UIControlStateSelected];
        [_contentButton setImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-content-active-ipad.png": @"sidemeneu-content-icon-active.png")] forState:UIControlStateHighlighted];
        [_contentButton setImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-content-active-ipad.png": @"sidemenu-content-icon-active.png")] forState:UIControlStateDisabled];
        [_contentButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _contentButton.adjustsImageWhenDisabled = NO;
    }
    return _contentButton;
}


- (UIButton *) factButton
{
    if (!_factButton)
    {
        _factButton = [[UIButton alloc] init];
        _factButton.translatesAutoresizingMaskIntoConstraints = YES;
        [_factButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-facts-ipad.png" : @"sidemenu-facts.png")] forState:UIControlStateNormal];
        [_factButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-facts-ipad.png" : @"sidemenu-facts.png")] forState:UIControlStateSelected];
        [_factButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-facts-ipad.png" : @"sidemenu-facts.png")] forState:UIControlStateHighlighted];
        [_factButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-facts-ipad.png" : @"sidemenu-facts.png")] forState:UIControlStateDisabled];
        [_factButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-facts-ipad.png" : @"sidemenu-facts.png")] forState:UIControlStateNormal];
        [_factButton setImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-facts-inactive-ipad.png": @"sidemenu-facts-icon.png")] forState:UIControlStateNormal];
        [_factButton setImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-facts-active-ipad.png": @"sidemenu-facts-icon-active.png")] forState:UIControlStateSelected];
        [_factButton setImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-facts-active-ipad.png": @"sidemeneu-facts-icon-active.png")] forState:UIControlStateHighlighted];
        [_factButton setImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-facts-active-ipad.png": @"sidemenu-facts-icon-active.png")] forState:UIControlStateDisabled];
        
        [_factButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _factButton.adjustsImageWhenDisabled = NO;
    }
    return _factButton;
}
- (UIButton *) quizButton
{
    if (!_quizButton)
    {
        _quizButton = [[UIButton alloc] init];
        _quizButton.translatesAutoresizingMaskIntoConstraints = YES;
        [_quizButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-quiz-ipad.png" : @"sidemenu-quiz.png")] forState:UIControlStateNormal];
        [_quizButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-quiz-ipad.png" : @"sidemenu-quiz.png")] forState:UIControlStateSelected];
        [_quizButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-quiz-ipad.png" : @"sidemenu-quiz.png")] forState:UIControlStateHighlighted];
        [_quizButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-quiz-ipad.png" : @"sidemenu-quiz.png")] forState:UIControlStateDisabled];
        [_quizButton setBackgroundImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-quiz-ipad.png" : @"sidemenu-quiz.png")] forState:UIControlStateNormal];
        [_quizButton setImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-quiz-inactive-ipad.png": @"sidemenu-quiz-icon.png")] forState:UIControlStateNormal];
        [_quizButton setImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-quiz-active-ipad.png": @"sidemenu-quiz-icon-active.png")] forState:UIControlStateSelected];
        [_quizButton setImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-quiz-active-ipad.png": @"sidemeneu-quiz-icon-active.png")] forState:UIControlStateHighlighted];
        [_quizButton setImage:[UIImage imageNamed:(IS_IPAD ? @"sidemenu-quiz-active-ipad.png": @"sidemenu-quiz-icon-active.png")] forState:UIControlStateDisabled];
        [_quizButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _quizButton.adjustsImageWhenDisabled = NO;
    }
    return _quizButton;
}

- (void) setSelectedItem:(SideMenuItem)selectedItem
{
   // NSLog(@"sets to %ld", selectedItem);
    switch (selectedItem)
    {
        case SideMenuItemContent:
            self.contentButton.userInteractionEnabled  = NO;
            self.factButton.userInteractionEnabled = YES;
            self.quizButton.userInteractionEnabled = YES;
            self.contentButton.highlighted = YES;
            self.factButton.highlighted = NO;
            self.quizButton.highlighted = NO;
            break;
        case SideMenuItemFacts:
            self.contentButton.userInteractionEnabled  = YES;
            self.factButton.userInteractionEnabled = NO;
            self.quizButton.userInteractionEnabled = YES;
            self.contentButton.highlighted = NO;
            self.factButton.highlighted = YES;
            self.quizButton.highlighted = NO;
            break;
        case SideMenuItemQuiz:
            self.contentButton.userInteractionEnabled  = YES;
            self.factButton.userInteractionEnabled = YES;
            self.quizButton.userInteractionEnabled = NO;
            self.contentButton.highlighted = NO;
            self.factButton.highlighted = NO;
            self.quizButton.highlighted = YES;
            break;

        default:
            break;
    }
    _selectedItem = selectedItem;
}
@end
