//
//  Avatar.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 15/05/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Avatar : NSObject
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSArray *avatar;

@end
