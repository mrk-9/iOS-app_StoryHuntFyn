//
//  LanguageContentHelper.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 26/04/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "LanguageContentHelper.h"
#import "Language.h"
#import "AppDelegate.h"
#import "Datalayer.h"

@implementation LanguageContentHelper

+ (NSString *) bestFittingLanguageFromLanguageCodes:(NSArray *)codes;
{
    
    
	NSString *preferred = [[[Datalayer sharedInstance] language ]code];
	if ([codes containsObject:preferred])
	{
		return preferred;
	}
	else
	{
		NSString *fitting = [[Datalayer sharedInstance] bestLanguageCodeFromArrayOfCodes:codes];
		if (!fitting)
		{

			fitting = [codes firstObject];
		}
		return fitting;
	}
}

+ (id) contentForObject:(NSDictionary *)contents
{
	NSString *language = [self bestFittingLanguageFromLanguageCodes:[contents allKeys]];
	return [contents valueForKeyPath:language];
}
@end
