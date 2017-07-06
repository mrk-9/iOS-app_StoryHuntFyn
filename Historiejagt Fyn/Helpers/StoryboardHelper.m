//
//  StoryboardHelper.m
//  WordBoard
//
//  Created by Gert Lavsen on 12/11/14.
//  Copyright (c) 2014 House of Code. All rights reserved.
//

#import "StoryboardHelper.h"
#import <UIKit/UIStoryboard.h>
@implementation StoryboardHelper

+ (id) getViewControllerWithId:(NSString *) identifier
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *storyboardName = [bundle objectForInfoDictionaryKey:@"UIMainStoryboardFile"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    
     return [storyboard instantiateViewControllerWithIdentifier:identifier];
}

@end
