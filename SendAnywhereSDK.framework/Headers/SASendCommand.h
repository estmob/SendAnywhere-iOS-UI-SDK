//
//  SASendCommand.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 12/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SATransferCommand.h"

#define SA_SEND_PARAM_FILE_INFOS    @"FileInfos"
#define SA_SEND_PARAM_KEY           @"Key"
#define SA_SEND_PARAM_THUMBNAIL     @"Thumbnail"

#define SA_ERROR_EXPIRED 9999999

@class PHImageManager;
@interface SAFileInfo : NSObject

@property (nonatomic, retain) NSString *fileName;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, assign) unsigned long long size;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) id userInfo;
@property (nonatomic, retain) PHImageManager *imageManager;

@property (nonatomic, retain) NSFileHandle *tempFile;

- (instancetype)initWithFileName:(NSString*)fileName path:(NSString*)path size:(unsigned long long)size time:(NSInteger)time data:(NSData*)data;

- (void)setupResource;
- (size_t)getBuf:(char*)buf start:(unsigned long long)start length:(size_t)length;
- (void)tryToDeleteDump;

@end

@class SASendCommand;
@protocol SASendErrorDelegate <NSObject>
@optional
- (void)didSendErrorExpired:(SASendCommand*)sender;
- (void)didSendErrorNoRequest:(SASendCommand*)sender;

@end

@interface SASendCommand : SATransferCommand

@property (nonatomic, assign) BOOL expired;
@property (nonatomic, retain) NSString *targetDeviceId;
@property (nonatomic, retain) NSString *linkUrl;

+ (instancetype)makeInstance;

- (void)setParamWithFileInfos:(NSArray<SAFileInfo*>*)fileInfos mode:(PaprikaTransferMode)mode;
- (void)setParamWithKey:(NSString*)key thumbnail:(UIImage*)thumbnail;

- (SAFileInfo*)cloneFileInfos:(SASendCommand*)srcCommand mode:(PaprikaTransferMode)mode;
- (BOOL)checkFileSize;

+ (void)sendPushKey:(NSString*)key deviceId:(NSString*)deviceId comment:(NSString*)comment thumbnail:(UIImage*)thumbnail;

@end
