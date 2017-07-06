//
//  QuizAnswerModel.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "QuizAnswerModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation QuizAnswerModel

@dynamic answer;
@dynamic correct;

+(NSString *)parseClassName
{
	return @"Answer";
}
@end
