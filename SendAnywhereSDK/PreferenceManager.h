//
//  PreferenceManager.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ServerType) {
    ServerTypeApi,
    ServerTypeStaging,
    ServerTypeTest
};

@interface PreferenceManager : NSObject

+ (instancetype)sharedInstance;

- (ServerType)serverType;


@end
