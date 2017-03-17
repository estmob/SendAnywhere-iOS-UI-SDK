//
//  SATransferCommand.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 06/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SATransferCommand.h"
#import "SACommand+sa_private.h"
#import "Global.h"

NSInteger simpleProgressMaximum = 10000;

@interface SATransferCommand()

@property (nonatomic, readwrite) NSTimeInterval expireTime;
@property (nonatomic, readwrite) NSInteger progress;
@property (nonatomic, readwrite) NSInteger sizeToTransfer;
@property (nonatomic, readwrite) NSInteger sizeTransferred;
@property (nonatomic, readwrite) NSString *transferID;
@property (nonatomic, readwrite) PaprikaTransferMode transferMode;

@property (nonatomic, readwrite) NSArray *fileList;
@property (nonatomic, retain) NSDictionary *fileMap;
@property (nonatomic, retain) NSMutableSet *activeFileSet;
@property (nonatomic, assign) NSInteger finishedFileCount;

@property (nonatomic, assign) SAConnectionMode connectionMode;

@property (nonatomic, readwrite) BOOL transferStarted;
@property (nonatomic, readwrite) BOOL fileListUpdated;
@property (nonatomic, readwrite) BOOL transferPaused;

@property (nonatomic, retain) NSMutableArray *transferObservers;

@end

@implementation SATransferCommand

- (instancetype)init {
    if (self = [super init]) {
        self.transferObservers = [NSMutableArray array];
    }
    return self;
}

- (SATransferFileStatus)fileStatusWithIndex:(NSInteger)index {
    
    NSValue *value = [self.fileList objectAtIndex:index];
    const PaprikaTransferFileState *fileState = (const PaprikaTransferFileState*)[value pointerValue];
    if ([SATransferCommand checkFileStateTransferCompleted:*fileState]) {
        return SATransferFileStatusFinished;
    } else if ([self.activeFileSet containsObject:value]) {
        return SATransferFileStatusTransferring;
    }
    return SATransferFileStatusIdle;
}

- (void)addPrepareObserver:(id)observer {
    [super addPrepareObserver:observer];
}

- (void)addErrorObserver:(id)observer {
    [super addErrorObserver:observer];
}

- (void)addTransferObserver:(id)observer {
    [self.transferObservers addObject:observer];
}

- (void)removePrepareObserver:(id)observer {
    [super removePrepareObserver:observer];
}

- (void)removeErrorObserver:(id)observer {
    [super removeErrorObserver:observer];
}

- (void)removeTransferObserver:(id)observer {
    [self.transferObservers removeObject:observer];
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
                const PaprikaTransferFileState *fileState = (const PaprikaTransferFileState*)[value pointerValue];
                self.sizeToTransfer += fileState->size;
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
    if (param == nil) {
        DDLogInfo(@"notify param is nil !!");
        return;
    }
    
    const PaprikaTransferFileState *fileState = (const PaprikaTransferFileState*)[param pointerValue];
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
                for (id observer in self.transferObservers) {
                    if ([observer respondsToSelector:@selector(willTransferStart:)]) {
                        [observer willTransferStart:self];
                    }
                }
                [self.activeFileSet addObject:param];
                for (id observer in self.transferObservers) {
                    if ([observer respondsToSelector:@selector(willTransferFileStart:fileIndex:fileCount:fileState:)]) {
                        [observer willTransferFileStart:self fileIndex:index fileCount:self.fileList.count fileState:*fileState];
                    }
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_TRANSFERRING_END_FILE:
            for (id observer in self.transferObservers) {
                if ([observer respondsToSelector:@selector(didTransferFileFinish:fileIndex:fileCount:fileState:)]) {
                    [observer didTransferFileFinish:self fileIndex:index fileCount:self.fileList.count fileState:*fileState];
                }
            }
            [self.activeFileSet removeObject:param];
            self.sizeTransferred += fileState->size;
            
            if (++self.finishedFileCount == self.fileList.count) {
                [self.activeFileSet removeAllObjects];
                self.sizeTransferred = self.sizeToTransfer;
                for (id observer in self.transferObservers) {
                    if ([observer respondsToSelector:@selector(didTransferFinish:)]) {
                        [observer didTransferFinish:self];
                    }
                }
            }
            [self handleFileProgress:self.connectionMode fileIndex:index fileState:*fileState];
            break;
        case PAPRIKA_DETAILED_STATE_TRANSFERRING_SERVER:
            [self handleFileProgress:SAConnectionServer fileIndex:index fileState:*fileState];
            break;
        case PAPRIKA_DETAILED_STATE_TRANSFERRING_ACTIVE:
            [self handleFileProgress:SAConnectionActive fileIndex:index fileState:*fileState];
            break;
        case PAPRIKA_DETAILED_STATE_TRANSFERRING_PASSIVE:
            [self handleFileProgress:SAConnectionPassive fileIndex:index fileState:*fileState];
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
            for (id observer in self.prepareObservers) {
                if ([observer respondsToSelector:@selector(didTransferRequestKey:)]) {
                    [observer didTransferRequestKey:self];
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_KEY:
            for (id observer in self.prepareObservers) {
                if ([observer respondsToSelector:@selector(didTransferKeyUpdated:key:)]) {
                    [observer didTransferKeyUpdated:self key:(NSString*)param];
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_PREPARING_REQUEST_MODE:
            for (id observer in self.prepareObservers) {
                if ([observer respondsToSelector:@selector(didTransferRequestMode:)]) {
                    [observer didTransferRequestMode:self];
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_MODE:
            for (id observer in self.prepareObservers) {
                if ([observer respondsToSelector:@selector(didTransferModeUpdated:)]) {
                    [observer didTransferModeUpdated:self];
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_FILE_LIST:
            for (id observer in self.prepareObservers) {
                if ([observer respondsToSelector:@selector(didTransferFileListUpdated:fileStates:)]) {
                    [observer didTransferFileListUpdated:self fileStates:(NSArray*)param];
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_PREPARING_WAIT_NETWORK:
            for (id observer in self.prepareObservers) {
                if ([observer respondsToSelector:@selector(didTransferWaitForTheNetwork:)]) {
                    [observer didTransferWaitForTheNetwork:self];
                }
            }
            break;
    }
    
}

- (void)dispatchTaskError:(NSInteger)state detailedState:(NSInteger)detailedState param:(id)param {
    [super dispatchTaskError:state detailedState:detailedState param:param];
    
    switch (detailedState) {
        case PAPRIKA_DETAILED_STATE_ERROR_FILE_NETWORK:
            for (id observer in self.errorObservers) {
                if ([observer respondsToSelector:@selector(didTransferErrorFileNetwork:)]) {
                    [observer didTransferErrorFileNetwork:self];
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_FILE_WRONG_PROTOCOL:
            for (id observer in self.errorObservers) {
                if ([observer respondsToSelector:@selector(didTransferErrorFileWrongProtocol:)]) {
                    [observer didTransferErrorFileWrongProtocol:self];
                }
            }
//        case PAPRIKA_DETAILED_STATE_ERROR_FILE_BY_PEER:
//                for (id observer in self.errorObservers) {
//            if ([self.errorDelegate respondsToSelector:@selector(fileByPeer:)]) {
//                [self.errorDelegate fileByPeer:self];
//            }
//              }
//            break;
    }
}

- (void)dispatchFileProgress:(SAConnectionMode)mode fileIndex:(NSInteger)fileIndex fileState:(PaprikaTransferFileState)fileState {
    for (id observer in self.transferObservers) {
        if ([observer respondsToSelector:@selector(didTransferFileProgress:mode:done:max:fileIndex:fileState:)]) {
            [observer didTransferFileProgress:self mode:mode done:fileState.sent max:fileState.size fileIndex:fileIndex fileState:fileState];
        }
    }
}

- (void)dispatchSimpleProgress:(NSInteger)fileIndex fileState:(PaprikaTransferFileState)fileState {
    for (id observer in self.transferObservers) {
        if ([observer respondsToSelector:@selector(didTransferSimpleProgress:progress:max:fileIndex:fileState:)]) {
            [observer didTransferSimpleProgress:self progress:self.progress max:simpleProgressMaximum fileIndex:fileIndex fileState:fileState];
        }
    }
}

#pragma mark - properties

- (NSString*)devicePeerID {
    return [super valueForKey:PAPRIKA_VALUE_TRANSFER_PEER_DEVICE_ID defaultValue:@""];
}

- (NSTimeInterval)expireTime {
    if (_expireTime != -1) {
        return _expireTime;
    }
    
    return [[super valueForKey:PAPRIKA_VALUE_UPLOAD_EXPIRES_TIME defaultValue:@(DEFAULT_TRANSFER_EXPIRE_TIME)] doubleValue];
}

- (NSString*)transferKey {
    return [super valueForKey:PAPRIKA_VALUE_TRANSFER_KEY defaultValue:@""];
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
        const PaprikaTransferFileState *fileState = (const PaprikaTransferFileState*)[value pointerValue];
        size += fileState->size;
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
