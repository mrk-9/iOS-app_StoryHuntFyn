//
//  CachingTileOverlay.m
//  Historiejagten Fyn
//
//  Created by Gert Lavsen on 16/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "CachingTileOverlay.h"
#import <HOCReachabilityHelper-ios/HOCReachabilityHelper.h>
NSString * const CachingTileOverlayLoadsTileForZoomLevel = @"LoadsTileForZoomLevel";
@interface CachingTileOverlay()
@property (nonatomic, readonly) BOOL online;

@end

@implementation CachingTileOverlay

- (id) init
{
	if (self = [super init])
	{
        
	}
	return self;
}

- (NSURL *)URLForTilePath:(MKTileOverlayPath)path
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://c.tile.openstreetmap.org/%ld/%ld/%ld.png", (long)path.z, (long)path.x, (long)path.y]];
}

- (NSString *)pathForPreCachedTile:(MKTileOverlayPath)path
{
	return [NSString stringWithFormat:@"%@/tiles/%ld/%ld/%ld.png", [[NSBundle mainBundle] bundlePath], (long)path.z, (long)path.x, (long)path.y];
}

- (NSString *)pathForSavedTile:(MKTileOverlayPath) path
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	return [NSString stringWithFormat:@"%@/tiles/%ld/%ld/%ld.png", documentsDirectory, (long)path.z, (long)path.x, (long)path.y];
}
- (NSCache *) cache
{
	if (!_cache)
	{
		_cache = [[NSCache alloc] init];
	}
	return _cache;
}

- (NSOperationQueue *) operationQueue
{
	if (!_operationQueue)
	{
		_operationQueue = [[NSOperationQueue alloc]init];
	}
	return _operationQueue;
}

- (void) storeLoadedTile:(NSData *)tile forPath:(MKTileOverlayPath) path
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *dir = [NSString stringWithFormat:@"%@/tiles/%ld/%ld", documentsDirectory, (long)path.z, (long)path.x];
	NSError *error = nil;
	if (![[NSFileManager defaultManager] fileExistsAtPath:dir])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
		
	}
	if (!error)
	{
		[tile writeToFile:[self pathForSavedTile:path] atomically:YES];
	}
	else
	{
		//NSLog(@"Error %@", error);
	}

}


- (void)loadTileAtPath:(MKTileOverlayPath)path
                result:(void (^)(NSData *data, NSError *error))result
{
    if (self.online)
    {
        result(nil, nil);
    }
    
    
    if (!result)
	{
        return;
    }
	NSDictionary* dict = [NSDictionary dictionaryWithObject: [NSNumber numberWithInteger:path.z] forKey:@"zoomLevel"];
	[[NSNotificationCenter defaultCenter] postNotificationName:CachingTileOverlayLoadsTileForZoomLevel object:self userInfo:dict];

	// check if precached file exist
	NSString *tilePath = [self pathForPreCachedTile:path];
	if ([[NSFileManager defaultManager] fileExistsAtPath:tilePath])
	{
		//NSLog(@"Precached tile for %d/%d/%d", path.z, path.x, path.y);
        if (!self.online)
        {
            result([[NSFileManager defaultManager] contentsAtPath:tilePath], nil);
        }
    }
	else
	{
		tilePath = [self pathForSavedTile:path];
		if ([[NSFileManager defaultManager] fileExistsAtPath:tilePath])
		{
			//NSLog(@"Saved tile for %d/%d/%d", path.z, path.x, path.y);
            if (!self.online)
            {
                result([[NSFileManager defaultManager] contentsAtPath:tilePath], nil);
            }
		}
		else
		{
			//NSLog(@"Loading tile for %d/%d/%d", path.z, path.x, path.y);
			NSURLRequest *request = [NSURLRequest  requestWithURL:[self URLForTilePath:path]];
			[NSURLConnection sendAsynchronousRequest:request queue:self.operationQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
			 {
                 if (!self.online)
                 {
                     result(data, connectionError);
                 }
				 [self storeLoadedTile:data forPath:path];
			 }];
		}
	}
}

- (BOOL) canReplaceMapContent
{
    return NO;
}


- (BOOL) online
{
    return [HOCReachabilityHelper isReachable];
}
@end
