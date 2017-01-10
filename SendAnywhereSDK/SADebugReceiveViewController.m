//
//  SADebugReceiveViewController.m
//  paprika_ios_4_sdk
//
//  Created by 박도영 on 10/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

#import "SADebugReceiveViewController.h"
#import "DebugReceiveMainViewController.h"

@interface SADebugReceiveViewController ()

@end

@implementation SADebugReceiveViewController

- (instancetype)init {
    DebugReceiveMainViewController *vc = [DebugReceiveMainViewController new];
    if (self = [super initWithRootViewController:vc]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
        
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
