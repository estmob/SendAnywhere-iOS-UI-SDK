//
//  SATransferCommand+ModeUtils.m
//  paprika_ios_4_sdk
//
//  Created by do on 08/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SATransferCommand+TypeUtils.h"

@implementation SATransferCommand (TypeUtils)

- (BOOL)kindOfReceiveType {
    return self.transferType == SATransferTypeReceive ||
    self.transferType == SATransferTypeReceivedPushKey;
}

- (BOOL)kindOfSendType {
    return self.transferType == SATransferTypeSendDirectly ||
    self.transferType == SATransferTypeUploadToDevice ||
    self.transferType == SATransferTypeUploadToServer;
    
}

- (BOOL)kindOfUploadToServerType {
    return self.transferType == SATransferTypeUploadToServer ||
    self.transferType == SATransferTypeUploadToDevice;
}

+ (SATransferType)transferModeWithString:(NSString*)string {
    if (string.length == 0) {
        return SATransferTypeIdle;
    }
    
    if ([string isEqualToString:@"SEND_DIRECTLY"] ||
        [string isEqualToString:@"SEND_2DEVICE"]) {
        return SATransferTypeSendDirectly;
    }
    if ([string isEqualToString:@"UPLOAD_TO_SERVER"] ||
        [string isEqualToString:@"SEND_2SERVER"]) {
        return SATransferTypeUploadToServer;
    }
    if ([string isEqualToString:@"RECEIVE"] ||
        [string isEqualToString:@"DOWNLOAD"]) {
        return SATransferTypeReceive;
    }
    if ([string isEqualToString:@"RECEIVED_PUSH_KEY"]) {
        return SATransferTypeReceivedPushKey;
    }
    if ([string isEqualToString:@"UPLOAD_TO_DEVICE"]) {
        return SATransferTypeUploadToDevice;
    }
    if ([string isEqualToString:@"SHARE"]) {
        return SATransferTypeShare;
    }
    return SATransferTypeIdle;
}

@end
