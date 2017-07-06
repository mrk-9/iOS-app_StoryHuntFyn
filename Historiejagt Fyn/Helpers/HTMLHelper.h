//
//  HTMLHelper.h
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 22/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
@interface HTMLHelper : NSObject

+ (NSString *)dialogHtmlFromBodyString:(NSString *)htmlBodyString;

/*!
 *  Generate a html string with a specific font and text color
 *
 *  @param htmlBodyString HTML text to format
 *  @param font           Font to use
 *  @param textColor      Color to use
 *
 *  @return HTML document formatted with font and text color
 */
+ (NSString *)htmlFromBodyString:(NSString *)htmlBodyString
                        textFont:(UIFont *)font
                       textColor:(UIColor *)textColor;

/*!
 *  Generate html for content view
 *
 *  @param htmlBodyString Body part to insert in document
 *  @param title          Title to insert
 *  @param imageData      NSData representation for the image to show
 *  @param imageTitle     Title for the image
 *  @param videoUrl       ID for the youtube video
 *  @param videoTitle     Title for the video
 *
 *  @return HTML document in string form
 */
+ (NSString *)htmlForContentView:(NSString *)htmlBodyString
						   title:(NSString *) title
						   image:(NSData *)imageData
					  imageTitle:(NSString *) imageTitle
						videoUrl:(NSString *)videoUrl
					  videoTitle:(NSString *) videoTitle
				   avatarEnabled:(BOOL) avatarEnabled;

@end
