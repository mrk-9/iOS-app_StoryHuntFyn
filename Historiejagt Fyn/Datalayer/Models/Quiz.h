//
//  Quiz.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Answer.h"
#import "Question.h"

@interface Quiz : NSObject
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain, readonly) NSString *header;
@property (nonatomic, retain) NSDictionary *headers;


//! Array of Question's
@property (nonatomic, retain) NSDictionary *questionss;
@property (nonatomic, retain, readonly) NSArray *questions;

@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSString *objectId;

- (NSInteger) numberOfQuestions;

- (NSInteger) numberOfAnswersForQuestionAtIndex:(NSInteger) index;

- (Question *)questionAtIndex:(NSInteger) index;

@end
