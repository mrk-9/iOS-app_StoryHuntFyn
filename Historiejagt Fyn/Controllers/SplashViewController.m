//
//  SplashViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 21/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//
//#import "AppDelegate.h"
#import "SplashViewController.h"
#import "Datalayer.h"
#import "datalayernotificationsstrings.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
#import <MOGOpenBookSegue/MOGOpenBookSegue.h>
#import "PaperToast.h"
#import "SoundHelper.h"
#import "StoryboardHelper.h"
#import "AlertViewController.h"

@interface SplashViewController() <AlertViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *toastContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *biasedCenterContraint;
@property (weak, nonatomic) IBOutlet UIImageView *coverImage;
@property (weak, nonatomic) IBOutlet UIImageView *movingPage;
@property (weak, nonatomic) IBOutlet PaperToast *toast;
@property (nonatomic, strong) AlertViewController *alertViewController;
@property (nonatomic, assign) int updateCounter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (atomic, assign) BOOL segueStarted;
@end
@implementation SplashViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.segueStarted = NO;
    
    self.biasedCenterContraint.constant =((28.0f/640.0f)*[[UIScreen mainScreen] bounds].size.width);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNetwork) name:kDatalayeOfflineWithoutData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(datalayerUpdateStarted) name:kDatalayerUpdateStarted object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(datalayerReady) name:kDatalayerReady object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(datalayerUpdateProgress:) name:kDatalayerUpdateInProgress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorDatalayer:) name:kDatalayerErrorOccured object:nil];
  
    __block NSInteger fontSize = 19;
    [UIDevice executeOnIphone4:^{
       // NSLog(@"Image set on iphone 4");
        [self.coverImage setImage:[UIImage imageNamed:@"book-cover-3.5.png"]];
        fontSize = 19;
    }];
    [UIDevice executeOnIphone5:^{
       // NSLog(@"Image set on iphone 5");

        [self.coverImage setImage:[UIImage imageNamed:@"book-cover-4.png"]];
        fontSize = 19;
    }];
    [UIDevice executeOnIphone6:^{
        [self.coverImage setImage:[UIImage imageNamed:@"book-cover-4.png"]];
        fontSize = 23;
    }];
    [UIDevice executeOnIphone6Plus:^{
        [self.coverImage setImage:[UIImage imageNamed:@"book-cover-4.png"]];
        fontSize = 25;
    }];
    [UIDevice executeOnIpad:^{
        [self.coverImage setImage:[UIImage imageNamed:@"book-cover-ipad.png"]];
        fontSize = 35;
    }];
    
    self.titleLabel.font =  [UIFont fontWithName:@"MarkerFelt-Thin" size:fontSize];
}

- (void) viewDidAppear:(BOOL)animated
{
    [[Datalayer sharedInstance] performSelector:@selector(updateDatalayer) withObject:nil afterDelay:0.5f];
}

- (void) updateViewConstraints
{
    [super updateViewConstraints];
 
    [UIDevice executeOnIphone4:^{
     
        self.titleTopConstraint.constant = 131;
    }];

    [UIDevice executeOnIphone5:^{
        self.titleTopConstraint.constant = 156;
    }];
    
    [UIDevice executeOnIphone6:^{
        self.titleTopConstraint.constant = 156*1.175f;

    }];
    [UIDevice executeOnIphone6Plus:^{
        self.titleTopConstraint.constant = 155*1.294;
    }];
    [UIDevice executeOnIpad:^{
        self.titleTopConstraint.constant =  260;
    }];
    
    
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//        [self.view layoutIfNeeded];
//    self.biasedCenterContraint.constant =((28.0f/640.0f)*[[UIScreen mainScreen] bounds].size.width);
//        [self.view layoutIfNeeded];
  

}
- (void) viewWillDisappear:(BOOL)animated
{
   // NSLog(@"View will disappear");
    [[NSNotificationCenter defaultCenter] removeObserver:kDatalayeOfflineWithData];
    [[NSNotificationCenter defaultCenter] removeObserver:kDatalayeOfflineWithoutData];
    [[NSNotificationCenter defaultCenter] removeObserver:kDatalayerUpdateStarted];
    [[NSNotificationCenter defaultCenter] removeObserver:kDatalayerReady];
    [[NSNotificationCenter defaultCenter] removeObserver:kDatalayerUpdateInProgress];
}

- (void) errorDatalayer:(NSNotification *) note
{
//    [self.alertViewController presentInParentViewController:self withTitle:NSLocalizedString(@"Fejl", @"title for alert view show when an error occured during update") andText:NSLocalizedString(@"Historiejagt Fyn fejlede opdatering af data. Prøv igen!", nil)];
//    [self.alertViewController presentInParentViewController:self withTitle:NSLocalizedString(@"Success", @"title for alert view show Update successfully") andText:NSLocalizedString(@"Welcome!", nil)];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerReady object:nil];
}

- (void) noNetwork
{
  //  NSLog(@"noNetwork");
    // No net and no data stored
    // Show error dialog and try again on ok...
    [self.alertViewController presentInParentViewController:self withTitle:NSLocalizedString(@"Fejl", @"title for alert view shown when no internet and not data present") andText:NSLocalizedString(@"Historiejagt Fyn har behov for at hente data fra internettet. Opret forbindelse og prøv igen.", nil)];
}

-(void) datalayerReady
{
    if (self.segueStarted)
    {
        return;
    }
    self.segueStarted = YES;
    // Continue to main screen....
   // NSLog(@"Datalayer updated");
    self.toast.text = NSLocalizedString(@"Opdatering færdig", @"Toast on splash telling that the data is updated");
    

    [[NSNotificationCenter defaultCenter] removeObserver:kDatalayeOfflineWithData];
    [[NSNotificationCenter defaultCenter] removeObserver:kDatalayeOfflineWithoutData];
    [[NSNotificationCenter defaultCenter] removeObserver:kDatalayerUpdateStarted];
    [[NSNotificationCenter defaultCenter] removeObserver:kDatalayerReady];
    [[NSNotificationCenter defaultCenter] removeObserver:kDatalayerUpdateInProgress];
    self.toast.hidden = YES;
    [self performSegueWithIdentifier:@"welcomeViewControllerSegue" sender:self];
}

- (void) datalayerUpdateStarted
{
   // NSLog(@"Datalayer update started");
    self.toast.text = NSLocalizedString(@"Opdaterer indhold", @"Toast on splash telling that the data are getting updated");
    self.toast.hidden = NO;
}

- (void) datalayerUpdateProgress:(NSNotification *) note
{
    NSString *updatingTitle = NSLocalizedString(@"Opdaterer indhold", @"Toast on splash telling that the data are getting updated");
    
    [note.userInfo valueForKeyPath:kDatalayerUpdateProgressTitleKey];
    NSInteger amount = [[note.userInfo valueForKeyPath:kDatalayerUpdateProgressAmountKey] integerValue];
    NSInteger total = [[note.userInfo valueForKeyPath:kDatalayerUpdateProgressTotalKey] integerValue];
    NSLog(@"Updating %@ - %ld of %ld", updatingTitle, amount, total);
    if (total > 1)
    {
        self.toast.text = [NSString stringWithFormat:NSLocalizedString(@"%@: %ld af %ld", @"Combined title and amount of total"), updatingTitle, amount, total];
    }
    else
    {
        self.toast.text = updatingTitle;
    }
    
    
    self.updateCounter++;
    if (self.updateCounter > 10)
    {
        self.updateCounter = 1;
    }
    self.toast.text = [NSString stringWithFormat:@"%@\n%@", updatingTitle, [@"" stringByPaddingToLength:self.updateCounter withString:@"." startingAtIndex:0]];
    // Update ui
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[SoundHelper sharedInstance] playPageTurnSound];
    MOGOpenBookSegue *openBookSegue = (MOGOpenBookSegue *)segue;
    CGRect frame = self.coverImage.frame;
//    frame.origin.x = 50;
//    frame.size.width -= 50;
    [openBookSegue setupBookView:[self takeSnapshot] frame:frame];
    [openBookSegue setCompletionBlock:^(BOOL transitionCompleted) {
    //    NSLog(@"open!");
    } closeCompletion:^(BOOL transitionCompleted) {
     //   NSLog(@"close!");
    }];
    [super prepareForSegue:segue sender:sender];
}

- (AlertViewController *) alertViewController
{
    if (!_alertViewController)
    {
        _alertViewController = [StoryboardHelper getViewControllerWithId: IS_IPAD ? @"iPadAlertViewController" : @"alertViewController"];
        _alertViewController.delegate = self;
    }
    return _alertViewController;
}

- (void) buttonPressedAtAlertViewController:(AlertViewController *)vc
{
 //   NSLog(@"Tries again");
    [[Datalayer sharedInstance] updateDatalayer];
}

- (UIImage *) takeSnapshot
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    
    // old style [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
