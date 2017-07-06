//
//  RoutePointModel.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 18/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "RoutePointModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation RoutePointModel
@dynamic name;
@dynamic contents;
@dynamic pointOfInterests;
@dynamic route;

+(NSString *)parseClassName
{
	return @"RoutePoint";
}
@end
