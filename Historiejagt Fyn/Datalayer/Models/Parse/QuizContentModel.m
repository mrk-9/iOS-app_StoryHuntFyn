//
//  QuizContentModel.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 08/05/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "QuizContentModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation QuizContentModel
@dynamic questions;
@dynamic header;
@dynamic language;

+(NSString *)parseClassName
{
	return @"QuizContent";
}
@end
