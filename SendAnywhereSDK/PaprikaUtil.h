//
//  ConvertUtil.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 10/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaprikaUtil : NSObject

+ (id)convertParamWithState:(NSInteger)detailedState param:(const void*)param;
+ (const void*)convertOptionWithKey:(NSInteger)key option:(id)optionValue;


@end
