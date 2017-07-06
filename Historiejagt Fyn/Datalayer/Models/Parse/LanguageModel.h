//
//  LanguageModel.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Parse/Parse.h>

@interface LanguageModel : PFObject<PFSubclassing>
@property (nonatomic, retain) NSString *language;
@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSArray *priorityList;
@property (nonatomic, assign) NSInteger priority;

@property (nonatomic, assign) BOOL active;
+ (NSString *) parseClassName;

@end
