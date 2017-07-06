//
//  PointOfInterestConnection.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 23/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "PointOfInterestConnection.h"

@implementation PointOfInterestConnection

- (id)initWithCoder:(NSCoder *)decoder // NSCoding deserialization
{
    if ((self = [super init]))
	{
		self.sourceId = [decoder decodeObjectForKey:@"sourceId"];
		self.destId = [decoder decodeObjectForKey:@"destId"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder // NSCoding serialization
{
	[encoder encodeObject:self.sourceId forKey:@"sourceId"];
	[encoder encodeObject:self.destId forKey:@"destId"];
}
@end
