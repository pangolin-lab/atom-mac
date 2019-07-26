//
//  SofaAccount.swift
//  sofa
//
//  Created by wsli on 2019/7/15.
//  Copyright © 2019 com.nbs. All rights reserved.
//

import Foundation
class SofaAccountCtrl :NSWindowController{
        
        @IBOutlet weak var SofaAddress: NSTextField!
        @IBOutlet weak var EthereumAddress: NSTextField!
        @IBOutlet weak var waitingTips: NSProgressIndicator!
        
        let service = Service.sharedInstance
        var queue = DispatchQueue(label: "smart contract queue")
        var delegate:StateChangedDelegate?
        
        override func windowDidLoad() {
                super.windowDidLoad()
                
                SofaAddress.stringValue = service.account.addr
                EthereumAddress.stringValue = service.account.ethAddr
        }
        
        @IBAction func Exit(_ sender: Any) {
                self.close()
        }
        
        @IBAction func CopyAddress(_ sender: Any) {
                let sofaAddr = self.SofaAddress.stringValue
                if sofaAddr == ""{
                        return
                }
                
                let pasteboard = NSPasteboard.general
                pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
                pasteboard.setString(sofaAddr, forType: NSPasteboard.PasteboardType.string)
        }
        
        @IBAction func ReloadFromEthereum(_ sender: Any) {
                let sofaAddr = self.SofaAddress.stringValue
                if sofaAddr == ""{
                        dialogOK(question: "Tips", text: "No Sofa Address right now.")
                        return
                }
                LoadBindings()
        }
        
        public func LoadBindings(){
                let sofaAddr = self.SofaAddress.stringValue
                if sofaAddr == ""{
                        return
                }
                
                waitingTips.isHidden = false
                queue.async {
                        let ethAddr = self.service.account.LoadEthAddrBySofaAddr(sofa: sofaAddr)
                        DispatchQueue.main.async {
                                self.waitingTips.isHidden = true
                                self.EthereumAddress.stringValue = ethAddr
                        }
                }
        }
        
        @IBAction func CreateSofaAddress(_ sender: Any) {
                if !service.account.IsEmpty(){
                        dialogOK(question: "Duplicate Account", text: "Already got account!")
                        return
                }
                
                let (pwd1, pwd2, ok) = show2PasswordDialog()
                if !ok{
                        return
                }
                
                if pwd1 != pwd2{
                       dialogOK(question: "Error", text: "The 2 Passwords are different")
                        return
                }
                
                do{
                        try service.CreateNewAccount(password: pwd1)
                } catch {
                        dialogOK(question: "Error", text: "Create Account Failed!")
                        return
                }
                
                dialogOK(question: "Tips", text: "Create Success")
                UpdateUI()
        }
        
        @IBAction func ImportAccount(_ sender: Any) {
                
                if !service.account.IsEmpty(){
                        dialogOK(question: "Tips", text: "You got an account already, please remove the old one first")
                        return
                }
                
                let openPanel = NSOpenPanel()
                openPanel.allowsMultipleSelection = false
                openPanel.canChooseDirectories = false
                openPanel.canCreateDirectories = false
                openPanel.canChooseFiles = true
                NSApp.activate(ignoringOtherApps: true)
                openPanel.allowedFileTypes=["text", "txt", "json"]
                openPanel.begin { (result) -> Void in
                        if result.rawValue != NSFileHandlingPanelOKButton {
                                return
                        }
                        
                        let password = showPasswordDialog()
                        if password == ""{
                                return
                        }
                        
                        do {
                                try self.service.ImportAccount(path: (openPanel.url?.path)!, password: password)
                                dialogOK(question: "Success", text: "Import account successfully")
                                
                                self.UpdateUI()
                                self.delegate?.updateMenu(data: nil, tagId: 1)
                                
                        }catch{
                                dialogOK(question: "Warn", text:error.localizedDescription)
                                return
                        }
                }                
        }
        @IBAction func ExportAccount(_ sender: Any) {
                
                if service.account.IsEmpty(){
                        dialogOK(question: "Tips", text: "No account to export")
                        return
                }
                let FS = NSSavePanel()
                FS.canCreateDirectories = true
                FS.allowedFileTypes = ["text", "txt", "json"]
                FS.canCreateDirectories = true
                FS.isExtensionHidden = false
                FS.nameFieldStringValue = "ypacc.json".localized
                NSApp.activate(ignoringOtherApps: true)
                FS.begin { result in
                        if result.rawValue != NSFileHandlingPanelOKButton {
                                return
                        }
                        do {
                                try self.service.account.ExportAccount(url:FS.url)
                                dialogOK(question: "Success", text: "Export account Successfully")
                        }catch{
                                dialogOK(question: "Error", text: error.localizedDescription)
                                return
                        }
                }
        }
        
        @IBAction func DeleteAccount(_ sender: Any) {
                if service.account.IsEmpty(){
                        dialogOK(question: "Tips", text: ServiceError.AccountEmpty.localizedDescription)
                        return
                }
                
                let ok = dialogOKCancel(question: "Are you sure?", text: "Service will be shut down if you remove the account")
                if !ok{
                        return
                }
                
                do{
                        try service.RemoveAccount()
                }catch{
                        dialogOK(question: "Tips", text: error.localizedDescription)
                        return
                }
                
                UpdateUI()
                self.delegate?.updateMenu(data: nil, tagId: 1) 
        }
        
        func UpdateUI(){
                self.SofaAddress.stringValue = service.account.addr
                self.EthereumAddress.stringValue = service.account.ethAddr
        }
}
