//
//  CameraBaseViewController.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 12/02/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import "BaseViewController.h"
#import "PointBar.h"
@interface CameraBaseViewController : BaseViewController
@property (nonatomic, strong) UIView *preview;
@property (nonatomic, strong) UIImageView *overlay;

@end
