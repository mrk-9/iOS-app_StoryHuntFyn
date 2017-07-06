//
//  BaseViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 27/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "BaseViewController.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
@interface BaseViewController ()

@end

@implementation BaseViewController



- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.leftPageOffset = ((60.0f/640.0f)*[[UIScreen mainScreen] bounds].size.width);
    self.rightPageOffset = ((76.0f/640.0f)*[[UIScreen mainScreen] bounds].size.width);
    
    // Set background depending on the device type and size
//    [UIDevice executeOnIphone4:^{
//        [self.background setImage:[UIImage imageNamed:@"page-3.5"]];
//    }];
//    [UIDevice executeOnIphonesExceptIphone4:^{
//        [self.background setImage:[UIImage imageNamed:@"page-4"]];
//    }];
//    [UIDevice executeOnIpad:^{
//        [self.background setImage:[UIImage imageNamed:@"page-ipad"]];
//    }];
    [self.view addSubview:self.background];
    [self.view sendSubviewToBack:self.background];

    self.showTabBar = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.background attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.background attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.background attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.background attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    
    self.pageLeftConstraint.constant = self.leftPageOffset;
    self.pageRightConstraint.constant = self.rightPageOffset;
}

- (UIImageView *) background
{
    if (!_background)
    {
        _background = [[UIImageView alloc] init];
        _background.translatesAutoresizingMaskIntoConstraints = NO;
        _background.contentMode = UIViewContentModeScaleAspectFill;
        [UIDevice executeOnIphone4:^{
            [_background setImage:[UIImage imageNamed:@"page-3.5.png"]];
        }];
        [UIDevice executeOnIphone5:^{
            [_background setImage:[UIImage imageNamed:@"page-4.png"]];
        }];
        [UIDevice executeOnIphone6:^{
            [_background setImage:[UIImage imageNamed:@"page-4.png"]];
        }];
        [UIDevice executeOnIphone6:^{
            [_background setImage:[UIImage imageNamed:@"page-4.png"]];
        }];
        [UIDevice executeOnIpad:^{
            [_background setImage:[UIImage imageNamed:@"page-ipad"]];
        }];
    }
    return _background;
}

- (void) prepareStop {
    NSAssert(true, @"prepareStop is abstract method and must be implemented by subclass.");
}

@end
