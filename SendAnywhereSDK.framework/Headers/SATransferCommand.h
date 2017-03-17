//
//  SATransferCommand.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 06/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SACommand.h"
#import "SATransferType.h"

extern NSInteger simpleProgressMaximum;

#define SA_TRANSFER_PARAM_KEY @"key"
#define SA_TRANSFER_PARAM_MODE @"mode"
#define SA_TRANSFER_PARAM_RELATIVE_PATH @"relative_path"

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

@class UIImage;
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

@protocol SATransferNotifyDelegate <NSObject>
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
@property (nonatomic, assign) NSTimeInterval expireTime;

@property (nonatomic, readonly) NSString *peerDeviceId;

@property (nonatomic, readonly) NSInteger progress;
@property (nonatomic, readonly) unsigned long long sizeToTransfer;
@property (nonatomic, readonly) unsigned long long sizeTransferred;
@property (nonatomic, readonly) PaprikaTransferMode transferMode;

@property (nonatomic, retain) NSString *transferID;
@property (nonatomic, retain) NSString *transferKey;

@property (nonatomic, readonly) NSArray *fileList;

@property (nonatomic, readonly) BOOL transferStarted;
@property (nonatomic, readonly) BOOL fileListUpdated;
@property (nonatomic, readonly) BOOL transferPaused;
@property (nonatomic, readonly) BOOL isTransferValid;

- (SATransferFileStatus)fileStatusWithIndex:(NSInteger)index;
- (NSString*)fileNameWithIndex:(NSInteger)index;
- (NSString*)filePathWithIndex:(NSInteger)index;
- (unsigned long long)fileTransferredSizeWithIndex:(NSInteger)index;
- (unsigned long long)fileSizeWithIndex:(NSInteger)index;

- (void)updateFilePath:(NSString*)filePath index:(NSInteger)index;

- (void)addPrepareObserver:(id)observer;
- (void)addErrorObserver:(id)observer;
- (void)addTransferObserver:(id)observer;

- (void)removePrepareObserver:(id)observer;
- (void)removeErrorObserver:(id)observer;
- (void)removeTransferObserver:(id)observer;

+ (BOOL)isTransferringWithTransferId:(NSString*)transferId;

+ (void)cancelWithTransferInfo:(id)transferInfo;
+ (void)requestDeleteKeyWithKey:(NSString*)transferKey;
+ (void)requestDeleteHistoryWithTransferId:(NSString*)transferId completion:(void (^)())completion;
+ (void)requestDeleteOfferedKeyWithInfoId:(NSString*)infoId completion:(void (^)())completion;
+ (void)requestDeleteAllHistoryWithType:(NSInteger)type completion:(void (^)())completion;

@end
