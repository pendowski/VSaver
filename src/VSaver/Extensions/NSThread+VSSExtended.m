//
//  NSThread+VSSExtended.m
//  VSaver
//
//  Created by Jarek Pendowski on 04/01/2019.
//  Copyright © 2019 Jarek Pendowski. All rights reserved.
//

#import "NSThread+VSSExtended.h"

@implementation NSThread (VSSExtended)

+ (NSArray<NSString *> *)vss_simpleCallStackSymbolsWithLimit:(NSInteger)limit
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([\\-+]{1}[^\\]]*\\])[^\\+]*(\\+ [0-9]+)+" options:0 error:&error];
    if (error) {
        NSLog(@"Regular expression failed: %@", error);
    }
    NSMutableArray *results = [@[] mutableCopy];
    
    NSArray *symbols = [self callStackSymbols];
    NSInteger resultsCount = 0;
    for (NSString *line in symbols) {
        NSTextCheckingResult *result = [regex firstMatchInString:line options:0 range:NSMakeRange(0, line.length)];
        if (result.numberOfRanges > 2) {
            NSRange methodRange = [result rangeAtIndex:1];
            NSRange offsetRange = [result rangeAtIndex:2];
            if (methodRange.location == NSNotFound || offsetRange.location == NSNotFound) {
                NSLog(@"Something's wrong with call stack regular expression for line: %@", line);
                continue;
            }
            NSString *method = [line substringWithRange:methodRange];
            if ([method containsString:@"NSThread(VSSExtended) vss_"]) {
                continue;
            }
            [results addObject:[NSString stringWithFormat:@"%@(%@)", method, [line substringWithRange:offsetRange]]];
            if (++resultsCount == limit) {
                break;
            }
        }
    }
    return results;
}

+ (NSString *)vss_simpleCallStackWithLimit:(NSInteger)limit
{
    return [[self vss_simpleCallStackSymbolsWithLimit:limit] componentsJoinedByString:@" -> "];
}

@end
