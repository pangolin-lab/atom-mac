//
//  MenuController.swift
//  Pangolin
//
//  Created by Bencong Ri on 2019/1/30.
//  Copyright © 2019 pangolink.org All rights reserved.
//

import Cocoa

@objc protocol StateChangedDelegate {
        func updateMenu(data: Any?, tagId:Int)
}

class MenuController: NSObject, StateChangedDelegate {
      
        @IBOutlet weak var statusMenu: NSMenu!
        
        @IBOutlet weak var switchBtn: NSMenuItem!
        @IBOutlet weak var smartModel: NSMenuItem!
        @IBOutlet weak var globalModel: NSMenuItem!
        @IBOutlet weak var walletMenu: NSMenuItem!
        @IBOutlet weak var minerPoolMenu: NSMenuItem!
        
        var walletCtrl: WalletController!
        
        let server = Service.sharedInstance
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        override func awakeFromNib() {
                let icon = NSImage(named: "statusOff")
                icon?.isTemplate = true // best for dark mode
                statusItem.button?.image = icon
                statusItem.menu = statusMenu
                server.SetDelegate(d: self)
                updateUI()
        }
        
        func updateMenu(data: Any?, tagId: Int) {
                DispatchQueue.main.async{ self.updateUI()}
        }
        
        func updateUI() -> Void {                
                if server.IsTurnOn {
                        switchBtn.title = "Turn Off".localized
                        statusItem.button?.image = NSImage(named: "statusOn")
                }else{
                        switchBtn.title = "Turn On".localized
                        statusItem.button?.image = NSImage(named: "statusOff")
                }
                if server.IsGlobal{
                        smartModel.state = .off
                        globalModel.state = .on
                }else{
                        smartModel.state = .on
                        globalModel.state = .off
                }
//
//                if server.account.IsEmpty(){
//                        accountMenu.title = "Account(Empty)".localized
//                }else{
//                         accountMenu.title = "Account".localized
//                }
        }
        
        @IBAction func switchTurnOnOff(_ sender: NSMenuItem) {
                
                do{
                        if server.IsTurnOn{
                                try server.StopServer()
                        }else{
                                try server.StartServer()
                        }
                        
                        updateUI()
                        
                }catch{
                        dialogOK(question: "Error", text: error.localizedDescription)
                }
        }
        
        @IBAction func ShowWalletView(_ sender: NSMenuItem) {
                if walletCtrl != nil {
                        walletCtrl.close()
                }
                walletCtrl = WalletController(windowNibName: "WalletController")
                walletCtrl.showWindow(self)
                NSApp.activate(ignoringOtherApps: true)
                walletCtrl.window?.makeKeyAndOrderFront(nil)
        }
        

        @IBAction func changeModel(_ sender: NSMenuItem) {
               
                do{try server.ChangeModel(global: sender.tag == 1)}catch{
                        dialogOK(question: "Error", text: error.localizedDescription)
                        return
                }
                updateUI()
        }
        
        @IBAction func finish(_ sender: NSMenuItem) { 
                server.Exit()
                NSApplication.shared.terminate(self)
        }
}
