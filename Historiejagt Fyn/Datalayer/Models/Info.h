//
//  Info.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 05/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Info : NSObject
@property (nonatomic, retain, readonly) NSString *title;
@property (nonatomic, retain, readonly) NSString *text;
@property (nonatomic, retain) NSDictionary *titles;
@property (nonatomic, retain) NSDictionary *texts;
@property (nonatomic, retain) NSString *languageCode;

@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSString *objectId;

@end
