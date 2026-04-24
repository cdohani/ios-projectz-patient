//
//  TwoFATCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 05/11/2025.
//

import UIKit

class TwoFATCell: UITableViewCell {

    @IBOutlet var vwBackground: UIView!
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var lblDesc: UILabel!
    @IBOutlet var imgNext: UIImageView!
    @IBOutlet var btnSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
