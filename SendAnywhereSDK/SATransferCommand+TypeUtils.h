//
//  SATransferCommand+ModeUtils.h
//  paprika_ios_4_sdk
//
//  Created by do on 08/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SATransferCommand.h"

@interface SATransferCommand (TypeUtils)

- (BOOL)kindOfReceiveType;
- (BOOL)kindOfSendType;
- (BOOL)kindOfUploadToServerType;
+ (SATransferType)transferModeWithString:(NSString*)string;

@end
