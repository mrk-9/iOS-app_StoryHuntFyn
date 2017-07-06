//
//  TabBarView.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 24/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"
//typedef NS_ENUM(NSUInteger, TabBarViewItem)
//{
//    TabBarViewNonSelected = 0,
//    TabBarViewRoutesItemSelected = 1,
//    TabBarViewMapItemSelected = 2,
//    TabBarViewArItemSelected = 3,
//    TabBarViewScanItemSelected = 4,
//};

@protocol TarBarViewDelegate;
@interface TabBarView : UIView
@property (nonatomic, assign) ViewControllerItems selected;
@property (nonatomic, weak) id<TarBarViewDelegate> delegate;
-(void)setHiddenAnimated:(BOOL)hide duration:(NSTimeInterval)duration completion:(void (^)()) completion;
-(void)setHiddenAnimated:(BOOL)hide completion:(void (^)()) completion;
-(void)setHiddenAnimated:(BOOL)hide;
@end

@protocol TarBarViewDelegate <NSObject>
- (void) tabBarView:(TabBarView *)tabBarView selectedItem:(ViewControllerItems) item;
@end