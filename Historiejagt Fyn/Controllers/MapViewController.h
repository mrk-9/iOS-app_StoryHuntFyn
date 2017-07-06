//
//  MapViewController.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 25/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface MapViewController : BaseViewController
@property (nonatomic, strong) NSString *routeId;
@property (nonatomic, assign) BOOL returnFromContentView;

@end
