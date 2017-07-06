//
//  AvatarModel.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface AvatarModel : PFObject<PFSubclassing>
// Base properties
@property (nonatomic, retain) NSString *avatar;
@property (nonatomic, retain) PFFile *image1;
@property (nonatomic, retain) PFFile *image2;
@property (nonatomic, retain) PFFile *image3;
+ (NSString *) parseClassName;

@end
