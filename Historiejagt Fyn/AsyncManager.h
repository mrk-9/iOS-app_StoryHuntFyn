//
//  AsyncManager.h
//  Historiejagt Fyn
//
//  Created by thomas_leomobile on 10/04/16.
//  Copyright © 2016 thomas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsyncManager : NSObject
{
}
-(void)callAPI:(NSString*)api_name withParams:(NSDictionary*)params success:(void (^)(NSData *data))successBlock error:(void(^)(NSError *error))errorBlock;
@end
