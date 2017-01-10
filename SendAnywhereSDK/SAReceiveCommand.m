//
//  SAReceiveCommand.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 06/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SAReceiveCommand.h"
#import "SACommand+private.h"
#import <paprika.h>
#import "NSString+sa.h"

@interface SAReceiveCommand()

@end

@implementation SAReceiveCommand

- (void)executeWithKey:(NSString*)key destDir:(NSString*)destDir {
    [self setParamWithKey:key destDir:destDir];
    
    [super execute];
}

- (void)executeWithKey:(NSString*)key destDir:(NSString*)destDir dispatchQueue:(dispatch_queue_t)dispatchQueue {
    [self setParamWithKey:key destDir:destDir];
    
    [super executeWithDispatchQueue:dispatchQueue];
}

- (void)setParamWithKey:(NSString *)key {
    [super clearmParams];
    [super setParamWithKey:SA_COMMAND_PARAM_TYPE value:@([key containsString:@"://"] ? 4 : 0)];
    [super setParamWithKey:SA_TRANSFER_PARAM_KEY value:key];
}

- (void)setParamWithKey:(NSString *)key destDir:(NSString *)destDir {
    [super clearmParams];
    [super setParamWithKey:SA_COMMAND_PARAM_TYPE value:@([key containsString:@"://"] ? 5 : 1)];
    [super setParamWithKey:SA_TRANSFER_PARAM_KEY value:key];
    [super setParamWithKey:SA_TRANSFER_PARAM_DESTDIR value:destDir];
}

- (NSString*)devicePeerID {
    NSString *peerID = [super devicePeerID];
    
    return peerID;
}

- (NSString*)licenseUrl {
    PaprikaTask task = [super currentTask];
    
    return @"";
}

- (void)addErrorObserver:(id<SACommandErrorDelegate,SATransferErrorDelegate,SAReceiveErrorDelegate>)observer {
    [super addErrorObserver:observer];
}

- (void)removeErrorObserver:(id<SACommandErrorDelegate,SATransferErrorDelegate,SAReceiveErrorDelegate>)observer {
    [super removeErrorObserver:observer];
}

#pragma mark - handlers

#pragma mark - dispatchers

- (void)dispatchTaskError:(NSInteger)state detailedState:(NSInteger)detailedState param:(id)param {
    [super dispatchTaskError:state detailedState:detailedState param:param];
    
    switch ((NSInteger)detailedState) {
        case PAPRIKA_DETAILED_STATE_ERROR_FILE_NO_DISK_SPACE:
            for (id observer in self.errorObservers) {
                if ([observer respondsToSelector:@selector(didReceiveErrorNoDiskSpace:)]) {
                    [observer didReceiveErrorNoDiskSpace:self];
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_FILE_NO_DOWNLOAD_PATH:
            for (id observer in self.errorObservers) {
                if ([observer respondsToSelector:@selector(didReceiveErrorDownloadPathNotExists:)]) {
                    [observer didReceiveErrorDownloadPathNotExists:self];
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_NO_EXIST_KEY:
            for (id observer in self.errorObservers) {
                if ([observer respondsToSelector:@selector(didReceiveErrorKeyNotExists:)]) {
                    [observer didReceiveErrorKeyNotExists:self];
                }
            }
            break;
    }
    
}

#pragma mark - task functions

- (PaprikaTask)createTask {
    NSString *key = [super paramForKey:SA_TRANSFER_PARAM_KEY];
    NSString *destDir = [super paramForKey:SA_TRANSFER_PARAM_DESTDIR];
    
    return paprika_create_download(key.wchars, destDir.wchars);
}

- (void)processTaskResult:(PaprikaTask)task {
    [super processTaskResult:task];
    
    
}

@end
