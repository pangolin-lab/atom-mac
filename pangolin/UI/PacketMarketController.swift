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
        @IBOutlet weak var myStatus: NSTextField!
        @IBOutlet weak var poolTypeField: NSTextField!
        @IBOutlet weak var poolDescField: NSTextField!
        
        var currentPool:MinerPool? = nil
        
        override func windowDidLoad() {
                super.windowDidLoad()
                self.loadMinerPools()
        } 
        
        @IBAction func Exit(_ sender: Any) {
                self.close()
        }
        
        func loadMinerPools(){
                WaitingTip.isHidden = false
                Service.sharedInstance.queue.async {
                        MinerPoolManager.loadMinerPool()
                        DispatchQueue.main.async {
                                self.WaitingTip.isHidden = true
                                self.updateUI()
                        }
                }
        }
        
        func updateUI() {
                poolTableView.reloadData()
        }
        
        func updatePoolDetails(){
                guard let details = self.currentPool else {
                        return
                }
                
                self.poolTypeField.stringValue = String.init(format: "%d", details.PoolType)
                self.poolDescField.stringValue = details.DetailInfos
                self.pollIDField.stringValue = String.init(format: "%d", details.ID)
        }
        @IBAction func SycFromEthereumAction(_ sender: NSButton) {
                WaitingTip.isHidden = false
                Service.sharedInstance.queue.async {
                        MinerPoolManager.loadFromBlockChain()
                        DispatchQueue.main.async {
                                self.WaitingTip.isHidden = true
                                self.updateUI()
                        }
                }
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
                
                let addrKey = MinerPoolManager.PoolAddressArr[row]
                guard let poolInfo = MinerPoolManager.PoolDataCache[addrKey] else{
                        return nil
                }
                
                if tableColumn == tableView.tableColumns[0] {
                        cellIdentifier = CellIdentifiers.AddressCell
                        cellValue = addrKey
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
                if idx < 0 || idx >= MinerPoolManager.PoolAddressArr.count{
                        return
                }
                
                let addrKey = MinerPoolManager.PoolAddressArr[idx]
                guard let poolInfo = MinerPoolManager.PoolDataCache[addrKey] else{
                        return
                }
                self.currentPool = poolInfo
                updatePoolDetails()
        }
}

extension PacketMarketController:NSTableViewDataSource {
        
        func numberOfRows(in tableView: NSTableView) -> Int {
                let num = MinerPoolManager.PoolAddressArr.count
                return num
        }
}
