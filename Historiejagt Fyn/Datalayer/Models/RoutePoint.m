//
//  RoutePoint.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 03/04/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "RoutePoint.h"
#import "LanguageContentHelper.h"

@implementation RoutePoint

- (id)initWithCoder:(NSCoder *)decoder // NSCoding deserialization
{
    if ((self = [super init]))
	{
		self.text25s  = [decoder decodeObjectForKey:@"text25s"];
		self.text50s  = [decoder decodeObjectForKey:@"text50s"];
		self.text75s  = [decoder decodeObjectForKey:@"text75s"];
		self.text100s = [decoder decodeObjectForKey:@"text100s"];

		self.pointOfInterestIds = [decoder decodeObjectForKey:@"pointOfInterestIds"];
		self.routeId = [decoder decodeObjectForKey:@"routeId"];
		self.languageCode = [decoder decodeObjectForKey:@"languageCode"];
		self.updatedAt = [decoder decodeObjectForKey:@"updatedAt"];
		self.objectId = [decoder decodeObjectForKey:@"objectId"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder // NSCoding serialization
{
	[encoder encodeObject:self.text25s forKey:@"text25s"];
	[encoder encodeObject:self.text50s forKey:@"text50s"];
	[encoder encodeObject:self.text75s forKey:@"text75s"];
	[encoder encodeObject:self.text100s forKey:@"text100s"];
	
	[encoder encodeObject:self.pointOfInterestIds forKey:@"pointOfInterestIds"];
	[encoder encodeObject:self.routeId forKey:@"routeId"];
	[encoder encodeObject:self.languageCode forKey:@"languageCode"];
	[encoder encodeObject:self.objectId forKey:@"objectId"];
	[encoder encodeObject:self.updatedAt forKey:@"updatedAt"];
}

- (NSString *) text25
{
	return [LanguageContentHelper contentForObject:self.text25s];
}

- (NSString *) text50
{
	return [LanguageContentHelper contentForObject:self.text50s];
}

- (NSString *) text75
{
	return [LanguageContentHelper contentForObject:self.text75s];
}

- (NSString *) text100
{
	return [LanguageContentHelper contentForObject:self.text100s];
}

@end
