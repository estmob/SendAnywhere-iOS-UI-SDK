//
//  SACommand.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 06/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SACommand.h"
#import "Global.h"

static dispatch_queue_t commandDispatchQueue = nil;

@interface SACommand()

@property (nonatomic, assign) SACommandState status;
@property (nonatomic, assign) NSTimeInterval startedTime;
@property (nonatomic, readwrite) NSTimeInterval finishedTime;

@property (nonatomic, assign) PaprikaTask currentTask;

@property (nonatomic, readwrite) PaprikaState state;
@property (nonatomic, readwrite) PaprikaDetailedState detailedState;
@property (nonatomic, readwrite) PaprikaDetailedState lastError;

@property (nonatomic, assign) PaprikaDetailedState finishedState;

@property (nonatomic, assign) BOOL canceled;
@property (nonatomic, assign) BOOL used;

@property (nonatomic, assign) paprika_listener_function taskNotifyListener;

@property (nonatomic, retain) NSMutableDictionary *optionDic;
@property (nonatomic, retain) NSMutableDictionary *paramDic;

@end

@implementation SACommand

- (instancetype)init {
    if (self = [super init]) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            commandDispatchQueue = dispatch_queue_create("com.estmob.sendanywhere.sdk.command", DISPATCH_QUEUE_SERIAL);
        });
        
        self.status = SACommandReady;
        self.used = NO;
        self.canceled = NO;
        self.finishedState = PAPRIKA_DETAILED_STATE_UNKNOWN;
        
        self.optionDic = [NSMutableDictionary dictionary];
        self.paramDic = [NSMutableDictionary dictionary];
        
        __weak SACommand *weakSelf = self;
        
        self.taskNotifyListener = (__bridge void *)^(PaprikaState state,
                                               PaprikaDetailedState detailedState,
                                               const void* param,
                                               void* userptr){
            id obj = (__bridge id)userptr;
            [weakSelf handleTaskNotify:state detailedState:detailedState param:obj];
            
        };
    }
    return self;
}

- (void)execute {
    [self executeWithDispatchQueue:commandDispatchQueue];
}

- (void)executeWithDispatchQueue:(dispatch_queue_t)dispatchQueue {
    if (self.used) {
        @throw @"Not allowed for multiple executing !!";
    }
    
    self.used = YES;
    dispatch_async(dispatchQueue, ^{
        DDLogInfo(@"Starting SACommand");
        self.startedTime = [[NSDate date] timeIntervalSince1970];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleCommandStart];
        });
        
        [self resetState];
        
        self.currentTask = [self createTask];
        if (self.currentTask == nil) {
            DDLogInfo(@"Task is nil.");
        } else {
            DDLogInfo(@"Task create.");
            [self setOptionValues];
            [self handleTaskStart];
            
            if (self.canceled) {
                self.state = PAPRIKA_STATE_FINISHED;
                self.detailedState = PAPRIKA_DETAILED_STATE_FINISHED_CANCEL;
            } else {
                paprika_set_listner(self.currentTask, self.taskNotifyListener, 0);
                DDLogInfo(@"Task starting");
                paprika_start(self.currentTask);
                DDLogInfo(@"Task awaiting");
                paprika_wait(self.currentTask);
                DDLogInfo(@"Task finished");
                [self processTaskResult];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleCommandFinish];
        });
        DDLogInfo(@"Finished SACommand");
    });
}

- (void)setOptionWithKey:(PaprikaOptionKey)key value:(id)value {
    self.optionDic[@(key)] = value;
}

- (void)setParamWithKey:(NSString*)key value:(id)value {
    self.paramDic[key] = value;
}

- (id)paramForKey:(NSString*)key {
    return self.paramDic[key];
}

- (id)valueForKey:(PaprikaValue)key defaultValue:(id)defaultValue {
    void *param;
    paprika_get_value(self.currentTask, key, param);
    
    
    return defaultValue;
}

#pragma mark - handlers

- (void)handleCommandStart {
    self.status = SACommandRunning;
    [self dispatchCommandStart];
}

- (void)handleCommandFinish {
    self.status = SACommandFinished;
    self.finishedTime = [[NSDate date] timeIntervalSince1970];
    [self dispatchCommandFinish];
    paprika_close(self.currentTask);
}

- (void)handleTaskStart {
    [self dispatchTaskStart:self.currentTask];
}

- (void)handleTaskNotify:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    self.state = state;
    self.detailedState = detailedState;
    
    DDLogInfo(@"%@ %s %s", NSStringFromClass([self class]),
              paprika_state_to_string(state),
              paprika_detailedstate_to_string(detailedState));
    
    [self dispatchTaskNotify:state detailedState:detailedState param:param];
    
    switch ((NSInteger)state) {
        case PAPRIKA_STATE_PREPARING:
            [self dispatchTaskPrepare:state detailedState:detailedState param:param];
            break;
        case PAPRIKA_STATE_FINISHED:
            self.finishedState = detailedState;
            [self dispatchTaskFinish:state detailedState:detailedState param:param];
            break;
        case PAPRIKA_STATE_ERROR:
            self.lastError = detailedState;
            [self dispatchTaskError:state detailedState:detailedState param:param];
            break;
    }

}

- (void)handleTaskPrepare:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    [self dispatchTaskPrepare:state detailedState:detailedState param:param];
}

- (void)handleTaskFinish:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    self.finishedState = detailedState;
    [self dispatchTaskFinish:state detailedState:detailedState param:param];
}

- (void)handleTaskError:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    self.lastError = detailedState;
    [self dispatchTaskError:state detailedState:detailedState param:param];
}

#pragma mark - dispatchers

- (void)dispatchCommandStart {
    if ([self.notifyDelegate respondsToSelector:@selector(willCommandStart:)]) {
        [self.notifyDelegate willCommandStart:self];
    }
}

- (void)dispatchCommandFinish {
    if ([self.notifyDelegate respondsToSelector:@selector(didCommandFinish:)]) {
        [self.notifyDelegate didCommandFinish:self];
    }
}

- (void)dispatchTaskStart:(PaprikaTask)task {
    if ([self.notifyDelegate respondsToSelector:@selector(willTaskStart:task:)]) {
        [self.notifyDelegate willTaskStart:self task:task];
    }
}

- (void)dispatchTaskNotify:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    if ([self.notifyDelegate respondsToSelector:@selector(didTaskNotify:state:detailedState:param:)])  {
        [self.notifyDelegate didTaskNotify:self state:state detailedState:detailedState param:param];
    }
}

- (void)dispatchTaskPrepare:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    if ([self.notifyDelegate respondsToSelector:@selector(didTaskPrepare:detailedState:param:)])  {
        [self.notifyDelegate didTaskPrepare:self detailedState:detailedState param:param];
    }
    
    switch ((NSInteger)detailedState) {
        case PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_AUTH_TOKEN:
            if ([self.prepareDelegate respondsToSelector:@selector(didUpdateAuthToken:token:)]) {
                [self.prepareDelegate didUpdateAuthToken:self token:param];
            }
            break;
        case PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_DEVICE_ID:
            if ([self.prepareDelegate respondsToSelector:@selector(didUpdateDeviceID:deviceId:)]) {
                [self.prepareDelegate didUpdateDeviceID:self deviceId:param];
            }
            break;
    }
}

- (void)dispatchTaskFinish:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    if ([self.notifyDelegate respondsToSelector:@selector(didTaskFinish:detailedState:param:)])  {
        [self.notifyDelegate didTaskFinish:self detailedState:detailedState param:param];
    }
}

- (void)dispatchTaskError:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    if ([self.notifyDelegate respondsToSelector:@selector(didTaskError:detailedState:param:)])  {
        [self.notifyDelegate didTaskError:self detailedState:detailedState param:param];
    }
    
    switch ((NSInteger)detailedState) {
        case PAPRIKA_DETAILED_STATE_ERROR_REQUIRED_LOGIN:
            if ([self.errorDelegate respondsToSelector:@selector(didErrorRequireLogin:)]) {
                [self.errorDelegate didErrorRequireLogin:self];
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_SERVER_AUTHENTICATION:
            if ([self.errorDelegate respondsToSelector:@selector(didErrorServerAuthentication:)]) {
                [self.errorDelegate didErrorServerAuthentication:self];
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_WRONG_API_KEY:
            if ([self.errorDelegate respondsToSelector:@selector(didErrorWrongAPIKey:)]) {
                [self.errorDelegate didErrorWrongAPIKey:self];
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_SERVER_WRONG_PROTOCOL:
            if ([self.errorDelegate respondsToSelector:@selector(didErrorServerWrongProtocol:)]) {
                [self.errorDelegate didErrorServerWrongProtocol:self];
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_SERVER_NETWORK:
            if ([self.errorDelegate respondsToSelector:@selector(didErrorServerNetwork:)]) {
                [self.errorDelegate didErrorServerNetwork:self];
            }
            break;
    }
}

#pragma mark - task functions

- (PaprikaTask)createTask {
    return nil;
}

- (void)setOptionValues {
    
}

- (void)processTaskResult:(PaprikaTask)task {
    
}

#pragma mark - properties

- (BOOL)isRunning {
    return self.status == SACommandRunning;
}

- (BOOL)isFinished {
    return self.status == SACommandFinished;
}

- (BOOL)isCanceled {
    return self.canceled;
}

- (BOOL)isCanceledByOpponent {
    return !self.canceled && self.finishedState == PAPRIKA_DETAILED_STATE_FINISHED_CANCEL;
}

- (BOOL)hasError {
    return self.lastError != PAPRIKA_DETAILED_STATE_UNKNOWN;
}

#pragma mark - helpers

- (void)resetState {
    [self setState:PAPRIKA_STATE_UNKNOWN detailedState:PAPRIKA_DETAILED_STATE_UNKNOWN];
    self.lastError = PAPRIKA_DETAILED_STATE_UNKNOWN;
}

- (void)setState:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState {
    self.state = state;
    self.detailedState = detailedState;
}

@end
