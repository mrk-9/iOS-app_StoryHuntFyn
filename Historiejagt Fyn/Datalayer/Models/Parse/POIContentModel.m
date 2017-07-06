//
//  POIContentModel.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "POIContentModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation POIContentModel
@dynamic info;
@dynamic name;
@dynamic language;
@dynamic facts;
@dynamic imageTitle;
@dynamic factsImageTitle;
@dynamic videoTitle;

+(NSString *)parseClassName
{
	return @"POIContent";
}
@end
