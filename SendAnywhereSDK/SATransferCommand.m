//
//  SATransferCommand.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 06/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SATransferCommand.h"
#import "SACommand+private.h"
#import "Global.h"

NSInteger simpleProgressMaximum = 10000;

@interface SATransferCommand()

@property (nonatomic, readwrite) NSTimeInterval expireTime;
@property (nonatomic, readwrite) NSInteger progress;
@property (nonatomic, readwrite) NSInteger sizeToTransfer;
@property (nonatomic, readwrite) NSInteger sizeTransferred;
@property (nonatomic, readwrite) NSString *transferID;
@property (nonatomic, readwrite) SATransferType transferType;
@property (nonatomic, readwrite) PaprikaTransferMode transferMode;

@property (nonatomic, readwrite) NSArray *fileList;
@property (nonatomic, retain) NSDictionary *fileMap;
@property (nonatomic, retain) NSMutableSet *activeFileSet;
@property (nonatomic, assign) NSInteger finishedFileCount;

@property (nonatomic, assign) SAConnectionMode connectionMode;

@property (nonatomic, readwrite) BOOL transferStarted;
@property (nonatomic, readwrite) BOOL fileListUpdated;
@property (nonatomic, readwrite) BOOL transferPaused;

@end

@implementation SATransferCommand

@dynamic prepareDelegate;
@dynamic errorDelegate;

- (SATransferFileStatus)getFileStatusWithIndex:(NSInteger)index {
    PaprikaTransferFileState fileState;
    NSValue *value = [self.fileList objectAtIndex:index];
    [value getValue:&fileState];
    if ([SATransferCommand checkFileStateTransferCompleted:fileState]) {
        return SATransferFileStatusFinished;
    } else if ([self.activeFileSet containsObject:value]) {
        return SATransferFileStatusTransferring;
    }
    return SATransferFileStatusIdle;
}

#pragma mark - handlers

- (void)handleCommandStart {
    [super handleCommandStart];
    self.fileListUpdated = NO;
    self.transferStarted = NO;
    self.transferPaused = NO;
    self.expireTime = -1;
}

- (void)handleTaskPrepare:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    [super handleTaskPrepare:state detailedState:detailedState param:param];
    
    switch ((NSInteger)detailedState) {
        case PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_FILE_LIST:
            self.fileListUpdated = YES;
            break;
    }
}

- (void)handleTaskNotify:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    [super handleTaskNotify:state detailedState:detailedState param:param];
    
    switch ((NSInteger)detailedState) {
        case PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_FILE_LIST:
            self.fileList = (NSArray*)param;
            self.fileMap = [self generateFileMap:self.fileList];
            self.activeFileSet = [NSMutableSet set];
            self.finishedFileCount = 0;
            self.sizeToTransfer = 0;
            self.sizeTransferred = 0;
            
            for (NSValue *value in self.fileList) {
                PaprikaTransferFileState fileState;
                [value getValue:&fileState];
                self.sizeToTransfer += fileState.size;
            }
            
            break;
    }
    
    switch ((NSInteger)state) {
        case PAPRIKA_STATE_FINISHED:
            self.transferPaused = NO;
            break;
        case PAPRIKA_STATE_TRANSFERRING:
            [self handleTransferNotify:state detailedState:detailedState param:param];
            break;
    }
}

- (void)handleTransferNotify:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    PaprikaTransferFileState fileState;
    [param getValue:&fileState];
    NSInteger index = [self.fileMap[param] integerValue];
    
    switch ((NSInteger)detailedState) {
        case PAPRIKA_DETAILED_STATE_TRANSFERRING_PAUSE:
            self.transferPaused = YES;
            break;
        case PAPRIKA_DETAILED_STATE_TRANSFERRING_RESUME:
            self.transferPaused = NO;
            break;
        case PAPRIKA_DETAILED_STATE_TRANSFERRING_START_NEW_FILE:
            if (self.sizeTransferred == 0) {
                self.transferStarted = YES;
                if ([self.transferDelegate respondsToSelector:@selector(willTransferStart:)]) {
                    [self.transferDelegate willTransferStart:self];
                }
                [self.activeFileSet addObject:param];
                if ([self.transferDelegate respondsToSelector:@selector(willTransferFileStart:fileIndex:fileCount:fileState:)]) {
                    [self.transferDelegate willTransferFileStart:self fileIndex:index fileCount:self.fileList.count fileState:fileState];
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_TRANSFERRING_END_FILE:
            if ([self.transferDelegate respondsToSelector:@selector(didTransferFileFinish:fileIndex:fileCount:fileState:)]) {
                [self.transferDelegate didTransferFileFinish:self fileIndex:index fileCount:self.fileList.count fileState:fileState];
            }
            [self.activeFileSet removeObject:param];
            self.sizeTransferred += fileState.size;
            
            if (++self.finishedFileCount == self.fileList.count) {
                [self.activeFileSet removeAllObjects];
                self.sizeTransferred = self.sizeToTransfer;
                if ([self.transferDelegate respondsToSelector:@selector(didTransferFinish:)]) {
                    [self.transferDelegate didTransferFinish:self];
                }
            }
            [self handleFileProgress:self.connectionMode fileIndex:index fileState:fileState];
            break;
        case PAPRIKA_DETAILED_STATE_TRANSFERRING_SERVER:
            [self handleFileProgress:SAConnectionServer fileIndex:index fileState:fileState];
            break;
        case PAPRIKA_DETAILED_STATE_TRANSFERRING_ACTIVE:
            [self handleFileProgress:SAConnectionActive fileIndex:index fileState:fileState];
            break;
        case PAPRIKA_DETAILED_STATE_TRANSFERRING_PASSIVE:
            [self handleFileProgress:SAConnectionPassive fileIndex:index fileState:fileState];
            break;
    }
    
}

- (void)handleFileProgress:(SAConnectionMode)mode fileIndex:(NSInteger)fileIndex fileState:(PaprikaTransferFileState)fileState {
    self.connectionMode = mode;
    NSInteger pos = self.sizeTransferred + [self getActiveFileTransferSize];
    self.progress = (self.sizeToTransfer == 0 ? simpleProgressMaximum : (NSInteger)(pos * simpleProgressMaximum / self.sizeToTransfer));
    
    [self dispatchSimpleProgress:fileIndex fileState:fileState];
    [self dispatchFileProgress:mode fileIndex:fileIndex fileState:fileState];
}

#pragma mark - dispatchers

- (void)dispatchTaskStart:(PaprikaTask)task {
    self.transferID = [NSUUID UUID].UUIDString;
    self.transferStarted = NO;
    [super dispatchTaskStart:task];
}

- (void)dispatchTaskPrepare:(NSInteger)state detailedState:(NSInteger)detailedState param:(id)param {
    [super dispatchTaskPrepare:state detailedState:detailedState param:param];
    
    
    switch (detailedState) {
        case PAPRIKA_DETAILED_STATE_PREPARING_REQUEST_KEY:
            if ([self.prepareDelegate respondsToSelector:@selector(didTransferRequestKey:)]) {
                [self.prepareDelegate didTransferRequestKey:self];
            }
            break;
        case PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_KEY:
            if ([self.prepareDelegate respondsToSelector:@selector(didTransferKeyUpdated:key:)]) {
                [self.prepareDelegate didTransferKeyUpdated:self key:(NSString*)param];
            }
            break;
        case PAPRIKA_DETAILED_STATE_PREPARING_REQUEST_MODE:
            if ([self.prepareDelegate respondsToSelector:@selector(didTransferRequestMode:)]) {
                [self.prepareDelegate didTransferRequestMode:self];
            }
            break;
        case PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_MODE:
            if ([self.prepareDelegate respondsToSelector:@selector(didTransferModeUpdated:)]) {
                [self.prepareDelegate didTransferModeUpdated:self];
            }
            break;
        case PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_FILE_LIST:
            if ([self.prepareDelegate respondsToSelector:@selector(didTransferFileListUpdated:fileStates:)]) {
                [self.prepareDelegate didTransferFileListUpdated:self fileStates:(NSArray*)param];
            }
            break;
        case PAPRIKA_DETAILED_STATE_PREPARING_WAIT_NETWORK:
            if ([self.prepareDelegate respondsToSelector:@selector(didTransferWaitForTheNetwork:)]) {
                [self.prepareDelegate didTransferWaitForTheNetwork:self];
            }
            break;
    }
    
}

- (void)dispatchTaskError:(NSInteger)state detailedState:(NSInteger)detailedState param:(id)param {
    [super dispatchTaskError:state detailedState:detailedState param:param];
    
    switch (detailedState) {
        case PAPRIKA_DETAILED_STATE_ERROR_FILE_NETWORK:
            if ([self.errorDelegate respondsToSelector:@selector(didTransferErrorFileNetwork:)]) {
                [self.errorDelegate didTransferErrorFileNetwork:self];
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_FILE_WRONG_PROTOCOL:
            if ([self.errorDelegate respondsToSelector:@selector(didTransferErrorFileWrongProtocol:)]) {
                [self.errorDelegate didTransferErrorFileWrongProtocol:self];
            }
//        case PAPRIKA_DETAILED_STATE_ERROR_FILE_BY_PEER:
//            if ([self.errorDelegate respondsToSelector:@selector(fileByPeer:)]) {
//                [self.errorDelegate fileByPeer:self];
//            }
//            break;
    }
}

- (void)dispatchFileProgress:(SAConnectionMode)mode fileIndex:(NSInteger)fileIndex fileState:(PaprikaTransferFileState)fileState {
    if ([self.transferDelegate respondsToSelector:@selector(didTransferFileProgress:mode:done:max:fileIndex:fileState:)]) {
        [self.transferDelegate didTransferFileProgress:self mode:mode done:fileState.sent max:fileState.size fileIndex:fileIndex fileState:fileState];
    }
}

- (void)dispatchSimpleProgress:(NSInteger)fileIndex fileState:(PaprikaTransferFileState)fileState {
    if ([self.transferDelegate respondsToSelector:@selector(didTransferSimpleProgress:progress:max:fileIndex:fileState:)]) {
        [self.transferDelegate didTransferSimpleProgress:self progress:self.progress max:simpleProgressMaximum fileIndex:fileIndex fileState:fileState];
    }
}

#pragma mark - properties

- (NSString*)devicePeerID {
    return [super getValueWithKey:PAPRIKA_VALUE_TRANSFER_PEER_DEVICE_ID defaultValue:@""];
}

- (NSTimeInterval)expireTime {
    if (_expireTime != -1) {
        return _expireTime;
    }
    
    return [[super getValueWithKey:PAPRIKA_VALUE_UPLOAD_EXPIRES_TIME defaultValue:@(DEFAULT_TRANSFER_EXPIRE_TIME)] doubleValue];
}

- (NSString*)transferKey {
    return [super getValueWithKey:PAPRIKA_VALUE_TRANSFER_KEY defaultValue:@""];
}

#pragma mark - helpers

- (NSDictionary*)generateFileMap:(NSArray*)fileList {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [fileList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dic[obj] = @(idx);
    }];
    return dic;
}

- (NSInteger)getActiveFileTransferSize {
    NSInteger size = 0;
    for (NSValue *value in self.activeFileSet) {
        PaprikaTransferFileState fileState;
        [value getValue:&fileState];
        size += fileState.size;
    }
    return size;
}

+ (BOOL)checkFileStateTransferCompleted:(PaprikaTransferFileState)fileState {
    if (fileState.size != -1) {
        return (fileState.sent >= fileState.size);
    } else if (fileState.size == -1) {
        return (fileState.sent > 0);
    }
    return NO;
}

@end
