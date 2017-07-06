//
//  ImageModel.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "ImageModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation ImageModel
@dynamic name;
@dynamic image;
@dynamic cropped;
@dynamic x1;
@dynamic x2;
@dynamic y1;
@dynamic y2;
@dynamic height;
@dynamic width;

+(NSString *)parseClassName
{
	return @"Image";
}
@end
