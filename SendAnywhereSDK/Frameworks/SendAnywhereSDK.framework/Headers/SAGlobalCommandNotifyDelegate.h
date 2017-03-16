//
//  SAGlobalCommandNotifyDelegate.h
//  PaprikaSDK
//
//  Created by do on 21/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#ifndef SAGlobalCommandNotifyDelegate_h
#define SAGlobalCommandNotifyDelegate_h

@class SACommand;
@class SATransferCommand;
@protocol SAGlobalCommandNotifyDelegate <NSObject>
@optional
- (void)willGlobalCommandStart:(SACommand*)sender;
- (void)didGlobalCommandFinish:(SACommand*)sender;
- (void)didGlobalTransferFileListUpdated:(SATransferCommand*)sender;
- (void)willGlobalTransferStart:(SATransferCommand*)sender;
- (void)willGlobalTransferFileStart:(SATransferCommand*)sender;
- (void)didGlobalTransferFileFinish:(SATransferCommand*)sender fileIndex:(NSInteger)fileIndex filePath:(NSString*)filePath;
- (void)didGlobalTransferFinish:(SATransferCommand*)sender;
- (void)didGlobalTransferError:(SATransferCommand*)sender;

@end

#endif /* SAGlobalCommandNotifyDelegate_h */
