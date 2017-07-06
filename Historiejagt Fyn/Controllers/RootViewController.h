//
//  RootViewController.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 25/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface RootViewController : UIViewController
@property (nonatomic, assign) BOOL showTabBar;
@property (nonatomic, strong) NSString *activeRoute;
@end

