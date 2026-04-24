//
//  AccountSettingTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 22/02/2024.
//

import UIKit

class AccountSettingTCell: UITableViewCell {

    @IBOutlet weak var vwBackground: UIView!
    @IBOutlet weak var imgOption: UIImageView!
    @IBOutlet weak var lblOption: UILabel!
    @IBOutlet weak var imgNext: UIImageView!
    @IBOutlet weak var btnSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //btnSwitch.transform = CGAffineTransform(scaleX: 1.0, y: 0.75)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setCell(item:HealthCheckModel){
        lblOption.text = item.name
        btnSwitch.isOn = item.isSelected
    }

}
