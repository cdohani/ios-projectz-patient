//
//  AddedInsuranceTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 29/04/2024.
//

import UIKit

class AddedInsuranceTCell: UITableViewCell {
    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var vwHeader: UIView!
    @IBOutlet weak var lblInsuranceType: UILabel!
    @IBOutlet weak var btnDelet: UIButton!
    @IBOutlet weak var lblPlanandCarrierHeading: UILabel!
    @IBOutlet weak var lblPlanVal: UILabel!
    @IBOutlet var lblMemberIDHeading: UILabel!
    @IBOutlet var lblMemberID: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        vwHeader.makeCornersRound(corners: [.topLeft,.topRight], radius: 20)
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(data:UserInsuranceModel){
        let plans = data.arrPlan.map { $0.name }.joined(separator: " - ")
        let primary = data.isPrimary ? "Primary" : "Secondary"
        lblInsuranceType.text = "\(primary) Insurance"
        lblPlanVal.text = "\(data.insuranceName)\n\(plans)"
        lblMemberID.text = data.cardMembderID
    }

}
