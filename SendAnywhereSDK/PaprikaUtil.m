//
//  ConvertUtil.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 10/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "PaprikaUtil.h"
#import "paprika.h"
#import "NSString+sa.h"

@implementation PaprikaUtil

+ (id)convertParamWithState:(NSInteger)detailedState param:(const void*)param {
    switch (detailedState) {
        case PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_DEVICE_ID:
            return [NSString stringWithUTF8String:(const char*)param];
            break;
        case PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_FILE_LIST: {
            NSMutableArray *fileList = [NSMutableArray array];
            const PaprikaAllTransferFileState *files = (const PaprikaAllTransferFileState*)param;
            for (int i = 0; i < files->number; ++i) {
                [fileList addObject:[NSValue valueWithPointer:&(files[i])]];
            }
            return fileList;
        }
    }
    return [NSValue valueWithPointer:param];
}

+ (const void*)convertOptionWithKey:(NSInteger)key option:(id)optionValue {
    switch(key) {
        case PAPRIKA_OPTION_API_SERVER:
        case PAPRIKA_OPTION_SERVER_REGION:
        case PAPRIKA_OPTION_PUSH_SERVER:
        case PAPRIKA_OPTION_PUSH_ID: {
            return [optionValue UTF8String];
        }
        case PAPRIKA_OPTION_PROFILE_NAME: {
            return [optionValue wchars];
        }
        case PAPRIKA_OPTION_SHARED_PATH: {
            //TODO
            break;
        }
        case PAPRIKA_OPTION_UPLOAD_KEYTYPE:
        case PAPRIKA_OPTION_UPLOAD_TIMEOUT: {
            int result = [optionValue intValue];
            return &result;
        }
        case PAPRIKA_OPTION_PARALLEL_TRANSFER: {
            bool result = [optionValue boolValue];
            return &result;
        }
    }
    
    return NULL;
}

@end
