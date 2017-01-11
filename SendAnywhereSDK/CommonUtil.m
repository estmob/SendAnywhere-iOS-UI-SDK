//
//  CommonUtil.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 09/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "CommonUtil.h"
#import "SendAnywhere.h"

@implementation CommonUtil

+ (NSString*)documentPath {
    if ([SendAnywhere sharedInstance].rootPath.length > 0) {
        return [SendAnywhere sharedInstance].rootPath;
    }
    
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}

@end
