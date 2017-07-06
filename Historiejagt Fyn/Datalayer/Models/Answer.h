//
//  Answer.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Answer : NSObject
@property (nonatomic, retain) NSString *answer;
@property (nonatomic, assign) BOOL correct;

@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSString *objectId;

// Used to keep track of the users answers in the tableView;
@property (nonatomic, assign) BOOL userSelected;

- (id) init;

@end
