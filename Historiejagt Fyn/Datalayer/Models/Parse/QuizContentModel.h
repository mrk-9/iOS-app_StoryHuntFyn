//
//  QuizContentModel.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 08/05/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LanguageModel.h"
#import <Parse/Parse.h>

@interface QuizContentModel : PFObject<PFSubclassing>

@property (nonatomic, retain) NSString *header;
@property (nonatomic, retain) LanguageModel *language;
@property (nonatomic, retain) PFRelation *questions;
+ (NSString *) parseClassName;

@end
