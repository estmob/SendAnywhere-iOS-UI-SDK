//
//  FileListViewController.swift
//  SendAnywhereSDK
//
//  Created by 박도영 on 16/03/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import SendAnywhereSDK

class FileListViewController: UITableViewController, SAGlobalCommandNotifyDelegate {
    
    var rootDir: URL?
    var urlList: [URL]?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else {
            return
        }
        
        rootDir = URL(fileURLWithPath: dir)
        
        urlList = try? FileManager.default.contentsOfDirectory(at: rootDir!, includingPropertiesForKeys: nil, options: [])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SendAnywhere.sharedInstance().addCommandNotifyObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SendAnywhere.sharedInstance().removeCommandNotifyObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urlList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fileCell", for: indexPath)
        if let name = urlList?[indexPath.row].lastPathComponent {
            cell.textLabel?.text = name
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = urlList?[indexPath.row] {
            do {
                let viewController = try sa_showSendView(withFiles: [url])
                
            } catch let error {
                debugPrint(error.localizedDescription)
            }
            
        }
    }
    
    func didGlobalCommandFinish(_ sender: SACommand!) {
        if sender is SASendCommand {
            navigationController?.popViewController(animated: true)
        }
    }

}
