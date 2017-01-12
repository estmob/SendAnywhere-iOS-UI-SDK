//
//  ViewController.swift
//  paprika_example
//
//  Created by 박도영 on 11/01/2017.
//  Copyright © 2017 do. All rights reserved.
//

import UIKit
import PaprikaSDK
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
SATransferPrepareDelegate, SATranferNotifyDelegate, SATransferErrorDelegate, SASendErrorDelegate {
    
    var btnSendTest: UIButton!
    var btnReceiveTest: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bounds = self.view.bounds
        
        self.btnSendTest = UIButton(type: .system)
        self.btnSendTest.frame = CGRect(x: 20, y: 100, width: bounds.width-40, height: 60)
        self.btnSendTest.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        self.btnSendTest.setTitle("Send Test", for: .normal)
        self.btnSendTest.addTarget(self, action: #selector(ViewController.didPressSendTest(sender:)), for: .touchUpInside)
        self.view.addSubview(self.btnSendTest)
        
        self.btnReceiveTest = UIButton(type: .system)
        self.btnReceiveTest.frame = CGRect(x: 20, y: 200, width: bounds.width-40, height: 60)
        self.btnReceiveTest.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        self.btnReceiveTest.setTitle("Receive Test", for: .normal)
        self.btnReceiveTest.addTarget(self, action: #selector(ViewController.didPressReceiveTest(sender:)), for: .touchUpInside)
        self.view.addSubview(self.btnReceiveTest)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Mark - events
    
    func didPressSendTest(sender: UIButton) {
        let pc = UIImagePickerController()
        pc.delegate = self
        pc.sourceType = .savedPhotosAlbum
        self.present(pc, animated: true, completion: nil)
    }
    
    func didPressReceiveTest(sender: UIButton) {
        self.present(SADebugReceiveViewController(), animated: true, completion: nil)
    }
    
    // Mark - image picker delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let url = info[UIImagePickerControllerReferenceURL] as? URL {
            let result = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)
            result.enumerateObjects({ (asset, idx, stop) in
                PHImageManager.default().requestImageData(for: asset, options: nil, resultHandler: { (data, name, orientation, infos) in
                    if let command = SASendCommand.makeInstance() {
                        command.addTransferObserver(self)
                        command.addPrepareObserver(self)
                        command.addErrorObserver(self)
                        if let info = SAFileInfo(fileName: name, path: url.absoluteString, data: data) {
                            command.execute(withFileInfos: [info], mode: PAPRIKA_TRANSFER_DIRECT);
                        }
                        
                    }
                })
            })
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}

