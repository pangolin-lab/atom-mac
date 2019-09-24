//
//  ShopingViewController.swift
//  Pangolin
//
//  Created by wsli on 2019/9/22.
//  Copyright © 2019 com.nbs. All rights reserved.
//

import Cocoa
import DecentralizedShadowSocks

class ShopingViewController: NSViewController {
        
        @IBOutlet weak var loggingView: NSScrollView!
        @IBOutlet weak var approveTx: NSTextField!
        @IBOutlet weak var RechargeTx: NSTextField!
        @IBOutlet weak var ApproveStatus: NSTextField!
        @IBOutlet weak var RechargeStatus: NSTextField!
        
        override func viewDidLoad() {
                super.viewDidLoad()
        }       
}

func ShowShopingDialog() ->Void{
        
        let alert = NSAlert()
        alert.messageText = "Packet shop".localized
        alert.informativeText = "Please full fill your recharge bill".localized
        alert.alertStyle = .informational
        let shopVC = ShopingViewController()
        alert.accessoryView = shopVC.view
        alert.addButton(withTitle: "Cancel".localized)
        alert.runModal()
}
