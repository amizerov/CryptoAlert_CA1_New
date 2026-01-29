//
//  ParaFindTableViewCell.swift
//  CryptoAlert
//
//  Created by Andrey Mizerov on 10.09.2021.
//

import UIKit

class ParaFindTVCell: UITableViewCell {

    @IBOutlet weak var lblSymbol: UILabel!
    @IBOutlet weak var lblBase: UILabel!
    @IBOutlet weak var lblQuote: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
