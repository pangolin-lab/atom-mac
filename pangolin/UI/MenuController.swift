//
//  MenuController.swift
//  Proton
//
//  Created by Bencong Ri on 2019/1/30.
//  Copyright © 2019 com.proton. All rights reserved.
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
        
//        @IBAction func protonAccountCtrl(_ sender: NSMenuItem) {
//                if protonAccountCtrl != nil {
//                        protonAccountCtrl.close()
//                }
//                protonAccountCtrl = ProtonAccountCtrl(windowNibName: "ProtonAccount")
//                protonAccountCtrl.showWindow(self)
//                protonAccountCtrl.delegate = self
//                protonAccountCtrl.LoadBindings()
//                NSApp.activate(ignoringOtherApps: true)
//                protonAccountCtrl.window?.makeKeyAndOrderFront(nil)
//        }
        

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
