//
//  EventUtil.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventUtil : NSObject

+ (void)post:(NSString*)eventName;
+ (void)post:(NSString*)eventName userInfo:(NSDictionary*)userInfo;

@end
