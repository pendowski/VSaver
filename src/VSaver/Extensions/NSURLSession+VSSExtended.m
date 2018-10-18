//
//  NSURLSession+VSSExtended.m
//  VSaver
//
//  Created by Jarek Pendowski on 15/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "NSURLSession+VSSExtended.h"

@implementation NSURLSession (VSSExtended)

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url mainQueueCompletionHandler:(void (^)(NSData *_Nullable, NSURLResponse *_Nullable, NSError *_Nullable))completionHandler
{
    return [self dataTaskWithURL:url completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
                       completionHandler(data, response, error);
                   });
    }];
}

@end
