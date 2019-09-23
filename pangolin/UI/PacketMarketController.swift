//
//  MinerPoolController.swift
//  Pangolin
//
//  Created by Bencong Ri on 2019/8/29.
//  Copyright © 2019年 pangolink.org All rights reserved.
//

import Cocoa
import DecentralizedShadowSocks

class PacketMarketController: NSWindowController {
        
        
        @IBOutlet weak var WaitingTip: NSProgressIndicator!
        @IBOutlet weak var poolTableView: NSTableView!
        @IBOutlet weak var avgPriceField: NSTextField!
        @IBOutlet weak var myStatusField: NSTextField!
        @IBOutlet weak var myBalanceField: NSTextField!
        @IBOutlet weak var PoolAddressField: NSTextField!
        @IBOutlet weak var poolDescField: NSScrollView!
        @IBOutlet weak var mortagedField: NSTextField!
        @IBOutlet weak var approvedField: NSTextField!
        @IBOutlet weak var unclaimed: NSTextField!
        
        var currentPool:MinerPool? = nil
        let service = Service.sharedInstance
        
        override func windowDidLoad() {
                super.windowDidLoad()
                
                NotificationCenter.default.addObserver(self, selector:#selector(updatePoolList(notification:)),
                                                       name: PoolsInMarketChanged, object: nil)
                
                NotificationCenter.default.addObserver(self, selector:#selector(buyPacketResult(notification:)),
                                                       name: WalletBuyPacketResultNoti, object: nil)
                
                WaitingTip.isHidden = false
                self.loadPoolsData()
                MinerPool.asyncFreshMarketData()
                self.avgPriceField.doubleValue = Double(Service.sharedInstance.srvConf.packetPrice)
        }
        
        deinit {
                NotificationCenter.default.removeObserver(self)
        }
        
        @objc func updatePoolList(notification: Notification){
                self.loadPoolsData()
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
        
        func loadPoolsData(){
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
                 
                self.poolDescField.documentView?.insertText(details.DetailInfos)
                self.PoolAddressField.stringValue = details.MainAddr
                self.mortagedField.doubleValue = details.GuaranteedNo.CoinValue()
                self.approvedField.doubleValue = QueryApproved(details.MainAddr.toGoString())
        }
        
        @IBAction func SycFromEthereumAction(_ sender: NSButton) {
                MinerPool.asyncFreshMarketData()
        }
        
        @IBAction func BuyPacketAction(_ sender: NSButton) {
                guard let details = self.currentPool else {
                        dialogOK(question: "Tips:",text: "Please select one pool first")
                        return
                }
                let(addr, token, isOk) = ShowShopingDialog(poolDetals: details)
        }
}

extension PacketMarketController:NSTableViewDelegate {
        
        fileprivate enum CellIdentifiers {
                static let AddressCell = "AddressCellID"
                static let CoinPledgedCell = "CoinPledgedCellID"
                static let NameCell = "ShortNameCellID"
        }
        
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
                let poolInfo = MinerPool.poolArray[row]
                
                guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ShortNameCellID"), owner: nil) as? NSTableCellView else{
                        return nil
                }
                
                cell.textField?.stringValue = poolInfo.ShortName
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

