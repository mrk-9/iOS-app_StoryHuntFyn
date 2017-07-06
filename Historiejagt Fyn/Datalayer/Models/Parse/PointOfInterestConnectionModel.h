//
//  PointOfInterestConnectionModel.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 18/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "PointOfInterestModel.h"
@interface PointOfInterestConnectionModel : PFObject<PFSubclassing>
@property (nonatomic, retain) PointOfInterestModel *source;
@property (nonatomic, retain) PointOfInterestModel *destination;

+ (NSString *) parseClassName;


@end
