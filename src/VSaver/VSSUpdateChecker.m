//
//  VSSVersionChecker.m
//  VSaver
//
//  Created by Jarek Pendowski on 22/10/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import "VSSUpdateChecker.h"
#import "NSObject+Extended.h"
#import "NSURLComponents+Extended.h"
#import "NSString+Extended.h"
#import "NSDate+VSSExtended.h"
#import "VSSLogger.h"

@interface VSSUpdateChecker ()
@property (nullable, nonatomic, copy) NSString *currentVersion;
@property (nonnull, nonatomic, strong) id<VSSSettings> settings;
@end

@implementation VSSUpdateChecker

- (instancetype)initWithVersionSource:(NSString *_Nullable (^_Nullable)(void))source settings:(nonnull id<VSSSettings>)settings
{
    self = [super init];

    self.currentVersion = source ? source() : [self defaultCurrentVersion];
    self.settings = settings;

    return self;
}

- (void)checkForUpdates:(void (^)(BOOL, NSString *))updates
{
    NSDate *lastUpdateCheckedAt = self.settings.lastUpdateCheckedAt;
    NSDate *now = [NSDate date];
    if ([lastUpdateCheckedAt vss_isTheSameDayAs:now]) {
        return;
    }
    VSSLog(@"Checking for updates for version %@", self.currentVersion);
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    [[session dataTaskWithURL:[NSURL URLWithString:@"https://github.com/pendowski/VSaver/releases/latest"] completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        NSArray<NSString *> *pathComponents = [NSURLComponents componentsWithURL:response.URL resolvingAgainstBaseURL:NO].vss_pathComponents;
        
        if ([pathComponents containsObject:@"tag"]) {
            NSUInteger tagIndex = [pathComponents indexOfObject:@"tag"];
            
            if (pathComponents.count > tagIndex) {
                
                NSString *versionComponent = pathComponents[tagIndex + 1];
                NSRegularExpression *versionRegex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+[0-9\\.]*[0-9])" options:0 error:nil];
                NSRange versionRange = [versionRegex rangeOfFirstMatchInString:versionComponent options:0 range:NSMakeRange(0, versionComponent.length)];
                
                if (versionRange.length > 0) {
                    NSString *version = [versionComponent substringWithRange:versionRange];
                    
                    if ([self.currentVersion vss_compareWithVersion:version] == NSOrderedAscending) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            VSSLog(@"Updates found! New version %@ available", version);
                            updates(YES, version);
                        });
                        return;
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            VSSLog(@"No updates");
            self.settings.lastUpdateCheckedAt = now;
            updates(NO, nil);
        });
    }] resume];
}

#pragma mark - Private

- (NSString *)defaultCurrentVersion
{
    NSDictionary<NSString *, id> *info = [[NSBundle mainBundle] infoDictionary];
    return info[@"CFBundleShortVersionString"];
}

@end
