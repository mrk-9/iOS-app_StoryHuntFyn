//
//  HOCARView.h
//  Created by Gert Lavsen on 14/02/15.
//  Copyright (c) 2015 House of Code. All rights reserved.


#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "HOCPoiView.h"
@protocol HOCARViewDatasource;

@interface HOCARView : UIView < CLLocationManagerDelegate>

@property (nonatomic, readonly) CLLocation *currentLocation;
@property (nonatomic, strong) NSArray *pois;
@property (nonatomic, weak) id<HOCARViewDatasource> datasource;
- (void)start;
- (void)stop;
@end

@protocol HOCARViewDatasource <NSObject>
@required
- (HOCPoiView *) viewForPoiWithIdentifier:(NSString *) identifier;
@end
