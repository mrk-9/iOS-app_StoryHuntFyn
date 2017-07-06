//
//  IconModel.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "IconModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation IconModel
@dynamic icon;
@dynamic iconRetina;
@dynamic pin;
@dynamic pinRetina;
@dynamic pinInactive;
@dynamic pinInactiveRetina;
@dynamic arPin;
@dynamic arPinInactive;
@dynamic arPinRetina;
@dynamic arPinInactiveRetina;

@dynamic iconId;
@dynamic name;

+(NSString *)parseClassName
{
	return @"Icon";
}
@end

