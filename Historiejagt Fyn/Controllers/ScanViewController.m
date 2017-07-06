//
//  ScanViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 25/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "ScanViewController.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
#import "Datalayer.h"
#import "Moodstocks/Moodstocks.h"
#import "Flurry.h"
@interface ScanViewController () <MSAutoScannerSessionDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) MSAutoScannerSession *scannerSession;
@end

@implementation ScanViewController

- (void)viewDidLoad {
    [Flurry logEvent:kFlurryShowScanViewEventName withParameters:nil timed:YES];

    [super viewDidLoad];
    self.scannerSession.delegate = self;
    NSLog(@"View did load for scan view controller");
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

    
    CALayer *videoPreviewLayer = [self.preview layer];
   // [videoPreviewLayer setMasksToBounds:YES];
    
    CALayer *captureLayer = [self.scannerSession captureLayer];
    [captureLayer setFrame:[self.preview bounds]];
    
    [videoPreviewLayer insertSublayer:captureLayer
                                below:[[videoPreviewLayer sublayers] objectAtIndex:0]];
    [self.view bringSubviewToFront:self.overlay];

}

- (void) viewDidAppear:(BOOL)animated
{
    NSLog(@"View did appear");
    [super viewDidAppear:animated];
    [self.scannerSession startRunning];


}

- (void) viewWillDisappear:(BOOL)animated
{
    NSLog(@"View will disappear");
    [super viewWillDisappear:animated];
    [self.scannerSession stopRunning];
    [Flurry endTimedEvent:kFlurryShowScanViewEventName withParameters:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"Memory warning");
    // Dispose of any resources that can be recreated.
}


- (MSAutoScannerSession *) scannerSession
{
    if (!_scannerSession)
    {
        [Datalayer sharedInstance].scanner = nil;
        NSLog(@"Init scaner session");
        _scannerSession = [[MSAutoScannerSession alloc] initWithScanner:[[Datalayer sharedInstance] scanner]];
        _scannerSession.delegate = self;
        _scannerSession.resultTypes = MSResultTypeImage;
        [UIDevice executeOnIphonesExceptIphone4:^{
            _scannerSession.searchOptions = MSSearchSmallTarget;
        }];
        
    }
    return _scannerSession;
}


#define DISABLE_LOCK YES
- (void) showPoiWithObjectId:(NSString *)objectId
{
    [[Datalayer sharedInstance] registerVisitOfPointOfInterestWithObjectId:objectId];
    
    // Send out notification for active app use...
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kDatalayerPointOfInterestClickedManually object:nil userInfo:@{@"pointOfInterest" : objectId}];
    });
        if (self.delegate)
        {
            [self.delegate viewController:self requestsShowing:ViewControllerItemInfo withUserInfo:@{@"poiId" : objectId}];
        }
}

#pragma mark - Scanner Delegate
- (void)session:(id)scannerSession didFindResult:(MSResult *)result
{
//    NSString *title = [result type] == MSResultTypeImage ? @"Image" : @"Barcode";
 //   NSLog(@"Did find %@ with string: %@", title,  [result string]);
    [self showPoiWithObjectId:[result string]];
}

- (void) session:(id)scannerSession didEncounterWarning:(NSString *)warning
{
    NSLog(@"Warning: %@", warning);
}

- (void) prepareStop
{
    
}

@end
