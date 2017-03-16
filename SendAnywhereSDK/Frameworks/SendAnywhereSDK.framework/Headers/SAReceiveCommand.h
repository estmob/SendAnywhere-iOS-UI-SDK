//
//  SAReceiveCommand.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 06/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SATransferCommand.h"

#define SA_RECEIVE_PARAM_FILE_PATTERN @"file_pattern"

@class SAReceiveCommand;
@protocol SAReceiveErrorDelegate <NSObject>
@optional
- (void)didReceiveErrorDownloadPathNotExists:(SAReceiveCommand*)sender;
- (void)didReceiveErrorKeyNotExists:(SAReceiveCommand*)sender;
- (void)didReceiveErrorNoDiskSpace:(SAReceiveCommand*)sender;
- (void)didReceiveErrorLinkShareKey:(SAReceiveCommand*)sender;

@end

@interface SAReceiveCommand : SATransferCommand

@property (nonatomic, retain) NSString *licenseUrl;

+ (instancetype)makeInstance;

- (void)executeWithKey:(NSString*)key;
- (void)executeWithKey:(NSString *)key filePattern:(NSString*)filePattern;

- (void)setParamWithTransferKey:(NSString *)key;
- (void)setParamWithTransferKey:(NSString *)key relativePath:(NSString*)relativePath;
- (void)setParamWithTransferMode:(PaprikaTransferMode)mode;
- (void)setParamWithFilePattern:(NSString*)filePattern;

@end
