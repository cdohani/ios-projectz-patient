//
//  HighlightsTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 05/03/2024.
//

import UIKit

class HighlightsTCell: UITableViewCell {

    @IBOutlet var imgInfo: UIImageView!
    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var lblValue: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setHighlightData(index:Int, providerData:ProviderDetailModel){
        if index == 0{
            lblHeading.text = "New Patient Appointments"
            lblValue.text = providerData.higlights.newPatientAppointment
            imgInfo.image = UIImage(named: "newPatient")
        }else if index == 1{
            lblHeading.text = "Excellent wait time"
            lblValue.text = providerData.higlights.excellentWaitTime
            imgInfo.image = UIImage(named: "waitTime")
        }else {
            lblHeading.text = "Highly Recommended"
            lblValue.text = providerData.higlights.highlyRecommended
            imgInfo.image = UIImage(named: "recommended")
        }
    }

}
