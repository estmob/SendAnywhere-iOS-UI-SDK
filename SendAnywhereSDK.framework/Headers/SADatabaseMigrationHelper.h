//
//  SADatabaseMigrationHelper.h
//  PaprikaSDK
//
//  Created by Jehoon Shin on 2017. 2. 24..
//  Copyright © 2017년 do. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SADatabaseMigrationHelper : NSObject

+ (void)insertDevices:(NSArray<NSDictionary*>*)devices completion:(void (^)())completion;
+ (void)insertReceivedPushKeys:(NSArray<NSDictionary*>*)keys completion:(void (^)())completion;
    
@end

