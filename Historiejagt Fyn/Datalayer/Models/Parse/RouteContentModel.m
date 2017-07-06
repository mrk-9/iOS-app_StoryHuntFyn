//
//  RouteContentModel.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 18/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "RouteContentModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation RouteContentModel
@dynamic name;
@dynamic info;
@dynamic language;

+(NSString *)parseClassName
{
	return @"RouteContent";
}
@end
