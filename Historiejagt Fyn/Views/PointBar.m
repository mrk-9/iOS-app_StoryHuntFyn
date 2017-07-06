//
//  PointBar.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 15/02/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "PointBar.h"
#import <TYMProgressBarView/TYMProgressBarView.h>
#import "Datalayer.h"
#import "datalayernotificationsstrings.h"
#import "SoundHelper.h"
@interface PointBar()
@property (nonatomic, assign) RoutePointPercentageBlock activeRoutePercentage;
@property (nonatomic, assign) float percentage;
@property (nonatomic, strong) TYMProgressBarView *progressBar;
@property (nonatomic, strong) NSString *routePointId;
@end

@implementation PointBar

@synthesize routePointId = _routePointId;
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

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setup
{

  //  NSLog(@"setup");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pointOfInterestFound:) name:kDatalayerPointOfInterestFound object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pointOfInterestFound:) name:kDatalayerPointOfInterestClickedManually object:nil];
    self.backgroundColor  = [UIColor clearColor];
    [self addSubview:self.progressBar];
    [self updateConstraints];
}

- (void) updateConstraints
{
 //   NSLog(@"update constraints");
    [super updateConstraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressBar attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressBar attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.progressBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
}

- (void) pointOfInterestFound:(NSNotification *) note
{
//
    NSLog(@"point of interest found: %@", note);
    NSString *poiId = [note.userInfo valueForKey:@"pointOfInterest"];
    if (!poiId)
    {
        NSLog(@"point of interest found without poi id");
        return;
    }
    NSString *rpId = [[Datalayer sharedInstance] pointOfInterestBelongsToPointSystem:poiId];
    if (!rpId)
    {
        NSLog(@"point of interest found not belong to a point system");
        return;
    }
    
    [[SoundHelper sharedInstance] playGetPointSound];
    
    if (![rpId isEqualToString:self.routePointId])
    {
        NSLog(@"point of interest found belonging to another route point system: %@", rpId);
        self.routePointId = rpId;
    }
    

    self.percentage = [[Datalayer sharedInstance] calculatePercentageCompletedForRouteWithObjectId:self.routePointId];
    
    [self checkForPoint];
}

- (void) registerHasShownDialogForPointLevel:(RoutePointPercentageBlock) level forRouteWithObjectId:(NSString *) objectId
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setBool:YES forKey:[NSString stringWithFormat:@"dialog_shown_%ld_%@", (unsigned long)level, objectId]];
    [def synchronize];
}


- (TYMProgressBarView *) progressBar
{
    if (!_progressBar)
    {
        _progressBar = [[TYMProgressBarView alloc] init];
        _progressBar.translatesAutoresizingMaskIntoConstraints = NO;
        [_progressBar setBarBackgroundColor:[UIColor whiteColor]];
        [_progressBar setBarBorderWidth:1.0f];
        [_progressBar setBarFillColor:[UIColor colorWithRed:162.0f/255.0f green:59.0f/255.0f blue:63.0f/255.0f alpha:1.0f]];
        [_progressBar setBarInnerBorderWidth:0.0f];
        [_progressBar setBarInnerPadding:0.0f];
        [_progressBar setBarBorderColor:[UIColor grayColor]];
        [_progressBar setProgress:0.0f];
        [_progressBar setHidden:YES];
    }
    return _progressBar;
}

- (void) updatePoints
{
 //   NSLog(@"Update point bar");
    self.percentage = [[Datalayer sharedInstance] calculatePercentageCompletedForRouteWithObjectId:self.routePointId];
    self.activeRoutePercentage = [[Datalayer sharedInstance] percentageBlockForPercentage:self.percentage];
    [self checkForPoint];
}

- (void) setPercentage:(float)percentage
{
    
  //  NSLog(@"setPercentage: %f", percentage);
    _percentage = percentage;
    [self.progressBar setProgress:_percentage];
    [self.progressBar setHidden:(self.percentage <= 0.0f)];
}

- (void) setActiveRoutePercentage:(RoutePointPercentageBlock) activeRoutePercentage
{
    _activeRoutePercentage = activeRoutePercentage;
    
//    NSLog(@"setActiveRoutePercentage: %lu", activeRoutePercentage);
    
    //[self.progressbar setHidden:(_activeRoutePercentage == kPercentage0)];
    [self.progressBar setHidden:(self.percentage <= 0.0f)];
}

/*!
 *  Check if route point has changed and if new point block is reached - call delegate
 */
-  (void) checkForPoint
{
    NSLog(@"Check for points");
    // Only do it if a route is active
    if (self.routePointId)
    {
    //    NSLog(@"Route sat");
        // Keep old percentage for comparision
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        RoutePointPercentageBlock oldActiveRoutePercentage = (RoutePointPercentageBlock)[defaults integerForKey:[NSString stringWithFormat:@"routePoint-%@", self.routePointId]];
        // Get new percentage
        self.activeRoutePercentage = [[Datalayer sharedInstance] percentageCompletedForRouteWithObjectId:self.routePointId];
        BOOL callDelegate = NO;
        if ((oldActiveRoutePercentage != self.activeRoutePercentage) && self.activeRoutePercentage > kPercentage0)
        {
            [defaults setInteger:self.activeRoutePercentage forKey:[NSString stringWithFormat:@"routePoint-%@", self.routePointId]];
            [defaults synchronize];
            callDelegate  =YES;
        }
        else
        {
            callDelegate = ![[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"dialog_shown_%ld_%@", (unsigned long)self.activeRoutePercentage, self.routePointId]];
        }
        if (callDelegate)
        {
            if (self.delegate)
            {
              //  NSLog(@"YO YO");
                [self.delegate pointBar:self registeredPointLevel:self.activeRoutePercentage forRouteWithObjectId:self.routePointId];
            }
        }
    }
}

- (NSString *) routePointId
{
    if (!_routePointId)
    {
        _routePointId = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastActiveRoutePointSystem"];
    }
    return _routePointId;
}

- (void) setRoutePointId:(NSString *)routePointId
{
    _routePointId = routePointId;
    [[NSUserDefaults standardUserDefaults] setObject:routePointId forKey:@"lastActiveRoutePointSystem"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
