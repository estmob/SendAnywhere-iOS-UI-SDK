//
//  SASendCommand.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 12/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SASendCommand.h"
#import "SACommand+sa_private.h"
#import "NSString+sa.h"
#import "CommandManager.h"
#import <paprika.h>

size_t upload_read_callback(char* buf, unsigned long long start, size_t n, void* userData) {
    SAFileInfo *info = (__bridge SAFileInfo*)userData;
    NSData *data = info.data;
    if (!data) {
        return 0;
    }

    [data getBytes:buf range:NSMakeRange(start, n)];
    
    return data.length - (start + n);
}

@implementation SAFileInfo

- (instancetype)initWithFileName:(NSString*)fileName path:(NSString*)path data:(NSData*)data {
    if (self = [super init]) {
        self.fileName = fileName;
        self.path = path;
        self.data = data;
    }
    return self;
}

@end

@implementation SASendCommand

+ (instancetype)makeInstance {
    return [[CommandManager sharedInstance] makeManagedSendCommand];
}

- (void)executeWithFileInfos:(NSArray*)fileInfos {
    [self setParamWithFileInfos:fileInfos];
    
    [super execute];
}

- (void)executeWithFileInfos:(NSArray*)fileInfos mode:(PaprikaTransferMode)mode {
    [self setParamWithFileInfos:fileInfos mode:mode];
    
    [super execute];
}

- (void)setParamWithDatas:(NSArray*)fileInfos {
    [super clearmParams];
    [super setParamWithKey:SA_COMMAND_PARAM_TYPE value:@0];
    [super setParamWithKey:SA_SEND_PARAM_FILE_INFOS value:fileInfos];
}

- (void)setParamWithFileInfos:(NSArray*)fileInfos mode:(PaprikaTransferMode)mode {
    [super clearmParams];
    [super setParamWithKey:SA_COMMAND_PARAM_TYPE value:@1];
    [super setParamWithKey:SA_SEND_PARAM_FILE_INFOS value:fileInfos];
    [super setParamWithKey:SA_SEND_PARAM_MODE value:@(mode)];
}

#pragma mark - task functions

- (PaprikaTask)createTask {
    
    NSArray * fileInfos = [super paramForKey:SA_SEND_PARAM_FILE_INFOS];
    PaprikaTransferMode mode = (PaprikaTransferMode)[[super paramForKey:SA_SEND_PARAM_MODE] integerValue];
    
    unsigned int fileNumber = fileInfos.count;
    const wchar_t **files = new const wchar_t*[fileNumber];
    PaprikaUploadFileInfo *streams = new PaprikaUploadFileInfo[fileNumber];
    
    [fileInfos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SAFileInfo *fileInfo = (SAFileInfo*)obj;
        files[idx] = fileInfo.fileName.wchars;
        
        PaprikaUploadFileInfo& fi = streams[idx];
        fi.name = fileInfo.fileName.wchars;
        fi.path = fileInfo.path.wchars;
        fi.size = fileInfo.data.length;
        fi.readFunc = upload_read_callback;
        fi.userData = (__bridge void*)fileInfo;
    }];
    
    PaprikaTask task = paprika_create_upload_stream(NULL, 0, (PaprikaUploadFileInfo*)streams, fileNumber, mode);
    delete [] files;
    delete [] streams;
    return task;
}

@end
