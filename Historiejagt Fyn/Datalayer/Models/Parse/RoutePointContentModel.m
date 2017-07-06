//
//  RoutePointContentModel.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 18/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "RoutePointContentModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation RoutePointContentModel
@dynamic text25;
@dynamic text50;
@dynamic text75;
@dynamic text100;
@dynamic language;

+(NSString *)parseClassName
{
	return @"RoutePointContent";
}
@end
