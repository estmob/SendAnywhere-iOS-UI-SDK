//
//  UIViewController+SendAnywhere.h
//  PaprikaSDK
//
//  Created by 박도영 on 09/03/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SASendFileResultType) {
    SASendFileResultTypeSucceed,
    SASendFileResultTypeInvalidArgument,
    SASendFileResultTypeFailed
};

@interface UIViewController (SendAnywhere)
    
- (SASendFileResultType)sa_showSendViewWithFiles:(NSArray<NSURL*>*)fileURLs;
- (SASendFileResultType)sa_showSendViewWithDatas:(NSDictionary<NSString*, NSData*>*)datas;

- (void)sa_showReceiveView;

@end
