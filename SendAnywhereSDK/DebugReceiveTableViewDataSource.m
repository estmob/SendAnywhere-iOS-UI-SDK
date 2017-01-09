//
//  DebugReceiveTableViewDataSource.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "DebugReceiveTableViewDataSource.h"
#import "DebugReceiveTableViewCell.h"
#import "Global.h"

#define CellId @"CellId"

@interface DebugReceiveTableViewDataSource()

@property (nonatomic, retain) NSMutableArray *msgList;

@end

@implementation DebugReceiveTableViewDataSource

- (instancetype)init {
    if (self = [super init]) {
        self.msgList = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerTableViewCell:(UITableView *)tableView {
    [tableView registerClass:[DebugReceiveTableViewCell class] forCellReuseIdentifier:CellId];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:ShowLogEvent object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        DDLogMessage *log = note.userInfo[@"log"];
        if (log) {
            [self.msgList addObject:log];
            [tableView reloadData];
            [tableView layoutIfNeeded];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.msgList.count - 1 inSection:0];
            [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
        }
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.msgList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DebugReceiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId forIndexPath:indexPath];
    
    DDLogMessage *log = [self.msgList objectAtIndex:indexPath.row];
    if (log) {
        cell.lbMsg.text = log.message;
    }
    
    return cell;
}

@end
