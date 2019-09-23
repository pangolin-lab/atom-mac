//
//  PacketPool.swift
//  Pangolin
//
//  Created by bencong ri on 2019/8/29.
//  Copyright © 2019年 pangolink.org All rights reserved.
//

import Foundation
import DecentralizedShadowSocks

class MinerPool: NSObject {
        
        static var poolArray:[MinerPool] = []
        
        var MainAddr:String = ""
        var Payer:String = ""
        var GuaranteedNo:Double = 0.0
        var ShortName:String = ""
        var DetailInfos:String = ""
        var Seeds:String = ""
        
        override init(){
                super.init()
        }
        
        init(dict:NSDictionary){
                super.init()
                self.MainAddr = dict["MainAddr"] as? String ?? ""
                self.Payer = dict["Payer"] as? String ?? ""
                self.GuaranteedNo = dict["GuaranteedNo"] as? Double ?? 0.00
                self.ShortName = dict["ShortName"] as? String ?? ""
                self.DetailInfos = dict["DetailInfos"] as? String ?? ""
                self.Seeds = dict["Seeds"] as? String ?? ""
        } 
        
        static func parsePoolsData(data:Data){
                guard let array = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! NSArray else {
                        return
                }
                
                poolArray.removeAll()
                for (_, value) in array.enumerated() {
                        
                        guard let dict = value as? NSDictionary else{
                                continue
                        }
                        
                        let channel = MinerPool.init(dict:dict)
                        poolArray.append(channel)
                }
        }
        
        static func PoolInfoInMarket(){
                
                guard let ret = PoolInfosInMarket() else {
                        return
                }
                
                guard let data = String(cString: ret).data(using: .utf8) else{
                        return
                }
                self.parsePoolsData(data: data)
        }
        
        static func asyncFreshMarketData(){
                AsyncLoadMarketData()
        }
}
