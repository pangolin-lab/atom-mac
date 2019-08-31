//
//  PacketPool.swift
//  Pangolin
//
//  Created by bencong ri on 2019/8/29.
//  Copyright © 2019年 pangolink.org All rights reserved.
//

import Foundation
class MinerPool: NSObject {
        
        var MainAddr:String = ""
        var Payer:String = ""
        var SubAddr:String = ""
        var GuaranteedNo:Float64 = 0.0
        var ID:Int = 0
        var PoolType:Int = 0
        var ShortName:String = ""
        var DetailInfos:String = ""
        
        override init(){
                super.init()
        }
        
        init(dict:NSDictionary){
                self.MainAddr = dict["MainAddr"] as! String
                self.Payer = dict["Payer"] as! String
                self.SubAddr = dict["SubAddr"] as! String
                self.GuaranteedNo = dict["GuaranteedNo"] as! Float64
                self.ID = dict["ID"] as! Int
                self.PoolType = dict["PoolType"] as! Int
                self.ShortName = dict["ShortName"] as! String
                self.DetailInfos = dict["DetailInfos"] as! String
        }
}
