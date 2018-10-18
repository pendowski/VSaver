//
//  NSObject+Extended.h
//  VSaver
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VSSAS(obj, cls) (cls *)[obj vss_as:[cls class]]

@interface NSObject (Extended)

- (id _Nullable)vss_as:(Class _Nonnull)class;

@end
