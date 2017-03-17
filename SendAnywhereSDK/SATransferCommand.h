//
//  SATransferCommand.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 06/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SACommand.h"

extern NSInteger simpleProgressMaximum;

#define SA_TRANSFER_PARAM_KEY @"key"
#define SA_TRANSFER_PARAM_DESTDIR @"dest_dir"

typedef NS_ENUM(NSInteger, SAConnectionMode) {
    SAConnectionActive,
    SAConnectionPassive,
    SAConnectionServer
};

typedef NS_ENUM(NSInteger, SATransferFileStatus) {
    SATransferFileStatusIdle,
    SATransferFileStatusTransferring,
    SATransferFileStatusFinished
};

typedef NS_ENUM(NSInteger, SATransferType) {
    SATransferTypeIdle,
    SATransferTypeSendDirectly,
    SATransferTypeUploadToServer,
    SATransferTypeReceive,
    SATransferTypeReceivedPushKey,
    SATransferTypeUploadToDevice,
    SATransferTypeShare
};

@class SATransferCommand;
@protocol SATransferPrepareDelegate <NSObject>
@optional
- (void)didTransferFileListUpdated:(SATransferCommand*)sender fileStates:(NSArray*)fileState;
- (void)didTransferKeyUpdated:(SATransferCommand*)sender key:(NSString*)key;
- (void)didTransferModeUpdated:(SATransferCommand*)sender;
- (void)didTransferRequestKey:(SATransferCommand*)sender;
- (void)didTransferRequestMode:(SATransferCommand*)sender;
- (void)didTransferWaitForTheNetwork:(SATransferCommand*)sender;

@end

@protocol SATranferNotifyDelegate <NSObject>
@optional
- (void)willTransferStart:(SATransferCommand*)sender;
- (void)willTransferFileStart:(SATransferCommand*)sender fileIndex:(NSInteger)fileIndex fileCount:(NSInteger)fileCount fileState:(PaprikaTransferFileState)fileState;
- (void)didTransferFileProgress:(SATransferCommand*)sender mode:(SAConnectionMode)mode done:(long long)done max:(long long)max fileIndex:(NSInteger)fileIndex fileState:(PaprikaTransferFileState)fileState;
- (void)didTransferSimpleProgress:(SATransferCommand*)sender progress:(NSInteger)progress max:(NSInteger)max fileIndex:(NSInteger)fileIndex fileState:(PaprikaTransferFileState)fileState;
- (void)didTransferFileFinish:(SATransferCommand*)sender fileIndex:(NSInteger)fileIndex fileCount:(NSInteger)fileCount fileState:(PaprikaTransferFileState)fileState;
- (void)didTransferFinish:(SATransferCommand*)sender;
- (void)willTransferPause:(SATransferCommand*)sender;
- (void)didTransferResume:(SATransferCommand*)sender;

@end

@protocol SATransferErrorDelegate <NSObject>
@optional
- (void)didTransferErrorFileByPeer:(SATransferCommand*)sender;
- (void)didTransferErrorFileNetwork:(SATransferCommand*)sender;
- (void)didTransferErrorFileWrongProtocol:(SATransferCommand*)sender;

@end

@interface SATransferCommand : SACommand

@property (nonatomic, assign) SATransferType transferType;

@property (nonatomic, readonly) NSString *devicePeerID;
@property (nonatomic, readonly) NSTimeInterval expireTime;
@property (nonatomic, readonly) NSString *transferKey;
@property (nonatomic, readonly) NSInteger progress;
@property (nonatomic, readonly) NSInteger sizeToTransfer;
@property (nonatomic, readonly) NSInteger sizeTransferred;
@property (nonatomic, readonly) NSString *transferID;
@property (nonatomic, readonly) PaprikaTransferMode transferMode;

@property (nonatomic, readonly) NSArray *fileList;

@property (nonatomic, readonly) BOOL transferStarted;
@property (nonatomic, readonly) BOOL fileListUpdated;
@property (nonatomic, readonly) BOOL transferPaused;

- (SATransferFileStatus)fileStatusWithIndex:(NSInteger)index;

- (void)addPrepareObserver:(id)observer;
- (void)addErrorObserver:(id)observer;
- (void)addTransferObserver:(id)observer;

- (void)removePrepareObserver:(id)observer;
- (void)removeErrorObserver:(id)observer;
- (void)removeTransferObserver:(id)observer;

@end
