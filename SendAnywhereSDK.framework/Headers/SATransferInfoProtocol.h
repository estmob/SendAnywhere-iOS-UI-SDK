//
//  SATransferInfoProtocol.h
//  PaprikaSDK
//
//  Created by 박도영 on 20/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#ifndef SATransferInfoProtocol_h
#define SATransferInfoProtocol_h

typedef NS_ENUM(NSInteger, SATransferInfoStatus) {
    SATransferInfoStatusNotSet,
    SATransferInfoStatusCompleted,
    SATransferInfoStatusError,
    SATransferInfoStatusCanceled,
    SATransferInfoStatusCanceledByOpponent,
    SATransferInfoStatusTransferring,
    SATransferInfoStatusWaiting
};

typedef NS_ENUM(NSInteger, SATransferInfoType) {
    SATransferInfoTypeHistory,
    SATransferInfoTypeCommand,
    SATransferInfoTypeOfferedKey
};

@class UIImage;
@protocol SATransferFileProtocol <NSObject>

- (NSString*)fileName;
- (NSString*)filePath;
- (unsigned long long)fileSize;
- (unsigned long long)transferredSize;
- (SATransferInfoStatus)status;
- (UIImage*)thumbnail;
- (BOOL)exists;

@end

@protocol SATransferInfoProtocol <NSObject>

- (SATransferInfoType)type;

- (NSString*)state;
- (NSString*)detailedState;
- (NSString*)errorString;
- (NSInteger)peerState;
- (SATransferInfoStatus)status;

- (NSString*)deviceId;
- (NSUInteger)identifier;
- (NSString*)key;
- (NSString*)link;
- (NSString*)transferId;
- (NSInteger)transferMode;
- (NSInteger)transferType;

- (NSDate*)expireTime;
- (NSDate*)finishedTime;

- (NSInteger)fileCount;
- (NSInteger)availableFileCount;
- (id<SATransferFileProtocol>)fileInfo:(NSInteger)index;
- (unsigned long long)transferredSize;
- (unsigned long long)totalFileSize;

- (BOOL)isCanceled;
- (BOOL)isCanceledByOpponent;
- (BOOL)isRunning;
- (BOOL)isExpired;
- (BOOL)isSender;
- (BOOL)isSucceeded;
- (BOOL)isResumable;
- (BOOL)isEnableToLink;

- (void)removeObserver:(id)observer;
- (void)addObserver:(id)observer;

@end

#endif /* SATransferInfoProtocol_h */
