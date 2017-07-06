//
//  RouteContentModel.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 18/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "LanguageModel.h"

@interface RouteContentModel : PFObject<PFSubclassing>
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *info;
@property (nonatomic, retain) LanguageModel *language;

+ (NSString *) parseClassName;
@end
