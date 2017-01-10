//
//  ScanQRViewController.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 10/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScanQRViewController;
@protocol ScanQRDelegate <NSObject>
@optional;
- (void)didScanQRFinished:(ScanQRViewController*)controller key:(NSString*)key;

@end

@interface ScanQRViewController : UIViewController

@property (nonatomic, retain) id<ScanQRDelegate> delegate;

@end
