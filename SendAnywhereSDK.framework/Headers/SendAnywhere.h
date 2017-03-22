//
//  SendAnywhere.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAGlobalCommandNotifyDelegate.h"

typedef NS_OPTIONS(NSInteger, SAFileFilterType) {
    SAFileFilterTypeNone            = 0,
    SAFileFilterTypeDocument        = 1 << 0,
    SAFileFilterTypeImage           = 1 << 1,
    SAFileFilterTypeVideo           = 1 << 2,
    SAFileFilterTypeAudio           = 1 << 3
};

@interface SendAnywhere : NSObject

/**
 * downloadPath means a directory to receive files. and It can be changed to other directory.
 *
 * By default, downloadPath is NSDocumentDirectory.
 */
@property (nonatomic, retain) NSString *downloadPath;

/** 
 * You can receive files only specfic type like document file.
 *
 * If customFilePattern is set, this field is ignored.
 *
 * By default, downloadFileFilter is none.
 */
@property (nonatomic, assign) SAFileFilterType downloadFileFilter;

/**
 * You can receive files only custom pattern. (regular expression pattern)
 */
@property (nonatomic, retain) NSString *customFilePattern;

@property (nonatomic, readonly) NSString *apiKey;

@property (nonatomic, readonly) BOOL isWifiMode;
@property (nonatomic, readonly) BOOL isNetworkAvailable;

@property (nonatomic, readonly) BOOL isTransferring;

/**
 *  Returns the SendAnywhereSDK singleton object.
 */
+ (instancetype)sharedInstance;

/**
 * Initialize SendAnywhereSDK. Call this method within your App Delegate's `application:didFinishLaunchingWithOptions:`.
 *
 * Only the first call to this method is honored. Subsequent calls are no-ops.
 *
 * @param apiKey The SendAnywhereSDK API Key for this app
 * you can get in https://send-anywhere.com/web/page/api
 *
 * @return Returns the shared SendAnywhereSDK instance. In most cases this can be ignored.
*/
+ (instancetype)withKey:(NSString*)apiKey;

/**
 * If you use App Groups you should use this method for sharing UserDefaults.
 *
 * @param userDefaults
 */
+ (instancetype)withKey:(NSString*)apiKey userDefaults:(NSUserDefaults*)userDefaults;

/** 
 * Register observer for transferring.
 */
- (void)addCommandNotifyObserver:(id<SAGlobalCommandNotifyDelegate>)observer;

/**
 * Unregister observer.
 */
- (void)removeCommandNotifyObserver:(id<SAGlobalCommandNotifyDelegate>)observer;

/**
 * Cancel all transfer jobs.
 */
- (void)cancelAllTransfers;

/**
 * below methods are used for internal.
 */
- (id)defaultValueForKey:(NSString*)defaultName;
- (void)setDefaultValue:(id)value forKey:(NSString*)defaultName;

@end
