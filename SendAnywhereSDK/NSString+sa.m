//
//  NSString+sa.m
//  paprika_ios_4_sdk
//
//  Created by do on 08/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "NSString+sa.h"

@implementation NSString (sa)

// http://blog.ablepear.com/2010/07/objective-c-tuesdays-wide-character.html
- (const wchar_t*)wchars {
    return (const wchar_t*)[self cStringUsingEncoding:NSUTF32LittleEndianStringEncoding];
}

@end
