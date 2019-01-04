//
//  VSSWebViewProvider.h
//  VSaver
//
//  Created by Jarek Pendowski on 08/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VSSProvider.h"
@import WebKit;

@interface VSSWebViewProvider : NSObject <VSSProvider>
@property (nullable, nonatomic, strong, readonly) NSURL *loadingURL;
@property (nullable, nonatomic, copy, readonly) NSString *script;

- (instancetype)initWithScriptName:(NSString *)scriptName;

- (void)callCompletion:(VSSURLItem *_Nullable)item;
- (void)handleLoadedPage:(WebFrame *)mainFrame;

- (NSString *)htmlInFrame:(WebFrame * _Nullable)frame;

@end
