//
//  HTMLHelper.m
//  Historiejagt Fyn
//
//  Created by Gert Lavsen on 22/03/14.
//  Copyright (c) 2014 Woerk ApS. All rights reserved.
//

#import "HTMLHelper.h"
#import <uidevice-segmentation-ios/UIDevice+Segmentation.h>
@implementation HTMLHelper


+ (NSString *)dialogHtmlFromBodyString:(NSString *)htmlBodyString
{
	
	NSString *withOutXML;
	if ([htmlBodyString rangeOfString:@"<xml>"].location == NSNotFound)
	{
		withOutXML = htmlBodyString;
	}
	else
	{
		
		withOutXML = [htmlBodyString componentsSeparatedByString:@"</xml>"][1];
	}

	NSString *text = [self stripTags:withOutXML];
	text = [NSString stringWithFormat:@"%@...", [text componentsSeparatedByString:@"."][0]];
    
    __block UIFont *font = nil;
    [UIDevice executeOnIphone5:^{
        font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    }];
    [UIDevice executeOnIphone4:^{
        font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    }];
    
    [UIDevice executeOnIphone6:^{
        font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    }];
    
    [UIDevice executeOnIphone6Plus:^{
        font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    }];
    [UIDevice executeOnIpad:^{
        font = [UIFont fontWithName:@"HelveticaNeue" size:20];
    }];
    
    
	//UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 24 : 14];
	return [self htmlFromBodyString:text textFont:font textColor:[UIColor blackColor]];
}
+ (NSString *)stripTags:(NSString *)str
{
    NSMutableString *html = [NSMutableString stringWithCapacity:[str length]];
	
    NSScanner *scanner = [NSScanner scannerWithString:str];
    scanner.charactersToBeSkipped = NULL;
    NSString *tempText = nil;
	
    while (![scanner isAtEnd])
    {
        [scanner scanUpToString:@"<" intoString:&tempText];
		
        if (tempText != nil)
            [html appendString:tempText];
		
        [scanner scanUpToString:@">" intoString:NULL];
		
        if (![scanner isAtEnd])
            [scanner setScanLocation:[scanner scanLocation] + 1];
		
        tempText = nil;
    }
	
    return html;
}



+ (NSString *)htmlFromBodyString:(NSString *)htmlBodyString
                        textFont:(UIFont *)font
                       textColor:(UIColor *)textColor
{

    size_t numComponents = CGColorGetNumberOfComponents([textColor CGColor]);
    
    NSAssert(numComponents == 4 || numComponents == 2, @"Unsupported color format");
    
    // E.g. FF00A5
    NSString *colorHexString = nil;
    
    const CGFloat *components = CGColorGetComponents([textColor CGColor]);
    
    if (numComponents == 4)
    {
        unsigned int red = components[0] * 255;
        unsigned int green = components[1] * 255;
        unsigned int blue = components[2] * 255;
        colorHexString = [NSString stringWithFormat:@"%02X%02X%02X", red, green, blue];
    }
    else
    {
        unsigned int white = components[0] * 255;
        colorHexString = [NSString stringWithFormat:@"%02X%02X%02X", white, white, white];
    }
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
	{
		
	}
    NSString *HTML = [NSString stringWithFormat:@"<html>\n"
                      "<head>\n"
                      "<style type=\"text/css\">\n"
                      "body {font-family: \"%@\"; font-size: %@; color:#%@;}\n"
                      "</style>\n"
                      "</head>\n"
                      "<body>%@</body>\n"
                      "</html>",
                      font.familyName, @(font.pointSize), colorHexString, htmlBodyString];
    HTML = [HTML stringByReplacingOccurrencesOfString:@":::IMAGE_HERE:::" withString:@""];
	HTML = [HTML stringByReplacingOccurrencesOfString:@":::VIDEO_HERE:::" withString:@""];
    return HTML;
}

+ (NSString *)htmlForContentView:(NSString *)htmlBodyString title:(NSString *) title image:(NSData *)imageData imageTitle:(NSString *) imageTitle videoUrl:(NSString *)videoUrl videoTitle:(NSString *) videoTitle avatarEnabled:(BOOL) avatarEnabled
{
	NSError *error;
	NSString *css = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? @"stylesheet_ipad" : @"stylesheet" ofType:@"css"] encoding:NSASCIIStringEncoding error:&error];
	//NSLog(@"error css %@", error);
	css = [css stringByReplacingOccurrencesOfString:@"\n" withString:@" "]; // js dom inject doesn't accept line breaks, so remove them

	NSString *html = [[NSString alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? @"skeleton_ipad" : @"skeleton" ofType:@"html"] encoding:NSUTF8StringEncoding error:&error];
	//NSLog(@"error html %@", error);
	html = [html stringByReplacingOccurrencesOfString:@":::CSS:::" withString:css];
    __block NSString *titleFontSize = @"24";
    
    [UIDevice executeOnIphone5:^{
        titleFontSize = @"24";
    }];
    [UIDevice executeOnIphone4:^{
        titleFontSize = @"24";
    }];
    
    [UIDevice executeOnIphone6:^{
        titleFontSize = @"28";
    }];
    
    [UIDevice executeOnIphone6Plus:^{
        titleFontSize = @"30";
    }];
    [UIDevice executeOnIpad:^{
        titleFontSize = @"34";
    }];

    
    html = [html stringByReplacingOccurrencesOfString:@":::TITLEFONTSIZE:::" withString:titleFontSize];
	NSString *imageTag = avatarEnabled ? @"<div id=\"imageDiv\" class=\"image\"><div style=\"height:187px;min-height: 187px;\"></div></div>" : @"";
	NSString *videoTag = @"";
	html = [html stringByReplacingOccurrencesOfString:@":::TITLE:::" withString:title ? title : @""];
	
	NSString *bodyHTML = htmlBodyString;
	UIFont *font = [UIFont fontWithName:@"Markerfelt-Thin" size: ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 18 : 9];
	if (imageData)
	{
		// Image present - replace :::IMAGE_HERE::: with image block
		NSData *frameData = UIImagePNGRepresentation([UIImage imageNamed:([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? @"photo-template-ipad.png" : @"photo-template.png"]);
		 imageTag = [NSString stringWithFormat:
					 @"<div id=\"imageDiv\" class=\"image\">"
 					  "<a href=\"historiejagtfyn://imageClicked\">"
					  "<img src=\"data:image/png;base64,%@\" width=%dpx height=%dpx class=\"image-img\"/>"
					  "<img src=\"data:image/png;base64,%@\" width=%dpx height=%dpx class=\"image-frame\"  />"
					 "</a>"
					 "<div class=\"image-text\"><span style=\"font-family: '%@'; font-size: %@px; text-decoration:none;\">%@</span></div>"
					  "</div>"
					 , [imageData base64EncodedStringWithOptions:0]
					 , ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 254 : 127
					 , ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 236 : 118
					 , [frameData base64EncodedStringWithOptions:0]

					 , ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 354 : 177
					 , ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 374 : 188


					 , font.familyName
					 , @(font.pointSize)
					 , imageTitle
					 ];
	}
	bodyHTML = [bodyHTML stringByReplacingOccurrencesOfString:@":::IMAGE_HERE:::" withString:imageTag];
	
	if (videoUrl)
	{
	
		// We have a video url - replace :::VIDEO_HERE::: with video preview
		NSData *frameData = UIImagePNGRepresentation([UIImage imageNamed:@"video-template.png"]);
		NSData *buttonData = UIImagePNGRepresentation([UIImage imageNamed:([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ?  @"play-icon-ipad.png" : @"play-icon.png"]);
		videoTag = [NSString stringWithFormat:
					@"<div class=\"video-container\">"
					"<div class=\"video\">"
					"<img src=\"http://img.youtube.com/vi/%@/0.jpg\" width=%dpx height=%dpx class=\"video-img\"/>"
					"<img src=\"data:image/png;base64,%@\" width=%dpx height=%dpx class=\"video-frame\"  />"
					"<div class=\"video-text\"><span style=\"font-family: '%@'; font-size: %@px;\">%@</span></div>"
					"</div>"
					"<a href=\"historiejagtfyn://videoClicked\">"
					"<img src=\"data:image/png;base64,%@\" width=48px height=48px class=\"video-btn\"/>"
					"</a>"
					"</div>"
					, videoUrl
					, ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 386 : 193
					, ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 264 : 132
					, [frameData base64EncodedStringWithOptions:0]
					
					, ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 472 : 236
					, ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 402 : 201


					, font.familyName
					, @(font.pointSize)
					, videoTitle
					, [buttonData base64EncodedStringWithOptions:0]
					];
	}
	bodyHTML = [bodyHTML stringByReplacingOccurrencesOfString:@":::VIDEO_HERE:::" withString:videoTag];
	
	html = [html stringByReplacingOccurrencesOfString:@":::BODY:::" withString:bodyHTML ? bodyHTML : @""];
	return html;
}


@end
