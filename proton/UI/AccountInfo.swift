//
//  Account.swift
//  sofa
//
//  Created by wsli on 2019/4/7.
//  Copyright © 2019 com.nbs. All rights reserved.
//

import Foundation
class AccountWindowCtrl:NSWindowController{
        
        override func windowDidLoad() {
                super.windowDidLoad()
                let service = Service.sharedInstance
                if (service.account.IsEmpty()){
                        AddressField.stringValue = ""
                        CipherField.stringValue = ""
                }else{
                        AddressField.stringValue = Service.sharedInstance.account.addr
                        CipherField.stringValue = Service.sharedInstance.account.cipher
                }
        }
        
        @IBOutlet weak var AddressField: NSTextField!
        @IBOutlet weak var CipherField: NSTextField!
        
        
        @IBAction func Close(_ sender: Any) {
                self.close()
        }
}
