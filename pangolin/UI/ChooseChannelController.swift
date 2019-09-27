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
                                                       name: PayChannelChangedNoti, object: nil)
                
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
        
        @IBAction func ExitAction(_ sender: Any) {
                self.close()
        }
        
}

extension ChooseChannelController:NSTableViewDelegate{
        func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
                
                let mp = MPCManager.ObjAt(idx: row)
                var cellIdentifier: String = ""
                var cellValue: String = ""
                
                if tableColumn == tableView.tableColumns[0] {
                        cellIdentifier = "PoolStatusOfChannel"
                        if Service.sharedInstance.srvConf.poolInUsed == mp.MainAddr{
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
                if idx < 0 || idx >= MPCManager.PayChannels.count{
                        return
                }
                
                self.selectedRow = MPCManager.ObjAt(idx: idx)
                self.updatePoolDetails()
        }
        
        func updatePoolDetails(){
                guard let channel = self.selectedRow else {
                        return
                }
                
                self.DataBalanceField.stringValue = ConvertBandWith(val: Double(channel.RemindPackets))
                self.DataUsedField.stringValue = "---"
        }
}

extension ChooseChannelController:NSTableViewDataSource{
        func numberOfRows(in tableView: NSTableView) -> Int {
                return MPCManager.PayChannels.count
        }
}
