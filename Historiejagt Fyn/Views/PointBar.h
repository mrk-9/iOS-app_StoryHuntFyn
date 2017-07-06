//
//  PointBar.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 15/02/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Datalayer.h"
@protocol PointBarDelegate;
@interface PointBar : UIView
- (void) updatePoints;
//@property (nonatomic, strong) NSString *routeId;
@property (nonatomic, weak) id<PointBarDelegate> delegate;
- (void) registerHasShownDialogForPointLevel:(RoutePointPercentageBlock) level forRouteWithObjectId:(NSString *) objectId;
@end

@protocol PointBarDelegate <NSObject>
@optional
- (void) pointBar:(PointBar *) pointBar registeredPointLevel:(RoutePointPercentageBlock) level forRouteWithObjectId:(NSString *) objectId;

@end