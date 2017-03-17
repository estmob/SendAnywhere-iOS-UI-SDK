//
//  DebugReceiveTableViewDataSource.h
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DebugReceiveTableViewDataSource : NSObject<UITableViewDataSource>

- (void)registerTableViewCell:(UITableView*)tableView;

@end
