//
//  SACommand.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 06/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SACommand.h"
#import "Global.h"
#import "PreferenceManager.h"
#import "PaprikaUtil.h"

static dispatch_queue_t commandDispatchQueue = nil;

@interface SACommand()

@property (nonatomic, assign) SACommandState status;
@property (nonatomic, assign) NSTimeInterval startedTime;
@property (nonatomic, readwrite) NSTimeInterval finishedTime;

@property (nonatomic, readwrite) PaprikaState state;
@property (nonatomic, readwrite) PaprikaDetailedState detailedState;
@property (nonatomic, readwrite) PaprikaDetailedState lastError;

@property (nonatomic, assign) PaprikaDetailedState finishedState;

@property (nonatomic, assign) BOOL canceled;
@property (nonatomic, assign) BOOL used;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, retain) dispatch_semaphore_t sem;

@property (atomic, retain) NSMutableArray *taskQueue;

@property (nonatomic, retain) NSMutableDictionary *optionDic;
@property (nonatomic, retain) NSMutableDictionary *paramDic;

@property (nonatomic, retain) NSMutableArray *prepareObservers;
@property (nonatomic, retain) NSMutableArray *notifyObservers;
@property (nonatomic, retain) NSMutableArray *errorObservers;

@property (nonatomic, assign) PaprikaAuthToken authToken;
@property (nonatomic, assign) PaprikaOption taskOption;

@end

@implementation SACommand

void taskNotifyListener(PaprikaState state,
              PaprikaDetailedState detailedState,
              const void* param,
              void* userptr){
    
    SACommand *weakSelf = (__bridge SACommand*)userptr;
    
    id obj = [PaprikaUtil convertParamWithState:detailedState param:param];
    
    [weakSelf handleTaskNotify:state detailedState:detailedState param:obj];
    
}

- (instancetype)init {
    if (self = [super init]) {
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            commandDispatchQueue = dispatch_queue_create("com.estmob.sendanywhere.sdk.command", DISPATCH_QUEUE_SERIAL);
        });
        
        self.status = SACommandReady;
        self.used = NO;
        self.canceled = NO;
        self.paused = NO;
        
        self.sem = dispatch_semaphore_create(0);
        
        self.finishedState = PAPRIKA_DETAILED_STATE_UNKNOWN;
        
        self.taskQueue = [NSMutableArray array];
        
        self.optionDic = [NSMutableDictionary dictionary];
        self.paramDic = [NSMutableDictionary dictionary];
        
        self.prepareObservers = [NSMutableArray array];
        self.notifyObservers = [NSMutableArray array];
        self.errorObservers = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    paprika_auth_close(self.authToken);
    paprika_option_close(self.taskOption);
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
        
        PaprikaTask task = [self createTask];
        if (task == nil) {
            DDLogInfo(@"Task is nil.");
        } else {
            [self enqueueTask:task];
            DDLogInfo(@"Task create.");
            [self setupAuthToken];
            [self setupOptionValues];
            [self handleTaskStart];
            
            if (self.canceled) {
                self.state = PAPRIKA_STATE_FINISHED;
                self.detailedState = PAPRIKA_DETAILED_STATE_FINISHED_CANCEL;
            } else {
                __weak SACommand *weakSelf = self;
                paprika_set_listner(task, taskNotifyListener, (__bridge void *)(weakSelf));
                DDLogInfo(@"Task starting");
                paprika_start(task);
                DDLogInfo(@"Task awaiting");
                paprika_wait(task);
                DDLogInfo(@"Task finished");
                [self processTaskResult:task];
            }
            
            if (!self.canceled && self.paused) {
                DDLogInfo(@"Task waiting loop began...");
                dispatch_semaphore_wait(self.sem, DISPATCH_TIME_FOREVER);                
                DDLogInfo(@"Task waiting loop ended");
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleCommandFinish];
        });
        DDLogInfo(@"Finished SACommand");
    });
}

- (void)cancel {
    self.canceled = YES;
    @synchronized (self) {
        for (NSValue *value in self.taskQueue) {
            PaprikaTask task = [value pointerValue];
            paprika_cancel(task);
        }
    }
}

- (void)setOptionWithKey:(PaprikaOptionKey)key value:(id)value {
    self.optionDic[@(key)] = value;
    
    switch ((NSInteger)key) {
        case PAPRIKA_OPTION_API_SERVER:
            DDLogInfo(@"Server : %@", value);
            break;
        case PAPRIKA_OPTION_PROFILE_NAME:
            DDLogInfo(@"Profile : %@", value);
            break;
    }
}

- (void)setParamWithKey:(NSString*)key value:(id)value {
    self.paramDic[key] = value;
}

- (id)paramForKey:(NSString*)key {
    return self.paramDic[key];
}

- (void)clearmParams {
    [self.paramDic removeAllObjects];
}

- (id)valueForKey:(PaprikaValue)key defaultValue:(id)defaultValue {
    PaprikaTask task = [self currentTask];
    if (task == 0) {
        return defaultValue;
    }
    
    void *param;
    paprika_get_value(task, key, param);
    
    
    return defaultValue;
}

- (void)addPrepareObserver:(id)observer {
    [self.prepareObservers addObject:observer];
}

- (void)addNotifyObserver:(id)observer {
    [self.notifyObservers addObject:observer];
}

- (void)addErrorObserver:(id)observer {
    [self.errorObservers addObject:observer];
}

- (void)removePrepareObserver:(id)observer {
    [self.prepareObservers removeObject:observer];
}

- (void)removeNotifyObserver:(id)observer {
    [self.notifyObservers removeObject:observer];
}

- (void)removeErrorObserver:(id)observer {
    [self.errorObservers removeObject:observer];
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
    PaprikaTask task = [self dequeueTask];
    if (task != 0) {
        paprika_close(task);
    }
}

- (void)handleTaskError:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    self.lastError = detailedState;
    [self dispatchTaskError:state detailedState:detailedState param:param];
}

#pragma mark - dispatchers

- (void)dispatchCommandStart {
    for (id observer in self.notifyObservers) {
        if ([observer respondsToSelector:@selector(willCommandStart:)]) {
            [observer willCommandStart:self];
        }
    }
}

- (void)dispatchCommandFinish {
    for (id observer in self.notifyObservers) {
        if ([observer respondsToSelector:@selector(didCommandFinish:)]) {
            [observer didCommandFinish:self];
        }
    }
}

- (void)dispatchTaskStart:(PaprikaTask)task {
    for (id observer in self.notifyObservers) {
        if ([observer respondsToSelector:@selector(willTaskStart:task:)]) {
            [observer willTaskStart:self task:task];
        }
    }
}

- (void)dispatchTaskNotify:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    for (id observer in self.notifyObservers) {
        if ([observer respondsToSelector:@selector(didTaskNotify:state:detailedState:param:)])  {
            [observer didTaskNotify:self state:state detailedState:detailedState param:param];
        }
    }
}

- (void)dispatchTaskPrepare:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    for (id observer in self.notifyObservers) {
        if ([observer respondsToSelector:@selector(didTaskPrepare:detailedState:param:)])  {
            [observer didTaskPrepare:self detailedState:detailedState param:param];
        }
    }
    
    switch ((NSInteger)detailedState) {
        case PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_AUTH_TOKEN:
            for (id observer in self.prepareObservers) {
                if ([observer respondsToSelector:@selector(didUpdateAuthToken:token:)]) {
                    [observer didUpdateAuthToken:self token:param];
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_PREPARING_UPDATED_DEVICE_ID:
            for (id observer in self.prepareObservers) {
                if ([observer respondsToSelector:@selector(didUpdateDeviceID:deviceId:)]) {
                    [observer didUpdateDeviceID:self deviceId:param];
                }
            }
            break;
    }
}

- (void)dispatchTaskFinish:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    for (id observer in self.notifyObservers) {
        if ([observer respondsToSelector:@selector(didTaskFinish:detailedState:param:)])  {
            [observer didTaskFinish:self detailedState:detailedState param:param];
        }
    }
}

- (void)dispatchTaskError:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param {
    for (id observer in self.notifyObservers) {
        if ([observer respondsToSelector:@selector(didTaskError:detailedState:param:)])  {
            [observer didTaskError:self detailedState:detailedState param:param];
        }
    }
    
    switch ((NSInteger)detailedState) {
        case PAPRIKA_DETAILED_STATE_ERROR_REQUIRED_LOGIN:
            for (id observer in self.errorObservers) {
                if ([observer respondsToSelector:@selector(didErrorRequireLogin:)]) {
                    [observer didErrorRequireLogin:self];
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_SERVER_AUTHENTICATION:
            for (id observer in self.errorObservers) {
                if ([observer respondsToSelector:@selector(didErrorServerAuthentication:)]) {
                    [observer didErrorServerAuthentication:self];
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_WRONG_API_KEY:
            for (id observer in self.errorObservers) {
                if ([observer respondsToSelector:@selector(didErrorWrongAPIKey:)]) {
                    [observer didErrorWrongAPIKey:self];
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_SERVER_WRONG_PROTOCOL:
            for (id observer in self.errorObservers) {
                if ([observer respondsToSelector:@selector(didErrorServerWrongProtocol:)]) {
                    [observer didErrorServerWrongProtocol:self];
                }
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_SERVER_NETWORK:
            for (id observer in self.errorObservers) {
                if ([observer respondsToSelector:@selector(didErrorServerNetwork:)]) {
                    [observer didErrorServerNetwork:self];
                }
            }
            break;
    }
}

#pragma mark - task functions

- (PaprikaTask)createTask {
    return nil;
}

- (void)setupAuthToken {
    PaprikaTask task = [self currentTask];
    if (task == 0) {
        return;
    }
    
    NSString *deviceID = [PreferenceManager sharedInstance].deviceID;
    NSString *password = [PreferenceManager sharedInstance].devicePassword;
    if (deviceID.length == 0 || password.length == 0) {
        self.authToken = paprika_auth_create();
    } else {
        self.authToken = paprika_auth_create_with_deviceid(deviceID.UTF8String, password.UTF8String);
    }
}

- (void)setupOptionValues {
    PaprikaTask task = [self currentTask];
    if (task == 0) {
        return;
    }
    self.taskOption = paprika_option_create();
    [self.optionDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        PaprikaOptionKey optKey = (PaprikaOptionKey)[key integerValue];
        const void *value = [PaprikaUtil convertOptionWithKey:optKey option:obj];
        paprika_option_set_value(self.taskOption, optKey, value);
    }];
    
    paprika_set_option(task, self.taskOption);
}

- (void)processTaskResult:(PaprikaTask)task {
    
}

- (PaprikaTask)currentTask {
    @synchronized (self) {
        if (self.taskQueue.count == 0) {
            return 0;
        }
        return [[self.taskQueue objectAtIndex:0] pointerValue];
    }
}

- (void)enqueueTask:(PaprikaTask)task {
    @synchronized (self) {
        NSValue *value = [NSValue valueWithPointer:task];
        [self.taskQueue addObject:value];
    }
}

- (PaprikaTask)dequeueTask {
    @synchronized (self) {
        if (self.taskQueue.count == 0) {
            return 0;
        }
        PaprikaTask task = [[self.taskQueue objectAtIndex:0] pointerValue];
        [self.taskQueue removeObjectAtIndex:0];
        return task;
    }
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

- (void)setPaused:(BOOL)paused {
    _paused = paused;
    
    if (!paused && _sem != nil) {
        dispatch_semaphore_signal(_sem);
    }
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
