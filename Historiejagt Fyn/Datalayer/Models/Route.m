//
//  Route.m
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "Route.h"
#import "LanguageContentHelper.h"
#import "DataFileHelper.h"

@implementation Route
- (id)initWithCoder:(NSCoder *)decoder // NSCoding deserialization
{
    if ((self = [super init]))
	{
		self.languageCode = [decoder decodeObjectForKey:@"languageCode"];
		self.contentUpdatedAt = [decoder decodeObjectForKey:@"contentUpdatedAt"];
		self.updatedAt = [decoder decodeObjectForKey:@"updatedAt"];
		self.objectId = [decoder decodeObjectForKey:@"objectId"];
		self.names = [decoder decodeObjectForKey:@"names"];
		self.infos = [decoder decodeObjectForKey:@"infos"];
        self.namesforlist = [decoder decodeObjectForKey:@"namesforlist"];
		self.pointOfInterestIds = [decoder decodeObjectForKey:@"pointOfInterestIds"];
        self.iconRetina = [decoder decodeObjectForKey:@"iconRetina"];
        self.pinRetina = [decoder decodeObjectForKey:@"pinRetina"];
        self.pinInactiveRetina = [decoder decodeObjectForKey:@"pinInactiveRetina"];
        self.iconNonRetina = [decoder decodeObjectForKey:@"iconNonRetina"];
        self.pinNonRetina = [decoder decodeObjectForKey:@"pinNonRetina"];
        self.pinInactiveNonRetina = [decoder decodeObjectForKey:@"pinInactiveNonRetina"];
        self.routeCoordinates = [decoder decodeObjectForKey:@"routeCoordinates"];
		
		self.arPinRetina = [decoder decodeObjectForKey:@"arPinRetina"];
        self.arPinInactiveRetina = [decoder decodeObjectForKey:@"arPinInactiveRetina"];
        self.arPinNonRetina = [decoder decodeObjectForKey:@"arPinNonRetina"];
        self.arPinInactiveNonRetina = [decoder decodeObjectForKey:@"arPinInactiveNonRetina"];
		
		CLLocationDegrees latitude = (CLLocationDegrees)[(NSNumber*)[decoder decodeObjectForKey:@"latitude"] doubleValue];
		CLLocationDegrees longitude = (CLLocationDegrees)[(NSNumber*)[decoder decodeObjectForKey:@"longitude"] doubleValue];
		self.centerCoordinates = (CLLocationCoordinate2D) { latitude, longitude };
		self.avatarId = [decoder decodeObjectForKey:@"avatarId"];
	}
	return self;
}

-(NSData *)icon {
//    if (IS_RETINA) {
//        return self.iconRetina;
//    } else {
//        return self.iconNonRetina;
//    }
    return self.iconRetina;
}

-(NSData *)pin {
//    if (IS_RETINA) {
//        return self.pinRetina;
//    } else {
//        return self.pinNonRetina;
//    }
    return self.pinRetina;
}

-(NSData *)pinInactive {
//    if (IS_RETINA) {
//        return self.pinInactiveRetina;
//    } else {
//        return self.pinInactiveNonRetina;
//    }
    return self.pinInactiveRetina;
}

- (NSData *)arPin
{
//	if (IS_RETINA)
//	{
//		return self.arPinRetina;
//	}
//	else
//	{
//		return self.arPinNonRetina;
//	}
    return self.arPinRetina;
}

- (NSData *)arPinInactive
{
//	if (IS_RETINA)
//	{
//		return self.arPinInactiveRetina;
//	}
//	else
//	{
//		return self.arPinInactiveNonRetina;
//	}
    return self.arPinInactiveRetina;
}

- (NSString *) name
{
	return [LanguageContentHelper contentForObject:self.names];
}
- (NSString *) info
{
	return [LanguageContentHelper contentForObject:self.infos];
}

- (NSArray*) avatar {
	if (self.avatarId)
	{
		NSString *fileName = [NSString stringWithFormat:@"%@_avatars", self.avatarId];
		return [DataFileHelper loadArrayNamed:fileName];
	}
	return nil;
}

- (void)encodeWithCoder:(NSCoder *)encoder // NSCoding serialization
{
	[encoder encodeObject:self.languageCode forKey:@"languageCode"];
	[encoder encodeObject:self.objectId forKey:@"objectId"];
	[encoder encodeObject:self.contentUpdatedAt forKey:@"contentUpdateAt"];
	[encoder encodeObject:self.updatedAt forKey:@"updatedAt"];
	[encoder encodeObject:self.names forKey:@"names"];
	[encoder encodeObject:self.infos forKey:@"infos"];
    [encoder encodeObject:self.namesforlist forKey:@"namesforlist"];
	[encoder encodeObject:self.pointOfInterestIds forKey:@"pointOfInterestIds"];
	[encoder encodeObject:self.iconRetina forKey:@"iconRetina"];
	[encoder encodeObject:self.iconNonRetina forKey:@"iconNonRetina"];
	[encoder encodeObject:self.pinRetina forKey:@"pinRetina"];
	[encoder encodeObject:self.pinNonRetina forKey:@"pinNonRetina"];
	[encoder encodeObject:self.pinInactiveRetina forKey:@"pinInactiveRetina"];
	[encoder encodeObject:self.pinInactiveNonRetina forKey:@"pinInactiveNonRetina"];
	
	[encoder encodeObject:self.arPinRetina forKey:@"arPinRetina"];
	[encoder encodeObject:self.arPinNonRetina forKey:@"arPinNonRetina"];
	[encoder encodeObject:self.arPinInactiveRetina forKey:@"arPinInactiveRetina"];
	[encoder encodeObject:self.arPinInactiveNonRetina forKey:@"arPinInactiveNonRetina"];
    [encoder encodeObject:self.routeCoordinates forKey:@"routeCoordinates"];
	NSNumber *latitude = [NSNumber numberWithDouble:self.centerCoordinates.latitude];
	NSNumber *longitude = [NSNumber numberWithDouble:self.centerCoordinates.longitude];
	[encoder encodeObject:latitude forKey:@"latitude"];
	[encoder encodeObject:longitude forKey:@"longitude"];
	[encoder encodeObject:self.avatarId forKey:@"avatarId"];
}

@end
