//
//  AnnotationView.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 24/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "PointOfInterest.h"
#import "Route.h"

@interface AnnotationView : MKAnnotationView

@property (nonatomic, strong) Route *route;
@property (nonatomic, assign) PointOfInterest *pointOfInterest;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, assign) BOOL groupPin;
@end
