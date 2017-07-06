//
//  Quiz.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "Quiz.h"
#import "LanguageContentHelper.h"

@implementation Quiz
- (id)initWithCoder:(NSCoder *)decoder // NSCoding deserialization
{
    if ((self = [super init]))
	{
		self.updatedAt = [decoder decodeObjectForKey:@"updatedAt"];
		self.objectId = [decoder decodeObjectForKey:@"objectId"];
		self.name = [decoder decodeObjectForKey:@"name"];
		self.questionss = [decoder decodeObjectForKey:@"questionss"];
		self.headers = [decoder decodeObjectForKey:@"headers"];

		
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder // NSCoding serialization
{
	[encoder encodeObject:self.objectId forKey:@"objectId"];
	[encoder encodeObject:self.updatedAt forKey:@"updatedAt"];
	[encoder encodeObject:self.name forKey:@"name"];
	[encoder encodeObject:self.questionss forKey:@"questionss"];
	[encoder encodeObject:self.headers forKey:@"headers"];
}

- (NSArray *) questions
{
	return [LanguageContentHelper contentForObject:self.questionss];
}

- (NSString *) header
{
	return [LanguageContentHelper contentForObject:self.headers];
}

- (NSInteger) numberOfQuestions
{
	return [self.questions count];
}

- (NSInteger) numberOfAnswersForQuestionAtIndex:(NSInteger) index
{
	return [((Question *)[self questions]).answers count];
}

- (Question *)questionAtIndex:(NSInteger) index
{
	return [self.questions objectAtIndex:index];
}

@end
