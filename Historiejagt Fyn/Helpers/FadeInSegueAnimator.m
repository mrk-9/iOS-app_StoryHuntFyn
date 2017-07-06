//
//  FadeInSegueAnimator.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 07/06/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "FadeInSegueAnimator.h"

@implementation FadeInSegueAnimator

- (void) perform
{
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;

    [sourceViewController.view addSubview:destinationViewController.view];
    destinationViewController.view.alpha = 0.0f;
    [UIView animateWithDuration:0.3f animations:^{
        destinationViewController.view.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [destinationViewController.view removeFromSuperview];
        [[self sourceViewController] presentViewController:[self destinationViewController] animated:NO completion:nil];
    }];
    
//    CATransition *transition = [CATransition animation];
//    transition.duration = 0.2;
//    transition.type = kCATransitionFade;
//    
//    [[[[[self sourceViewController] view] window] layer] addAnimation:transition
//                                                               forKey:kCATransitionFade];
//    
//    [[self sourceViewController]
//     presentViewController:[self destinationViewController]
//     animated:NO completion:NULL];
}

@end
