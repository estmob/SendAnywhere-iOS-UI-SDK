//
//  ViewController.swift
//  sdk_example
//
//  Created by 박도영 on 05/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

import UIKit
import PaprikaSDK

class ViewController: UIViewController {

    @IBAction func didPressSAReceiveBtn(_ sender: UIButton) {
        let vc = SADebugReceiveViewController()
        self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

