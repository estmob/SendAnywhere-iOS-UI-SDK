//
//  EventUtil.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "EventUtil.h"
#import "Global.h"

@implementation EventUtil

+ (void)post:(NSString*)eventName {
    [self post:eventName userInfo:nil];
}

+ (void)post:(NSString*)eventName userInfo:(NSDictionary*)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:eventName object:nil userInfo:userInfo];
}

@end
