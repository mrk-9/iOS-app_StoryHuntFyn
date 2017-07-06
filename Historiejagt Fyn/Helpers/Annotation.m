//
//  Annotation.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 24/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "Annotation.h"

@interface Annotation()
@end

@implementation Annotation


- (id)initWithPointOfInterest:(PointOfInterest *)pointOfInterest forRoute:(Route *)route active:(BOOL) active
{
	self = [super init];
  if (self)
	{
		self.pointOfInterest = pointOfInterest;
		self.route = route;
		self.active = active;
    pointOfInterest.active = active;
	}
	return self;

}

- (CLLocationCoordinate2D) coordinate
{
	if (self.pointOfInterest)
	{
		return self.pointOfInterest.coordinates;
	}
	else
	{
		return self.route.centerCoordinates;
	}
}

- (NSString *) title
{
	if (self.pointOfInterest)
	{
		return self.pointOfInterest.title;
	}
	else
	{
		return self.route.name;
	}
}

- (NSString *) subtitle
{
	return @"";
}

- (BOOL) routeAnnotation
{
	return self.pointOfInterest == nil;
}

- (BOOL) pointOfInterestAnnotation
{
	return (self.pointOfInterest != nil);
}


@end
