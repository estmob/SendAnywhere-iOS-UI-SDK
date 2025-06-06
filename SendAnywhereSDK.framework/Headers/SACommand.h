//
//  SACommand.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 06/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "paprika.h"

#define SA_COMMAND_PARAM_TYPE @"type"

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
- (void)didTaskPrepare:(SACommand*)sender detailedState:(PaprikaDetailedState)detailedState param:(id)param;
- (void)didTaskNotify:(SACommand*)sender state:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param;
- (void)didTaskFinish:(SACommand*)sender detailedState:(PaprikaDetailedState)detailedState param:(id)param;
- (void)didTaskError:(SACommand*)sender detailedState:(PaprikaDetailedState)detailedState param:(id)param;

@end

@protocol SACommandErrorDelegate <NSObject>
@optional
- (void)didErrorRequireLogin:(SACommand*)sender;
- (void)didErrorServerAuthentication:(SACommand*)sender;
- (void)didErrorServerNetwork:(SACommand*)sender;
- (void)didErrorServerWrongProtocol:(SACommand*)sender;
- (void)didErrorWrongAPIKey:(SACommand*)sender;
@end

@interface SACommand : NSObject

@property (nonatomic, readonly) NSString *deviceId;
@property (nonatomic, readonly) PaprikaState state;
@property (nonatomic, readonly) PaprikaDetailedState detailedState;
@property (nonatomic, readonly) PaprikaDetailedState lastError;
@property (nonatomic, readonly) NSTimeInterval startedTime;
@property (nonatomic, readonly) NSTimeInterval finishedTime;

@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, readonly) BOOL isFinished;
@property (nonatomic, readonly) BOOL isCanceled;
@property (nonatomic, readonly) BOOL isCanceledByOpponent;
@property (nonatomic, readonly) BOOL hasError;

@property (nonatomic, readonly) NSString *stateString;
@property (nonatomic, readonly) NSString *detailedString;
@property (nonatomic, readonly) NSString *lastErrorString;

- (void)executeWithCompletion:(void (^)())completion;
- (void)executeWithDispatchQueue:(dispatch_queue_t)dispatchQueue completion:(void (^)())completion;
- (void)cancel;

- (void)resume;

- (void)setOptionWithKey:(PaprikaOptionKey)key value:(id)value;
- (void)setParamWithKey:(NSString*)key value:(id)value;
- (id)paramForKey:(NSString*)key;
- (void)clearmParams;

- (id)valueForKey:(PaprikaValue)key defaultValue:(id)defaultValue;

- (void)addPrepareObserver:(id)observer;
- (void)addNotifyObserver:(id)observer;
- (void)addErrorObserver:(id)observer;

- (void)removePrepareObserver:(id)observer;
- (void)removeNotifyObserver:(id)observer;
- (void)removeErrorObserver:(id)observer;

@end
