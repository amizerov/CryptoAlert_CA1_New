//
//  TradeVC.swift
//  CryptoAlert
//
//  Created by Andrey on 24.10.2023.
//

import UIKit

class TradeVC: UIViewController {
    
    var symbol: String?
    var exchange: Int?
    
    @IBOutlet weak var tradingLabel: UILabel!
    @IBOutlet weak var exchangeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let s = symbol {
            tradingLabel.text = s
        }
        if let e = exchange {
            let name = (e == 1 ? "Binance" : e == 2 ? "Kucoin" : "Huobi")
            exchangeLabel.text = name
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
