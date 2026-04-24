//
//  SelectMemberTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 20/10/2025.
//

import UIKit

class SelectMemberTCell: UITableViewCell {

    @IBOutlet var vwContainer: UIView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblInsurance: UILabel!
    @IBOutlet var imgSelection: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(item: MemberDetailModel){
    var insuranceName = "No Insurance added"
        if !item.primaryInsuranceInfo.name.isEmpty{
            insuranceName = item.primaryInsuranceInfo.name
        }else if !item.secondaryInsuranceInfo.name.isEmpty{
            insuranceName = item.secondaryInsuranceInfo.name
        }
        lblName.text = item.firstName + " " + item.lastName
        lblInsurance.text = insuranceName
    }
    
    func setInsuranceData(item: UserInsuranceModel){
    
        lblName.text = item.insuranceName
        lblInsurance.text = item.arrPlan.map { $0.name }.joined(separator: ", ")
    }

}
