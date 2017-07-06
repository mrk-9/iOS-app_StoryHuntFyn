//
//  LogoSplashViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 07/06/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "LogoSplashViewController.h"
#import "AppDelegate.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
#import "Flurry.h"
#import <Canvas/Canvas.h>
@interface LogoSplashViewController ()
@property (weak, nonatomic) IBOutlet CSAnimationView *animationView;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;

@end

@implementation LogoSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIDevice executeOnIphone4:^{
        // NSLog(@"Image set on iphone 4");
        [self.coverImage setImage:[UIImage imageNamed:@"Splash-iPhone4.png"]];
    }];
    [UIDevice executeOnIphone5:^{
        // NSLog(@"Image set on iphone 5");
        
        [self.coverImage setImage:[UIImage imageNamed:@"Splash-iPhone5.png"]];
    }];
    [UIDevice executeOnIphone6:^{
        [self.coverImage setImage:[UIImage imageNamed:@"Splash-iPhone6.png"]];
    }];
    [UIDevice executeOnIphone6Plus:^{
        [self.coverImage setImage:[UIImage imageNamed:@"Splash-iPhone6Plus.png"]];
    }];
    [UIDevice executeOnIpad:^{
        [self.coverImage setImage:[UIImage imageNamed:@"Splash-iPad.png"]];
    }];
    self.view.backgroundColor = [UIColor blackColor];
    [Flurry startSession:@"5TFQVVJ2XYWH4Q6FY59F"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
        [self.animationView startCanvasAnimation];
        [self performSelector:@selector(continueLoad) withObject:nil afterDelay:4.5f];
}

- (void) continueLoad
{
    [self performSegueWithIdentifier:@"logoSplashDone" sender:self];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
