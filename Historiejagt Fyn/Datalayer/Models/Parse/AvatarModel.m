//
//  AvatarModel.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "AvatarModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation AvatarModel
@dynamic avatar;
@dynamic image1;
@dynamic image2;
@dynamic image3;

+(NSString *)parseClassName
{
	return @"Avatar";
}
@end

