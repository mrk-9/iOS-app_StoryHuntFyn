//
//  RoutePointContentModel.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 18/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "LanguageModel.h"

@interface RoutePointContentModel : PFObject<PFSubclassing>
@property (nonatomic, retain) NSString *text25;
@property (nonatomic, retain) NSString *text50;
@property (nonatomic, retain) NSString *text75;
@property (nonatomic, retain) NSString *text100;
@property (nonatomic, retain) LanguageModel *language;

+ (NSString *) parseClassName;
@end
