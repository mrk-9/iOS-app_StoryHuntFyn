//
//  QuestionModel.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "QuestionModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation QuestionModel

@dynamic question;
@dynamic answers;

+(NSString *)parseClassName
{
	return @"Question";
}
@end
