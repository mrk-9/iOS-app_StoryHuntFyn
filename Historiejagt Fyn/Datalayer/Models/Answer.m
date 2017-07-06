//
//  Answer.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "Answer.h"

@implementation Answer

- (id) init
{
	self = [super init];
	if (self)
	{
		self.userSelected = NO;
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)decoder // NSCoding deserialization
{
    if ((self = [super init]))
	{
		self.answer = [decoder decodeObjectForKey:@"answer"];
		self.correct = [decoder decodeBoolForKey:@"correct"];
		self.objectId = [decoder decodeObjectForKey:@"updatedAt"];
		self.updatedAt = [decoder decodeObjectForKey:@"objectId"];
		self.userSelected = NO;
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)encoder // NSCoding serialization
{
    [encoder encodeObject:self.answer forKey:@"answer"];
    [encoder encodeObject:self.updatedAt forKey:@"updatedAt"];
    [encoder encodeObject:self.objectId forKey:@"objectId"];
    [encoder encodeBool:self.correct forKey:@"correct"];
}

@end
