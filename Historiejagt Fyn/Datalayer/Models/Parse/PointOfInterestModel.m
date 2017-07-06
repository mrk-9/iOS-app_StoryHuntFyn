//
//  PointOfInterestModel.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "PointOfInterestModel.h"
#import <Parse/PFObject+Subclass.h>

@implementation PointOfInterestModel

@dynamic name;
@dynamic contents;
@dynamic autoplay;
@dynamic pointAwarding;
@dynamic coordinates;
@dynamic audio;
@dynamic image;
@dynamic factsImage;
@dynamic videoURL;
@dynamic quiz;
@dynamic parentPOI;
@dynamic unlockPOI;
@dynamic mapRange;
@dynamic arRange;
@dynamic clickRange;
@dynamic autoRange;
@dynamic parentPoint;
@dynamic noAvatar;
@dynamic avatar;

+(NSString *)parseClassName
{
	return @"PointOfInterest";
}
@end
