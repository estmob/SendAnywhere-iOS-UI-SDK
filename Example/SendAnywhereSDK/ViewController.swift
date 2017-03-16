//
//  ViewController.swift
//  SendAnywhereSDK
//
//  Created by doyoung park on 03/14/2017.
//  Copyright (c) 2017 doyoung park. All rights reserved.
//

import UIKit
import SendAnywhereSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didPressSendBtn(_ sender: UIButton) {
        //sa_showSendView(withDatas: [])
    }
    
    @IBAction func didPressReceiveBtn(_ sender: UIButton) {
        sa_showReceiveView()
    }
}

