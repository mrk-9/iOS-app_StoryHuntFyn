//
//  DataFileHelper.h
//  Historiejagt Fyn
//
//  Created by Rasmus Styrk on 01/05/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataFileHelper : NSObject


+ (NSString *) applicationDocumentsDirectory;
+ (NSString*) bundleDirectory;

+ (void) saveData:(NSData *)data named:(NSString*)name;
+ (NSData*) loadDataNamed:(NSString*)name;


+ (void) saveArray:(NSArray*)array named:(NSString*)name;
+ (NSArray*) loadArrayNamed:(NSString*)name;

+ (BOOL) hasPreloadedFile:(NSString *) file;

@end
