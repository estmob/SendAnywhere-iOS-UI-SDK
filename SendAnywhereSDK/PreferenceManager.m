//
//  PreferenceManager.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "PreferenceManager.h"
#import "Global.h"

@implementation PreferenceManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static PreferenceManager *shared = nil;
    
    dispatch_once(&once, ^{
        shared = [PreferenceManager new];
    });
    
    return shared;
}

- (ServerType)serverType {
    NSBundle *bundle = [NSBundle mainBundle];
    if (bundle == nil) {
        return ServerTypeApi;
    }
    NSNumber *type = [bundle objectForInfoDictionaryKey:PREFERENCE_SERVER_TYPE];
    if (type == nil) {
        DDLogDebug(@"%@ not found in plist file.", PREFERENCE_SERVER_TYPE);
        return ServerTypeApi;
    }
    return type.integerValue;
}

- (NSTimeInterval)transferExpireTime {
    NSBundle *bundle = [NSBundle mainBundle];
    if (bundle == nil) {
        return 0;
    }
    NSNumber *time = [bundle objectForInfoDictionaryKey:PREFERENCE_TRANSFER_EXPIRE_TIME];
    if (time == nil) {
        return 0;
    }
    return time.doubleValue;
}

@end
