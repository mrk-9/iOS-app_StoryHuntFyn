//
//  ImageModel.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ImageModel : PFObject<PFSubclassing>
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) PFFile *image;
@property (nonatomic, retain) PFFile *cropped;
@property (nonatomic, assign) NSInteger x1;
@property (nonatomic, assign) NSInteger y1;
@property (nonatomic, assign) NSInteger x2;
@property (nonatomic, assign) NSInteger y2;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, assign) NSInteger width;

+ (NSString *) parseClassName;
@end
