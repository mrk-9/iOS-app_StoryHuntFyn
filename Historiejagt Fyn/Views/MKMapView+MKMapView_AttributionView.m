//
//  MKMapView+MKMapView_AttributionView.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 03/02/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "MKMapView+MKMapView_AttributionView.h"

@implementation MKMapView (MKMapView_AttributionView)
- (UIView*)attributionView
{
    for (UIView *subview in self.subviews)
    {
        if ([subview isKindOfClass:[UILabel class]])
        {
            return subview;
        }
    }
    return nil;
}
@end
