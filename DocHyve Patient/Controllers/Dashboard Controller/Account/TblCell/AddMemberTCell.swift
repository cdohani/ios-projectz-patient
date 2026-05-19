//
//  AddMemberTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 12/03/2024.
//

import UIKit

class AddMemberTCell: UITableViewCell {
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblMemberName: UILabel!
    @IBOutlet weak var lblRelation: UILabel!
    @IBOutlet weak var lblMemberRelation: UILabel!
    @IBOutlet weak var lblGenderHeading: UILabel!
    @IBOutlet weak var lblGender: UILabel!
    @IBOutlet var lblDOBHeading: UILabel!
    @IBOutlet var lblDOBValue: UILabel!
    @IBOutlet var btnDelete: UIButton!
    @IBOutlet var btnEdit: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(item:MemberDetailModel){
        let imageURL = Constants.URLs.imagePath + item.userImage
        imgUser.loadImage(from: imageURL)
        lblMemberName.text = "\(item.firstName) \(item.lastName)"
        lblMemberRelation.text = item.relationship
        lblGender.text = item.gender == "" ? "N/A" : item.gender.capitalized
        lblDOBValue.text = item.dob == "" ? "N/A" : item.dob
    }
}

