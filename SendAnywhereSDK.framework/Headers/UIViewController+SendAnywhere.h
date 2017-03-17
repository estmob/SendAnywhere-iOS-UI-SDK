//
//  UIViewController+SendAnywhere.h
//  PaprikaSDK
//
//  Created by 박도영 on 09/03/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (SendAnywhere)

/**
 * @param fileURLs array of fileURL to send.
 *
 * @return viewController.
 */
- (UIViewController*)sa_showSendViewWithFiles:(NSArray<NSURL*>*)fileURLs error:(NSError**)error;

/**
 * @param datas dictionary of (fileName, fileData) to send.
 *
 * @return viewController.
 */
- (UIViewController*)sa_showSendViewWithDatas:(NSDictionary<NSString*, NSData*>*)datas error:(NSError**)error;

/**
 * @return viewController.
 */

- (UIViewController*)sa_showReceiveViewWithError:(NSError**)error;

@end
