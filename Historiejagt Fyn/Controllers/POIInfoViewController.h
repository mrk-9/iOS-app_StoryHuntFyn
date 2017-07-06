//
//  POIInfoViewController.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 28/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
typedef NS_ENUM(NSUInteger, POIInfoType)
{
    POIInfoTypeInfo = 0,
    POIInfoTypeFacts = 1,
};

@interface POIInfoViewController : BaseViewController
@property (nonatomic, assign) ViewControllerItems returnItem;
@property (nonatomic, assign) POIInfoType showType;
@property (nonatomic, strong) NSString *poiId;
@end
