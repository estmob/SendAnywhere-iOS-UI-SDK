//
//  SendAnywhere.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SendAnywhere.h"
#import "CocoaLumberjack.h"
#import "Logger.h"
#import "paprika.h"

DDLogLevel ddLogLevel = DDLogLevelOff;

@interface SendAnywhere ()

@property (nonatomic, retain) NSString *apiKey;

@end

@implementation SendAnywhere

+ (SendAnywhere*)sharedInstance {
    static dispatch_once_t once;
    static SendAnywhere *shared = nil;
    
    dispatch_once(&once, ^{
        shared = [SendAnywhere new];
    });
    
    return shared;
}

- (void)initializeWithKey:(NSString*)apiKey debugLevel:(SADebugLevel)debugLevel {
    self.apiKey = apiKey;
    
    paprika_set_apikey(apiKey.UTF8String);
    
    DDLogInfo(@"api key : %@", apiKey);
    
    [self prepareLogWithLevel:debugLevel];
}

- (void)prepareLogWithLevel:(SADebugLevel)debugLevel {
    switch (debugLevel) {
        case SADebugLevelVerbose:
            ddLogLevel = DDLogLevelVerbose;
            break;
        case SADebugLevelDebug:
            ddLogLevel = DDLogLevelDebug;
            break;
        case SADebugLevelInfo:
            ddLogLevel = DDLogLevelInfo;
            break;
        case SADebugLevelWarning:
            ddLogLevel = DDLogLevelWarning;
            break;
        case SADebugLevelError:
            ddLogLevel = DDLogLevelError;
            break;
        default:
            ddLogLevel = DDLogLevelOff;
            break;
    }
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[Logger sharedInstance]];
    
    DDFileLogger *fileLogger = [DDFileLogger new];
    fileLogger.rollingFrequency = 60 * 60 * 24;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
}

@end
