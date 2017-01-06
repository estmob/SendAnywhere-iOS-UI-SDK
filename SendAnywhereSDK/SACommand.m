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

@property (nonatomic, readwrite) SACommandState status;
@property (nonatomic, readwrite) NSTimeInterval startedTime;
@property (nonatomic, readwrite) NSTimeInterval finishedTime;

@property (nonatomic, assign) PaprikaState state;
@property (nonatomic, assign) PaprikaDetailedState detailedState;
@property (nonatomic, assign) NSInteger finishedState;
@property (nonatomic, assign) NSInteger lastError;

@property (nonatomic, assign) BOOL canceled;
@property (nonatomic, assign) BOOL used;

@property (nonatomic, assign) paprika_listener_function taskNotifyListener;

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
        self.finishedState = 0;
        
        __weak SACommand *weakSelf = self;
        
        self.taskNotifyListener = (__bridge void *)^(PaprikaState state,
                                               PaprikaDetailedState detailedState,
                                               const void* param,
                                               void* userptr){
            weakSelf.state = state;
            weakSelf.detailedState = detailedState;
            
            DDLogInfo(@"%@ %s %s", NSStringFromClass([weakSelf class]),
                      paprika_state_to_string(state),
                      paprika_detailedstate_to_string(detailedState));
            
            id obj = (__bridge id)param;
            
            [weakSelf dispatchTaskNotify:state detailedState:detailedState param:obj];
            
            switch (state) {
                case PAPRIKA_STATE_PREPARING:
                    [weakSelf dispatchTaskPrepare:state detailedState:detailedState param:obj];
                    break;
                case PAPRIKA_STATE_FINISHED:
                    weakSelf.finishedState = detailedState;
                    [weakSelf dispatchTaskFinish:state detailedState:detailedState param:obj];
                    break;
                case PAPRIKA_STATE_ERROR:
                    weakSelf.lastError = detailedState;
                    [weakSelf dispatchTaskError:state detailedState:detailedState param:obj];
                    break;
                default:
                    break;
            }
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
        
        PaprikaTask task = [self createTask];
        if (task == nil) {
            DDLogInfo(@"Task is nil.");
        } else {
            DDLogInfo(@"Task create.");
            [self setOptionValuesWithTask:task];
            [self dispatchTaskStart];
            
            if (self.canceled) {
                self.state = PAPRIKA_STATE_FINISHED;
                self.detailedState = PAPRIKA_DETAILED_STATE_FINISHED_CANCEL;
            } else {
                paprika_set_listner(task, self.taskNotifyListener, 0);
                DDLogInfo(@"Task starting");
                paprika_start(task);
                DDLogInfo(@"Task awaiting");
                paprika_wait(task);
                DDLogInfo(@"Task finished");
                [self processTaskResult:task];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleCommandFinish];
        });
        DDLogInfo(@"Finished SACommand");
    });
}

- (void)handleCommandStart {
    self.status = SACommandRunning;
    if ([self.notifyDelegate respondsToSelector:@selector(willCommandStart:)]) {
        [self.notifyDelegate willCommandStart:self];
    }
}

- (void)handleCommandFinish {
    self.status = SACommandFinished;
    self.finishedTime = [[NSDate date] timeIntervalSince1970];
    if ([self.notifyDelegate respondsToSelector:@selector(didCommandFinish:)]) {
        [self.notifyDelegate didCommandFinish:self];
    }
}

- (void)dispatchTaskStart:(PaprikaTask)task {
    if ([self.notifyDelegate respondsToSelector:@selector(willTaskStart:task:)]) {
        [self.notifyDelegate willTaskStart:self task:task];
    }
}

- (void)dispatchTaskNotify:(NSInteger)state detailedState:(NSInteger)detailedState param:(id)param {
    if ([self.notifyDelegate respondsToSelector:@selector(didTaskNotify:state:detailedState:param:)])  {
        [self.notifyDelegate didTaskNotify:self state:state detailedState:detailedState param:param];
    }
}

- (void)dispatchTaskPrepare:(NSInteger)state detailedState:(NSInteger)detailedState param:(id)param {
    if ([self.notifyDelegate respondsToSelector:@selector(didTaskPrepare:detailedState:param:)])  {
        [self.notifyDelegate didTaskPrepare:self detailedState:detailedState param:param];
    }
    
    switch (detailedState) {
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

- (void)dispatchTaskFinish:(NSInteger)state detailedState:(NSInteger)detailedState param:(id)param {
    if ([self.notifyDelegate respondsToSelector:@selector(didTaskFinish:detailedState:param:)])  {
        [self.notifyDelegate didTaskFinish:self detailedState:detailedState param:param];
    }
}

- (void)dispatchTaskError:(NSInteger)state detailedState:(NSInteger)detailedState param:(id)param {
    if ([self.notifyDelegate respondsToSelector:@selector(didTaskError:detailedState:param:)])  {
        [self.notifyDelegate didTaskError:self detailedState:detailedState param:param];
    }
    
    switch (detailedState) {
        case PAPRIKA_DETAILED_STATE_ERROR_REQUIRED_LOGIN:
            if ([self.errorDelegate respondsToSelector:@selector(requireLogin:)]) {
                [self.errorDelegate requireLogin:self];
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_SERVER_AUTHENTICATION:
            if ([self.errorDelegate respondsToSelector:@selector(serverAuthentication:)]) {
                [self.errorDelegate serverAuthentication:self];
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_WRONG_API_KEY:
            if ([self.errorDelegate respondsToSelector:@selector(wrongAPIKey:)]) {
                [self.errorDelegate wrongAPIKey:self];
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_SERVER_WRONG_PROTOCOL:
            if ([self.errorDelegate respondsToSelector:@selector(serverWrongProtocol:)]) {
                [self.errorDelegate serverWrongProtocol:self];
            }
            break;
        case PAPRIKA_DETAILED_STATE_ERROR_SERVER_NETWORK:
            if ([self.errorDelegate respondsToSelector:@selector(serverNetwork:)]) {
                [self.errorDelegate serverNetwork:self];
            }
            break;
    }
}

- (PaprikaTask)createTask {
    return nil;
}

- (void)setOptionValuesWithTask:(PaprikaTask)task {
    
}

- (void)processTaskResult:(PaprikaTask)task {
    
}


@end
