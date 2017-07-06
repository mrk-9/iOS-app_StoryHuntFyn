//
//  Annotation.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 24/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "PointOfInterest.h"
#import "Route.h"
@interface Annotation : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *subtitle;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, strong) PointOfInterest *pointOfInterest;
@property (nonatomic, strong) Route *route;
@property (nonatomic, readonly) BOOL routeAnnotation;
@property (nonatomic, readonly) BOOL pointOfInterestAnnotation;
@property (nonatomic, assign) CLLocationDistance lastKnownDistanceToUser;
@property (nonatomic, assign) BOOL insideRegion;
- (id)initWithPointOfInterest:(PointOfInterest *)pointOfInterest forRoute:(Route *)route active:(BOOL) active;


@end
