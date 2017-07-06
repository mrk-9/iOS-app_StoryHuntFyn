//
//  RouteModel.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 18/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "RouteModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation RouteModel
@dynamic name;
@dynamic contents;
@dynamic centerCoordinates;
@dynamic icon;
@dynamic pointOfInterests;
@dynamic avatar;

+(NSString *)parseClassName
{
	return @"Route";
}

@end
