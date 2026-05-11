//
//  MedicalHistoryTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 13/03/2024.
//

import UIKit
import Foundation
class MedicalHistoryTCell: UITableViewCell {

    @IBOutlet weak var imgSelect: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var btnSwitch: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(item:HealthCheckModel){
        lblName.text = item.name
        btnSwitch.isOn = item.isSelected
//        if item.isSelected{
//            imgSelect.image = UIImage(systemName: "checkmark.square.fill")
//            imgSelect.tintColor = UIColor(named: "customBlueColor")
//        }else{
//            imgSelect.image = UIImage(systemName: "square")
//            imgSelect.tintColor = UIColor.lightGray
//        }
    }
    


}
