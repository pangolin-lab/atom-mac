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
        
        
        var currentPool:MinerPool? = nil
        
        override func windowDidLoad() {
                super.windowDidLoad()
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
                                
                        }
                }
        }
        
        func updateUI() {
                poolTableView.reloadData()
        }
}

extension PacketMarketController:NSTableViewDelegate {
        
        func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
                let addrKey = MinerPoolManager.PoolAddressArr[row]
                var poolInfo = MinerPoolManager.PoolDataCache[addrKey]
                
                
                return mp
        }
}

extension PacketMarketController:NSTableViewDataSource {
        func numberOfRows(in tableView: NSTableView) -> Int {
                return MinerPoolManager.PoolAddressArr.count
        }
}
