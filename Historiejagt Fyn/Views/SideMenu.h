//
//  SideMenu.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 29/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointOfInterest.h"
typedef NS_ENUM(NSUInteger, SideMenuItem)
{
    SideMenuItemNone = 0,
    SideMenuItemContent = 1,
    SideMenuItemFacts = 2,
    SideMenuItemQuiz = 3,
};

@protocol SideMenuDelegate;

@interface SideMenu : UIView
- (void) startAnimations;
@property (nonatomic, assign) SideMenuItem selectedItem;
@property (nonatomic, weak) id<SideMenuDelegate> delegate;
@property (nonatomic, strong) PointOfInterest *poi;
@end

@protocol SideMenuDelegate <NSObject>
- (void) sideMenu:(SideMenu *) menu didSelectItem:(SideMenuItem) item;
@end