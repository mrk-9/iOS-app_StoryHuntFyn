//
//  PointOfInterestModel.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Parse/Parse.h>
#import "POIContentModel.h"
#import "ImageModel.h"
#import "AvatarModel.h"
#import "QuizModel.h"

@interface PointOfInterestModel : PFObject<PFSubclassing>
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) PFGeoPoint *coordinates;
@property (nonatomic, assign) BOOL autoplay;
@property (nonatomic, assign) BOOL pointAwarding;
@property (nonatomic, retain) PFFile *audio;
@property (nonatomic, retain) NSString *videoURL;
@property (nonatomic, retain) ImageModel *image;
@property (nonatomic, retain) ImageModel *factsImage;
@property (nonatomic, retain) QuizModel *quiz;
@property (nonatomic, retain) PFRelation *contents;
@property (nonatomic, retain) PointOfInterestModel *parentPOI;
@property (nonatomic, retain) PointOfInterestModel *unlockPOI;
@property (nonatomic, assign) NSInteger mapRange;
@property (nonatomic, assign) NSInteger arRange;
@property (nonatomic, assign) NSInteger clickRange;
@property (nonatomic, assign) NSInteger autoRange;
@property (nonatomic, assign) BOOL parentPoint;
@property (nonatomic, assign) BOOL noAvatar;
@property (nonatomic, retain) AvatarModel *avatar;

+ (NSString *) parseClassName;

@end
