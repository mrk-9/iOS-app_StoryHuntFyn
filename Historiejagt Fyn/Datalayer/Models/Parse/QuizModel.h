//
//  QuizModel.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Parse/Parse.h>

@interface QuizModel : PFObject<PFSubclassing>

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) PFRelation *contents;

+ (NSString *) parseClassName;

@end
