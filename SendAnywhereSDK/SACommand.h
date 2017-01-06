//
//  SACommand.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 06/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <paprika.h>

typedef NS_ENUM(NSInteger, SACommandState) {
    SACommandReady,
    SACommandRunning,
    SACommandFinished
};

@class SACommand;
@protocol SACommandPrepareDelegate <NSObject>
@optional
- (void)didUpdateAuthToken:(SACommand*)sender token:(NSString*)token;
- (void)didUpdateDeviceID:(SACommand*)sender deviceId:(NSString*)deviceId;

@end

@protocol SACommandNotifyDelegate <NSObject>
@optional
- (void)willCommandStart:(SACommand*)sender;
- (void)didCommandFinish:(SACommand*)sender;

- (void)willTaskStart:(SACommand*)sender task:(PaprikaTask)task;
- (void)didTaskPrepare:(SACommand*)sender detailedState:(NSInteger)detailedState param:(id)param;
- (void)didTaskNotify:(SACommand*)sender state:(NSInteger)state detailedState:(NSInteger)detailedState param:(id)param;
- (void)didTaskFinish:(SACommand*)sender detailedState:(NSInteger)detailedState param:(id)param;
- (void)didTaskError:(SACommand*)sender detailedState:(NSInteger)detailedState param:(id)param;

@end

@protocol SACommandErrorDelegate <NSObject>
@optional
- (void)requireLogin:(SACommand*)sender;
- (void)serverAuthentication:(SACommand*)sender;
- (void)serverNetwork:(SACommand*)sender;
- (void)serverWrongProtocol:(SACommand*)sender;
- (void)wrongAPIKey:(SACommand*)sender;

@end

@interface SACommand : NSObject

@property (nonatomic, retain) id<SACommandPrepareDelegate> prepareDelegate;
@property (nonatomic, retain) id<SACommandNotifyDelegate> notifyDelegate;
@property (nonatomic, retain) id<SACommandErrorDelegate> errorDelegate;

- (void)execute;

- (void)executeWithDispatchQueue:(dispatch_queue_t)dispatchQueue;

@end
