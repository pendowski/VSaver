//
//  NSDate+VSSExtended.h
//  VSaver
//
//  Created by Jarek Pendowski on 04/01/2019.
//  Copyright © 2019 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (VSSExtended)

- (BOOL)vss_isTheSameDayAs:(NSDate *)day;

@end

NS_ASSUME_NONNULL_END
