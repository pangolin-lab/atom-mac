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
        
        var minerPoolAddrs:[String:MinerPool] = [:]
        
        override func windowDidLoad() {
                super.windowDidLoad()
        } 
        
        @IBAction func Exit(_ sender: Any) {
                self.close()
        }
    
        func loadMinerPools() -> Void {
                
                guard let poolJson = MinerPoolList() else { return  }
                let jsonData:Data = String(cString:poolJson).data(using: .utf8)!
                
                guard let array = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! NSArray else {
                        return
                }
                
                self.minerPoolAddrs.removeAll()
                
                for (_, value) in array.enumerated() {
                        guard let detailData = value as? Data else{
                                continue
                        }
                        
                        guard let dict = try? JSONSerialization.jsonObject(with: detailData, options: .mutableContainers) as! NSDictionary else{
                                continue
                        }
                        
                        let pool = MinerPool.init(dict:dict)
                        self.minerPoolAddrs[pool.MainAddr] = pool
                }                 
        }
}
