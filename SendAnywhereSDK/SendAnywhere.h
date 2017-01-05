//
//  SendAnywhere.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SADebugLevel) {
    SADebugLevelNone,
    SADebugLevelError,
    SADebugLevelWarning,
    SADebugLevelInfo,
    SADebugLevelDebug,
    SADebugLevelVerbose
};

@interface SendAnywhere : NSObject

+ (SendAnywhere*)sharedInstance;

- (void)initializeWithKey:(NSString*)apiKey debugLevel:(SADebugLevel)debugLevel;

@end
