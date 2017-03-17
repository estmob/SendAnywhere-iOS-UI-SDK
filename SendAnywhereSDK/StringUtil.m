//
//  StringUtil.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 09/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "StringUtil.h"

@implementation StringUtil

+ (NSString*)extractKey:(NSString*)orgKey {
    NSArray *prefixs = @[@"http://eoq.kr/",
                                @"https://eoq.kr/",
                                @"eoq.kr/",
                                @"http://sendanywhe.re/",
                                @"https://sendanywhe.re/",
                                @"sendanywhe.re/",
                                @"http://send-anywhere.com/web/link/"];
    NSString *ref = orgKey.lowercaseString;
    for (NSString *prefix in prefixs) {
        if ([ref hasPrefix:prefix]) {
            ref = [orgKey substringFromIndex:prefix.length];
            break;
        }
    }
    return ref;
}

@end
