//
//  RouteDetailViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 26/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//
#import "SoundHelper.h"
#import "HTMLHelper.h"
#import "RouteDetailViewController.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
#import "Flurry.h"
#import "Datalayer.h"
@interface RouteDetailViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation RouteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    __block UIFont *font = [UIFont fontWithName:@"MarkerFelt-Thin" size:22];
    [UIDevice executeOnIphone5:^{
        font = [UIFont fontWithName:@"MarkerFelt-Thin" size:24];
    }];
    [UIDevice executeOnIphone4:^{
        font = [UIFont fontWithName:@"MarkerFelt-Thin" size:24];
    }];
    
    [UIDevice executeOnIphone6:^{
        font = [UIFont fontWithName:@"MarkerFelt-Thin" size:28];
    }];
    
    [UIDevice executeOnIphone6Plus:^{
        font = [UIFont fontWithName:@"MarkerFelt-Thin" size:30];
    }];
    [UIDevice executeOnIpad:^{
        font = [UIFont fontWithName:@"MarkerFelt-Thin" size:34];
    }];
    [self.titleLabel setFont:font];

    self.webView.delegate = self;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    [self.webView.scrollView flashScrollIndicators];
    self.showTabBar = NO;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.route)
    {
        // Send the name of the current route along as parameters to Flurry
        NSDictionary *flurryParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                      self.route.name, @"Rutenavn",
                                      nil
                                      ];
        
        [Flurry logEvent:kFlurryShowRouteDetailViewEventName withParameters:flurryParams timed:YES];

        __block UIFont *font = nil;
        [UIDevice executeOnIphone5:^{
            font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        }];
        [UIDevice executeOnIphone4:^{
            font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        }];
        
        [UIDevice executeOnIphone6:^{
            font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        }];
        
        [UIDevice executeOnIphone6Plus:^{
            font = [UIFont fontWithName:@"HelveticaNeue" size:18];
        }];
        [UIDevice executeOnIpad:^{
            font = [UIFont fontWithName:@"HelveticaNeue" size:24];
        }];
        
        self.titleLabel.text = self.route.name;
        [self.avatarImageView setImage:[UIImage imageWithData:[self.route.avatar objectAtIndex:0]]];
        //UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 24 : 14];
        NSString *text = [HTMLHelper htmlFromBodyString:self.route.info textFont:font textColor:[UIColor blackColor]];
        [self.webView loadHTMLString:text baseURL:nil];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.webView.scrollView flashScrollIndicators];
    [self.webView.scrollView flashScrollIndicators];
    self.webView.scrollView.showsVerticalScrollIndicator = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) backTapped:(id)sender
{
    [Flurry endTimedEvent:kFlurryShowRouteDetailViewEventName withParameters:nil];
   // NSLog(@"BACK");
    [self.delegate viewController:self requestsShowing:ViewControllerItemRoutes];
}

- (IBAction) mapTapped:(id)sender
{
    [Flurry endTimedEvent:kFlurryShowRouteDetailViewEventName withParameters:nil];
    [self.delegate viewController:self requestsShowing:ViewControllerItemMap withUserInfo:@{@"route" : self.route.objectId}];
}
- (void) prepareStop
{
    
}
@end
