//
//  MedicalVisitTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 27/02/2024.
//

import UIKit

class MedVisitTCell: UITableViewCell {

    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var imgOption: UIImageView!
    @IBOutlet weak var lblVisitType: UILabel!
    @IBOutlet weak var lblLastVisit: UILabel!
    @IBOutlet weak var lblLastVisitDate: UILabel!
    @IBOutlet var btnAddExaminationDate: UIButton!
    @IBOutlet var btnAddReminder: UIButton!
    @IBOutlet var btnDeleteReminder: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellData(item:WellnessGuideModel){
        print(item.iconUrl)
        imgOption.loadImage(from: item.iconUrl)
        lblVisitType.text = item.name
        if item.lastVisitDate == ""{
            lblLastVisitDate.isHidden = true
            btnAddExaminationDate.isHidden = false
            btnDeleteReminder.isHidden = true
        }else{
            lblLastVisitDate.isHidden = false
            lblLastVisitDate.text = item.lastVisitDate
            btnAddExaminationDate.isHidden = true
            btnDeleteReminder.isHidden = false
        }
    }

}
