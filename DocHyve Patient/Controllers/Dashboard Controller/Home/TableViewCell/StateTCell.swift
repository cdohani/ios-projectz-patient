//
//  StateTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 30/04/2025.
//

import UIKit

class StateTCell: UITableViewCell {

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var imgSelected: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
