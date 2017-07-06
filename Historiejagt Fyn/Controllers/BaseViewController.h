//
//  BaseViewController.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 27/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
//! View controllers to handle
typedef NS_ENUM(NSUInteger, ViewControllerItems)
{
    ViewControllerItemNone = 0,
    
    ViewControllerItemRoutes = 1,
    ViewControllerItemMap = 2,
    ViewControllerItemAr = 3,
    ViewControllerItemScan = 4,
    
    ViewControllerItemWelcome = 5,
    ViewControllerItemRouteDetail = 6,
    ViewControllerItemInfo = 7,
    ViewControllerItemFacts = 8,
    ViewControllerItemQuiz = 9,
    ViewControllerItemMapSettings = 10,
};

@protocol RootViewControllerDelegate;
@interface BaseViewController : UIViewController
@property (nonatomic, strong) UIImageView *background;
@property (nonatomic, weak) id<RootViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL showTabBar;
@property (nonatomic, assign) CGFloat leftPageOffset;
@property (nonatomic, assign) CGFloat rightPageOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageLeftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pageRightConstraint;
- (void) prepareStop;
@end


@protocol RootViewControllerDelegate <NSObject>
//- (void) viewController:(BaseViewController *) fromController requestsShowing:(BaseViewController *) toViewController tabBarVisible:(BOOL) visible;
- (void) viewController:(BaseViewController *) fromController requestsShowing:(ViewControllerItems ) item;
- (void) viewController:(BaseViewController *) fromController requestsShowing:(ViewControllerItems ) item withUserInfo:(NSDictionary *) userInfo;
@end