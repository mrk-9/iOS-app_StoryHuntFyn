 //
//  RootViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 25/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//
#import "Flurry.h"
#import "RootViewController.h"
#import "TabBarView.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
#import "WelcomeViewController.h"
#import "RoutesViewController.h"
#import "MapViewController.h"
#import "StoryboardHelper.h"
#import "ARViewController.h"
#import "ScanViewController.h"
#import "SoundHelper.h"
#import "datalayernotificationsstrings.h"
#import "Datalayer.h"
#import "POIInfoViewController.h"
#import "QuizViewController.h"
#import "RouteDetailViewController.h"
#import "MapSettingsViewController.h"
#import "AlertViewController.h"
#import <sys/utsname.h>
/** A private UIViewControllerContextTransitioning class to be provided transitioning delegates.
 @discussion Because we are a custom UIVievController class, with our own containment implementation, we have to provide an object conforming to the UIViewControllerContextTransitioning protocol. The system view controllers use one provided by the framework, which we cannot configure, let alone create. This class will be used even if the developer provides their own transitioning objects.
 @note The only methods that will be called on objects of this class are the ones defined in the UIViewControllerContextTransitioning protocol. The rest is our own private implementation.
 */
@interface PrivateTransitionContext : NSObject <UIViewControllerContextTransitioning>
- (instancetype)initWithFromViewController:(BaseViewController *)fromViewController toViewController:(BaseViewController *)toViewController; /// Designated initializer.
@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete); /// A block of code we can set to execute after having received the completeTransition: message.
@property (nonatomic, assign, getter=isAnimated) BOOL animated; /// Private setter for the animated property.
@property (nonatomic, assign, getter=isInteractive) BOOL interactive; /// Private setter for the interactive property.
@end

/** Instances of this private class perform the default transition animation which is to slide child views horizontally.
 @note The class only supports UIViewControllerAnimatedTransitioning at this point. Not UIViewControllerInteractiveTransitioning.
 */
@interface PrivateAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>
@end


@interface RootViewController() <TarBarViewDelegate, RootViewControllerDelegate>
@property (nonatomic, strong) AlertViewController *alertViewController;
@property (nonatomic, assign) BOOL isIphone4;

@property (weak, nonatomic) IBOutlet UIButton *fakeNotificationButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabBarViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabBarViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabBarViewCenterConstraint;
@property (weak, nonatomic) IBOutlet TabBarView *tabBarView;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backgroundBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBottomConstraint;

@property (nonatomic, assign) BOOL isTurning;
@property (nonatomic, strong) BaseViewController *currentViewController;
@property (nonatomic, assign) ViewControllerItems currentViewControllerItem;
@property (nonatomic, assign) ViewControllerItems previousViewControllerItem;

@property (nonatomic, strong) WelcomeViewController *welcomeViewController;

@property (nonatomic, strong) RoutesViewController *routesViewController;
@property (nonatomic, strong) RouteDetailViewController *routeDetailViewController;

@property (nonatomic, strong) MapViewController *mapViewController;
@property (nonatomic, strong) MapSettingsViewController *mapSettingsViewController;

@property (nonatomic, strong) ARViewController *arViewController;

@property (nonatomic, strong) ScanViewController *scanViewController;

@property (nonatomic, strong) POIInfoViewController *infoViewController;
@property (nonatomic, strong) POIInfoViewController *factViewController;
@property (nonatomic, strong) QuizViewController *quizViewController;



@end
@implementation RootViewController

//!
// Return the device name
//
- (NSString *) deviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (void) viewDidLoad
{
    
    NSString *deviceName = self.deviceName;
    if ([deviceName isEqualToString:@"iPhone3,1"] || [deviceName isEqualToString:@"iPhone3,2"]) {
        self.isIphone4 = YES;
    }
    else
    {
        self.isIphone4 = NO;
    }
    [super viewDidLoad];
    // Default settings
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.showTabBar = NO;
    self.isTurning = NO;
    self.tabBarView.delegate = self;
    self.tabBarView.selected = ViewControllerItemRoutes;
    self.previousViewControllerItem = ViewControllerItemNone;
    // Set background depending on the device type and size
    [UIDevice executeOnIpad:^{
        [self.background setImage:[UIImage imageNamed:@"background-ipad"]];
    }];

    [UIDevice executeOnIphone4:^{
        //self.background.contentMode = UIViewContentModeScaleAspectFill;
        [self.background setImage:[UIImage imageNamed:@"background-3.5.png"]];
    }];
    [UIDevice executeOnIphone5:^{
        //self.background.contentMode = UIViewContentModeScaleAspectFill;
        [self.background setImage:[UIImage imageNamed:@"background-4.png"]];
    }];
    [UIDevice executeOnIphone6:^{
        [self.background setImage:[UIImage imageNamed:@"page-4.png"]];
    }];
    [UIDevice executeOnIphone6:^{
        [self.background setImage:[UIImage imageNamed:@"page-4.png"]];
    }];
    self.background.backgroundColor = [UIColor redColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pointOfInterestFound:) name:kDatalayerPointOfInterestFound object:nil];
    NSString *pointOfInterestToShow = [[Datalayer sharedInstance] pointOfInterestNotificationObjectId];
    // Show found poi if not already showing one - hot fix preventing showing multiple overlapping pois
    if (pointOfInterestToShow  && !(self.currentViewControllerItem == ViewControllerItemInfo || self.currentViewControllerItem == ViewControllerItemFacts || self.currentViewControllerItem == ViewControllerItemQuiz))
    {
        //NSLog(@"From localPush");
        self.infoViewController.poiId = pointOfInterestToShow;
        //NSLog(@"Init should had happend here");
        [[Datalayer sharedInstance] setPointOfInterestNotificationObjectId:nil];
        [self transitionToChildViewController:self.infoViewController showTabBar:NO];
        self.infoViewController.showType = POIInfoTypeInfo;
        self.currentViewController = self.infoViewController;
        self.previousViewControllerItem = ViewControllerItemWelcome;
        self.currentViewControllerItem = ViewControllerItemInfo;
    }
    else
    {
        [self transitionToChildViewController:self.welcomeViewController showTabBar:NO];
        self.currentViewController = self.welcomeViewController;
        self.previousViewControllerItem = self.currentViewControllerItem;
        self.currentViewControllerItem = ViewControllerItemWelcome;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self updateViewConstraints];
}

// Setup auto laout constaints
- (void) updateViewConstraints
{
    [super updateViewConstraints];
    
    [UIDevice executeOnIpad:^{
        self.tabBarViewHeightConstraint.constant = 119.0f;
        self.tabBarViewWidthConstraint.constant = 352.0f;
    }];
    self.tabBarViewCenterConstraint.constant = ((39.0f/640.0f)*[[UIScreen mainScreen] bounds].size.width);
    [self.view setNeedsDisplay];
}


- (void) pointOfInterestFound:(NSNotification *) note
{
    NSString *pointOfInterestToShow = [note.userInfo valueForKeyPath:@"pointOfInterest"];
    
    // If in info view return - prevent showing multiple pois at the same time
    if (self.currentViewControllerItem == ViewControllerItemInfo || self.currentViewControllerItem == ViewControllerItemFacts || self.currentViewControllerItem == ViewControllerItemQuiz)
    {
        return;
    }
    
    // Setup infoViewController
    self.previousViewControllerItem = self.currentViewControllerItem;
    self.infoViewController.poiId = pointOfInterestToShow;
    self.infoViewController.showType = POIInfoTypeInfo;
    self.infoViewController.returnItem = self.currentViewControllerItem;
    [self transitionToChildViewController:self.infoViewController showTabBar:NO];
    self.currentViewController = self.infoViewController;
    self.currentViewControllerItem = ViewControllerItemInfo;
}

#pragma mark tabbar delegate
// Select tab bar icon - 
- (void) tabBarView:(TabBarView *)tabBarView selectedItem:(ViewControllerItems) item
{
    if (self.isIphone4 && item == ViewControllerItemAr)
    {
        [self.alertViewController presentInParentViewController:self withTitle:NSLocalizedString(@"Ikke understøttet", @"title for alert view shown when an iPhone 4 is used and the view to show is AR VIEW") andText:NSLocalizedString(@"AR View er ikke understøttet på iPhone 4!", nil)];
        tabBarView.selected = self.currentViewControllerItem;
        return;
    }
    
    if (self.currentViewController)
    {
        [self.currentViewController prepareStop];
    }
    self.arViewController = nil;
    self.routesViewController = nil;
    self.scanViewController = nil;
    self.mapViewController = nil;
    self.infoViewController = nil;
    self.factViewController = nil;
    self.quizViewController = nil;
    self.mapSettingsViewController  =nil;
    self.routeDetailViewController = nil;
    BaseViewController *controller = nil;
    switch (item)
    {
        case ViewControllerItemRoutes:
            controller = self.routesViewController;
            self.activeRoute = nil;
            break;
        case ViewControllerItemMap:
            self.mapViewController.routeId = self.activeRoute;
            controller = self.mapViewController;
            
            break;
        case ViewControllerItemAr:
            self.arViewController.routeId = self.activeRoute;
            controller = self.arViewController;
            break;
        case ViewControllerItemScan:
            controller = self.scanViewController;
        default:
            break;
    }
    if (controller)
    {
        [self transitionToChildViewController:controller showTabBar:YES];
        self.currentViewControllerItem = item;
    }
}

- (void) setShowTabBar:(BOOL)showTabBar
{
    _showTabBar = showTabBar;
    
    [self.tabBarView setHidden:!_showTabBar];
}

- (void) transitionToChildViewController:(BaseViewController *)toViewController showTabBar:(BOOL) showTabBar
{
    // Prevent double turning
    if (self.isTurning)
    {
        return;
    }
    
    self.isTurning = YES;
    BaseViewController *fromViewController = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    UIView *toView = toViewController.view;
    [toView setTranslatesAutoresizingMaskIntoConstraints:YES];
    toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toView.frame = self.containerView.frame;
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    // If this is the initial presentation, add the new child with no animation.
    if (!fromViewController)
    {
        [self.containerView addSubview:toViewController.view];
        [toViewController didMoveToParentViewController:self];
       // self.showTabBar = showTabBar;
        self.isTurning  = NO;

        return;
    }
    
    
    // Animate the transition by calling the animator with our private transition context. If we don't have a delegate, or if it doesn't return an animated transitioning object, we will use our own, private animator.
    
    id<UIViewControllerAnimatedTransitioning>animator = [[PrivateAnimatedTransition alloc] init];;
    PrivateTransitionContext *transitionContext = [[PrivateTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController];
    
    transitionContext.animated = YES;
    transitionContext.interactive = NO;
    transitionContext.completionBlock = ^(BOOL didComplete)
    {

        [fromViewController.view removeFromSuperview];

        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
        
        if ([animator respondsToSelector:@selector (animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
        toViewController.delegate = self;
        self.currentViewController = toViewController;
        self.showTabBar = showTabBar;
        self.tabBarView.userInteractionEnabled = YES;
        self.isTurning  = NO;
        [self.view bringSubviewToFront:self.fakeNotificationButton];
    };
    
    self.tabBarView.userInteractionEnabled = NO; // Prevent user tapping buttons mid-transition, messing up state
    [[SoundHelper sharedInstance] playPageTurnSound];
    if (self.showTabBar)
    {
        self.showTabBar = NO;
        [animator animateTransition:transitionContext];
    }
    else
    {
        [animator animateTransition:transitionContext];
    }
}

#pragma mark - view controllers

- (WelcomeViewController *) welcomeViewController
{
    if (!_welcomeViewController)
    {
        _welcomeViewController = [StoryboardHelper getViewControllerWithId:@"welcomeViewController"];
        _welcomeViewController.delegate = self;
        _welcomeViewController.showTabBar = NO;
    }
    return _welcomeViewController;
}

- (RoutesViewController *) routesViewController
{
    if (!_routesViewController)
    {
        _routesViewController = [StoryboardHelper getViewControllerWithId:@"routesViewController"];
        _routesViewController.delegate = self;
        _routeDetailViewController.showTabBar = YES;
    }
    return _routesViewController;
}

- (MapViewController *) mapViewController
{
    if (!_mapViewController)
    {
        _mapViewController = [StoryboardHelper getViewControllerWithId:@"mapViewController"];
        _mapViewController.delegate = self;
        _mapViewController.showTabBar = YES;
    }
    return _mapViewController;
}

- (MapSettingsViewController *) mapSettingsViewController
{
    if (!_mapSettingsViewController)
    {
        _mapSettingsViewController = [StoryboardHelper getViewControllerWithId:@"mapSettingsViewController"];
        _mapSettingsViewController.delegate = self;
        _mapSettingsViewController.showTabBar = NO;
    }
    return _mapSettingsViewController;
}

- (RouteDetailViewController *) routeDetailViewController
{
    if (!_routeDetailViewController)
    {
        _routeDetailViewController = [StoryboardHelper getViewControllerWithId:@"routeDetailViewController"];
        _routeDetailViewController.delegate = self;
        _routeDetailViewController.showTabBar = NO;
    }
    return _routeDetailViewController;
}

- (POIInfoViewController *) infoViewController
{
    if (!_infoViewController)
    {
        _infoViewController =  [StoryboardHelper getViewControllerWithId:@"POIInfoViewController"];
        _infoViewController.delegate = self;
        _infoViewController.showTabBar = NO;
    }
    return _infoViewController;
}

- (POIInfoViewController *) factViewController
{
    if (!_factViewController)
    {
        _factViewController = [StoryboardHelper getViewControllerWithId:@"POIInfoViewController"];
        _factViewController.delegate = self;
        _factViewController.showTabBar = NO;
    }
    return _factViewController;
}

- (QuizViewController *) quizViewController
{
    if (!_quizViewController)
    {
        _quizViewController = [StoryboardHelper getViewControllerWithId:@"QuizViewController"];
        _quizViewController.delegate = self;
        _quizViewController.showTabBar = NO;
    }
    return _quizViewController;
}

- (ScanViewController *) scanViewController
{
    if (!_scanViewController)
    {
        _scanViewController = [StoryboardHelper getViewControllerWithId:@"ScanViewController"];
        _scanViewController.delegate = self;
        _scanViewController.showTabBar = YES;
    }
    return _scanViewController;
}

- (ARViewController *) arViewController
{
    if (!_arViewController)
    {
        _arViewController = [StoryboardHelper getViewControllerWithId:@"ARViewController"];
        _arViewController.delegate = self;
        _arViewController.showTabBar = YES;
    }
    return _arViewController;
}

#pragma mark - BaseViewController delegate

- (void) viewController:(BaseViewController *) fromController requestsShowing:(ViewControllerItems) item
{
    [self viewController:fromController requestsShowing:item withUserInfo:nil];
}

- (void) viewController:(BaseViewController *) fromController requestsShowing:(ViewControllerItems) item withUserInfo:(NSDictionary *)userInfo
{
    if ([userInfo valueForKey:@"route"])
    {
        self.activeRoute = [userInfo valueForKey:@"route"];
    }
    if (fromController)
    {
        [fromController prepareStop];
    }
    // Select view controller to show
    BaseViewController *controller = nil;
    switch (item)
    {
        case ViewControllerItemRoutes:
            controller = self.routesViewController;
            self.activeRoute = nil;
            break;
        case ViewControllerItemMap:
        {
            // Setup up map view according to previous views
            //NSString *routeId = nil;
            BOOL returnFromContentView = NO;
            if (self.currentViewController == self.mapSettingsViewController)
            {
                //routeId = self.mapViewController.routeId;
                returnFromContentView = YES;
            }
//            else if ([userInfo valueForKeyPath:@"route"])
//            {
//                routeId = [userInfo valueForKeyPath:@"route"];
//            }
//            else if (self.mapViewController.routeId)
//            {
//                routeId = self.mapViewController.routeId;
//            }
            if (self.currentViewControllerItem == ViewControllerItemInfo || self.currentViewControllerItem == ViewControllerItemFacts|| self.currentViewControllerItem == ViewControllerItemQuiz)
            {
                returnFromContentView = YES;
            }
            self.mapViewController = nil;
            self.mapViewController.routeId = self.activeRoute;
            self.mapViewController.returnFromContentView = returnFromContentView;
            controller = self.mapViewController;
            break;
        }
        case ViewControllerItemAr:
            self.arViewController = nil;
            self.arViewController.routeId = self.activeRoute;
            controller = self.arViewController;
            break;
        case ViewControllerItemScan:
            self.scanViewController = nil;
            controller = self.scanViewController;
            break;
        case ViewControllerItemRouteDetail:
            self.routeDetailViewController.route = [userInfo valueForKeyPath:@"route"];
            controller = self.routeDetailViewController;
            break;
        case ViewControllerItemWelcome:
            controller = self.welcomeViewController;
            break;
        case ViewControllerItemInfo:
            controller = self.infoViewController;
            if ([userInfo valueForKeyPath:@"poiId"])
            {
                self.infoViewController.poiId = [userInfo valueForKeyPath:@"poiId"];
            }
            self.infoViewController.showType = POIInfoTypeInfo;
            break;
        case ViewControllerItemFacts:
            controller = self.factViewController;
            self.factViewController.poiId = self.infoViewController.poiId;
            self.factViewController.showType = POIInfoTypeFacts;
            self.factViewController.returnItem = self.infoViewController.returnItem;
            break;
        case ViewControllerItemQuiz:
            controller = self.quizViewController;
            self.quizViewController.poiId = self.infoViewController.poiId;
            self.quizViewController.returnItem = self.infoViewController.returnItem;
            break;
        case ViewControllerItemMapSettings:
            controller = self.mapSettingsViewController;
            self.mapSettingsViewController.showRouteshowSettings = (self.mapViewController.routeId != nil);
            break;
        default:
            break;
    }
    if (controller)
    {
        self.tabBarView.selected = item;
        
        if (item == ViewControllerItemInfo || item == ViewControllerItemFacts || item == ViewControllerItemQuiz )
        {
            if ((self.currentViewControllerItem == ViewControllerItemInfo || self.currentViewControllerItem == ViewControllerItemFacts || self.currentViewControllerItem == ViewControllerItemQuiz))
            {
                // Active is content view
                //NSLog(@"Current is an info controller: %ld", self.currentViewControllerItem);
                
            }
            else
            {
                
                switch (item)
                {
                    case ViewControllerItemInfo:
                        self.infoViewController.returnItem = self.currentViewControllerItem;
                        //NSLog(@"Sets return type: %ld", self.currentViewControllerItem);
                        break;
                    case ViewControllerItemFacts:
                        self.factViewController.returnItem = self.currentViewControllerItem;
                        //NSLog(@"Sets return type: %ld", self.currentViewControllerItem);
                        break;
                    case ViewControllerItemQuiz:
                        self.quizViewController.returnItem = self.currentViewControllerItem;
                        //NSLog(@"Sets return type: %ld", self.currentViewControllerItem);
                        break;
                    default:
                        break;
                }
            }
            
        }
        self.currentViewControllerItem = item;

        [self transitionToChildViewController:controller showTabBar:item <= ViewControllerItemScan];
        self.currentViewController = controller;
    }
}


- (AlertViewController *) alertViewController
{
    if (!_alertViewController)
    {
        _alertViewController = [StoryboardHelper getViewControllerWithId: IS_IPAD ? @"iPadAlertViewController" : @"alertViewController"];
    }
    return _alertViewController;
}


@end






#pragma mark - Private Transitioning Classes

@interface PrivateTransitionContext ()
@property (nonatomic, strong) NSDictionary *privateViewControllers;
@property (nonatomic, assign) CGRect privateDisappearingFromRect;
@property (nonatomic, assign) CGRect privateAppearingFromRect;
@property (nonatomic, assign) CGRect privateDisappearingToRect;
@property (nonatomic, assign) CGRect privateAppearingToRect;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;
@end

@implementation PrivateTransitionContext

- (instancetype)initWithFromViewController:(BaseViewController *)fromViewController toViewController:(BaseViewController *)toViewController
{
    NSAssert ([fromViewController isViewLoaded] && fromViewController.view.superview, @"The fromViewController view must reside in the container view upon initializing the transition context.");
    
    if ((self = [super init])) {
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = fromViewController.view.superview;
        self.privateViewControllers = @{
                                        UITransitionContextFromViewControllerKey:fromViewController,
                                        UITransitionContextToViewControllerKey:toViewController,
                                        };
        
        // Set the view frame properties which make sense in our specialized ContainerViewController context. Views appear from and disappear to the sides, corresponding to where the icon buttons are positioned. So tapping a button to the right of the currently selected, makes the view disappear to the left and the new view appear from the right. The animator object can choose to use this to determine whether the transition should be going left to right, or right to left, for example.
        self.privateDisappearingFromRect = self.privateAppearingToRect = self.containerView.bounds;

    }
    
    return self;
}

- (CGRect)initialFrameForViewController:(BaseViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.privateDisappearingFromRect;
    } else {
        return self.privateAppearingFromRect;
    }
}

- (CGRect)finalFrameForViewController:(BaseViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.privateDisappearingToRect;
    } else {
        return self.privateAppearingToRect;
    }
}

- (BaseViewController *)viewControllerForKey:(NSString *)key {
    return self.privateViewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete {
    if (self.completionBlock) {
        self.completionBlock (didComplete);
    }
}

- (BOOL)transitionWasCancelled { return NO; } // Our non-interactive transition can't be cancelled (it could be interrupted, though)

// Supress warnings by implementing empty interaction methods for the remainder of the protocol:

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {}
- (void)cancelInteractiveTransition {}

@end

@implementation PrivateAnimatedTransition

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}


/// Slide views horizontally, with a bit of space between, while fading out and in.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    
    UIView* containerView = [transitionContext containerView];
    
    // Grab the from and to view controllers from the context
    BaseViewController *toViewController = (BaseViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    BaseViewController *fromViewController = (BaseViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [transitionContext.containerView addSubview:fromViewController.view];
    
    [transitionContext.containerView addSubview:toViewController.view];
    

    toViewController.view.userInteractionEnabled = YES;

    
    [UIView animateWithDuration:1 animations:^{
        toViewController.view.transform = CGAffineTransformMakeTranslation(0,0.0);
        
        CATransform3D _3Dt = CATransform3DIdentity;
        _3Dt = CATransform3DTranslate(_3Dt,-containerView.frame.size.width / 1.0, 0, 0);
        _3Dt.m34 = 1.0 / -500;
        
        _3Dt = CATransform3DRotate(_3Dt, M_PI * 1.5, 0.0, 1, 0.0);
        CGFloat denominator = IS_IPAD ? 2.0 : 1.2;
        _3Dt = CATransform3DTranslate(_3Dt, containerView.frame.size.width/denominator, 0, 0);
        
        
        fromViewController.view.layer.transform = _3Dt;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
    
    
    
}
@end


