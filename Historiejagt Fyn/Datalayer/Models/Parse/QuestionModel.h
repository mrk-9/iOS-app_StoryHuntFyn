//
//  QuestionModel.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Parse/Parse.h>
#import "LanguageModel.h"
@interface QuestionModel : PFObject<PFSubclassing>

@property (nonatomic, retain) NSString *question;
@property (nonatomic, retain) PFRelation *answers;

+ (NSString *) parseClassName;

@end
