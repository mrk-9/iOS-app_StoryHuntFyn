//
//  Route.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
@interface Route : NSObject
@property (nonatomic, retain) NSDate *contentUpdatedAt;
@property (nonatomic, retain) NSString *languageCode;
@property (nonatomic, retain,readonly) NSString *name;
@property (nonatomic, retain,readonly) NSString *info;
@property (nonatomic, retain,readonly) NSString *nameforlist;
@property (nonatomic, retain) NSDictionary *names;
@property (nonatomic, retain) NSDictionary *infos;
@property (nonatomic, retain) NSArray *namesforlist;


/** Array of objectIds for pointOfInterests */
@property (nonatomic, retain) NSArray *pointOfInterestIds;
@property (nonatomic, retain) NSString *avatarId;
@property (nonatomic, retain, readonly) NSArray *avatar;
@property (nonatomic, retain, readonly) NSData *icon;
@property (nonatomic, retain) NSData *iconRetina;
@property (nonatomic, retain) NSData *iconNonRetina;
@property (nonatomic, retain, readonly) NSData *pin;
@property (nonatomic, retain) NSData *pinRetina;
@property (nonatomic, retain) NSData *pinNonRetina;

@property (nonatomic, retain, readonly) NSData *pinInactive;
@property (nonatomic, retain) NSData *pinInactiveRetina;
@property (nonatomic, retain) NSData *pinInactiveNonRetina;

@property (nonatomic, retain, readonly) NSData *arPin;
@property (nonatomic, retain, readonly) NSData *arPinInactive;

@property (nonatomic, retain) NSData *arPinRetina;
@property (nonatomic, retain) NSData *arPinInactiveRetina;
@property (nonatomic, retain) NSData *arPinNonRetina;
@property (nonatomic, retain) NSData *arPinInactiveNonRetina;

@property (nonatomic, retain) NSDictionary *routeCoordinates;


//@property (nonatomic, retain) NSData *

@property (nonatomic, assign) CLLocationCoordinate2D centerCoordinates;

@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSString *objectId;

@end
