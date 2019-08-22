//
//  EthereumWallet.swift
//  Proton
//
//  Created by ribencong on 2019/7/16.
//  Copyright © 2019 com.proton. All rights reserved.
//

import Foundation
import DecentralizedShadowSocks

class EthereumWalletCtrl :NSWindowController {
         
        @IBOutlet weak var EthAddresses: NSComboBox!
        @IBOutlet weak var EthBalance: NSTextField!
        @IBOutlet weak var ProtonAddressNo: NSTextField!
        @IBOutlet weak var ProtonAddress: NSTextField!
        @IBOutlet weak var WaitingTips: NSProgressIndicator!
        @IBOutlet weak var queriedEthAddress: NSTextField!
        
        let service = Service.sharedInstance
        var queue = DispatchQueue(label: "smart contract queue") 
        
        override func windowDidLoad() {
                super.windowDidLoad()
                
                ReloadLocalEthInfo()
        }
        
        @IBAction func Exit(_ sender: Any) {
                self.close()
        }
        
        @IBAction func CreateWallet(_ sender: Any) {

                let (pwd1, pwd2, ok) = show2PasswordDialog()
                if !ok{
                        return
                }
                
                if pwd1 != pwd2{
                        dialogOK(question: "Error", text: "The 2 Passwords are different")
                        return
                }
                do{
                        try service.CreateEthereumAccount(password: pwd1)
                } catch {
                        dialogOK(question: "Error", text: "Create Account Failed!")
                        return
                }
                
                dialogOK(question: "Tips", text: "Create Success")
                ReloadLocalEthInfo()
        }
        
        @IBAction func ImportWallet(_ sender: Any) {
                let openPanel = NSOpenPanel()
                openPanel.allowsMultipleSelection = false
                openPanel.canChooseDirectories = false
                openPanel.canCreateDirectories = false
                openPanel.canChooseFiles = true
                NSApp.activate(ignoringOtherApps: true)
                openPanel.begin { (result) -> Void in
                        if result.rawValue != NSFileHandlingPanelOKButton {
                                return
                        }
                        
                        let password = showPasswordDialog()
                        if password == ""{
                                return
                        }
                        
                        do {
                                try self.service.ImportEthereumAccount(path: (openPanel.url?.path)!, password: password)
                                dialogOK(question: "Success", text: "Import account successfully")
                                
                                self.ReloadLocalEthInfo()
                                
                        }catch{
                                dialogOK(question: "Warn", text:error.localizedDescription)
                                return
                        }
                }
        }
        
        @IBAction func BackupWallet(_ sender: Any) {
                let dir = service.ethereum.keystoreDirect
                if dir == ""{
                        dialogOK(question: "Error", text: "No ethereum account yet!")
                        return
                }
                
                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: dir)
        }
        
        func ReloadLocalEthInfo(){
                service.ethereum.loadAccount()
                ResetBlockChainInfo()
        }
        
        @IBAction func BuyProtonToken(_ sender: Any) {
                dialogOK(question: "Tips", text: "Proton token can't be trade right now!")
        }
        
        @IBAction func BindProtonAddress(_ sender: Any) {
                WaitingTips.isHidden = false
                defer {
                        WaitingTips.isHidden = true
                }
                
                guard let ethAddr = EthAddresses.selectedCell()?.title, ethAddr != "" else{
                        dialogOK(question: "Tips", text: "Please select the ehtereum account you want to bind with")
                        return
                }
                
                let protonAddr = ProtonAddress.stringValue
                if 0 == LibIsProtonAddress(protonAddr.toGoString()){
                        dialogOK(question: "Warning", text: "Invalid proton address")
                        return
                }
                
                let ethAddr2 = self.service.account.LoadEthAddrByProtonAddr(protonAddr: protonAddr)
                if ethAddr2 != "" && ethAddr2 != "0x0000000000000000000000000000000000000000" {
                        dialogOK(question: "Warning", text: "Duplicate bindings!")
                        return
                }
                
                let password = showPasswordDialog()
                if password == ""{
                        dialogOK(question: "Warning", text: "Invalid ethereum password")
                        return
                }
                
                guard let cipherTxt = service.ethereum.ethCiphTxt[ethAddr], cipherTxt != "" else{
                        dialogOK(question: "Warning", text: "Invalid ethereum account ciphere text")
                        return
                }
                
                let ret = LibBindProtonAddr(protonAddr.toGoString(), cipherTxt.toGoString(), password.toGoString())
                let errStr = String(cString: ret.r1)
                if errStr != ""{
                        dialogOK(question: "Error", text: errStr)
                        return
                }
                
                let txStr = String(cString:ret.r0)
                dialogOK(question: "Tips", text: "Bind request is pending on transaction:[\(txStr)]")
                if let url = URL(string: "\(BaseEtherScanUrl)/tx/\(txStr)") {
                        NSWorkspace.shared.open(url)
                }
        }
        @IBAction func UnbindProtonAddress(_ sender: Any) {
                WaitingTips.isHidden = false
                defer {
                        WaitingTips.isHidden = true
                }
                
                let protonAddr = ProtonAddress.stringValue
                if 0 == LibIsProtonAddress(protonAddr.toGoString()){
                        dialogOK(question: "Warning", text: "Invalid proton address")
                        return
                }
                
                let ethAddr = self.service.account.LoadEthAddrByProtonAddr(protonAddr: protonAddr)
                if ethAddr == ""{
                        dialogOK(question: "Warning", text: "No bindings with this proton address!")
                        return
                }
                
                guard let cipherTxt = service.ethereum.ethCiphTxt[ethAddr], cipherTxt != "" else{
                        dialogOK(question: "Warning", text: "Invalid ethereum account ciphere text")
                        return
                }
                
                let password = showPasswordDialog()
                if password == ""{
                        dialogOK(question: "Warning", text: "Invalid ethereum password")
                        return
                }
                
                let ret = LibUnbindProtonAddr(protonAddr.toGoString(), cipherTxt.toGoString(), password.toGoString())
                let errStr = String(cString: ret.r1)
                if errStr != ""{
                        dialogOK(question: "Error", text: errStr)
                        return
                }
                
                let txStr = String(cString:ret.r0)
                dialogOK(question: "Tips", text: "Unbind request is pending on transaction:[\(txStr)]")
                if let url = URL(string: "https://ropsten.etherscan.io/tx/\(txStr)") {
                        NSWorkspace.shared.open(url)
                }
        }
        
        @IBAction func ApplyTestToken(_ sender: Any) {
                if let url = URL(string: "https://protonio.net") {
                        NSWorkspace.shared.open(url)
                }
        }
        
        @IBAction func QueryProtonAddress(_ sender: Any) {
                let protonAddr = ProtonAddress.stringValue
                if protonAddr == ""{
                        dialogOK(question: "Warn", text: "Proton Address is Empty")
                        return
                }
                
                if 0 == LibIsProtonAddress(protonAddr.toGoString()){
                        dialogOK(question: "Warn", text: "Proton Address is Invalid")
                        return
                }
                
                WaitingTips.isHidden = false
                queue.async {
                        let ethAddr = self.service.account.LoadEthAddrByProtonAddr(protonAddr: protonAddr)
                        DispatchQueue.main.async {
                                self.queriedEthAddress.stringValue = ethAddr
                                self.WaitingTips.isHidden = true
                        }
                }
        }
        
        func ResetBlockChainInfo(){
                EthBalance.stringValue = "0.00 ETH"
                ProtonAddressNo.stringValue = "0"
        }
        
        @IBAction func Rrefresh(_ sender: Any) {
                
                guard let ethAddr = EthAddresses.selectedCell()?.title else{
                       ResetBlockChainInfo()
                        return
                }
                
                if ethAddr == "" {
                        ResetBlockChainInfo()
                        return
                }
                
                WaitingTips.isHidden = false
                queue.async {
                        let (ethBalance, protonNo) = self.service.ethereum.LoadBalance(address: ethAddr)
                        DispatchQueue.main.async {
                                self.EthBalance.stringValue = String.init(format: "%.9f ETH", ethBalance)
                                self.ProtonAddressNo.stringValue = String.init(format: "%d", protonNo)
                                self.WaitingTips.isHidden = true
                        }
                }
        }
}

extension EthereumWalletCtrl:NSComboBoxDelegate{
        func comboBoxSelectionDidChange(_ notification: Notification){
                
        }
        
        func comboBoxSelectionIsChanging(_ notification: Notification){
                
        }
}

extension EthereumWalletCtrl:NSComboBoxDataSource{
        func numberOfItems(in comboBox: NSComboBox) -> Int{
                return service.ethereum.ethAddrArr.count
        }
        
        func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any?{
                return service.ethereum.ethAddrArr[index]
        }
}

