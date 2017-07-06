//
//  AlertViewController.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 27/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AlertViewControllerDelegate;
@interface AlertViewController : UIViewController
- (void)presentInParentViewController:(UIViewController *)parentViewController withTitle:(NSString *) title andText:(NSString *) text andUserInfo:(NSDictionary *) userInfo andIdentifier:(NSString *) identifier;
- (void)presentInParentViewController:(UIViewController *)parentViewController withTitle:(NSString *) title andText:(NSString *) text andIdentifier:(NSString *) identifier;
- (void)presentInParentViewController:(UIViewController *)parentViewController withTitle:(NSString *) title andText:(NSString *) text;
@property (nonatomic, weak) id<AlertViewControllerDelegate> delegate;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSString *identifier;
@end

@protocol AlertViewControllerDelegate <NSObject>
- (void) buttonPressedAtAlertViewController:(AlertViewController *) vc;
@end
