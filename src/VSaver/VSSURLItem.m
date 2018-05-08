//
//  VSSURLItem.m
//  VSaver
//
//  Created by Jarek Pendowski on 07/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSURLItem.h"

@implementation VSSURLItem
    
- (instancetype)initWithTitle: (NSString *)title url: (NSURL *)url {
    self = [super init];
    if (self) {
        self.title = title;
        self.url = url;
    }
    return self;
}
    
    @end
