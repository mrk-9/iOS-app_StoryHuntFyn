//
//  MKPolyline+MKPolyline_NSCoding.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 18/02/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "MKPolyline+MKPolyline_NSCoding.h"

@implementation MKPolyline (MKPolyline_NSCoding)

+ (instancetype) instanceWithPointArray:(NSArray *) array
{
    NSUInteger numPoints = [array count];
    if (numPoints > 1)
    {
        MKMapPoint* coords = malloc(numPoints * sizeof(MKMapPoint));
        NSUInteger i = 0;
        for (NSDictionary *dict in array)
        {
            MKMapPoint coord = MKMapPointMake([[dict valueForKey:@"lat"] doubleValue], [[dict valueForKey:@"lng"] doubleValue]);

            
            coords[i++] = coord;
        }
        MKPolyline *polyline = [MKPolyline polylineWithPoints:coords count:numPoints];
        free(coords);
        return polyline;
    }
    return nil;
}



- (NSArray *) arrayValue
{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(int i = 0; i < self.pointCount; i++)
    {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:self.points[i].x], @"lat", [NSNumber numberWithDouble:self.points[i].y], @"lng", nil];
        [arr addObject:dict];
    }
    return arr;
}


@end
