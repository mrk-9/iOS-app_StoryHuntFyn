//
//  DialogViewController.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 05/02/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DialogViewControllerDelegate;
@interface DialogViewController : UIViewController

- (void)presentInParentViewController:(UIViewController *)parentViewController withTitle:(NSString *) title andText:(NSString *) text andIdentifier:(NSString *) identifier;
@property (nonatomic, weak) id<DialogViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *identifier;
@end

@protocol DialogViewControllerDelegate <NSObject>
- (void) okButtonPressedAtDialogViewController:(DialogViewController *) vc withIdentifier:(NSString *) identifier;
@optional
- (void) cancelButtonPressedAtDialogViewController:(DialogViewController *) vc withIdentifier:(NSString *) identifier;
@end