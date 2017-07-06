//
//  POIContentModel.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Parse/Parse.h>
#import "LanguageModel.h"
@interface POIContentModel : PFObject<PFSubclassing>
@property (nonatomic, retain) NSString *name;
//@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *info;
@property (nonatomic, retain) NSString *facts;
@property (nonatomic, retain) NSString *imageTitle;
@property (nonatomic, retain) NSString *factsImageTitle;
@property (nonatomic, retain) NSString *videoTitle;
@property (nonatomic, retain) LanguageModel *language;

+ (NSString *) parseClassName;

@end
