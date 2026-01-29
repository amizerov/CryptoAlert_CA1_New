//
//  OrderTVCell.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 29.03.2022.
//

import UIKit

class OrderTVCell: UITableViewCell {

	@IBOutlet weak var lblSymbol: UILabel!
	@IBOutlet weak var imgExcha: UIImageView!
	@IBOutlet weak var lblPrice: UILabel!
	
	@IBOutlet weak var lblBuySel: UILabel!
	@IBOutlet weak var lblSpotMar: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
	func fillData(_ o: Order) {
		lblSymbol.text = o.Symbol
		imgExcha.image = o.Exchange == 1 ? UIImage(named: "bina300") :
						 o.Exchange == 2 ? UIImage(named: "kuco300") : UIImage(named: "huob300")
		lblPrice.text = "\(o.Price)"
		lblBuySel.text = o.BuySel ? "Buy" : "Sel"
		lblSpotMar.text = o.SpotMar ? "Spot" : "Marj"
	}
}
