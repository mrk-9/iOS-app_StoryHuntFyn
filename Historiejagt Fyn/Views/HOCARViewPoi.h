//
//  HOCARViewPoi.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 14/02/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@protocol HOCARViewPoi <NSObject>
@required
@property (nonatomic, readonly) NSString *arIdentifier;
@property (nonatomic, readonly) CLLocation *arLocation;
@property (nonatomic, assign) CLLocationDistance arMaxDistance;
@end
