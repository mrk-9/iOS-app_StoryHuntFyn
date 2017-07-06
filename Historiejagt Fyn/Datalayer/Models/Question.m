//
//  Question.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "Question.h"

@implementation Question

- (id) init
{
	self = [super init];
	if (self)
	{
		self.userSelected = NO;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder // NSCoding deserialization
{
    if ((self = [super init]))
	{
		self.updatedAt = [decoder decodeObjectForKey:@"updatedAt"];
		self.objectId = [decoder decodeObjectForKey:@"objectId"];
		self.question = [decoder decodeObjectForKey:@"question"];
		self.answers = [decoder decodeObjectForKey:@"answers"];
		self.userSelected = NO;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder // NSCoding serialization
{
	[encoder encodeObject:self.objectId forKey:@"objectId"];
	[encoder encodeObject:self.updatedAt forKey:@"updatedAt"];
	[encoder encodeObject:self.question forKey:@"question"];
	[encoder encodeObject:self.answers forKey:@"answers"];
}

- (NSInteger) numberOfAnswers
{
	return [self.answers count];
}

- (Answer *) answerAtIndex:(NSInteger) index
{
	return (Answer*) [self.answers objectAtIndex:index];
}

@end
