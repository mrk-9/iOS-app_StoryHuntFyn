//
//  HOCPoiView.m
//  Created by Gert Lavsen on 14/02/15.
//  Copyright (c) 2015 House of Code. All rights reserved.
//

#import "HOCPoiView.h"
#define kDistanceNear 10.0
#define kDistanceIntermediate 50.0
#define kDistanceFar 200.0
#define kDistanceFarAway 1000.0
#define kDistanceHide 2000.0

@interface HOCPoiView()
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CLLocationDistance visibleDistance;
@property (nonatomic, assign) CLLocationDistance distance;
@property (nonatomic, assign) CLLocationDistance maxDistance;
@property (nonatomic, assign) CLLocationDistance minDistance;
@property (nonatomic, assign) CLLocationDistance tapDistance;

@end
@implementation HOCPoiView

- (instancetype) initWithSubView:(UIView *) subview identifier:(NSString *) identifier visibleWithinDistance:(CLLocationDistance) distance tapDistance:(CLLocationDistance)tapDistance
{
    self = [super init];
    
    if (self)
    {
        self.inView = NO;
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
        [self addGestureRecognizer:gestureRecognizer];
        self.tapDistance = tapDistance;
        self.visibleDistance = distance;
        self.identifier = identifier;
        CGRect frame = subview.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        subview.frame = frame;
        frame.origin = self.frame.origin;
        self.frame = frame;
        [self addSubview:subview];
        self.backgroundColor  = [UIColor clearColor];
        subview.layer.shadowColor = [UIColor blackColor].CGColor;
        subview.layer.shadowOffset = CGSizeMake(1, 1);
        subview.layer.masksToBounds = NO;
        subview.layer.shadowRadius = 10;
        subview.layer.shadowOpacity = 0.3;
        self.clipsToBounds = NO;
        subview.clipsToBounds = NO;
        
    }
    
    return self;
}

- (void) adjustView
{
    CGAffineTransform rotate = CGAffineTransformRotate(CGAffineTransformIdentity, -self.angle);
    CGAffineTransform scale = CGAffineTransformScale(CGAffineTransformIdentity,self.scale, self.scale);
    CGAffineTransform rotateAndScale = CGAffineTransformConcat( rotate, scale );
    [self setTransform:rotateAndScale];
    [self setNeedsDisplay];
}

- (void) setAngle:(CGFloat) angle
{
    if (fabs(_angle-angle) > 0.2)
    {
        //NSLog(@"Angle: %f", angle);
        
        [self adjustView];

    }
    _angle = angle;
    
}
#define DISTANCE_CLIP_FAR 2000
#define DISTANCE_CLIP_NEAR 10
- (void) updateDistance:(CLLocationDistance) distance minDistance:(CLLocationDistance) minDistance maxDistance:(CLLocationDistance) maxDistance
{
    self.maxDistance = MIN(maxDistance, DISTANCE_CLIP_FAR);
    self.minDistance = minDistance;
    self.distance = distance; // MIN(distance, self.maxDistance);
    CGFloat delta = maxDistance-minDistance;
    if (delta < 1)
    {
        self.scale = 1;
    }
    else
    {
        self.scale = (maxDistance-distance) / delta;
    }
    if (self.scale < 0.3)
    {
        self.scale  = 0;
    }
    [self adjustView];

}

- (CGFloat) zDistance
{
    CGFloat delta = MAX(self.maxDistance - self.minDistance, 1);
    return (self.maxDistance - self.distance) / delta;
}


- (void) tapped
{
    BOOL canBeTapped = YES;
    if (self.dataSource)
    {
        canBeTapped = [self.dataSource canTapPoiWithIdentifier:self.identifier];
    }
    //NSLog(@"Tapped: %d %d %f %f", self.locked, self.visible, self.visibleDistance, self.distance);
    if ((canBeTapped || self.tapDistance > self.distance ) && !self.hidden && self.visible && self.inView)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tappedPoiView:)])
        {
            [self.delegate tappedPoiView:self];
        }
    }
}

- (BOOL) visible
{
    //NSLog(@"Vissible Distance: %f > %f = %d", self.visibleDistance, self.distance, ((self.visibleDistance > self.distance) && !self.locked));
    return ((self.visibleDistance > self.distance) && !self.locked);
}

@end
