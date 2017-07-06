//
//  PointOfInterest.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "PointOfInterest.h"
#import "LanguageContentHelper.h"
#import "DataFileHelper.h"

@implementation PointOfInterest
- (id)initWithCoder:(NSCoder *)decoder // NSCoding deserialization
{
    if ((self = [super init]))
	{
		self.languageCode = [decoder decodeObjectForKey:@"languageCode"];
		self.contentUpdatedAt = [decoder decodeObjectForKey:@"contentUpdatedAt"];

		self.titles = [decoder decodeObjectForKey:@"titles"];
		self.infos = [decoder decodeObjectForKey:@"infos"];
		self.factss = [decoder decodeObjectForKey:@"factss"];
		self.imageTitles = [decoder decodeObjectForKey:@"imageTitles"];
        self.factsImageTitles = [decoder decodeObjectForKey:@"factsImageTitles"];
		self.videoTitles = [decoder decodeObjectForKey:@"videoTitles"];
		self.autoplay = [decoder decodeBoolForKey:@"autoplay"];
		self.pointAwarding = [decoder decodeBoolForKey:@"pointAwarding"];
		CLLocationDegrees latitude = (CLLocationDegrees)[(NSNumber*)[decoder decodeObjectForKey:@"latitude"] doubleValue];
		CLLocationDegrees longitude = (CLLocationDegrees)[(NSNumber*)[decoder decodeObjectForKey:@"longitude"] doubleValue];
		self.coordinates = (CLLocationCoordinate2D) { latitude, longitude };
		self.videoURL = [decoder decodeObjectForKey:@"videoUrl"];
//		self.audio = [decoder decodeObjectForKey:@"audio"];
//		self.largeImage = [decoder decodeObjectForKey:@"largeImage"];
//		self.image = [decoder decodeObjectForKey:@"image"];
		self.quizId = [decoder decodeObjectForKey:@"quizId"];
		
		self.parentPOI = [decoder decodeObjectForKey:@"parentPOI"];
		self.unlockPOI = [decoder decodeObjectForKey:@"unlockPOI"];
		
		self.mapRange = [decoder decodeIntegerForKey:@"mapRange"];
		self.arRange = [decoder decodeIntegerForKey:@"arRange"];
		self.clickRange = [decoder decodeIntegerForKey:@"clickRange"];
		self.autoRange = [decoder decodeIntegerForKey:@"autoRange"];
		
		self.updatedAt = [decoder decodeObjectForKey:@"updatedAt"];
		self.objectId = [decoder decodeObjectForKey:@"objectId"];
        self.parentPoint = [decoder decodeBoolForKey:@"parentPoint"];
		self.noAvatar = [decoder decodeBoolForKey:@"noAvatar"];
		self.avatarId = [decoder decodeObjectForKey:@"avatarId"];
//		self.avatar = [decoder decodeObjectForKey:@"avatar"];

		
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder // NSCoding serialization
{
	[encoder encodeObject:self.languageCode forKey:@"languageCode"];
	[encoder encodeObject:self.contentUpdatedAt forKey:@"contentUpdatedAt"];
	[encoder encodeObject:self.objectId forKey:@"objectId"];
	[encoder encodeObject:self.updatedAt forKey:@"updatedAt"];
	[encoder encodeObject:self.titles forKey:@"titles"];
	[encoder encodeObject:self.infos forKey:@"infos"];
	[encoder encodeObject:self.factss forKey:@"factss"];
	[encoder encodeObject:self.imageTitles forKey:@"imageTitles"];
	[encoder encodeObject:self.factsImageTitles forKey:@"factsImageTitles"];
	[encoder encodeObject:self.videoTitles forKey:@"videoTitles"];
	NSNumber *latitude = [NSNumber numberWithDouble:self.coordinates.latitude];
	NSNumber *longitude = [NSNumber numberWithDouble:self.coordinates.longitude];
	[encoder encodeObject:latitude forKey:@"latitude"];
	[encoder encodeObject:longitude forKey:@"longitude"];
	[encoder encodeObject:self.videoURL forKey:@"videoUrl"];
	[encoder encodeObject:self.quizId forKey:@"quizId"];
	[encoder encodeBool:self.autoplay forKey:@"autoplay"];
	[encoder encodeBool:self.pointAwarding forKey:@"pointAwarding"];
	
	[encoder encodeObject:self.parentPOI forKey:@"parentPOI"];
	[encoder encodeObject:self.unlockPOI forKey:@"unlockPOI"];
	
	[encoder encodeInteger:self.mapRange forKey:@"mapRange"];
	[encoder encodeInteger:self.arRange forKey:@"arRange"];
	[encoder encodeInteger:self.clickRange forKey:@"clickRange"];
	[encoder encodeInteger:self.autoRange forKey:@"autoRange"];
	[encoder encodeBool:self.parentPoint forKey:@"parentPoint"];
	[encoder encodeBool:self.noAvatar forKey:@"noAvatar"];
	[encoder encodeObject:self.avatarId forKey:@"avatarId"];
}

- (NSInteger)weight {
  return self.weight_active+self.weight_inactive;
}

- (NSString *) title
{
	return [LanguageContentHelper contentForObject:self.titles];
}


- (NSString *) info
{
	return [LanguageContentHelper contentForObject:self.infos];
}


- (NSString *) facts
{
	return [LanguageContentHelper contentForObject:self.factss];
}


- (NSString *) imageTitle
{
	return [LanguageContentHelper contentForObject:self.imageTitles];
}

- (NSString *) factsImageTitle
{
    return [LanguageContentHelper contentForObject:self.factsImageTitles];
}

- (NSString *) videoTitle
{
	return [LanguageContentHelper contentForObject:self.videoTitles];
}

- (void) setLargeImage:(NSData *)largeImage {
    NSString *fileName = [NSString stringWithFormat:@"%@_large", self.objectId];
    [DataFileHelper saveData:largeImage named:fileName];
}

- (NSData*) largeImage {
    NSString *fileName = [NSString stringWithFormat:@"%@_large", self.objectId];
    return [DataFileHelper loadDataNamed:fileName];
}

- (void) setImage:(NSData *)image {
    NSString *fileName = [NSString stringWithFormat:@"%@_image", self.objectId];
    [DataFileHelper saveData:image named:fileName];
}

- (NSData*) image
{
    NSString *fileName = [NSString stringWithFormat:@"%@_image", self.objectId];
    return [DataFileHelper loadDataNamed:fileName];
}

- (void) setFactsLargeImage:(NSData *)factsLargeImage
{
	NSString *fileName = [NSString stringWithFormat:@"%@_facts_large", self.objectId];
	[DataFileHelper saveData:factsLargeImage named:fileName];
}

- (NSData*) factsLargeImage
{
	NSString *fileName = [NSString stringWithFormat:@"%@_facts_large", self.objectId];
	return [DataFileHelper loadDataNamed:fileName];
}

- (void) setFactsImage:(NSData *)image
{
	NSString *fileName = [NSString stringWithFormat:@"%@_facts_image", self.objectId];
    NSLog(@"Sets facts Image: %@", fileName);
	[DataFileHelper saveData:image named:fileName];
}

- (NSData*) factsImage
{
	NSString *fileName = [NSString stringWithFormat:@"%@_facts_image", self.objectId];
    NSLog(@"Gets Facts image: %@", fileName);
	return [DataFileHelper loadDataNamed:fileName];
}

- (void) setAudio:(NSData *)audio {
	NSString *fileName = [NSString stringWithFormat:@"%@_audio", self.objectId];
	[DataFileHelper saveData:audio named:fileName];
}

- (NSData*) audio {
	NSString *fileName = [NSString stringWithFormat:@"%@_audio", self.objectId];
	return [DataFileHelper loadDataNamed:fileName];
}


- (NSArray*) avatar {
	if (self.avatarId)
	{
		NSString *fileName = [NSString stringWithFormat:@"%@_avatars", self.avatarId];
		return [DataFileHelper loadArrayNamed:fileName];
	}
	return nil;
}

- (CLCircularRegion *) geoRegion
{
    return [[CLCircularRegion alloc] initWithCenter:self.coordinates radius:self.autoRange identifier:self.objectId];
}

- (NSString *) arIdentifier
{
    return self.objectId;
}

- (CLLocation *) arLocation
{
    return [[CLLocation alloc] initWithLatitude:self.coordinates.latitude longitude:self.coordinates.longitude];
}

- (CLLocationDistance) arMaxDistance
{
    return self.arRange;
}
@end
