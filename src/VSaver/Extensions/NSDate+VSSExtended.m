//
//  NSDate+VSSExtended.m
//  VSaver
//
//  Created by Jarek Pendowski on 04/01/2019.
//  Copyright © 2019 Jarek Pendowski. All rights reserved.
//

#import "NSDate+VSSExtended.h"

@implementation NSDate (VSSExtended)

- (BOOL)vss_isTheSameDayAs:(NSDate *)date
{
    return [[NSCalendar autoupdatingCurrentCalendar] isDate:self inSameDayAsDate:date];
}

@end
