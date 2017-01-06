//
//  TransferManager.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 06/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "TransferManager.h"

@implementation TransferManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static TransferManager *shared = nil;
    
    dispatch_once(&once, ^{
        shared = [TransferManager new];
    });
    
    return shared;
}

@end
