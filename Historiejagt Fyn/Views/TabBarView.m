//
//  TabBarView.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 24/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "TabBarView.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
#import "SoundHelper.h"
#define kDisabledTabBarItemColor [UIColor colorWithRed:134.0f/255.0f green:134.0f/255.0f blue:134.0f/255.0f alpha:1.0]
@interface TabBarView()
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat buttonHeight;
@property (nonatomic, assign) CGFloat buttonWidth;
@property (nonatomic, assign) CGFloat topInsert;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat distance;

@property (nonatomic, strong) UIImageView *background;
@property (nonatomic, strong) UIButton *routesButton;
@property (nonatomic, strong) UIButton *mapButton;
@property (nonatomic, strong) UIButton *arButton;
@property (nonatomic, strong) UIButton *scanButton;
@property (nonatomic, strong) UILabel *routesLabel;
@property (nonatomic, strong) UILabel *mapLabel;
@property (nonatomic, strong) UILabel *arLabel;
@property (nonatomic, strong) UILabel *scanLabel;
@end
@implementation TabBarView
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
    [UIDevice executeOnIphone:^{
        self.width = 252;
        self.height = 79;
        self.topInsert = 35;
        self.buttonHeight = 32;
        self.buttonWidth = 36;
        self.top = 20.5;
        self.left = 19.5;
        self.distance = 22;
    }];
    [UIDevice executeOnIpad:^{
        self.width = 352;
        self.height = 119;
        self.topInsert = 35;
        self.buttonHeight = 48;
        self.buttonWidth = 60;
        self.top = 25;
        self.left = 19.5;
        self.distance = 22;
    }];
    
    self.selected = ViewControllerItemRoutes;
    
    [self addSubview:self.background];
    [self addSubview:self.routesButton];
    [self addSubview:self.mapButton];
    [self addSubview:self.arButton];
    [self addSubview:self.scanButton];
    [self addSubview:self.routesLabel];
    [self addSubview:self.mapLabel];
    [self addSubview:self.arLabel];
    [self addSubview:self.scanLabel];
    [self selectItem:self.selected];
    [self updateConstraints];
}

- (void) updateConstraints
{
    [super updateConstraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.background
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0
                                                      constant:self.height]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.background
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0
                                                      constant:self.width]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.background
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.background
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.routesButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0
                                                      constant:self.buttonHeight]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mapButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0
                                                      constant:self.buttonHeight]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0
                                                      constant:self.buttonHeight]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scanButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0
                                                      constant:self.buttonHeight]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.routesButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0
                                                      constant:self.buttonWidth]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mapButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0
                                                      constant:self.buttonWidth]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0
                                                      constant:self.buttonWidth]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scanButton
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0
                                                      constant:self.buttonWidth]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.routesButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:self.top]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mapButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:self.top]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:self.top]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scanButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:self.top]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.routesButton
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:self.left]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mapButton
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.routesButton
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0
                                                      constant:self.distance]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arButton
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.mapButton
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0
                                                      constant:self.distance]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scanButton
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.arButton
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0
                                                      constant:self.distance]];


    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.routesLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.routesButton
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mapLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.mapButton
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.arButton
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scanLabel
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.scanButton
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.routesLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.routesButton
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.mapLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.mapButton
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.arLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.arButton
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scanLabel
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.scanButton
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];
    
}


- (IBAction)selectButton:(id)sender
{
    //[[SoundHelper sharedInstance] playTapSound];
    ViewControllerItems selected = ViewControllerItemNone;
    if (sender == self.routesButton)
    {
        selected = ViewControllerItemRoutes;
    }
    else if (sender == self.mapButton)
    {
        selected = ViewControllerItemMap;
    }
    else if (sender == self.arButton)
    {
        selected = ViewControllerItemAr;
    }
    else if (sender == self.scanButton)
    {
        selected = ViewControllerItemScan;
    }
    [self selectItem:selected];
    if (self.delegate)
    {
        [self.delegate tabBarView:self selectedItem:selected];
    }
}


- (IBAction)selectItem:(ViewControllerItems) item
{
    if (item == ViewControllerItemRoutes)
    {
        self.routesButton.enabled = NO;
        self.mapButton.enabled = YES;
        self.arButton.enabled = YES;
        self.scanButton.enabled = YES;
        self.routesLabel.textColor = [UIColor blackColor];
        self.mapLabel.textColor = kDisabledTabBarItemColor;
        self.arLabel.textColor = kDisabledTabBarItemColor;
        self.scanLabel.textColor = kDisabledTabBarItemColor;
    }
    else if (item == ViewControllerItemMap)
    {
        self.routesButton.enabled = YES;
        self.mapButton.enabled = NO;
        self.arButton.enabled = YES;
        self.scanButton.enabled = YES;
        self.routesLabel.textColor = kDisabledTabBarItemColor;
        self.mapLabel.textColor = [UIColor blackColor];
        self.arLabel.textColor = kDisabledTabBarItemColor;
        self.scanLabel.textColor = kDisabledTabBarItemColor;
    }
    else if (item == ViewControllerItemAr)
    {
        self.routesButton.enabled = YES;
        self.mapButton.enabled = YES;
        self.arButton.enabled = NO;
        self.scanButton.enabled = YES;
        self.routesLabel.textColor = kDisabledTabBarItemColor;
        self.mapLabel.textColor = kDisabledTabBarItemColor;
        self.arLabel.textColor = [UIColor blackColor];
        self.scanLabel.textColor = kDisabledTabBarItemColor;
    }
    else if (item == ViewControllerItemScan)
    {
        self.routesButton.enabled = YES;
        self.mapButton.enabled = YES;
        self.arButton.enabled = YES;
        self.scanButton.enabled = NO;
        self.routesLabel.textColor = kDisabledTabBarItemColor;
        self.mapLabel.textColor = kDisabledTabBarItemColor;
        self.arLabel.textColor = kDisabledTabBarItemColor;
        self.scanLabel.textColor = [UIColor blackColor];
    }
}

- (void) setSelected:(ViewControllerItems) selected
{
    _selected = selected;
    [self selectItem:_selected];
}

- (UIImageView *) background
{
    if (!_background)
    {
        [UIDevice executeOnIphone:^{
            _background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar.png"]];
        }];
        [UIDevice executeOnIpad:^{
        _background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabbar-ipad.png"]];
        }];
        _background.translatesAutoresizingMaskIntoConstraints = NO;
        _background.contentMode = UIViewContentModeScaleToFill;
    }
    return _background;
}

- (UILabel *) routesLabel
{
    if (!_routesLabel)
    {
        _routesLabel = [[UILabel alloc] init];
        _routesLabel.text = NSLocalizedString(@"Ruter", @"Text for routes button in tabbar");
        _routesLabel.textColor = kDisabledTabBarItemColor;
        _routesLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:IS_IPAD ? 20 : 12];
        _routesLabel.textAlignment = NSTextAlignmentCenter;
        _routesLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _routesLabel.transform = CGAffineTransformMakeRotation( -M_PI/32 );
    }
    return _routesLabel;
}

- (UILabel *) mapLabel
{
    if (!_mapLabel)
    {
        _mapLabel = [[UILabel alloc] init];
        _mapLabel.text = NSLocalizedString(@"Kort", @"Text for map button in tabbar");
        _mapLabel.textColor = kDisabledTabBarItemColor;
        _mapLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:IS_IPAD ? 20 : 12];
        _mapLabel.textAlignment = NSTextAlignmentCenter;
        _mapLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _mapLabel.transform = CGAffineTransformMakeRotation( M_PI/32 );
    }
    return _mapLabel;
}

- (UILabel *) arLabel
{
    if (!_arLabel)
    {
        _arLabel = [[UILabel alloc] init];
        _arLabel.text = NSLocalizedString(@"AR View", @"Text for ar button in tabbar");
        _arLabel.textColor = kDisabledTabBarItemColor;
        _arLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:IS_IPAD ? 20 : 12];
        _arLabel.textAlignment = NSTextAlignmentCenter;
        _arLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _arLabel.transform = CGAffineTransformMakeRotation( -M_PI/32 );
    }
    return _arLabel;
}

- (UILabel *) scanLabel
{
    if (!_scanLabel)
    {
        _scanLabel = [[UILabel alloc] init];
        _scanLabel.text = NSLocalizedString(@"Scan", @"Text for scan button in tabbar");
        _scanLabel.textColor = kDisabledTabBarItemColor;
        _scanLabel.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:IS_IPAD ? 20 : 12];
        _scanLabel.textAlignment = NSTextAlignmentCenter;
        _scanLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _scanLabel.transform = CGAffineTransformMakeRotation( M_PI/32 );
    }
    return _scanLabel;
}


- (UIButton *) routesButton
{
    if (!_routesButton)
    {
        _routesButton = [[UIButton alloc] init];
        _routesButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_routesButton setImage:[UIImage imageNamed:IS_IPAD ? @"book-active.png" :@"book-active.png"] forState:UIControlStateSelected];
        [_routesButton setImage:[UIImage imageNamed:IS_IPAD ? @"book-inactive.png" :@"book-inactive.png"] forState:UIControlStateNormal];
        [_routesButton setImage:[UIImage imageNamed:IS_IPAD ? @"book-active.png" :@"book-active.png"] forState:UIControlStateDisabled];
        [_routesButton addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        //_routesButton.layer.borderColor = [[UIColor redColor] CGColor];
        //_routesButton.layer.borderWidth = 1;
    }
    return _routesButton;
}

- (UIButton *) mapButton
{
    if (!_mapButton)
    {
        _mapButton = [[UIButton alloc] init];
        _mapButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_mapButton setImage:[UIImage imageNamed:IS_IPAD ? @"map-active.png" :@"map-active.png"] forState:UIControlStateSelected];
        [_mapButton setImage:[UIImage imageNamed:IS_IPAD ? @"map-inactive.png" :@"map-inactive.png"] forState:UIControlStateNormal];
        [_mapButton setImage:[UIImage imageNamed:IS_IPAD ? @"map-active.png" :@"map-active.png"] forState:UIControlStateDisabled];
        [_mapButton addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        //_mapButton.layer.borderColor = [[UIColor redColor] CGColor];
        //_mapButton.layer.borderWidth = 1;
    }
    return _mapButton;
}

- (UIButton *) arButton
{
    if (!_arButton)
    {
        _arButton = [[UIButton alloc] init];
        _arButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_arButton setImage:[UIImage imageNamed:IS_IPAD ? @"binoculars-active.png" :@"binoculars-active.png"] forState:UIControlStateSelected];
        [_arButton setImage:[UIImage imageNamed:IS_IPAD ? @"binoculars-inactive.png" :@"binoculars-inactive.png"] forState:UIControlStateNormal];
        [_arButton setImage:[UIImage imageNamed:IS_IPAD ? @"binoculars-active.png" : @"binoculars-active.png"] forState:UIControlStateDisabled];
        [_arButton addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        //_arButton.layer.borderColor = [[UIColor redColor] CGColor];
        //_arButton.layer.borderWidth = 1;
    }
    return _arButton;
}

- (UIButton *) scanButton
{
    if (!_scanButton)
    {
        _scanButton = [[UIButton alloc] init];
        _scanButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_scanButton setImage:[UIImage imageNamed:IS_IPAD ? @"camera-active-ipad.png": @"camera-active.png"] forState:UIControlStateSelected];
        [_scanButton setImage:[UIImage imageNamed:IS_IPAD ? @"camera-inactive-ipad.png": @"camera-inactive.png"] forState:UIControlStateNormal];
        [_scanButton setImage:[UIImage imageNamed:IS_IPAD ? @"camera-active-ipad.png": @"camera-active.png"] forState:UIControlStateDisabled];
        [_scanButton addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        //_scanButton.layer.borderColor = [[UIColor redColor] CGColor];
        //_scanButton.layer.borderWidth = 1;
    }
    return _scanButton;
}

- (void) setHiddenAnimated:(BOOL) hide
{
    [self setHiddenAnimated:hide completion:nil];
}

- (void) setHiddenAnimated:(BOOL) hide completion:(void (^)()) completion
{
    [self setHiddenAnimated:hide duration:0.5 completion:completion];
}

-(void)setHiddenAnimated:(BOOL)hide duration:(NSTimeInterval)duration completion:(void (^)()) completion
{
    if (self.hidden == hide)
    {
        return;
    }
    if (hide)
    {
        self.alpha = 1;
    }
    else
    {
        self.alpha = 0;
        self.hidden = NO;
    }
    [UIView animateWithDuration:duration animations:^
    {
        if (hide)
        {
            self.alpha = 0;
        }
        else
        {
            self.alpha = 1;
        }
    } completion:^(BOOL finished)
    {
        if (finished)
        {
            self.hidden = hide;
        }
        if (completion)
        {
            completion();
        }
    }];
}


@end
