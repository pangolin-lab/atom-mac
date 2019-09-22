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
        }
        
        @IBAction func SycFromEthereumAction(_ sender: NSButton) {
                MinerPool.asyncFreshMarketData()
        }
        
        @IBAction func BuyPacketAction(_ sender: NSButton) {
                
                
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

