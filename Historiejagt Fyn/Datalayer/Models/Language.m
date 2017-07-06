//
//  Language.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 18/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "Language.h"

@implementation Language

- (id)initWithCoder:(NSCoder *)decoder // NSCoding deserialization
{
    if ((self = [super init]))
	{
		self.code = [decoder decodeObjectForKey:@"code"];
		self.priority = [decoder decodeObjectForKey:@"priority"];
		self.updatedAt = [decoder decodeObjectForKey:@"updatedAt"];
		self.objectId = [decoder decodeObjectForKey:@"objectId"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder // NSCoding serialization
{
	[encoder encodeObject:self.code forKey:@"code"];
	[encoder encodeObject:self.priority forKey:@"priority"];
	[encoder encodeObject:self.objectId forKey:@"objectId"];
	[encoder encodeObject:self.updatedAt forKey:@"updatedAt"];
}

@end
