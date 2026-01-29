//
//  ProdFindTVCell.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 31.12.2021.
//

import UIKit

class ProdFindTVCell: UITableViewCell {

	@IBOutlet weak var stackView: UIStackView!
	@IBOutlet weak var lblSymbol: UILabel!
	@IBOutlet weak var lblCnt1: UILabel!
	@IBOutlet weak var lblCnt2: UILabel!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	func UpdateData(_ p: Product) {
		
		lblSymbol.text = p.baseasset + "/" + p.quoteasset
		lblCnt1.text = "\(p.cnt1)"
		lblCnt2.text = "\(p.cnt2)"
	}
}
