//
//  CommandManager.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 09/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SASendCommand;
@class SAReceiveCommand;
@interface CommandManager : NSObject

+ (instancetype)sharedInstance;

- (SASendCommand*)makeManagedSendCommand;
- (SAReceiveCommand*)makeManagedReceiveCommand;

@end
