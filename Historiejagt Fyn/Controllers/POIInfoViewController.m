//
//  POIInfoViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 28/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "POIInfoViewController.h"
#import "PointOfInterest.h"
#import "Datalayer.h"
#import "AvatarView.h"
#import "HTMLHelper.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
#import <AVFoundation/AVFoundation.h>
#import <Canvas/Canvas.h>
#import "SideMenu.h"
@interface POIInfoViewController () <UIWebViewDelegate, AvatarViewDelegate, UIScrollViewDelegate, AVAudioPlayerDelegate, SideMenuDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet SideMenu *sideMenu;

//@property (weak, nonatomic) IBOutlet UIButton *contentButton;
//@property (weak, nonatomic) IBOutlet UIButton *factsButton;
//@property (weak, nonatomic) IBOutlet UIButton *quizButton;
//
//@property (weak, nonatomic) IBOutlet CSAnimationView *contentAnimation;
//
//@property (weak, nonatomic) IBOutlet CSAnimationView *factsAnimation;
//@property (weak, nonatomic) IBOutlet CSAnimationView *quizAnimation;



@property (strong, nonatomic) AVAudioPlayer *player;
@property (nonatomic, strong) PointOfInterest *pointOfInterest;
@property (nonatomic, strong) Route *route;
@property (nonatomic, strong) AvatarView *avatarView;
@property (strong, nonatomic) UIImageView *largeImage;

@end

@implementation POIInfoViewController

- (id) init
{
   // NSLog(@"init");
    self = [super init];
    if (self)
    {
        self.returnItem = ViewControllerItemMap;
        self.showType = POIInfoTypeInfo;
        
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
   // NSLog(@"initWithCoder");
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.returnItem = ViewControllerItemMap;
        self.showType = POIInfoTypeInfo;
        
    }
    return self;
    
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
   // NSLog(@"initWithNib");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.returnItem = ViewControllerItemMap;
        self.showType = POIInfoTypeInfo;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   // NSLog(@"ViewDidLoad");

    self.showTabBar = NO;
    
    self.webView.delegate = self;
    
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    self.webView.scrollView.delegate = self;
    self.sideMenu.delegate = self;
    [self.view sendSubviewToBack:self.sideMenu];
    [self setupViews];
    
}
- (void) viewWillAppear:(BOOL)animated
{
 //   NSLog(@"View Will Appear - POIInfoViewController");
    [super viewWillAppear:animated];
    self.pointOfInterest = nil;
    self.largeImage = nil;
    self.route = nil;
    self.avatarView.hidden = YES;
    self.avatarView = nil;
    [self setupViews];
}

- (void) viewDidAppear:(BOOL)animated
{
    self.sideMenu.poi = self.pointOfInterest;

    [super viewDidAppear:animated];
    [self.sideMenu startAnimations];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.player stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
  //  NSLog(@"Did receive memory warning in Poi View Controller");
}

#pragma mark - View logic

- (void) setupViews
{
  //  NSLog(@"Setup View: %ld - %@", self.showType, self.poiId );
    if (self.showType == POIInfoTypeInfo)
    {
        NSString *text = [HTMLHelper htmlForContentView:self.pointOfInterest.info
                                                  title:self.pointOfInterest.title
                                                  image:self.pointOfInterest.image
                                             imageTitle:self.pointOfInterest.imageTitle
                                               videoUrl:self.pointOfInterest.videoURL
                                             videoTitle:self.pointOfInterest.videoTitle
                                          avatarEnabled:!self.pointOfInterest.noAvatar];
        [self.webView loadHTMLString:text baseURL:nil];
        [self.sideMenu setSelectedItem:SideMenuItemContent];
    }
    else
    {
       NSLog(@"Facts er nu: %@", self.pointOfInterest.facts);
        NSLog(@"Facts image: %@", self.pointOfInterest.factsImage);
        NSString *text = [HTMLHelper htmlForContentView:self.pointOfInterest.facts
                                                  title:NSLocalizedString(@"Praktisk information", @"title for facts page")
                                                  image:self.pointOfInterest.factsImage
                                             imageTitle:self.pointOfInterest.factsImageTitle
                                               videoUrl:nil
                                             videoTitle:nil
                                          avatarEnabled:NO];
        [self.webView loadHTMLString:text baseURL:nil];
        self.sideMenu.selectedItem = SideMenuItemFacts;
    }
    [self.webView.scrollView setContentSize: CGSizeMake(self.webView.frame.size.width-10, self.webView.scrollView.contentSize.height)];
    
}

- (PointOfInterest *) pointOfInterest
{
    if (!_pointOfInterest)
    {
        _pointOfInterest = [[Datalayer sharedInstance] pointOfInterestWithObjectId:self.poiId];
     //   NSLog(@"Facts: %@", _pointOfInterest.facts);
    }
    return _pointOfInterest;
}

- (Route *) route
{
    if (!_route)
    {
        _route = [[Datalayer sharedInstance] routeContainingPointOfInterestWithObjectId:self.poiId];
    }
    return _route;
}

- (AvatarView *) avatarView
{
    if (!_avatarView)
    {
        if (self.showType == POIInfoTypeFacts || self.pointOfInterest.noAvatar)
        {
            _avatarView = nil;
        }
        else
        {
            NSArray *avatar = (self.pointOfInterest.avatar ? self.pointOfInterest.avatar : self.route.avatar);
            _avatarView = [[AvatarView alloc] initWithFrame:CGRectMake(0, 200, 142, 210) andImages:avatar soundEnabled:(self.pointOfInterest.audio != nil) autoPlayAvatars: self.pointOfInterest.autoplay];
            if (self.pointOfInterest.autoplay || [[Datalayer sharedInstance] boolSettingWithIdentifier:@"automatic_sound_setting" defaultValue:NO])
            {
                
                self.player.currentTime = 0;
                [self.player play];
            }
            _avatarView.delegate = self;
        }
    }
    return _avatarView;
}

- (AVAudioPlayer*) player
{
    if (!_player)
    {
        
        NSError *err = nil;
        _player = [[AVAudioPlayer alloc] initWithData:self.pointOfInterest.audio error:&err];
        
        if (err)
        {
            NSLog(@"Error: %@", err.userInfo);
            err = nil;
        }
        
        [_player setDelegate:self];
    }
    return _player;
}
- (UIImageView *) largeImage
{
    if (!_largeImage)
    {
        UIImage *image;
        if (self.showType == POIInfoTypeFacts)
        {
            image = [UIImage imageWithData: self.pointOfInterest.factsLargeImage];
        }
        else
        {
            image = [UIImage imageWithData: self.pointOfInterest.largeImage];
        }
        CGFloat ratio = image.size.width / image.size.height;
       // NSLog(@"ratio: %f / %f = %f", image.size.width, image.size.height, ratio);
        _largeImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200.0, 200.0 * ratio)];
        _largeImage.backgroundColor = [UIColor blackColor];
        _largeImage.image  = image;
        if (image.size.width > image.size.height)
        {
            _largeImage.transform=CGAffineTransformMakeRotation(M_PI / 2);
        }
        _largeImage.center = self.view.center;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(largeImageTapped)];
        singleTap.numberOfTapsRequired = 1;
        _largeImage.userInteractionEnabled = YES;
        [_largeImage addGestureRecognizer:singleTap];
        
    }
    return _largeImage;
}


- (void) setPoiId:(NSString *)poiId
{
    _poiId = poiId;
    self.sideMenu.poi = self.pointOfInterest;
}

- (IBAction)backButtonTapped:(id)sender
{
    //NSLog(@"ReturnItem: %ld", self.returnItem);
    [self.delegate viewController:self requestsShowing:self.returnItem];
}


- (IBAction)contentButtonTapped:(id)sender
{
    [self.delegate viewController:self requestsShowing:ViewControllerItemInfo];
}

- (IBAction)factsButtonTapped:(id)sender
{
    [self.delegate viewController:self requestsShowing:ViewControllerItemFacts];
}

- (IBAction)quizButtonTapped:(id)sender
{
    [self.delegate viewController:self requestsShowing:ViewControllerItemQuiz];
}

- (void) sideMenu:(SideMenu *)menu didSelectItem:(SideMenuItem)item
{
    switch (item)
    {
        case SideMenuItemContent:
            [self.delegate viewController:self requestsShowing:ViewControllerItemInfo];
            break;
        case SideMenuItemFacts:
            [self.delegate viewController:self requestsShowing:ViewControllerItemFacts];
            break;
        case SideMenuItemQuiz:
            [self.delegate viewController:self requestsShowing:ViewControllerItemQuiz];
            break;
        default:
            break;
    }
}

#pragma mark - webview delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType != UIWebViewNavigationTypeLinkClicked)
    {
        return YES;
    }
   // NSLog(@"shouldStartLoadWithRequst");
    if ([[request.URL scheme] isEqualToString:@"historiejagtfyn"])
    {
        if ([[request.URL absoluteString] isEqualToString:@"historiejagtfyn://videoClicked"])
        {
           // NSLog(@"Videobutton clicked");
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@", self.pointOfInterest.videoURL]]];
        }
        else if ([[request.URL absoluteString] isEqualToString:@"historiejagtfyn://imageClicked"])
        {
          //  NSLog(@"image clicked");
            
            self.largeImage.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0);
            [self.view addSubview:self.largeImage];
            CGPoint center = self.largeImage.center;
            [UIView animateWithDuration: 1.0f animations:^{
                self.largeImage.frame = self.view.frame;
                self.largeImage.center = center;
            }];
        }
        
        return NO; // Tells the webView not to load the URL
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"Error loading webview content %@", error);
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!self.pointOfInterest.noAvatar && (self.route.avatar || self.pointOfInterest.avatar))
    {
        if (self.showType == POIInfoTypeInfo)
        {
            CGRect frame = self.avatarView.frame;
            frame.origin.y = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('imageDiv').offsetTop;"] floatValue];
            if (frame.origin.y < 1.0)
            {
                frame.origin.y = (self.view.frame.size.height - frame.size.height)/2;
                
            }
            self.avatarView.frame = frame;
            
            self.avatarView.transform = CGAffineTransformIdentity;
            CGAffineTransform trans = CGAffineTransformScale(self.avatarView.transform, 0.01, 0.01);
            
            self.avatarView.transform = trans; // do it instantly, no animation
            [self.webView.scrollView addSubview:self.avatarView];
            
            self.avatarView.hidden = NO;
            
            [UIView animateWithDuration: 1.0f animations:^{
                self.avatarView.transform = CGAffineTransformScale(self.avatarView.transform, 100, 100);
                
            }];
            
        }
        else
        {
            self.avatarView.hidden = YES;
        }
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > 0)
    {
        scrollView.contentOffset = CGPointMake(0, scrollView.contentOffset.y);
    }
}

#pragma mark - wkavatarview delegate
- (void) avatarView:(AvatarView *)avatarView buttonPressWithState:(AvatarViewButtonState)state
{
    if (self.player.playing)
    {
        [self.player pause];
    }
    else
    {
        [self.player play];
    }
}

- (void) avatarView:(AvatarView *)avatarView changedImageToImage:(NSInteger) imageNumber;
{
    
}

# pragma mark - audio player delegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (self.avatarView)
    {
        [self.avatarView setState:AvatarViewButtonStatePause];
    }
}

#pragma mark - large image tap gesture selector

- (void) largeImageTapped
{
    [self.largeImage removeFromSuperview];
}


- (void) prepareStop
{
    
}

@end
