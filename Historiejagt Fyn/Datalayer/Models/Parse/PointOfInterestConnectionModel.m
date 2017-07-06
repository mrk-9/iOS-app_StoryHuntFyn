//
//  PointOfInterestConnectionModel.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 18/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "PointOfInterestConnectionModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation PointOfInterestConnectionModel
@dynamic source;
@dynamic destination;

+(NSString *)parseClassName
{
	return @"PointOfInterestConnection";
}
@end
