//
//  SAReceiveCommand.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 06/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SATransferCommand.h"

@class SAReceiveCommand;
@protocol SAReceiveErrorDelegate <NSObject>
@optional
- (void)didReceiveErrorDownloadPathNotExists:(SAReceiveCommand*)sender;
- (void)didReceiveErrorKeyNotExists:(SAReceiveCommand*)sender;
- (void)didReceiveErrorNoDiskSpace:(SAReceiveCommand*)sender;

@end

@interface SAReceiveCommand : SATransferCommand

@property (nonatomic, retain) id<SACommandErrorDelegate, SATransferErrorDelegate, SAReceiveErrorDelegate> errorDelegate;

@property (nonatomic, retain) NSString *licenseUrl;

- (void)executeWithKey:(NSString*)key destDir:(NSString*)destDir;
- (void)executeWithKey:(NSString*)key destDir:(NSString*)destDir dispatchQueue:(dispatch_queue_t)dispatchQueue;

- (void)setParamWithKey:(NSString *)key;
- (void)setParamWithKey:(NSString *)key destDir:(NSString*)destDir;

@end
