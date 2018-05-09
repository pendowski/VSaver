//
//  VSSURLItem.h
//  VSaver
//
//  Created by Jarek Pendowski on 07/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSSURLItem : NSObject
@property (nonnull, nonatomic, copy) NSString *title;
@property (nonnull, nonatomic, copy) NSURL *url;
    
- (instancetype _Nonnull )initWithTitle: (NSString *_Nonnull)title url: (NSURL *_Nonnull)url;
@end
