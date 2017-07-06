//
//  HOCPoiView.m
//  Created by Gert Lavsen on 14/02/15.
//  Copyright (c) 2015 House of Code. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol HOCPoiViewDelegate;
@protocol HOCPoiViewDataSource;

@interface HOCPoiView : UIView
- (instancetype) initWithSubView:(UIView *) subview identifier:(NSString *) identifier visibleWithinDistance:(CLLocationDistance) distance tapDistance:(CLLocationDistance) tapDistance;
- (void) updateDistance:(CLLocationDistance) distance minDistance:(CLLocationDistance) minDistance maxDistance:(CLLocationDistance) maxDistance;
@property (nonatomic, assign) CGFloat angle;
@property (nonatomic, readonly) CGFloat zDistance;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, readonly) BOOL visible;
@property (nonatomic, assign) BOOL locked;
@property (nonatomic, weak) id<HOCPoiViewDelegate> delegate;
@property (nonatomic, weak) id<HOCPoiViewDataSource> dataSource;
@property (nonatomic, assign) BOOL inView;
@end

@protocol HOCPoiViewDelegate <NSObject>
@optional
- (void) tappedPoiView:(HOCPoiView *) poiView;
@end

@protocol HOCPoiViewDataSource <NSObject>
- (BOOL) canTapPoiWithIdentifier:(NSString *) identifier;
@end