//
//  CachingTileOverlay.h
//  Historiejagten Fyn
//
//  Created by Gert Lavsen on 16/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <MapKit/MapKit.h>
#ifndef __CACHINGTILEOVERLAY_H__
#define __CACHINGTILEOVERLAY_H__
extern NSString * const CachingTileOverlayLoadsTileForZoomLevel;
#endif

@interface CachingTileOverlay : MKTileOverlay
@property (nonatomic, strong) NSCache *cache;
@property (nonatomic, strong) NSOperationQueue *operationQueue;


@end
