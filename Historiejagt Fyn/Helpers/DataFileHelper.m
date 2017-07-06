//
//  DataFileHelper.m
//  Historiejagt Fyn
//
//  Created by Rasmus Styrk on 01/05/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "DataFileHelper.h"

@implementation DataFileHelper


+ (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSString*) bundleDirectory {
	return [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] bundlePath]];
}

+ (void) saveData:(NSData *)data named:(NSString *)name {
	
	//NSLog(@"Save data to disk");
	NSString *dir = [NSString stringWithFormat:@"%@/databasefiles", [DataFileHelper applicationDocumentsDirectory]];
	NSError *error = nil;

	if (![[NSFileManager defaultManager] fileExistsAtPath:dir])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
		
	}
	if (!error)
	{
		NSString *filename = [NSString stringWithFormat:@"%@/%@", dir, name];
		[data writeToFile:filename atomically:YES];
	}
}

+ (NSData*) loadDataNamed:(NSString *)name {
	NSString *documentPath = [NSString stringWithFormat:@"%@/databasefiles/%@", [DataFileHelper applicationDocumentsDirectory], name];
	NSString *bundlePath = [NSString stringWithFormat:@"%@/databasefiles/%@", [DataFileHelper bundleDirectory], name];
	
	//NSLog(@"Loading data from disk");
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath]) {
		return [[NSData alloc] initWithContentsOfFile:bundlePath];
	}
	else if ([[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
		return [[NSData alloc] initWithContentsOfFile:documentPath];
	}
	
	return nil;
}

+ (void) saveArray:(NSArray *)array named:(NSString *)name {
	
	//NSLog(@"Save array to disk");
	NSString *dir = [NSString stringWithFormat:@"%@/databasefiles", [DataFileHelper applicationDocumentsDirectory]];
	NSError *error = nil;
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:dir])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
		
	}
	if (!error)
	{

		NSString *filename = [NSString stringWithFormat:@"%@/%@", dir, name];
		[array writeToFile:filename atomically:YES];
	}
}

+ (NSArray*) loadArrayNamed:(NSString *)name {
	NSString *documentPath = [NSString stringWithFormat:@"%@/databasefiles/%@", [DataFileHelper applicationDocumentsDirectory], name];
	NSString *bundlePath = [NSString stringWithFormat:@"%@/databasefiles/%@", [DataFileHelper bundleDirectory], name];
	
	//NSLog(@"Loading array from disk %@ %@", documentPath, bundlePath);
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath])
	{
		NSArray *arr =  [[NSArray alloc] initWithContentsOfFile:bundlePath];
		return arr;
	}
	else if ([[NSFileManager defaultManager] fileExistsAtPath:documentPath])
	{
		NSArray *arr =  [[NSArray alloc] initWithContentsOfFile:documentPath];
		return arr;
	}
    //NSLog(@"NIL");
	return nil;
}

+ (BOOL) hasPreloadedFile:(NSString *) file
{
    NSString *bundlePath = [NSString stringWithFormat:@"%@/databasefiles/%@", [DataFileHelper bundleDirectory], file];
    //NSLog(@"Checks bundle: %@ -- %@", bundlePath, ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath]) ? @"YES" : @"NO");
    return ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath]);

}


@end
