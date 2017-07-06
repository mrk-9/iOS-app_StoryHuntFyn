//
//  AlertViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 27/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "AlertViewController.h"
#import "SoundHelper.h"
#import <Canvas/Canvas.h>
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
@interface AlertViewController ()
@property (nonatomic, strong) UIViewController *parent;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (weak, nonatomic) IBOutlet CSAnimationView *animationBackground;
@end

@implementation AlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentInParentViewController:(UIViewController *)parentViewController withTitle:(NSString *) title andText:(NSString *) text
{
    [self presentInParentViewController:parentViewController withTitle:title andText:text andUserInfo:nil andIdentifier:nil];
}
- (void)presentInParentViewController:(UIViewController *)parentViewController withTitle:(NSString *) title andText:(NSString *) text andIdentifier:(NSString *) identifier
{
    [self presentInParentViewController:parentViewController withTitle:title andText:text andUserInfo:nil andIdentifier:identifier];
}
- (void)presentInParentViewController:(UIViewController *)parentViewController withTitle:(NSString *) title andText:(NSString *) text andUserInfo:(NSDictionary *) userInfo andIdentifier:(NSString *) identifier
{
    //Presents the view in the parent view controller
    self.parent = parentViewController;
    self.view.frame = parentViewController.view.frame;
    self.identifier = identifier;
    self.userInfo = userInfo;
    self.titleLabel.text = title;
    self.textView.text = text;
    
    [UIDevice executeOnIpad:^{
        self.textView.font = [UIFont systemFontOfSize:20];
    }];
    
    //Adds the nutrition view to the parent view, as a child
    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];
   // self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [self.animationBackground startCanvasAnimation];
    
}


- (IBAction)close:(id)sender
{
    //The close button
    [[SoundHelper sharedInstance] playTapSound];
    [self dismissFromParentViewController];
    
    
}

- (void)dismissFromParentViewController
{
    
    [self willMoveToParentViewController:self.parentViewController];
    [UIView animateWithDuration:0.9 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        
        self.view.alpha = 1;
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        if (self.delegate)
        {
            [self.delegate buttonPressedAtAlertViewController:self];
        }
    }];
}

@end
