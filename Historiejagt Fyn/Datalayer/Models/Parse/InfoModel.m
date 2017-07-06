//
//  InfoModel.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "InfoModel.h"
#import <Parse/PFObject+Subclass.h>


@implementation InfoModel
@dynamic title;
@dynamic text;
@dynamic language;

+(NSString *)parseClassName
{
	return @"Info";
}
@end
