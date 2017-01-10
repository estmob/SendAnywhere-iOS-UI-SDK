//
//  ConvertUtil.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 10/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "paprika.h"

@interface PaprikaUtil : NSObject

+ (id)convertParam:(const void*)param state:(PaprikaDetailedState)detailedState;

@end
