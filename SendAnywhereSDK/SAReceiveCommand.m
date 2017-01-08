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
@dynamic errorDelegate;

- (void)setParamWithKey:(NSString *)key destDir:(NSString *)destDir {
    [super setParamWithKey:SA_TRANSFER_PARAM_KEY value:key];
    [super setParamWithKey:SA_TRANSFER_PARAM_DESTDIR value:destDir];
}

#pragma mark - handlers

#pragma mark - dispatchers

- (void)dispatchTaskError:(NSInteger)state detailedState:(NSInteger)detailedState param:(id)param {
    [super dispatchTaskError:state detailedState:detailedState param:param];
    
    switch ((NSInteger)detailedState) {
        case PAPRIKA_DETAILED_STATE_ERROR_FILE_NO_DISK_SPACE:
            if ([self.errorDelegate respondsToSelector:@selector(didReceiveErrorNoDiskSpace:)]) {
                [self.errorDelegate didReceiveErrorNoDiskSpace:self];
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_FILE_NO_DOWNLOAD_PATH:
            if ([self.errorDelegate respondsToSelector:@selector(didReceiveErrorDownloadPathNotExists:)]) {
                [self.errorDelegate didReceiveErrorDownloadPathNotExists:self];
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_NO_EXIST_KEY:
            if ([self.errorDelegate respondsToSelector:@selector(didReceiveErrorKeyNotExists:)]) {
                [self.errorDelegate didReceiveErrorKeyNotExists:self];
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
    
    // ERROR_LINK_SHARING_KEY : 안드로이드에 이거 있는데 이 부분 처리해야 하나?
}

@end
