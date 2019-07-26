//
//  MenuController.swift
//  sofa
//
//  Created by wsli on 2019/1/30.
//  Copyright © 2019 com.nbs. All rights reserved.
//

import Cocoa

@objc protocol StateChangedDelegate {
        func updateMenu(data: Any?, tagId:Int)
}

class MenuController: NSObject, StateChangedDelegate {
       
        func updateMenu(data: Any?, tagId: Int) {
                DispatchQueue.main.async{ self.updateUI()}
        }
        

        @IBOutlet weak var ehtereumAccountMenu: NSMenuItem!
        @IBOutlet weak var accountMenu: NSMenuItem!
        @IBOutlet weak var statusMenu: NSMenu!
        @IBOutlet weak var switchBtn: NSMenuItem!
        @IBOutlet weak var smartModel: NSMenuItem!
        @IBOutlet weak var globalModel: NSMenuItem!
        
        var sofaAccountCtrl : SofaAccountCtrl!
        var ethereWalletCtrl:EthereumWalletCtrl!
        
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
                
                if server.account.IsEmpty(){
                        accountMenu.title = "Account(Empty)".localized
                }else{
                         accountMenu.title = "Account".localized
                }
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
        
        @IBAction func sofaAccountCtrl(_ sender: NSMenuItem) {
                if sofaAccountCtrl != nil {
                        sofaAccountCtrl.close()
                }
                sofaAccountCtrl = SofaAccountCtrl(windowNibName: "SofaAccount")
                sofaAccountCtrl.showWindow(self)
                sofaAccountCtrl.delegate = self
                sofaAccountCtrl.LoadBindings()
                NSApp.activate(ignoringOtherApps: true)
                sofaAccountCtrl.window?.makeKeyAndOrderFront(nil)
        }
        
        @IBAction func ethereumWalletCtrl(_ sender: Any) {
                if ethereWalletCtrl != nil {
                        ethereWalletCtrl.close()
                }
                ethereWalletCtrl = EthereumWalletCtrl(windowNibName: "EthereumWallet")
                ethereWalletCtrl.showWindow(self)
                ethereWalletCtrl.ReloadLocalEthInfo()
                NSApp.activate(ignoringOtherApps: true)
                ethereWalletCtrl.window?.makeKeyAndOrderFront(nil)
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
