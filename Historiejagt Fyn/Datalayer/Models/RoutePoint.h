//
//  RoutePoint.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 03/04/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>

//#ifndef __ROUTEPOINT_H__
//#define __ROUTEPOINT_H__
//typedef enum
//{
//	kPercentage0,
//	kPercentage25,
//	kPercentage50,
//	kPercentage75,
//	kPercentage100
//} RoutePointPercentageBlock;
//
//#endif

@interface RoutePoint : NSObject

@property (nonatomic, retain, readonly) NSString *text25;
@property (nonatomic, retain, readonly) NSString *text50;
@property (nonatomic, retain, readonly) NSString *text75;
@property (nonatomic, retain, readonly) NSString *text100;

@property (nonatomic, retain) NSDictionary *text25s;
@property (nonatomic, retain) NSDictionary *text50s;
@property (nonatomic, retain) NSDictionary *text75s;
@property (nonatomic, retain) NSDictionary *text100s;


@property (nonatomic, retain) NSArray *pointOfInterestIds;
@property (nonatomic, retain) NSString *routeId;

@property (nonatomic, retain) NSString *languageCode;

@property (nonatomic, retain) NSDate *updatedAt;
@property (nonatomic, retain) NSString *objectId;
@end
