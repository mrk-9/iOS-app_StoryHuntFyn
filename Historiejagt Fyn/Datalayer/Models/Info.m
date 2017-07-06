//
//  Info.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 05/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "Info.h"
#import "LanguageContentHelper.h"

@implementation Info

- (id)initWithCoder:(NSCoder *)decoder // NSCoding deserialization
{
    if ((self = [super init]))
	{
		self.titles = [decoder decodeObjectForKey:@"titles"];
		self.texts = [decoder decodeObjectForKey:@"texts"];
		self.languageCode = [decoder decodeObjectForKey:@"languageCode"];
		self.updatedAt = [decoder decodeObjectForKey:@"updatedAt"];
		self.objectId = [decoder decodeObjectForKey:@"objectId"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder // NSCoding serialization
{
	[encoder encodeObject:self.titles forKey:@"titles"];
	[encoder encodeObject:self.texts forKey:@"texts"];
	[encoder encodeObject:self.languageCode forKey:@"languageCode"];
	[encoder encodeObject:self.objectId forKey:@"objectId"];
	[encoder encodeObject:self.updatedAt forKey:@"updatedAt"];
}

- (NSString *) title
{
	return [LanguageContentHelper contentForObject:self.titles];
}

- (NSString *) text
{
	return [LanguageContentHelper contentForObject:self.texts];
}

@end
