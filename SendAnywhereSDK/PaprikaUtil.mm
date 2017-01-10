//
//  ConvertUtil.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 10/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "PaprikaUtil.h"

@implementation PaprikaUtil

+ (id)convertParam:(const void*)param state:(PaprikaDetailedState)detailedState {
    switch ((NSInteger)detailedState) {
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

@end
