//
//  PreferenceManager.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PREFERENCE_SERVER_DOMAIN @"SAServerDomain"
#define PREFERENCE_PROFILE_NAME @"SAProfileName"
#define PREFERENCE_TRANSFER_EXPIRE_TIME @"SATransferExpireTime"

@interface PreferenceManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) NSString *serverDomain;
@property (nonatomic, readonly) NSString *profileName;
@property (nonatomic, readonly) NSTimeInterval transferExpireTime;

@property (nonatomic, retain) NSString *deviceID;
@property (nonatomic, retain) NSString *devicePassword;

@end
