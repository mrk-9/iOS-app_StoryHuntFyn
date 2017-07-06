//
//  QuizModel.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "QuizModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation QuizModel

@dynamic name;
@dynamic contents;

+(NSString *)parseClassName
{
	return @"Quiz";
}
@end
