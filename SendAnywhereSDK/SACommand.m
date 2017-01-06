//
//  SACommand.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 06/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SACommand.h"
#import "Global.h"
#import <paprika.h>

static dispatch_queue_t commandDispatchQueue = nil;

@interface SACommand()

@property (nonatomic, readwrite) SACommandState status;
@property (nonatomic, readwrite) NSTimeInterval startedTime;
@property (nonatomic, readwrite) NSTimeInterval finishedTime;

@property (nonatomic, assign) PaprikaState state;
@property (nonatomic, assign) PaprikaDetailedState detailedState;
@property (nonatomic, assign) NSInteger finishedState;

@property (nonatomic, assign) BOOL canceled;
@property (nonatomic, assign) BOOL used;

@property (nonatomic, assign) paprika_listener_function taskListener;

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
                paprika_set_listner(task, self.taskListener, 0);
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

- (void)dispatchTaskStart {
    
}

- (void)dispatchTaskPrepare {
    
}

- (void)dispatchTaskNotify {
    
}

- (void)dispatchTaskFinish {
    
}

- (void)dispatchTaskError {
    
}

- (PaprikaTask)createTask {
    return nil;
}

- (void)setOptionValuesWithTask:(PaprikaTask)task {
    
}

- (void)processTaskResult:(PaprikaTask)task {
    
}


@end
