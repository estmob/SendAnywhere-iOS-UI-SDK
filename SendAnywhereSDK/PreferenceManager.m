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
    
    NSNumber *type = [bundle objectForInfoDictionaryKey:@"SAServerType"];
    if (type == nil) {
        DDLogDebug(@"SAServerType not found in plist file.");
        return ServerTypeApi;
    }
    
    return type.integerValue;
    
}

@end
