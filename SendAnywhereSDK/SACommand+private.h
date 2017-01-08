//
//  SACommand+private.h
//  paprika_ios_4_sdk
//
//  Created by do on 07/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SACommand.h"

@interface SACommand (private)

- (void)handleCommandStart;
- (void)handleTaskPrepare:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param;
- (void)handleTaskNotify:(PaprikaState)state detailedState:(PaprikaDetailedState)detailedState param:(id)param;

- (void)dispatchTaskStart:(PaprikaTask)task;
- (void)dispatchTaskPrepare:(NSInteger)state detailedState:(NSInteger)detailedState param:(id)param;
- (void)dispatchTaskError:(NSInteger)state detailedState:(NSInteger)detailedState param:(id)param;

- (void)processTaskResult:(PaprikaTask)task;

@end
