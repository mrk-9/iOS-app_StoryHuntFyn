//
//  RouteModel.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 18/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "AvatarModel.h"
#import "IconModel.h"

@interface RouteModel : PFObject<PFSubclassing>
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) AvatarModel *avatar;
@property (nonatomic, retain) IconModel *icon;
@property (nonatomic, retain) PFGeoPoint *centerCoordinates;
@property (nonatomic, retain) PFRelation *contents;
@property (nonatomic, retain) PFRelation *pointOfInterests;

+ (NSString *) parseClassName;
@end
