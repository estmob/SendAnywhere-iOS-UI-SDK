//
//  CommandManager.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 09/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "CommandManager.h"
#import "Global.h"
#import "SAReceiveCommand.h"
#import "PreferenceManager.h"

@interface CommandManager() <SACommandPrepareDelegate, SACommandNotifyDelegate, SATranferNotifyDelegate>

@property (nonatomic, retain) NSDictionary *options;

@end

@implementation CommandManager

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static CommandManager *shared = nil;
    
    dispatch_once(&once, ^{
        shared = [CommandManager new];
    });
    
    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        NSString *subDomain = [[PreferenceManager sharedInstance] serverDomain];
        NSString *address = [NSString stringWithFormat:@"https://%@.%@", subDomain, SERVER_ADDRESS];
        NSString *profileName = [[PreferenceManager sharedInstance] profileName];
        
        self.options = @{
//                         @(PAPRIKA_OPTION_API_SERVER): address,
                         @(PAPRIKA_OPTION_SERVER_REGION): @"",
                         @(PAPRIKA_OPTION_PUSH_ID): @"",
                         @(PAPRIKA_OPTION_PUSH_SERVER): @"",
                         @(PAPRIKA_OPTION_PROFILE_NAME): profileName,
                         @(PAPRIKA_OPTION_SHARED_PATH): @"",
                         @(PAPRIKA_OPTION_UPLOAD_TIMEOUT): @(24 * 3600),
                         @(PAPRIKA_OPTION_UPLOAD_KEYTYPE): @0,
                         @(PAPRIKA_OPTION_PARALLEL_TRANSFER): @YES};
    }
    return self;
}

- (SAReceiveCommand*)makeManagedReceiveCommand {
    return (SAReceiveCommand*)[self prepareManagedCommand:[SAReceiveCommand new]];
}

- (SACommand*)prepareManagedCommand:(SACommand*)command {
    [command addNotifyObserver:self];
    if ([command isKindOfClass:[SATransferCommand class]]) {
        [((SATransferCommand*)command) addTransferObserver:self];
    }
    [self setOptionsWithCommand:command];
    return command;
}

- (void)setOptionsWithCommand:(SACommand*)command {
    [self.options enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [command setOptionWithKey:(PaprikaOptionKey)[key integerValue] value:obj];
    }];
}

#pragma mark - prepare observer

- (void)didUpdateDeviceID:(SACommand *)sender deviceId:(NSString *)deviceId {
    
}

- (void)didUpdateAuthToken:(SACommand *)sender token:(NSString *)token {
    
}

@end
