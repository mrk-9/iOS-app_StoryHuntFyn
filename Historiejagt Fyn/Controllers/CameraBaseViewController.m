//
//  CameraBaseViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 12/02/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "CameraBaseViewController.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
#import "PointBar.h"
@interface CameraBaseViewController ()
@end

@implementation CameraBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view sendSubviewToBack:self.background];
    [self.view addSubview:self.preview];
    [self.view addSubview:self.overlay];
    
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = self.view.bounds;

    // Set background depending on the device type and size
    [UIDevice executeOnIphone4:^{
        maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"camera-mask-3.5.png"] CGImage];
    }];
    [UIDevice executeOnIphonesExceptIphone4:^{
        maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"camera-mask-4.png"] CGImage];
    }];
    [UIDevice executeOnIpad:^{
        maskLayer.contents = (__bridge id)[[UIImage imageNamed:@"camera-mask-ipad.png"] CGImage];
    }];
   
    self.preview.layer.mask = maskLayer;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     _overlay.contentMode = UIViewContentModeScaleAspectFill;
}

- (void) updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.preview attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.preview attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.preview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.preview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.overlay attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.overlay attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.overlay attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.overlay attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    
    
}

- (UIView *) preview
{
    if (!_preview)
    {
        _preview = [[UIView alloc] initWithFrame:self.view.frame];
        _preview.translatesAutoresizingMaskIntoConstraints = NO;
      //  _preview.backgroundColor = [UIColor whiteColor];
    }
    return _preview;
}

- (UIImageView *) overlay
{
    if (!_overlay)
    {
        _overlay = [[UIImageView alloc] init];
        _overlay.translatesAutoresizingMaskIntoConstraints = NO;

        [UIDevice executeOnIphone4:^{
            [_overlay setImage:[UIImage imageNamed:@"camera-overlay-3.5.png"]];
        }];
        [UIDevice executeOnIphonesExceptIphone4:^{
            [_overlay setImage:[UIImage imageNamed:@"camera-overlay-4.png"]];
        }];
        [UIDevice executeOnIpad:^{
            [_overlay setImage:[UIImage imageNamed:@"camera-overlay-ipad.png"]];
        }];
    }
    return _overlay;
}




@end
