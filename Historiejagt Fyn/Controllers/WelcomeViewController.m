//
//  WelcomeViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 23/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//
#import "SoundHelper.h"
#import "WelcomeViewController.h"
#import "Datalayer.h"
#import "datalayernotificationsstrings.h"
#import "Info.h"
#import "HTMLHelper.h"
#import <MOGOpenBookSegue/MOGOpenBookSegue.h>
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
#import "Flurry.h"
@interface WelcomeViewController() <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textHeightContstraint;


@end
@implementation WelcomeViewController
- (void) viewDidLoad
{
    [super viewDidLoad];
    [Flurry logEvent:kFlurryShowWelcomeViewEventName timed:YES];

    // Set font size depending on device type
    __block UIFont *font = nil;
    [UIDevice executeOnIphone5:^{
        font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    }];
    [UIDevice executeOnIphone4:^{
        font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    }];
    
    [UIDevice executeOnIphone6:^{

        font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    }];
    
    [UIDevice executeOnIphone6Plus:^{
        font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    }];
    [UIDevice executeOnIpad:^{
        font = [UIFont fontWithName:@"HelveticaNeue" size:24];
    }];

    
    // Set webview
    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;

    NSString *text = [HTMLHelper htmlFromBodyString:[[[Datalayer sharedInstance] info] text] textFont:font textColor:[UIColor blackColor]];
    //NSLog(@"TEXT: %@", text);
    [self.webView loadHTMLString:text baseURL:nil];

    // Set title
    self.titleLabel.text = [[[Datalayer sharedInstance] info] title];
}

- (void) updateViewConstraints
{
    [super updateViewConstraints];
    
    self.textHeightContstraint.constant += 10;

}

- (IBAction)continueTapped:(id)sender
{
    //[[SoundHelper sharedInstance] playTapSound];
    if (self.delegate)
    {
        [Flurry endTimedEvent:kFlurryShowWelcomeViewEventName withParameters:nil];
        [self.delegate viewController:self requestsShowing:ViewControllerItemRoutes withUserInfo:nil];
    }
}

- (void) prepareStop
{
    
}

@end
