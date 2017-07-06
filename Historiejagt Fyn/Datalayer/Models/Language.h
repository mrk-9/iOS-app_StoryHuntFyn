//
//  Language.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 18/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Language : NSObject
@property (nonatomic, retain) NSString *code;

// Other language object ids
@property (nonatomic, retain) NSArray *priority;

@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSString *objectId;
@end
