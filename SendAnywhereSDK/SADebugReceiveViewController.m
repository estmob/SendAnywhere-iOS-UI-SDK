//
//  ReceiveViewController.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SADebugReceiveViewController.h"
#import "Global.h"
#import "Masonry.h"
#import "DebugReceiveTableViewDataSource.h"

@interface SADebugReceiveViewController () <UITableViewDelegate>

@property (nonatomic, retain) UITextField *tfInput;
@property (nonatomic, retain) UIButton *btnSend;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) DebugReceiveTableViewDataSource *dataSource;

@end

@implementation SADebugReceiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self view].backgroundColor = [UIColor whiteColor];
    
    [self prepareSendBtn];
    [self prepareInput];
    [self prepareTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareSendBtn {
    self.btnSend = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.btnSend setTitle:@"Receive" forState:UIControlStateNormal];
    [self.btnSend addTarget:self action:@selector(didPressReceive:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnSend];
    
    [self.btnSend mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@80);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-10);
        make.top.equalTo(self.mas_topLayoutGuide).with.offset(10);
        make.height.equalTo(@36);
    }];
}

- (void)prepareInput {
    self.tfInput = [UITextField new];
    self.tfInput.keyboardType = UIKeyboardTypeNumberPad;
    self.tfInput.placeholder = @"Input receive Key";
    self.tfInput.borderStyle = UITextBorderStyleBezel;
    [self.view addSubview:self.tfInput];
    
    [self.tfInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view.mas_leading).with.offset(10);
        make.trailing.equalTo(self.btnSend.mas_leading).with.offset(-5);
        make.top.equalTo(self.btnSend.mas_top);
        make.height.equalTo(self.btnSend.mas_height);
    }];
}

- (void)prepareTableView {
    self.dataSource = [DebugReceiveTableViewDataSource new];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.btnSend.mas_bottom).with.offset(10);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-10);
        make.leading.equalTo(self.view.mas_leading).with.offset(5);
        make.trailing.equalTo(self.view.mas_trailing).with.offset(-5);
    }];
    
    [self.dataSource registerTableViewCell:self.tableView];
    
    
    
}

#pragma mark - events

- (void)didPressReceive:(UIButton*)sender {
    NSString *key = self.tfInput.text;
    self.tfInput.text = @"";
    
    DDLogDebug(@"receive key : %@", key);
    
}

#pragma mark - tableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

@end
