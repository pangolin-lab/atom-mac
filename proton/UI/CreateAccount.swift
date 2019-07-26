//
//  CreateAccount.swift
//  sofa
//
//  Created by wsli on 2019/4/7.
//  Copyright © 2019 com.nbs. All rights reserved.
//

import Foundation
class CreateAccountCtrl:NSWindowController{
        @IBOutlet weak var passWordField: NSTextField!
        @IBOutlet weak var passWordAgainField: NSTextField!
        @IBOutlet weak var AddressLabel: NSTextField!
        @IBOutlet weak var cipherTxtField: NSTextField!
        
        weak var menuDelegate:StateChangedDelegate?
        
        @IBAction func createAccount(_ sender: NSButton) {
                let server = Service.sharedInstance
                if !server.account.IsEmpty(){
                        dialogOK(question: "Duplicate Account", text: "Already got account!")
                        return
                }
                
                let pwStr = passWordField.stringValue
                let strLen = pwStr.lengthOfBytes(using: String.Encoding.utf8)
                if strLen > 20 || strLen < 8{
                        dialogOK(question: "Tips", text: "Password length is not fine!")
                        return
                }
                let pwStrAgain = passWordAgainField.stringValue
                if pwStr != pwStrAgain{
                        dialogOK(question: "Error", text: "The 2 Passwords are different")
                        return
                }
                
                do{
                       try server.CreateNewAccount(password: pwStr)
                } catch {
                        dialogOK(question: "Error", text: "Create Account Failed!")
                        return
                }
                
                AddressLabel.stringValue = server.account.addr
                cipherTxtField.stringValue = server.account.cipher
                dialogOK(question: "Tips", text: "Create Success")
                if let delegate = menuDelegate{
                        delegate.updateMenu(data: nil, tagId: 1)
                }
        }
        
        
        @IBAction func windowsClose(_ sender: NSButton) {
                self.close()
        }
        
}
