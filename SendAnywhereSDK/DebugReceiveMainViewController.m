//
//  ReceiveViewController.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "DebugReceiveMainViewController.h"
#import "Global.h"
#import "Masonry.h"
#import "DebugReceiveTableViewDataSource.h"
#import "StringUtil.h"
#import "CommonUtil.h"
#import "SAReceiveCommand.h"
#import "CommandManager.h"
#import "ScanQRViewController.h"

@interface DebugReceiveMainViewController () <UITableViewDelegate,
ScanQRDelegate,
SATransferPrepareDelegate, SATranferNotifyDelegate, SATransferErrorDelegate>

@property (nonatomic, retain) UITextField *tfInput;
@property (nonatomic, retain) UIButton *btnSend;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) DebugReceiveTableViewDataSource *dataSource;

@property (nonatomic, retain) SAReceiveCommand *command;

@end

@implementation DebugReceiveMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self prepareNavigation];
    [self prepareSendBtn];
    [self prepareInput];
    [self prepareTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tfInput becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    // Dispose of any resources that can be recreated.
}

#pragma mark - prepare methods

- (void)prepareNavigation {
    self.navigationItem.title = @"Send Anywhere - Receiver";
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"QR code" style:UIBarButtonItemStylePlain target:self action:@selector(didPressQRcode:)];
    self.navigationItem.rightBarButtonItem = item;
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
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
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

#pragma mark - internal

- (void)cancelTransfer {
    if (self.command != nil) {
        [self.command cancel];
        self.command = nil;
    }
}

- (void)handleReceiveKey:(NSString*)key {
    [self.view endEditing:YES];
    [self cancelTransfer];
    
    self.command = [[CommandManager sharedInstance] makeManagedReceiveCommand];
    self.command.transferType = SATransferTypeReceive;
    [self.command addTransferObserver:self];
    [self.command addPrepareObserver:self];
    [self.command addErrorObserver:self];
    
    NSString *destDir = [CommonUtil documentPath];
    [self.command executeWithKey:key destDir:destDir];
}

#pragma mark - events

- (void)didPressReceive:(UIButton*)sender {
    NSString *key = self.tfInput.text;
    self.tfInput.text = @"";
    
    key = [StringUtil extractKey:key];
    DDLogDebug(@"receive key : %@", key);
    
    [self handleReceiveKey:key];
}

- (void)didPressQRcode:(UIButton*)sender {
    ScanQRViewController *vc = [ScanQRViewController new];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - scan QR code delegate

- (void)didScanQRFinished:(ScanQRViewController *)controller key:(NSString *)key {
    [controller dismissViewControllerAnimated:YES completion:^{
        [self handleReceiveKey:key];
    }];
}

#pragma mark - prepare observer

- (void)didTransferFileListUpdated:(SATransferCommand *)sender fileStates:(NSArray *)fileState {
    
}

- (void)didTransferKeyUpdated:(SATransferCommand *)sender key:(NSString *)key {
    
}

- (void)didTransferModeUpdated:(SATransferCommand *)sender {
    
}

- (void)didTransferRequestKey:(SATransferCommand *)sender {
    
}

- (void)didTransferRequestMode:(SATransferCommand *)sender {
    
}

- (void)didTransferWaitForTheNetwork:(SATransferCommand *)sender {
    
}

#pragma mark - transfer observer

- (void)willTransferStart:(SATransferCommand *)sender {
    
}

- (void)willTransferFileStart:(SATransferCommand *)sender fileIndex:(NSInteger)fileIndex fileCount:(NSInteger)fileCount fileState:(PaprikaTransferFileState)fileState {
    
}

- (void)didTransferFileProgress:(SATransferCommand *)sender mode:(SAConnectionMode)mode done:(long long)done max:(long long)max fileIndex:(NSInteger)fileIndex fileState:(PaprikaTransferFileState)fileState {
    
}

- (void)didTransferSimpleProgress:(SATransferCommand *)sender progress:(NSInteger)progress max:(NSInteger)max fileIndex:(NSInteger)fileIndex fileState:(PaprikaTransferFileState)fileState {
    
}

- (void)didTransferFileFinish:(SATransferCommand *)sender fileIndex:(NSInteger)fileIndex fileCount:(NSInteger)fileCount fileState:(PaprikaTransferFileState)fileState {
    
}

- (void)didTransferFinish:(SATransferCommand *)sender {
    
}

- (void)willTransferPause:(SATransferCommand *)sender {
    
}

- (void)didTransferResume:(SATransferCommand *)sender {
    
}

#pragma mark - error observer

- (void)didTransferErrorFileNetwork:(SATransferCommand *)sender {
    
}

- (void)didTransferErrorFileWrongProtocol:(SATransferCommand *)sender {
    
}

#pragma mark - tableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

@end
