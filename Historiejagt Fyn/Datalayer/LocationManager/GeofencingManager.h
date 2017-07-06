//
//  GeofencingManager.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 27/01/15.
//  Copyright (c) 2015 Woerk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeofencingManager : NSObject

+ (instancetype) sharedInstance;
/*!
 * Checks if any poi is within its auto open range
 */
- (void) checkPois;
@end
