//
//  AllHealthCheckTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 24/10/2025.
//

import UIKit
import TagListView

class AllHealthCheckTCell: UITableViewCell {

    @IBOutlet var lblHeading: UILabel!
    @IBOutlet var vwBackground: UIView!
    @IBOutlet var vwTags: TagListView!
    
    var tags = ["adeel" ,"Amir" , "Asad","Ammonianana labhh" ,"uquwu" ,"kwk", "jqjwkqwsj","Medical History","Surgical History","Allergies","Medications","Family History","Social History","Physical Examination","Vital Signs","Immunizations","Past Medical History","Current Medical History","Past Medical History","Current Medical History","Past Medical History","Current Medical History"]
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        tags.forEach { (tag) in
//            vwTags.addTag(tag)
//        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
