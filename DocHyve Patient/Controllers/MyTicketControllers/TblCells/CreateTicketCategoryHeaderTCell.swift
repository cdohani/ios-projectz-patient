//
//  CreateTicketCategoryHeaderTCell.swift
//  DocHyve
//
//  Created by MacBook Pro on 29/07/2024.
//

import UIKit

class CreateTicketCategoryHeaderTCell: UITableViewCell {

    @IBOutlet var vwContainer: UIView!
    @IBOutlet var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        vwContainer.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

