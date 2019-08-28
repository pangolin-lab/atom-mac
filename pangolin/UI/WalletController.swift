//
//  WalletController.swift
//  Pangolin
//
//  Created by wsli on 2019/8/27.
//  Copyright © 2019年 com.nbs. All rights reserved.
//

import Cocoa

class WalletController: NSWindowController {
        
        var delegate:StateChangedDelegate?
        
        @IBOutlet weak var MainAddressField: NSTextField!
        @IBOutlet weak var SubAddressField: NSTextField!
        @IBOutlet weak var EthBalanceField: NSTextField!
        @IBOutlet weak var LinBalanceField: NSTextField!
        @IBOutlet weak var WaitingTip: NSProgressIndicator!
        @IBOutlet weak var DataBalanceField: NSTextField!
        @IBOutlet weak var DataUsedField: NSTextField!
        @IBOutlet weak var DataAvgPriceField: NSTextField!
        @IBOutlet weak var MinerDescField: NSScrollView!
        
        override func windowDidLoad() {
                super.windowDidLoad()
                updateWallet()
        }
        
        func updateWallet(){
                MainAddressField.stringValue = "0x" + Wallet.sharedInstance.MainAddress
                SubAddressField.stringValue = Wallet.sharedInstance.SubAddress
        }
        
        @IBAction func Exit(_ sender: Any) {
                self.close()
        }
        
        @IBAction func CreateWalletAction(_ sender: Any) {
                if  !Wallet.sharedInstance.IsEmpty(){
                        let ok = dialogOKCancel(question: "Replace This Wallet?", text: "Current wallet will be replaced by new created one!")
                        if !ok{
                                return
                        }
                }
                
                let (pwd1, pwd2, ok) = show2PasswordDialog()
                if !ok{
                        return
                }
                
                if pwd1 != pwd2{
                        dialogOK(question: "Error", text: "The 2 Passwords are different")
                        return
                }
                
                let success = Wallet.sharedInstance.CreateNewWallet(passPhrase: pwd1)
                if success{
                        updateWallet()
                        self.delegate?.updateMenu(data: nil, tagId: 1)
                }
        }
        
        @IBAction func ImportWalletAction(_ sender: Any) {
        }
        
        @IBAction func ExportWalletAction(_ sender: Any) {
        }
        
        @IBAction func SyncEthereumAction(_ sender: Any) {
        }
        
        @IBAction func ReloadMinerPoolActin(_ sender: Any) {
        }
        
        func loadFromEthContract(){
                WaitingTip.isHidden = false
                defer {
                        WaitingTip.isHidden = true
                }
                
        }
}

extension WalletController:NSTableViewDelegate{
        func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
                let mp = Wallet.sharedInstance.SMP[row]
                return mp.Name
        }
}

extension WalletController:NSTableViewDataSource{
        func numberOfRows(in tableView: NSTableView) -> Int {
                return Wallet.sharedInstance.SMP.count
        }
}

