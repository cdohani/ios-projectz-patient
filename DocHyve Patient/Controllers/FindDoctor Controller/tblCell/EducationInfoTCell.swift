//
//  EducationInfoTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 01/10/2025.
//

import UIKit

class EducationInfoTCell: UITableViewCell {
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
    
    func setEducationData(index:Int, providerData:ProviderDetailModel){
        if index == 0{
            lblHeading.text = "Specialties"
            lblValue.text = providerData.specialities.joined(separator: ", ")
            imgInfo.image = UIImage(named: "speciality")
        }else if index == 1{
            lblHeading.text = "Practice Names"
            lblValue.text = providerData.practiceName
            imgInfo.image = UIImage(named: "practiceName")
        }else if index == 2{
            lblHeading.text = "Education and Training"
            lblValue.text = providerData.educationAndTraning
            imgInfo.image = UIImage(named: "education")
        }else if index == 3{
            lblHeading.text = "Language Spoken"
            lblValue.text = providerData.languages.joined(separator: ", ")
            imgInfo.image = UIImage(named: "language")
        }else if index == 4{
            lblHeading.text = "Provider’s Gender"
            lblValue.text = providerData.gender
            imgInfo.image = UIImage(named: "gender")
        }else {
            lblHeading.text = "NPI Number"
            lblValue.text = providerData.npi
            imgInfo.image = UIImage(named: "npiNumber")
        }
    }

}
