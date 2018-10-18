//
//  main.m
//  SaverInstaller
//
//  Created by Jarek Pendowski on 09/05/2018.
//  Copyright © 2018 Jarek Pendowski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSArray+Extended.h"

int main(int argc, const char *argv[])
{
    @autoreleasepool {
        NSString *binaryParentPath = [[NSProcessInfo processInfo].arguments.firstObject stringByDeletingLastPathComponent];
        NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:binaryParentPath error:nil];

        NSArray *potentialSavers = [filenames vss_map:^id _Nullable (NSString *_Nonnull filename) {
            if (![filename containsString:@".saver"]) {
                return nil;
            }
            return [binaryParentPath stringByAppendingPathComponent:filename];
        }];

        if (potentialSavers.count != 1) {
            NSLog(@"Couldn't find .saver file at %@ among those files: %@", binaryParentPath, filenames);
            NSLog(@"Make sure it's compiled with the same build configuration before running the installer.");
            return -1;
        }

        NSTask *openTask = [[NSTask alloc] init];
        openTask.launchPath = @"/usr/bin/open";
        openTask.arguments = @[potentialSavers.firstObject];

        NSError *launchError;
        if (![openTask launchAndReturnError:&launchError]) {
            NSLog(@"Error installing the saver: %@", launchError);
            return -2;
        }

        NSLog(@"Instalation of screen saver successfully launched. Accept instalation inside System Preferences window.");
    }
    return 0;
}
