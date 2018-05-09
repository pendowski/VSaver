//
//  VSSScreenSaver.h
//  VSaver
//
//  Created by Jarek Pendowski on 09/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

@protocol VSSScreenSaver <NSObject>
- (nullable instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)preview;
- (NSWindow*)configureSheet;
@end
