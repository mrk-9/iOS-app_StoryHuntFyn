//
//  QuizViewController.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 02/02/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
#import "Datalayer.h"
#import "QuizViewController.h"
#import "SideMenu.h"
#import "Quiz.h"
#import "Flurry.h"
@interface QuizViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, SideMenuDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet SideMenu *sideMenu;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, readonly) Quiz *quiz;
@end

@implementation QuizViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Flurry logEvent:kFlurryShowQuizViewEventName withParameters:nil timed:YES];
    
    self.showTabBar = NO;

    self.tableView.backgroundColor = [UIColor clearColor];
    
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
    
    [self.view sendSubviewToBack:self.sideMenu];

}

- (void) viewDidAppear:(BOOL)animated
{
    self.sideMenu.poi = [[Datalayer sharedInstance] pointOfInterestWithObjectId:self.poiId];
    
    [super viewDidAppear:animated];
    UITextView *header = (UITextView *)[self.tableView tableHeaderView];
    header.delegate = self;
    header.text = [self.quiz header];
    
    __block UIFont *font = [UIFont  systemFontOfSize:18];
    [UIDevice executeOnIphone5:^{
        font = [UIFont  systemFontOfSize:16];
    }];
    [UIDevice executeOnIphone4:^{
        font = [UIFont  systemFontOfSize:16];
    }];
    
    [UIDevice executeOnIphone6:^{
        font = [UIFont  systemFontOfSize:18];
    }];
    
    [UIDevice executeOnIphone6Plus:^{
        font = [UIFont  systemFontOfSize:20];
    }];
    [UIDevice executeOnIpad:^{
        font = [UIFont  systemFontOfSize:22];
    }];

    
    [header setFont:font];
    
    [self textViewDidChange:header];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.sideMenu.delegate = self;
    self.sideMenu.selectedItem = SideMenuItemQuiz;

    
    
    //    [self.contentAnimation startCanvasAnimation];
    //    [self.factsAnimation startCanvasAnimation];
    //    [self.quizAnimation startCanvasAnimation];
    [self.sideMenu startAnimations];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - properties
- (Quiz *) quiz
{
    return [[Datalayer sharedInstance] quizForPOIWithObjectId:self.poiId];
}

#pragma mark - button action
- (IBAction)backButtonTapped:(id)sender
{
    [Flurry endTimedEvent:kFlurryShowQuizViewEventName withParameters:nil];
    //NSLog(@"ReturnItem: %ld", self.returnItem);
    [self.delegate viewController:self requestsShowing:self.returnItem];
}

#pragma mark - side menu delegate
- (void) sideMenu:(SideMenu *)menu didSelectItem:(SideMenuItem)item
{
    [Flurry endTimedEvent:kFlurryShowQuizViewEventName withParameters:nil];
    switch (item)
    {
        case SideMenuItemContent:
            [self.delegate viewController:self requestsShowing:ViewControllerItemInfo];
            break;
        case SideMenuItemFacts:
            [self.delegate viewController:self requestsShowing:ViewControllerItemFacts];
            break;
        default:
            break;
    }
}

#pragma mark - table view delegate / datasource

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *questionView = [tableView dequeueReusableCellWithIdentifier:@"sectionCell"];
    if (questionView == nil)
    {
        questionView = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sectionCell"];
    }
    [questionView setBackgroundColor:[UIColor clearColor]];
//    UITextView *textView = (UITextView *)[questionView viewWithTag:101];
    UILabel *label = (UILabel *) [questionView viewWithTag:101];
    label.text = [[self.quiz questionAtIndex:section] question];
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
    
    
    [label setFont:font];
    return questionView;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *text = [[self.quiz questionAtIndex:section] question];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    CGFloat height = 0;
    __block UIFont *font = [UIFont  systemFontOfSize:20];
    __block NSDictionary *attributes = @{NSFontAttributeName: font,
                                         NSParagraphStyleAttributeName: paragraphStyle};
//    [UIDevice executeOnIphone5:^{
//        font = [UIFont  systemFontOfSize:14];
//        attributes = @{NSFontAttributeName: font,
//                       NSParagraphStyleAttributeName: paragraphStyle};
//    }];
//    [UIDevice executeOnIphone4:^{
//        font = [UIFont  systemFontOfSize:14];
//        attributes = @{NSFontAttributeName: font,
//                       NSParagraphStyleAttributeName: paragraphStyle};
//    }];
//    
//    [UIDevice executeOnIphone6:^{
//        font = [UIFont  systemFontOfSize:16];
//        attributes = @{NSFontAttributeName: font,
//                       NSParagraphStyleAttributeName: paragraphStyle};
//    }];
//    
//    [UIDevice executeOnIphone6Plus:^{
//        font = [UIFont  systemFontOfSize:18];
//        attributes = @{NSFontAttributeName: font,
//                       NSParagraphStyleAttributeName: paragraphStyle};
//    }];
//    
//    [UIDevice executeOnIpad:^{
//        font = [UIFont  systemFontOfSize:22];
//        attributes = @{NSFontAttributeName: font,
//                       NSParagraphStyleAttributeName: paragraphStyle};
//    }];
    
    
    
    CGFloat width = CGRectGetWidth(tableView.frame) - (self.leftPageOffset + self.rightPageOffset) - 16.0f;
    
    CGRect bounds = [text boundingRectWithSize:CGSizeMake(width, 300.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
    
    
    height = bounds.size.height;
    NSLog(@"Frame: %@ %f", NSStringFromCGRect(bounds), height + 20);
    return height+20;
//    return IS_IPAD ? 100 : 50;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    return IS_IPAD ? 90 : 45;
    Question *question = [self.quiz questionAtIndex:indexPath.section];
    Answer *answer = [question answerAtIndex:indexPath.row];
    NSString *text = answer.answer;
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    CGFloat height = 0;
    __block UIFont *font = [UIFont  systemFontOfSize:20];
    __block NSDictionary *attributes = @{NSFontAttributeName: font,
                                         NSParagraphStyleAttributeName: paragraphStyle};
    //    [UIDevice executeOnIphone5:^{
    //        font = [UIFont  systemFontOfSize:14];
    //        attributes = @{NSFontAttributeName: font,
    //                       NSParagraphStyleAttributeName: paragraphStyle};
    //    }];
    //    [UIDevice executeOnIphone4:^{
    //        font = [UIFont  systemFontOfSize:14];
    //        attributes = @{NSFontAttributeName: font,
    //                       NSParagraphStyleAttributeName: paragraphStyle};
    //    }];
    //
    //    [UIDevice executeOnIphone6:^{
    //        font = [UIFont  systemFontOfSize:16];
    //        attributes = @{NSFontAttributeName: font,
    //                       NSParagraphStyleAttributeName: paragraphStyle};
    //    }];
    //
    //    [UIDevice executeOnIphone6Plus:^{
    //        font = [UIFont  systemFontOfSize:18];
    //        attributes = @{NSFontAttributeName: font,
    //                       NSParagraphStyleAttributeName: paragraphStyle};
    //    }];
    //
    //    [UIDevice executeOnIpad:^{
    //        font = [UIFont  systemFontOfSize:22];
    //        attributes = @{NSFontAttributeName: font,
    //                       NSParagraphStyleAttributeName: paragraphStyle};
    //    }];
    
    
    
    CGFloat width = CGRectGetWidth(tableView.frame) - (self.leftPageOffset + self.rightPageOffset) - 16.0f;
    
    CGRect bounds = [text boundingRectWithSize:CGSizeMake(width, 300.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
    
    
    height = bounds.size.height;
    NSLog(@"Frame: %@ %f", NSStringFromCGRect(bounds), height + 20);
    return MIN(100, MAX(50, height + 20)) * (IS_IPAD ? 2.0f : 1.0f);
    //    return IS_IPAD ? 100 : 50;

    
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.quiz questionAtIndex:section] numberOfAnswers];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.quiz numberOfQuestions];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"answerCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"answerCell"];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *label = (UILabel *)[cell viewWithTag:102];
    Question *question = [self.quiz questionAtIndex:indexPath.section];
    Answer *answer = [question answerAtIndex:indexPath.row];
    label.text = [answer answer];
    
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
    
    
    [label setFont:font];
    
    [label setTextColor:[UIColor blackColor]];
    
    UIImageView *correct = (UIImageView *)[cell viewWithTag:103];
    correct.highlighted = !answer.correct;
    correct.hidden = !((question.userSelected && answer.correct) || (question.userSelected && answer.userSelected));
    
    UIImageView *selected =(UIImageView *)[cell viewWithTag:101];
    selected.highlighted = answer.userSelected;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[tableView deselectRowAtIndexPath:indexPath animated:NO];
    Question *question = [self.quiz questionAtIndex:indexPath.section];
    if (question.userSelected)
    {
        return;
    }
    Answer *answer = [question answerAtIndex:indexPath.row];
    answer.userSelected = YES;
    question.userSelected = YES;
    
    [tableView reloadData];
    
}

#pragma mark - textview delegate
- (void)textViewDidChange:(UITextView *)textView
{
    //NSLog(@"Textview did change");
   // NSLog(@"Height before %f", textView.frame.size.height);
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    self.tableView.tableHeaderView = textView;
   // NSLog(@"Height after %f", textView.frame.size.height);
}

- (void) prepareStop
{
    
}

@end
