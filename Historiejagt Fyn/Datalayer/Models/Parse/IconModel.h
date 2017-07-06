//
//  IconModel.h
//  Kultur i bevægelse
//
//  Created by Gert Lavsen on 04/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface IconModel : PFObject<PFSubclassing>
// Base properties
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *iconId;
@property (nonatomic, retain) PFFile *icon;
@property (nonatomic, retain) PFFile *iconRetina;
@property (nonatomic, retain) PFFile *pin;
@property (nonatomic, retain) PFFile *pinRetina;
@property (nonatomic, retain) PFFile *pinInactive;
@property (nonatomic, retain) PFFile *pinInactiveRetina;

@property (nonatomic, retain) PFFile *arPin;
@property (nonatomic, retain) PFFile *arPinRetina;
@property (nonatomic, retain) PFFile *arPinInactive;
@property (nonatomic, retain) PFFile *arPinInactiveRetina;
+ (NSString *) parseClassName;


@end
