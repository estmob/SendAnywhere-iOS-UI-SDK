//
//  SendAnywhere.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAGlobalCommandNotifyDelegate.h"

@interface SendAnywhere : NSObject

@property (nonatomic, retain) NSString *downloadPath;
@property (nonatomic, assign) BOOL allowedDocumentFileType;

@property (nonatomic, readonly) NSString *apiKey;

@property (nonatomic, readonly) BOOL isWifiMode;
@property (nonatomic, readonly) BOOL isNetworkAvailable;

@property (nonatomic, readonly) BOOL isTransferring;

+ (instancetype)sharedInstance;

- (void)initializeWithKey:(NSString*)apiKey;
- (void)initializeWithKey:(NSString*)apiKey userDefaults:(NSUserDefaults*)userDefaults;

- (void)addCommandNotifyObserver:(id<SAGlobalCommandNotifyDelegate>)observer;
- (void)removeCommandNotifyObserver:(id<SAGlobalCommandNotifyDelegate>)observer;
    
- (void)cancelAllTransfers;

- (id)defaultValueForKey:(NSString*)defaultName;
- (void)setDefaultValue:(id)value forKey:(NSString*)defaultName;

@end
