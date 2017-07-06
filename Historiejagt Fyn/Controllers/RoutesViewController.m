//
//  RoutesViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 25/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "RoutesViewController.h"
#import "Datalayer.h"
#import "Route.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
#import "StoryboardHelper.h"
#import "RouteDetailViewController.h"
#import "Flurry.h"
#define kRoutesCellIdentifier @"routeCell"
#define kRoutesImageTag 101
#define kRoutesLabelTag 102

@interface RoutesViewController ()  <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation RoutesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"Routes View Controller ViewDidLoad");
    [Flurry logEvent:kFlurryShowRoutesViewEventName timed:YES];

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
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.showTabBar = YES;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:kFlurryShowRoutesViewEventName withParameters:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - tableview delegates

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block CGFloat size = 40;
    
    [UIDevice executeOnIphone5:^{
        size = 40;
    }];
    [UIDevice executeOnIphone4:^{
        size = 40;
    }];
    
    [UIDevice executeOnIphone6:^{
        size = 50;
    }];
    
    [UIDevice executeOnIphone6Plus:^{
        size = 50;
    }];
    [UIDevice executeOnIpad:^{
        size = 80;
    }];
    
    return size;}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[Datalayer sharedInstance] numberOfRoutes];
    //NSLog(@"Count: %ld", count);
    return count;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRoutesCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRoutesCellIdentifier];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.separatorInset = UIEdgeInsetsMake(0, -35, 0, 0);
    Route *route = [[Datalayer sharedInstance] routeAtIndex:indexPath.row];
    
    UIImageView *iconView = (UIImageView *)[cell viewWithTag:kRoutesImageTag];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kRoutesLabelTag];
    
    __block UIFont *font = [UIFont  systemFontOfSize:14];
    [UIDevice executeOnIphone5:^{
        font = [UIFont fontWithName:@"MarkerFelt-Thin" size:14];
    }];
    [UIDevice executeOnIphone4:^{
        font = [UIFont  fontWithName:@"MarkerFelt-Thin" size:14];
    }];
    
    [UIDevice executeOnIphone6:^{
        font = [UIFont  fontWithName:@"MarkerFelt-Thin" size:16];
    }];
    
    [UIDevice executeOnIphone6Plus:^{
        font = [UIFont  fontWithName:@"MarkerFelt-Thin" size:18];
    }];
    [UIDevice executeOnIpad:^{
        font = [UIFont  fontWithName:@"MarkerFelt-Thin" size:22];
    }];
    titleLabel.font = font;
    
//    NSArray *ary = route.namesforlist;
    titleLabel.text = route.name;
    iconView.image = [UIImage imageWithData:route.icon scale:2];
    [titleLabel setTextColor:[UIColor blackColor]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[Flurry endTimedEvent:kFlurryShowRoutesViewEventName withParameters:nil];
    
//    RouteDetailViewController *vc = [StoryboardHelper getViewControllerWithId:@"routeDetailViewController"];
//    vc.route = [[Datalayer sharedInstance] routeAtIndex:indexPath.row];
//    [self.delegate viewController:self requestsShowing:vc tabBarVisible:NO];
    [self.delegate viewController:self requestsShowing:ViewControllerItemRouteDetail withUserInfo:@{@"route" : [[Datalayer sharedInstance] routeAtIndex:indexPath.row]}];
}

- (void) prepareStop
{
    
}


@end
