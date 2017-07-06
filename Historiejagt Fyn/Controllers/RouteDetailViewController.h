//
//  RouteDetailViewController.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 26/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Route.h"
#import "BaseViewController.h"
@interface RouteDetailViewController : BaseViewController
@property (nonatomic, strong) Route *route;
@end
