//
//  LanguageModel.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "LanguageModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation LanguageModel
@dynamic language;
@dynamic code;
@dynamic priorityList;
@dynamic active;
@dynamic priority;

+(NSString *)parseClassName
{
	return @"Language";
}

@end
