//
//  BaseroutAPI.h
//  Historiejagt Fyn
//
//  Created by thomas_leomobile on 10/04/16.
//  Copyright © 2016 thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseroutAPI : NSObject
+ (BaseroutAPI*) sharedInstance;

- (void) setVar:(NSString *)key theValue:(NSString*)value;
- (NSString *) getVar:(NSString *)key;

- (void) setObj:(NSString *)key theObject:(id)value;
- (id) getObj:(NSString *)key;
- (void) MessageBox : (NSString*) title Message:(NSString*) message;

@end
