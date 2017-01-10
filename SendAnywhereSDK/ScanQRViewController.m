//
//  ScanQRViewController.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 10/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "ScanQRViewController.h"
#import "ZXingObjC.h"

@interface ScanQRViewController () <ZXCaptureDelegate>

@property (nonatomic, retain) ZXCapture *capture;
@property (nonatomic, retain) UIView *scanRectView;

@property (nonatomic, retain) UIButton *btnClose;

@end

@implementation ScanQRViewController

- (void)dealloc {
    [self.capture.layer removeFromSuperlayer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.capture = [ZXCapture new];
    self.capture.camera = self.capture.back;
    self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    
    [self.view.layer addSublayer:self.capture.layer];
    
    CGRect bounds = self.view.bounds;
    
    self.scanRectView = [[UIView alloc] initWithFrame:CGRectMake(60, 100, bounds.size.width-120, bounds.size.height-200)];
    self.scanRectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scanRectView.layer.borderColor = [UIColor redColor].CGColor;
    self.scanRectView.layer.borderWidth = 1;
    [self.view addSubview:self.scanRectView];
    
    self.btnClose = [UIButton buttonWithType:UIButtonTypeSystem];
    self.btnClose.frame = CGRectMake(bounds.size.width-80, 30, 50, 50);
    self.btnClose.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.btnClose.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.btnClose setTitle:@"Close" forState:UIControlStateNormal];
    [self.btnClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnClose addTarget:self action:@selector(didPressCloseBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnClose];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.capture.delegate = self;
    [self.capture start];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.capture stop];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.capture.layer.frame = self.view.frame;
    self.capture.scanRect = self.scanRectView.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - events

- (void)didPressCloseBtn:(UIButton*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - capture delegate

- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result {
    if (result == nil) {
        return;
    }
    if (result.barcodeFormat != kBarcodeFormatQRCode) {
        return;
    }
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    if ([self.delegate respondsToSelector:@selector(didScanQRFinished:key:)]) {
        [self.delegate didScanQRFinished:self key:result.text];
    }
    
}

@end
