//
//  AnnotationView.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 24/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "AnnotationView.h"

@implementation AnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (BOOL) draggable
{
	return false;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.centerOffset = CGPointMake(0, -self.image.size.height/2.5f);
}

@end
