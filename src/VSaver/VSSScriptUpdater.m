//
//  VSSScriptUpdater.m
//  VSaver
//
//  Created by Jarek Pendowski on 16/03/2019.
//  Copyright © 2019 Jarek Pendowski. All rights reserved.
//

#import "VSSScriptUpdater.h"
#import "NSBundle+VSSExtended.h"
#import "VSSLogger.h"

@interface VSSScriptUpdater ()
@property (nonatomic, nonnull, strong) NSMutableDictionary<NSString *, NSDate *> *updates;
@property (nonatomic, nonnull, strong) NSRegularExpression *minimumVersionComment;
@property (nonatomic, nonnull, strong) NSBundle *bundle;
@property (nonatomic, strong) NSURL *cacheURL;
@property (nonatomic, strong) NSURL *baseURL;
@end

@implementation VSSScriptUpdater

+ (void)configureSharedInstanceWithCacheURL:(NSURL *)cacheURL baseURL:(NSURL *)baseURL bundle:(NSBundle *)bundle
{
    VSSScriptUpdater *instance = [self sharedInstance];
    instance.cacheURL = cacheURL;
    instance.baseURL = baseURL;
    instance.bundle = bundle;
    [instance setupCache];
}

+ (instancetype)sharedInstance
{
    static VSSScriptUpdater *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] initWithCacheURL:nil baseURL:nil bundle:[NSBundle mainBundle]];
    });
    return shareObject;
}

- (instancetype)initWithCacheURL:(NSURL * _Nullable)cacheURL baseURL:(NSURL * _Nullable)baseURL bundle:(NSBundle *)bundle
{
    self = [super init];
    
    self.bundle = bundle;
    self.cacheURL = cacheURL;
    self.baseURL = baseURL;
    self.minimumVersionComment = [NSRegularExpression regularExpressionWithPattern:@"/\\*+[ ]*min(imum|imal)* ver(sion):[\\s]*(?<version>([0-9]+[\\.]{0,1})+)+[\\s]*\\*/+" options:NSRegularExpressionCaseInsensitive error:nil];
    self.updates = [NSMutableDictionary dictionary];
    
    [self setupCache];
    
    return self;
}

- (void)scriptWithPath:(NSString *)path completion:(void (^)(NSString *))completion
{
    if (!self.baseURL) {
        VSSLog(@"Missing `baseURL` for updating script");
        [self useBundleVersionForPath:path completion:completion];
        return;
    }
    
    NSTimeInterval secondsSinceLastUpdate = [[NSDate date] timeIntervalSince1970] - self.updates[path].timeIntervalSince1970;
    if (secondsSinceLastUpdate > 6 * 60 * 60) {
        VSSLog(@"Script %@ last updated %0.0f seconds ago - checking for new version", path, secondsSinceLastUpdate);
        NSURL *scriptURL = [self.baseURL URLByAppendingPathComponent:path];
        [[[NSURLSession sharedSession] dataTaskWithURL:scriptURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                self.updates[path] = [NSDate date];
                VSSLog(@"Script downloaded for %@", path);
                
                NSString *js = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if ([self isCurrentVersionCompatibleWithScript:js]) {
                    NSURL *cachedURL = [self cachedURLWithPath:path];
                    [data writeToURL:cachedURL atomically:YES];
                    
                    VSSLog(@"Saving cached version of %@ script", path);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(js);
                    });
                    return;
                } else {
                    VSSLogDailyFile(path, data);
                }
            } else {
                VSSLog(@"Failed to load script for %@ [%@]: %@\n%@", path, scriptURL, response, error);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self useCachedOrBundledScriptForPath:path completion:completion];
            });
        }] resume];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self useCachedOrBundledScriptForPath:path completion:completion];
        });
    }
}

#pragma mark - Private

- (NSURL *)cachedURLWithPath:(NSString *)path
{
    return [self.cacheURL URLByAppendingPathComponent:path];
}

- (BOOL)isCurrentVersionCompatibleWithScript:(NSString *)script
{
    NSTextCheckingResult *result = [self.minimumVersionComment firstMatchInString:script options:0 range:NSMakeRange(0, script.length)];
    
    NSRange versionRange = [result rangeWithName:@"version"];
    if (versionRange.length > 0) {
        NSString *minimumVersion = [script substringWithRange:versionRange];
        NSString *currentVersion = [self.bundle vss_bundleVersion];
        
        VSSLog(@"Scripts version %@ vs bundle version %@", minimumVersion, currentVersion);
        
        if ([currentVersion compare:minimumVersion options:NSNumericSearch] != NSOrderedAscending) {
            return YES;
        }
    }
    
    VSSLog(@"Version of script incompatible");
    
    return NO;
}

- (void)useCachedOrBundledScriptForPath:(NSString *)path completion:(void (^)(NSString *))completion
{
    NSURL *cachedURL = [self cachedURLWithPath:path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachedURL.path]) {
        NSString *script = [NSString stringWithContentsOfURL:cachedURL encoding:NSUTF8StringEncoding error:nil];
        VSSLog(@"Trying cached version %@", path);
        
        if ([self isCurrentVersionCompatibleWithScript:script]) {
            completion(script);
            return;
        }
    }
    
    [self useBundleVersionForPath:path completion:completion];
}

- (void)useBundleVersionForPath:(NSString *)path completion:(void (^)(NSString *))completion
{
    NSString *filename = [path lastPathComponent];
    NSString *filenameWithoutExtension = [filename stringByDeletingPathExtension];
    NSString *filenameExtension = [filename pathExtension];
    
    NSURL *url = [self.bundle URLForResource:filenameWithoutExtension withExtension:filenameExtension];
    if (!url) {
        VSSLog(@"Missing bundled version of script %@", path);
        completion(@"");
        return;
    }
    VSSLog(@"Using bundled version of script %@", path);
    NSString *script = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    completion(script);
}

- (void)setupCache
{
    if (!self.cacheURL) {
        return;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.cacheURL.path]) {
        VSSLog(@"Creating cache for scripts %@", self.cacheURL.path);
        
        [[NSFileManager defaultManager] createDirectoryAtURL:self.cacheURL
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:nil];
    }
}

@end
