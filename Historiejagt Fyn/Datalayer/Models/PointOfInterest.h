//
//  PointOfInterest.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Quiz.h"
#import "HOCARViewPoi.h"
@import MapKit;
@interface PointOfInterest : NSObject <HOCARViewPoi>


// Content
@property (nonatomic, retain) NSDate *contentUpdatedAt;
@property (nonatomic, retain) NSString *languageCode;
@property (nonatomic, retain, readonly) NSString *title;
@property (nonatomic, retain, readonly) NSString *info;
@property (nonatomic, retain, readonly) NSString *facts;
@property (nonatomic, retain, readonly) NSString *imageTitle;
@property (nonatomic, retain, readonly) NSString *factsImageTitle;
@property (nonatomic, retain, readonly) NSString *videoTitle;

@property (nonatomic, retain) NSDictionary *titles;
@property (nonatomic, retain) NSDictionary *infos;
@property (nonatomic, retain) NSDictionary *factss;
@property (nonatomic, retain) NSDictionary *imageTitles;
@property (nonatomic, retain) NSDictionary *factsImageTitles;
@property (nonatomic, retain) NSDictionary *videoTitles;

// General
@property (nonatomic, assign) BOOL autoplay;
@property (nonatomic, assign) BOOL pointAwarding;
@property (nonatomic, assign) CLLocationCoordinate2D coordinates;
@property (nonatomic, retain) NSString *videoURL;

// Audio
@property (nonatomic, retain) NSData *audio;

// Image
@property (nonatomic, retain) NSData *largeImage;
@property (nonatomic, retain) NSData *image;

@property (nonatomic, retain) NSData *factsLargeImage;
@property (nonatomic, retain) NSData *factsImage;

// Quiz
@property (nonatomic, retain) NSString *quizId;

// Ranges
@property (nonatomic, assign) NSInteger mapRange;
@property (nonatomic, assign) NSInteger arRange;
@property (nonatomic, assign) NSInteger clickRange;
@property (nonatomic, assign) NSInteger autoRange;


@property (nonatomic, retain) NSString *parentPOI;
@property (nonatomic, retain) NSString *unlockPOI;

@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSString *objectId;

@property (nonatomic, assign) BOOL parentPoint;
@property (nonatomic, assign) BOOL noAvatar;
@property (nonatomic, retain) NSString *avatarId;
@property (nonatomic, retain, readonly) NSArray *avatar;

// Used for zoom level filtering
@property (nonatomic) NSInteger zoomLevelMin;
@property (nonatomic) NSInteger zoomLevelMax;
@property (nonatomic) NSInteger weight_active;
@property (nonatomic) NSInteger weight_inactive;
@property (nonatomic) BOOL      isStack;
@property (nonatomic) BOOL      active;

- (NSInteger)weight;

// For use internal - pointer back to the route the poi belongs to.
@property (nonatomic, assign) NSString *routeId;

// For internal use - last known distance to user
@property (nonatomic, assign) CLLocationDistance lastKnownDistanceToUser;
// For internal use - unlocked
@property (nonatomic, assign) BOOL unlocked;
// FOr internal use - georegion
@property (nonatomic, readonly) CLCircularRegion *geoRegion;


#pragma mark - HOCARViewPoi
@property (nonatomic, readonly) NSString *arIdentifier;
@property (nonatomic, readonly) CLLocation *arLocation;
@property (nonatomic, assign) CLLocationDistance arMaxDistance;

@end
