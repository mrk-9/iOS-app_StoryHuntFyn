//
//  QuizViewController.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 02/02/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface QuizViewController : BaseViewController
@property (nonatomic, assign) ViewControllerItems returnItem;
@property (nonatomic, strong) NSString *poiId;
@end
