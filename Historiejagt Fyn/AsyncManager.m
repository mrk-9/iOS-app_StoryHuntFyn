//
//  AsyncManager.m
//  Historiejagt Fyn
//
//  Created by thomas_leomobile on 10/04/16.
//  Copyright © 2016 thomas. All rights reserved.
//

#import "AsyncManager.h"
#import "Constants.h"

@implementation AsyncManager

-(void)callAPI:(NSString*)api_name withParams:(NSDictionary*)params success:(void (^)(NSData *data))successBlock error:(void(^)(NSError *error))errorBlock
{
    NSString* server_url = SERVERURL;
    
    NSString* urlString = [NSString stringWithFormat:@"%@%@", server_url,api_name];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // Set post method
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSData *jsonString = [self getJSONStringWithDictionary:params];
    
    [request addValue:[NSString stringWithFormat:@"%lu",(unsigned long)jsonString.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:jsonString];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil){
            successBlock(data);
            //            NSError *errorJson = nil;
            //            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
            //            return ((NSDictionary *)dataDict)[@"data"];
        }
        else {
            errorBlock(error);
        }
    }];
    
    [postDataTask resume];
}

-(NSData*) getJSONStringWithDictionary:(NSDictionary*) parameters {
    NSData *bodyData = nil;
    if (![parameters isKindOfClass:[NSString class]] && [NSJSONSerialization isValidJSONObject:parameters])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&error];
        if (!jsonData)
        {
            NSLog(@"runRequestWithPath jsonData error: %@", error.localizedDescription);
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Request parameters should be NSString or NSDictionary."
                                         userInfo:nil];
        }
        else
        {
            bodyData = jsonData;
        }
    }
    else if ([parameters isKindOfClass:[NSString class]])
    {
        bodyData = [(NSString *)parameters dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([parameters isKindOfClass:[NSData class]]) {
        bodyData = (NSData *)parameters;
    }
    return bodyData;
}

@end
