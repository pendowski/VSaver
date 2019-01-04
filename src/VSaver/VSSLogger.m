//
//  VSSLogger.m
//  VSaver
//
//  Created by Jarek Pendowski on 03/01/2019.
//  Copyright © 2019 Jarek Pendowski. All rights reserved.
//

#import "VSSLogger.h"
#import "NSString+Extended.h"
#import <AppKit/AppKit.h>

@interface VSSLogger ()
@property (nonatomic, copy) NSString *basePath;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSFileHandle *fileHandle;
@end

@implementation VSSLogger

+ (VSSLogger *)sharedInstance
{
    static dispatch_once_t onceToken;
    static VSSLogger *instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"Y-MM-DD HH:mm:ss";
        
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
        self.basePath = [[libraryPath stringByAppendingPathComponent:@"Logs"] stringByAppendingPathComponent:@"VSaver"];
        NSString *nowString = [self.dateFormatter stringFromDate:[NSDate date]];
        NSString *datePart = [[nowString componentsSeparatedByString:@" "] firstObject];
        NSString *filename = [NSString stringWithFormat:@"VSaver-%@.log", datePart];
        NSString *filePath = [self.basePath stringByAppendingPathComponent:filename];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            if (![[NSFileManager defaultManager] fileExistsAtPath:self.basePath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:self.basePath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSData *data = [[NSString stringWithFormat:@"Log started at %@\r\n", nowString] dataUsingEncoding:NSUTF8StringEncoding];
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
        }
        self.fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        [self.fileHandle seekToEndOfFile];
        
#ifndef VSS_DO_NOT_REGISTER_FOR_SYSTEM_EVENTS
        [self registerForSystemEvents];
#endif
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
            [self cleanupOldFiles];
        });
    }
    return self;
}

- (void)log:(NSString *)format, ...
{
    va_list args;
    if (format) {
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        NSString *line = [NSString stringWithFormat:@"[%@] %@\r\n", [self.dateFormatter stringFromDate:[NSDate date]], message];
        [self.fileHandle writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        [self.fileHandle synchronizeFile];
        va_end(args);
    }
}

- (NSString *)logFile:(NSString *)filename data:(NSData *)data
{
    NSString *nowString = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *fullFilename = [NSString stringWithFormat:@"%@_%@", filename, nowString];
    if ([filename containsString:@"."]) {
        NSString *reversed = [filename vss_reversedString];
        NSRange dotRange = [reversed rangeOfString:@"."];
        NSString *reversedReplacement = [@"." stringByAppendingString:[nowString vss_reversedString]];
        fullFilename = [[reversed stringByReplacingCharactersInRange:dotRange withString:reversedReplacement] vss_reversedString];
    }
    [data writeToFile:[self.basePath stringByAppendingPathComponent:fullFilename] atomically:YES];
    return fullFilename;
}

- (void)registerForSystemEvents
{
    NSArray<NSNotificationName> *notifications = @[
                                                   NSApplicationWillTerminateNotification
                                                   ];
    for (NSNotificationName name in notifications) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationFired:) name:name object:nil];
    }
}

- (void)notificationFired:(NSNotification *)notification
{
    VSSLog(@"Notification fired: %@ -> %@", notification.name, notification.userInfo);
    if ([notification.name isEqualToString:NSApplicationWillTerminateNotification]) {
        VSSLog(@"------------------------------------------");
    }
}

#pragma mark - Private

- (void)cleanupOldFiles
{
    NSArray<NSURL *> *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.basePath]
                                                            includingPropertiesForKeys:@[
                                                                                         NSURLContentModificationDateKey
                                                                                         ]
                                                                               options:(NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsPackageDescendants|NSDirectoryEnumerationSkipsHiddenFiles)
                                                                                 error:nil];
    NSDate *now = [NSDate date];
    NSInteger removed = 0;
    for (NSURL *url in files) {
        NSDate *modifiedDate;
        if ([url getResourceValue:&modifiedDate forKey:NSURLContentModificationDateKey error:nil] && now.timeIntervalSince1970 - modifiedDate.timeIntervalSince1970 > 30 * 24 * 60 * 60) {
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
            removed += 1;
        }
    }
    if (removed > 0) {
        NSLog(@"Removed %ld old log files", removed);
    }
}

@end
