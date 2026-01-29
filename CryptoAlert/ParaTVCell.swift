//
//  TableViewCell.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 27.08.2021.
//

import UIKit

class ParaTVCell: UITableViewCell {

    @IBOutlet weak var lblSymbol: UILabel!
    @IBOutlet weak var lblInterval: UILabel!
    @IBOutlet weak var lblProcent: UILabel!
    @IBOutlet weak var lblExchange: UILabel!
    @IBOutlet weak var lblDtc: UILabel!
    @IBOutlet weak var imgUpDwn: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillData(_ p: Para) {
        lblSymbol.text = p.SymbolDecorate()
        lblInterval.text = "\(p.Interval) min"
        let proc = p.Procent == 0 ? "0,5" : "\(p.Procent)"
        lblProcent.text = "\(proc)%"
        lblExchange.text = Exchange.DisplayName(for: p.Exchange)
        imgUpDwn.image =
            (p.Tape == 1 ? UIImage(named: "upd") : (p.Tape == 2 ? UIImage(named: "up1") : UIImage(named: "dn1")))
        
        if(p.Dtc == "@") {
            lblDtc.text = ""
        }
        else {
            lblDtc.text = p.Dtc
            backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        }
    }

}
