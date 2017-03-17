//
//  SASendCommand.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 12/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SATransferCommand.h"

#define SA_SEND_PARAM_FILE_INFOS @"file_infos"
#define SA_SEND_PARAM_MODE @"mode"

@interface SAFileInfo : NSObject

@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSData *data;

- (instancetype)initWithFileName:(NSString*)fileName path:(NSString*)path data:(NSData*)data;

@end

@class SASendCommand;
@protocol SASendErrorDelegate <NSObject>
@optional
- (void)didSendErrorExpired:(SASendCommand*)sender;
- (void)didSendErrorNoRequest:(SASendCommand*)sender;

@end

@interface SASendCommand : SATransferCommand

@property (nonatomic, assign) BOOL isExpired;
@property (nonatomic, retain) NSString *peerDeviceID;

+ (instancetype)makeInstance;

- (void)executeWithFileInfos:(NSArray*)fileInfos;
- (void)executeWithFileInfos:(NSArray*)fileInfos mode:(PaprikaTransferMode)mode;

- (void)setParamWithFileInfos:(NSArray*)fileInfos;
- (void)setParamWithFileInfos:(NSArray*)fileInfos mode:(PaprikaTransferMode)mode;

@end
