//
//  RoutePointModel.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 18/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "RouteModel.h"
@interface RoutePointModel : PFObject<PFSubclassing>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) PFRelation *contents;
@property (nonatomic, retain) PFRelation *pointOfInterests;
@property (nonatomic, retain) RouteModel *route;
+ (NSString *) parseClassName;
@end
