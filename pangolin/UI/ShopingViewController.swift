//
//  ShopingViewController.swift
//  Pangolin
//
//  Created by wsli on 2019/9/22.
//  Copyright © 2019 com.nbs. All rights reserved.
//

import Cocoa
import DecentralizedShadowSocks

class ShopingViewController: NSViewController {
        
        @IBOutlet weak var buyForAddress: NSTextField!
        @IBOutlet weak var TokenToSpend: NSTextField!
        @IBOutlet weak var PacketPrice: NSTextField!
        @IBOutlet weak var PacketCanGet: NSTextField!
        @IBOutlet weak var EthBalance: NSTextField!
        @IBOutlet weak var LinBalance: NSTextField!
        @IBOutlet weak var hasApproved: NSTextField!
        @IBOutlet weak var approveTx: NSTextField!
        @IBOutlet weak var RechargeTx: NSTextField!
        @IBOutlet weak var ApproveStatus: NSTextField!
        @IBOutlet weak var RechargeStatus: NSTextField!
        @IBOutlet weak var PoolName: NSTextField!
        @IBOutlet weak var PoolAddress: NSTextField!
        
        var details: MinerPool? = nil
        
        override func viewDidLoad() {
                super.viewDidLoad()

                self.buyForAddress.stringValue = "0x" + Wallet.sharedInstance.MainAddress
                self.hasApproved.doubleValue = Wallet.sharedInstance.HasApproved.CoinValue()
                self.PacketPrice.doubleValue = Double(Service.sharedInstance.srvConf.packetPrice)
                self.hasApproved.doubleValue = QueryApproved(details!.MainAddr.toGoString())
                self.PoolName.stringValue = details!.ShortName
                self.PoolAddress.stringValue = details!.MainAddr
                
                self.EthBalance.doubleValue = Wallet.sharedInstance.EthBalance.CoinValue()
                self.LinBalance.doubleValue = Wallet.sharedInstance.TokenBalance.CoinValue()
        }
    
        @IBAction func rechargeAction(_ sender: Any) {
//                guard let details = self.currentPool else {
//                        dialogOK(question: "Tips", text: "Please choose a pool item first")
//                        return
//                }
//                
//                let tokenToSpend = self.TokenSpendField.doubleValue
//                if tokenToSpend <= 0.01{
//                        dialogOK(question: "Tips", text: "Too less token to spend!")
//                        return
//                }
//                
//                if Wallet.sharedInstance.TokenBalance < tokenToSpend{
//                        dialogOK(question: "Tips", text: "No enough token in your wallet!")
//                        return
//                }
//                
//                if Wallet.sharedInstance.EthBalance <= 0.001{
//                        dialogOK(question: "Tips", text: "No enough ETH for operation gas!")
//                        return
//                }
//                
//                let target = self.BuyForAddrField.stringValue
//                if target.lengthOfBytes(using: .utf8) != 42{
//                        dialogOK(question: "Tips", text: "Invalid target user address")
//                        return
//                }
//                
//                let password = showPasswordDialog()
//                if password == ""{
//                        return
//                }
//                
//                self.WaitingTip.isHidden = false
//                Wallet.sharedInstance.BuyPacketFrom(pool:details.MainAddr, for:target, by: tokenToSpend, with: password)
        }
}


extension ShopingViewController:NSTextFieldDelegate{
        
        func controlTextDidChange(_ notification: Notification){
                guard let field = notification.object as? NSTextField else {
                        Swift.print(notification.object as Any)
                        return
                }
                Swift.print(field.doubleValue)
                let tokenNo = field.doubleValue
                let bytesSum = tokenNo * Double(Service.sharedInstance.srvConf.packetPrice)
                self.PacketCanGet.stringValue = ConvertBandWith(val: bytesSum)
        }
}


func ShowShopingDialog(poolDetals:MinerPool) -> (String, Double, Bool){
        
        let alert = NSAlert()
        alert.messageText = "Packet shop".localized
        alert.informativeText = "Please full fill your recharge bill".localized
        alert.alertStyle = .informational
        let shopVC = ShopingViewController()
        shopVC.details = poolDetals
        alert.accessoryView = shopVC.view
        alert.addButton(withTitle: "OK".localized)
        alert.addButton(withTitle: "Cancel".localized)
        let butSel = alert.runModal()
        if butSel == .alertFirstButtonReturn{
                return (shopVC.buyForAddress.stringValue, shopVC.TokenToSpend.doubleValue, true)
        }
        
        return("", 0.0, false)
}
