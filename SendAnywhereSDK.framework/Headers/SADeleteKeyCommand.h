//
//  SADeleteKeyCommand.h
//  PaprikaSDK
//
//  Created by do on 21/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SACommand.h"

#define SA_DELETE_KEY_PARAM_KEY @"Key"
#define SA_DELETE_KEY_PARAM_KEY_ARRAY @"KeyArray"

@interface SADeleteKeyCommand : SACommand

- (void)setParamWithDeleteKey:(NSString*)key;
- (void)setParamWithDeleteKeys:(NSArray*)keyArray;

@end
