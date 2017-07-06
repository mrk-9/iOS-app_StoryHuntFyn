//
//  Question.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Answer.h"

@interface Question : NSObject
@property (nonatomic, retain) NSString *question;
// Array of answer objects
@property (nonatomic, retain) NSArray *answers;

@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSString *objectId;

@property (nonatomic, assign) BOOL userSelected;

- (id) init;


- (NSInteger) numberOfAnswers;
- (Answer *) answerAtIndex:(NSInteger) index;
@end
