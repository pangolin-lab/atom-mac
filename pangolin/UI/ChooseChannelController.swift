//
//  ChooseChannelController.swift
//  Pangolin
//
//  Created by wsli on 2019/9/5.
//  Copyright © 2019年 com.nbs. All rights reserved.
//

import Cocoa

class ChooseChannelController: NSWindowController {
        
        @IBOutlet weak var TokenBalance: NSTextField!
        @IBOutlet weak var PoolNameField: NSTextField!
        @IBOutlet weak var DataBalanceField: NSTextField!
        @IBOutlet weak var DataUsedField: NSTextField!
        @IBOutlet weak var PoolDescField: NSTextField!
        @IBOutlet weak var WaitingTip: NSProgressIndicator!
        @IBOutlet weak var ChannelsTableView: NSTableView!
        
        var selectedRow:MicroPayChannel?
        
        override func windowDidLoad() {
                super.windowDidLoad()
                NotificationCenter.default.addObserver(self, selector:#selector(freshPoolList(notification:)),
                                                       name: MicroPayChannel.SubMinerPoolLoadedNoti, object: nil)
                NotificationCenter.default.addObserver(self, selector:#selector(UpdatePoolName(notification:)),
                                                       name: MinerPool.MinerPoolChangedNoti, object: nil)
                MPCManager.loadMyChannels()
                
        }
        
        @objc func freshPoolList(notification: Notification){
                DispatchQueue.main.async {
                        self.WaitingTip.isHidden = true
                        self.ChannelsTableView.reloadData()
                }
        }
        
        @objc func UpdatePoolName(notification: Notification){
                DispatchQueue.main.async {
                        self.WaitingTip.isHidden = true
                        self.self.updatePoolDetails()
                }
        }
}

extension ChooseChannelController:NSTableViewDelegate{
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
                
                let mp = MPCManager.SubChannels[row]
                var cellIdentifier: String = ""
                var cellValue: String = ""
                
                if tableColumn == tableView.tableColumns[0] {
                        cellIdentifier = "PoolStatusOfChannel"
                        if mp.MainAddr == MPCManager.ChannelInUsed{
                                 cellValue = "In Use"
                        }else{
                                 cellValue = ""
                        }
                       
                }else if tableColumn == tableView.tableColumns[1] {
                        cellIdentifier = "PoolAddreesOfChannel"
                        cellValue = mp.MainAddr
                }
                guard let cell = tableView.makeView(withIdentifier:
                        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView else{
                                return nil
                }
                
                cell.textField?.stringValue = cellValue
                return cell
        }
        
        func tableViewSelectionDidChange(_ notification: Notification){
                let table = notification.object as! NSTableView
                let idx = table.selectedRow
                if idx < 0 || idx >= MPCManager.SubChannels.count{
                        return
                }
                
                self.selectedRow = MPCManager.SubChannels[idx]
                self.updatePoolDetails()
        }
        
        func updatePoolDetails(){
                guard let channel = self.selectedRow else {
                        return
                }
                
                self.DataBalanceField.stringValue = ConvertBandWith(val: Double(channel.RemindPackets))
                self.TokenBalance.doubleValue = channel.RemindTokens
                self.DataUsedField.stringValue = "---"
//                let date = Date.init(timeIntervalSince1970: TimeInterval(channel.Expiration))
//                self.DataBalanceField.stringValue = "\(date)"
                
                guard let pool = MinerPoolManager.PoolDataCache[channel.MainAddr] else{
                        self.WaitingTip.isHidden = false
                        MinerPoolManager.loadMinerPool()
                        return
                }
                
                self.PoolDescField.stringValue = pool.DetailInfos
                self.PoolNameField.stringValue = pool.ShortName
        }
}

extension ChooseChannelController:NSTableViewDataSource{
        func numberOfRows(in tableView: NSTableView) -> Int {
                return MPCManager.SubChannels.count
        }
}
