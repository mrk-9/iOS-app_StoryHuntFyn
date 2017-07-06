//
//  Avatar.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 15/05/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "Avatar.h"
#import "DataFileHelper.h"

@implementation Avatar
- (id)initWithCoder:(NSCoder *)decoder // NSCoding deserialization
{
    if ((self = [super init]))
	{
		self.name = [decoder decodeObjectForKey:@"name"];
		self.updatedAt = [decoder decodeObjectForKey:@"updatedAt"];
		self.objectId = [decoder decodeObjectForKey:@"objectId"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder // NSCoding serialization
{
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.objectId forKey:@"objectId"];
	[encoder encodeObject:self.updatedAt forKey:@"updatedAt"];
}

- (void) setAvatar:(NSArray *)avatar {
	NSString *fileName = [NSString stringWithFormat:@"%@_avatars", self.objectId];
	[DataFileHelper saveArray:avatar named:fileName];
}

- (NSArray*) avatar {
	NSString *fileName = [NSString stringWithFormat:@"%@_avatars", self.objectId];
	return [DataFileHelper loadArrayNamed:fileName];
}

@end
