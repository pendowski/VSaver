//
//  NSURLSession+VSSExtended.h
//  VSaver
//
//  Created by Jarek Pendowski on 15/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (VSSExtended)

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url mainQueueCompletionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

@end
