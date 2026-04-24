//
//  DoctorSearchTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 09/12/2025.
//

import UIKit

class DoctorSearchTCell: UITableViewCell {

    @IBOutlet var imgDoctor: UIImageView!
    @IBOutlet var lblDoctorName: UILabel!
    @IBOutlet var lblRole: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(item:SearchDoctorDataModel){
        lblDoctorName.text = item.name
        imgDoctor.loadImage(from: item.providerImage)
        lblRole.text = (item.arrSpeciality.first?.name ?? "") + " - " + item.state
    }

}
