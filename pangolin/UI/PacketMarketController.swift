//
//  MinerPoolController.swift
//  Pangolin
//
//  Created by Bencong Ri on 2019/8/29.
//  Copyright © 2019年 pangolink.org All rights reserved.
//

import Cocoa

class PacketMarketController: NSWindowController {
        
        
        @IBOutlet weak var WaitingTip: NSProgressIndicator!
        @IBOutlet weak var poolTableView: NSTableView!
        @IBOutlet weak var avgPriceField: NSTextField!
        @IBOutlet weak var userNoField: NSTextField!
        @IBOutlet weak var myStatusField: NSTextField!
        @IBOutlet weak var myBalanceField: NSTextField!
        @IBOutlet weak var pollIDField: NSTextField!
        @IBOutlet weak var poolTypeField: NSTextField!
        @IBOutlet weak var poolDescField: NSTextField!
        @IBOutlet weak var TokenSpendField: NSTextField!
        @IBOutlet weak var PacketGetField: NSTextField!
        @IBOutlet weak var BuyForAddrField: NSTextField!
        @IBOutlet weak var PoolAddressField: NSTextField!
        
        var currentPool:MinerPool? = nil
        let service = Service.sharedInstance
        
        override func windowDidLoad() {
                super.windowDidLoad()
                
                NotificationCenter.default.addObserver(self, selector:#selector(updatePoolList(notification:)),
                                                       name: PoolsInMarketChanged, object: nil)
                
                NotificationCenter.default.addObserver(self, selector:#selector(buyPacketResult(notification:)),
                                                       name: WalletBuyPacketResultNoti, object: nil)
                
                self.loadMinerPools()
                self.BuyForAddrField.stringValue = "0x" + Wallet.sharedInstance.MainAddress
                self.avgPriceField.doubleValue = Double(Service.sharedInstance.srvConf.packetPrice)
        }
        
        deinit {
                NotificationCenter.default.removeObserver(self)
        }
        
        @objc func updatePoolList(notification: Notification){
                self.loadMinerPools()
        }
        
        @objc func buyPacketResult(notification: Notification){
                DispatchQueue.main.async {
                        self.WaitingTip.isHidden = true
                }
                ShowTransResult(notification:notification)
        }
        
        @IBAction func Exit(_ sender: Any) {
                self.close()
        }
        
        func loadMinerPools(){
                WaitingTip.isHidden = false
                service.contractQueue.async {
                        MinerPool.PoolInfoInMarket()
                        DispatchQueue.main.async {
                                self.WaitingTip.isHidden = true
                                self.poolTableView.reloadData()
                        }
                }
        }
        
        func updatePoolDetails(){
                guard let details = self.currentPool else {
                        return
                }
                
                self.poolTypeField.stringValue = "-"
                self.poolDescField.stringValue = details.DetailInfos
                self.pollIDField.stringValue = "-"
                self.PoolAddressField.stringValue = details.MainAddr
        }
        
        @IBAction func SycFromEthereumAction(_ sender: NSButton) {
                loadMinerPools()
        }
        
        @IBAction func BuyPacketAction(_ sender: NSButton) {
                
                guard let details = self.currentPool else {
                        dialogOK(question: "Tips", text: "Please choose a pool item first")
                        return
                }
                
                let tokenToSpend = self.TokenSpendField.doubleValue
                if tokenToSpend <= 0.01{
                        dialogOK(question: "Tips", text: "Too less token to spend!")
                        return
                }
                
                if Wallet.sharedInstance.TokenBalance < tokenToSpend{
                        dialogOK(question: "Tips", text: "No enough token in your wallet!")
                        return
                }
                
                if Wallet.sharedInstance.EthBalance <= 0.001{
                        dialogOK(question: "Tips", text: "No enough ETH for operation gas!")
                        return
                }
                
                let target = self.BuyForAddrField.stringValue
                if target.lengthOfBytes(using: .utf8) != 42{
                        dialogOK(question: "Tips", text: "Invalid target user address")
                        return
                }
                
                let password = showPasswordDialog()
                if password == ""{
                        return
                }
                
                self.WaitingTip.isHidden = false
                Wallet.sharedInstance.BuyPacketFrom(pool:details.MainAddr, for:target, by: tokenToSpend, with: password)
        }
        
}

extension PacketMarketController:NSTableViewDelegate {
        
        fileprivate enum CellIdentifiers {
                static let AddressCell = "AddressCellID"
                static let CoinPledgedCell = "CoinPledgedCellID"
                static let NameCell = "ShortNameCellID"
        }
        
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
                
                var cellIdentifier: String = ""
                var cellValue: String = ""
                
                let poolInfo = MinerPool.poolArray[row]
                if tableColumn == tableView.tableColumns[0] {
                        cellIdentifier = CellIdentifiers.AddressCell
                        cellValue = poolInfo.MainAddr
                }else if tableColumn == tableView.tableColumns[1] {
                        cellIdentifier = CellIdentifiers.CoinPledgedCell
                        cellValue = String.init(format: "%.2f", poolInfo.GuaranteedNo)
                }else if tableColumn == tableView.tableColumns[2] {
                        cellIdentifier = CellIdentifiers.NameCell
                        cellValue = poolInfo.ShortName
                }else{
                        return nil
                }
                
                guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView else{
                        return nil
                }
                
                cell.textField?.stringValue = cellValue
                return cell
        }
        
        func tableViewSelectionDidChange(_ notification: Notification){
                let table = notification.object as! NSTableView
                let idx = table.selectedRow
                if idx < 0 || idx >= MinerPool.poolArray.count{
                        return
                }
                
                let poolInfo = MinerPool.poolArray[idx]
                
                self.currentPool = poolInfo
                updatePoolDetails()
        }
}

extension PacketMarketController:NSTableViewDataSource {
        
        func numberOfRows(in tableView: NSTableView) -> Int {
                return MinerPool.poolArray.count
        }
}

extension PacketMarketController:NSTextFieldDelegate{
        
        func controlTextDidChange(_ notification: Notification){
                guard let field = notification.object as? NSTextField else {
                        Swift.print(notification.object as Any)
                        return
                }
                Swift.print(field.doubleValue)
                let tokenNo = field.doubleValue
                let bytesSum = tokenNo * Double(Service.sharedInstance.srvConf.packetPrice)
                self.PacketGetField.stringValue = ConvertBandWith(val: bytesSum)
        }
}
