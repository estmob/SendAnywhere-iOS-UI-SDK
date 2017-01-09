//
//  PreferenceManager.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "PreferenceManager.h"
#import "Global.h"
@import UIKit;

@interface PreferenceManager()

@property (nonatomic, retain) NSUserDefaults *userDefaults;

@end

@implementation PreferenceManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static PreferenceManager *shared = nil;
    
    dispatch_once(&once, ^{
        shared = [PreferenceManager new];
    });
    
    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (NSString*)serverDomain {
    NSBundle *bundle = [NSBundle mainBundle];
    if (bundle == nil) {
        return @"api";
    }
    NSString *domain = [bundle objectForInfoDictionaryKey:PREFERENCE_SERVER_DOMAIN];
    if (domain == nil) {
        return @"api";
    }
    return domain;
}

- (NSString*)profileName {
    NSBundle *bundle = [NSBundle mainBundle];
    if (bundle == nil) {
        return [UIDevice currentDevice].name;
    }
    NSString *name = [bundle objectForInfoDictionaryKey:PREFERENCE_PROFILE_NAME];
    if (name == nil) {
        return [UIDevice currentDevice].name;
    }
    return name;
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

- (NSString*)deviceID {
    return [self.userDefaults stringForKey:@"sa_device_id"];
}

- (void)setDeviceID:(NSString *)deviceID {
    [self.userDefaults setValue:deviceID forKey:@"sa_device_id"];
}

- (NSString*)devicePassword {
    return [self.userDefaults stringForKey:@"sa_device_password"];
}

- (void)setDevicePassword:(NSString *)devicePassword {
    [self.userDefaults setValue:devicePassword forKey:@"sa_device_password"];
}

@end
