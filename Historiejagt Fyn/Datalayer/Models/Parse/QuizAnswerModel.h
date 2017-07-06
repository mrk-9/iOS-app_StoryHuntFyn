//
//  QuizAnswerModel.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Parse/Parse.h>

@interface QuizAnswerModel : PFObject<PFSubclassing>

@property (nonatomic, retain) NSString *answer;
@property (nonatomic, assign) BOOL correct;

+ (NSString *) parseClassName;

@end
