//
//  SATransferType.h
//  PaprikaSDK
//
//  Created by 박도영 on 20/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SATransferType) {
    SATransferTypeIdle,
    SATransferTypeSendDirectly,
    SATransferTypeUploadToServer,
    SATransferTypeReceive,
    SATransferTypeReceivedPushKey,
    SATransferTypeUploadToDevice,
    SATransferTypeShare
};

@interface SATransferTypeUtil : NSObject

+ (BOOL)kindOfReceiveType:(SATransferType)type;
+ (BOOL)kindOfSendType:(SATransferType)type;
+ (BOOL)kindOfUploadToServerType:(SATransferType)type;
+ (SATransferType)transferModeWithString:(NSString*)string;

@end
