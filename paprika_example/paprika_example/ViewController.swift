//
//  ViewController.swift
//  paprika_example
//
//  Created by 박도영 on 11/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

import UIKit
import PaprikaSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.present(SADebugReceiveViewController(), animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

