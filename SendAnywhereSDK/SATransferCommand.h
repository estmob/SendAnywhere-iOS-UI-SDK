//
//  SATransferCommand.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 06/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SACommand.h"

typedef NS_ENUM(NSInteger, SAConnectionMode) {
    SAConnectionActive,
    SAConnectionPassive,
    SAConnectionServer
};

@class SATransferCommand;
@protocol SATransferPrepareDelegate <NSObject>
@optional
- (void)didTransferFileListUpdated:(SATransferCommand*)sender fileStates:(NSArray*)fileState;
- (void)didTransferKeyUpdated:(SATransferCommand*)sender key:(NSString*)key;
- (void)didTransferModeUpdated:(SATransferCommand*)sender;


@end

@protocol SATranferNotifyDelegate <NSObject>
@optional
- (void)willTransferStart:(SATransferCommand*)sender;
- (void)willTransferFileStart:(SATransferCommand*)sender fileIndex:(NSInteger)fileIndex fileCount:(NSInteger)fileCount fileState:(PaprikaTransferFileState)fileState;
- (void)didFileProgress:(SATransferCommand*)sender mode:(SAConnectionMode)mode done:(long)done max:(long)max fileIndex:(NSInteger)fileIndex fileState:(PaprikaTransferFileState)fileState;
- (void)didSimpleProgress:(SATransferCommand*)sender progress:(NSInteger)progress max:(NSInteger)max fileIndex:(NSInteger)fileIndex fileState:(PaprikaTransferFileState)fileState;
- (void)didTransferFileFinish:(SATransferCommand*)sender fileIndex:(NSInteger)fileIndex fileCount:(NSInteger)fileCount fileState:(PaprikaTransferFileState)fileState;
- (void)willTranferPause:(SATransferCommand*)sender;
- (void)didTransferResume:(SATransferCommand*)sender;

@end


@interface SATransferCommand : NSObject



@end
