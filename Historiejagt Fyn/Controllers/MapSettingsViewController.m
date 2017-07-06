//
//  MapSettingsViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 05/02/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "MapSettingsViewController.h"
#import "Datalayer.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
@interface MapSettingsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) BOOL isChanged;
@end

@implementation MapSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isChanged = NO;
    [self configureTableView];
}

- (void)configureTableView {
    self.tableView.backgroundColor = [UIColor clearColor];

    [self.tableView registerNib:[UINib nibWithNibName:@"MapSettingsSectionHeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"sectionHeader"];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (IBAction)backButtonPressed:(id)sender
{
    if (self.delegate)
    {
        [self.delegate viewController:self requestsShowing:ViewControllerItemMap];
    }

}

- (void) viewWillDisappear:(BOOL)animated
{
    if (self.isChanged)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MapSettingsChanged" object:nil];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}
#pragma mark - tableview delegates

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"sectionHeader"];
    
    [header.contentView setBackgroundColor:[UIColor clearColor]];
    UITextView *textView = (UITextView *)[header viewWithTag:101];
    
    textView.text = (section == 0 ? NSLocalizedString(@"Her kan du ændre indstillinger vedrørende kort og brugen af dette", @"Description about settings") : NSLocalizedString(@"Hvilke ruter vil du tilføje som standard på kortet?", @"Description - which routes to show per default on map"));
    __block UIFont *font = [UIFont  systemFontOfSize:14];
    [UIDevice executeOnIphone5:^{
        font = [UIFont  systemFontOfSize:14];
    }];
    [UIDevice executeOnIphone4:^{
        font = [UIFont  systemFontOfSize:14];
    }];
    
    [UIDevice executeOnIphone6:^{
        font = [UIFont  systemFontOfSize:16];
    }];
    
    [UIDevice executeOnIphone6Plus:^{
        font = [UIFont  systemFontOfSize:18];
    }];
    [UIDevice executeOnIpad:^{
        font = [UIFont  systemFontOfSize:22];
    }];
    
    [textView setFont:font];
    return header;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    __block CGFloat size = section == 0 ? 60 : 50;

    [UIDevice executeOnIphone5:^{
        size = section == 0 ? 70 : 60;
    }];
    [UIDevice executeOnIphone4:^{
        size = section == 0 ? 70 : 60;
    }];
    
    [UIDevice executeOnIphone6:^{
        size = section == 0 ? 70 : 60;
    }];
    
    [UIDevice executeOnIphone6Plus:^{
        size = section == 0 ? 70 : 60;
    }];
    [UIDevice executeOnIpad:^{
        size = 100;
    }];
    
    return size;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block CGFloat size = 45;
    
    [UIDevice executeOnIphone5:^{
        size = 45;
    }];
    [UIDevice executeOnIphone4:^{
        size = 45;
    }];
    
    [UIDevice executeOnIphone6:^{
        size = 55;
    }];
    
    [UIDevice executeOnIphone6Plus:^{
        size = 55;
    }];
    [UIDevice executeOnIpad:^{
        size = 90;
    }];
    
    return size;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else
    {
        return [[Datalayer sharedInstance] numberOfRoutes];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell"];// forIndexPath:indexPath];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.separatorInset = UIEdgeInsetsMake(0, -35, 0, 0);
    
    UILabel *label = (UILabel *)[cell viewWithTag:102];
    UIImageView *check = (UIImageView *)[cell viewWithTag:101];
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
    label.font = font;
    if (IS_IPAD)
    {
        [check setImage:[UIImage imageNamed:@"settings-unchecked-ipad.png"]];
        [check setHighlightedImage:[UIImage imageNamed:@"settings-checked-ipad.png"]];
    }
    else
    {
        [check setImage:[UIImage imageNamed:@"settings-unchecked.png"]];
        [check setHighlightedImage:[UIImage imageNamed:@"settings-checked.png"]];
    }
    if (indexPath.section == 0)
    {
        // General settings
        if (indexPath.row == 0)
        {
            label.text = NSLocalizedString(@"Vis rute på kortet", nil);
            check.highlighted = [[Datalayer sharedInstance] boolSettingWithIdentifier:@"show_route_setting" defaultValue:YES];
            if (self.showRouteshowSettings)
            {
                label.textColor = [UIColor blackColor];
                
               
            }
            else
            {
                label.textColor = [UIColor grayColor];
                if (IS_IPAD)
                {
                    [check setImage:[UIImage imageNamed:@"disabled-settings-unchecked-ipad.png"]];
                    [check setHighlightedImage:[UIImage imageNamed:@"disabled-settings-checked-ipad.png"]];
                }
                else
                {
                    [check setImage:[UIImage imageNamed:@"disabled-settings-unchecked.png"]];
                    [check setHighlightedImage:[UIImage imageNamed:@"disabled-settings-checked.png"]];
                }
               
                
            }
        }
        else
        {
            label.text = NSLocalizedString(@"Afspil lyde automatisk", nil);
            check.highlighted = [[Datalayer sharedInstance] boolSettingWithIdentifier:@"automatic_sound_setting" defaultValue:YES];

        }
    }
    else
    {
        Route *route = [[Datalayer sharedInstance] routeAtIndex:indexPath.row];
        
        label.text = route.name;
        label.textColor = [UIColor blackColor];
        check.highlighted = [[Datalayer sharedInstance] boolSettingWithIdentifier: [NSString stringWithFormat:@"settings_route_%@", route.objectId] defaultValue:NO];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.isChanged = YES;
    if (indexPath.section == 0)
    {
        
        if (indexPath.row == 0 && self.showRouteshowSettings)
        {
            [[Datalayer sharedInstance] toggleBoolSettingWithIdentifier:@"show_route_setting"];
        }
        else if (indexPath.row == 1)
        {
            [[Datalayer sharedInstance] toggleBoolSettingWithIdentifier:@"automatic_sound_setting"];
        }
        
    }
    else
    {
        Route *route = [[Datalayer sharedInstance] routeAtIndex:indexPath.row];
        [[Datalayer sharedInstance] toggleBoolSettingWithIdentifier:[NSString stringWithFormat:@"settings_route_%@", route.objectId ]];
    }
    [tableView reloadData];
}

- (void) prepareStop
{
    
}

@end
