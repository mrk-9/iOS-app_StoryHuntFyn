//
//  InfoModel.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "LanguageModel.h"
@interface InfoModel : PFObject<PFSubclassing>
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) LanguageModel *language;
+ (NSString *) parseClassName;

@end
