//
//  UIViewController+SendAnywhere.h
//  PaprikaSDK
//
//  Created by 박도영 on 09/03/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SASendCommand;
@class SAReceiveCommand;
@interface UIViewController (SendAnywhere)
    
- (SASendCommand*)sa_showSendViewWithFiles:(NSArray<NSURL*>*)fileURLs error:(NSError**)error;
- (SASendCommand*)sa_showSendViewWithDatas:(NSDictionary<NSString*, NSData*>*)datas error:(NSError**)error;

- (SAReceiveCommand*)sa_showReceiveViewWithError:(NSError**)error;

@end
