//
//  WalletController.swift
//  Pangolin
//
//  Created by wsli on 2019/8/27.
//  Copyright © 2019年 com.nbs. All rights reserved.
//

import Cocoa

class WalletController: NSWindowController {
        
        
        var delegate:StateChangedDelegate?
        
        @IBOutlet weak var SubAddressField: NSTextField!
        @IBOutlet weak var MainAddressField: NSTextField!
        @IBOutlet weak var EthBalanceField: NSTextField!
        @IBOutlet weak var LinBalanceField: NSTextField!
        @IBOutlet weak var WaitingTip: NSProgressIndicator!
        @IBOutlet weak var DataBalanceField: NSTextField!
        @IBOutlet weak var DataUsedField: NSTextField!
        @IBOutlet weak var DataAvgPriceField: NSTextField!
        @IBOutlet weak var MinerDescField: NSScrollView!
        
        override func windowDidLoad() {
                super.windowDidLoad()
        }
        
        @IBAction func Exit(_ sender: Any) {
                self.close()
        }
        
        @IBAction func CreateWalletAction(_ sender: Any) {
        }
        
        @IBAction func ImportWalletAction(_ sender: Any) {
        }
        
        @IBAction func ExportWalletAction(_ sender: Any) {
        }
        
        @IBAction func SyncEthereumAction(_ sender: Any) {
        }
        
        @IBAction func ReloadMinerPoolActin(_ sender: Any) {
        }
        
}

extension WalletController:NSTableViewDelegate{
        
}
extension WalletController:NSTableViewDataSource{
        
}

