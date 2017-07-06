//
//  DialogViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 05/02/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "DialogViewController.h"
#import "HTMLHelper.h"
#import "SoundHelper.h"
#import <Canvas/Canvas.h>
@interface DialogViewController () <UIWebViewDelegate>
@property (nonatomic, strong) UIViewController *parent;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet CSAnimationView *animationBackground;

@end

@implementation DialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    self.okButton.titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentInParentViewController:(UIViewController *)parentViewController withTitle:(NSString *) title andText:(NSString *) text andIdentifier:(NSString *) identifier
{
    //Presents the view in the parent view controller
    self.parent = parentViewController;
    self.view.frame = parentViewController.view.frame;
    self.identifier = identifier;
    self.titleLabel.text = title;
    
    NSString *content = [HTMLHelper dialogHtmlFromBodyString:text];
    [self.webView loadHTMLString:content baseURL:nil];

    
    //Adds the nutrition view to the parent view, as a child
    [parentViewController.view addSubview:self.view];
    [parentViewController addChildViewController:self];
   // self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [self.animationBackground startCanvasAnimation];
    
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [[SoundHelper sharedInstance] playTapSound];

    [self dismissFromParentViewControllerWithCompletion:^{
        if (self.delegate)
        {
            [self.delegate cancelButtonPressedAtDialogViewController:self withIdentifier:self.identifier];
        }

    }];

}

- (IBAction)okButtonTapped:(id)sender
{
    [[SoundHelper sharedInstance] playTapSound];

    [self dismissFromParentViewControllerWithCompletion:^{
        if (self.delegate)
        {
            [self.delegate okButtonPressedAtDialogViewController:self withIdentifier:self.identifier];
        }
    }];
    
    
}

- (void)dismissFromParentViewControllerWithCompletion:(void (^) ()) block
{
    
    [self willMoveToParentViewController:self.parentViewController];
    [UIView animateWithDuration:0.9 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL b){
        
        self.view.alpha = 1;
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        block();
    }];
}
@end
