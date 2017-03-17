//
//  Logger.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "Logger.h"
#import "Global.h"
#import "EventUtil.h"

static Logger *sharedInstance;

@implementation Logger

+ (instancetype)sharedInstance {
    static dispatch_once_t DDASLLoggerOnceToken;
    
    dispatch_once(&DDASLLoggerOnceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}


- (void)logMessage:(DDLogMessage *)logMessage {
    [EventUtil post:ShowLogEvent userInfo:@{@"log": logMessage}];
}

@end
