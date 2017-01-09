//
//  CommonUtil.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 09/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "CommonUtil.h"

@implementation CommonUtil

+ (NSString*)documentPath {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

@end
