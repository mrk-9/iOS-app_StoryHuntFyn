//
//  MKPolyline+MKPolyline_NSCoding.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 18/02/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKPolyline (MKPolyline_NSCoding)

+ (instancetype) instanceWithPointArray:(NSArray *) array;

- (NSArray *) arrayValue;
@end
