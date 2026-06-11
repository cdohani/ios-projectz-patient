//
//  QuestionHeaderTCell.swift
//  DocHyve
//
//  Created by MacBook Pro on 30/07/2024.
//

import UIKit

class QuestionHeaderTCell: UITableViewCell {

    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var imgDrop: UIImageView!
    @IBOutlet weak var vwHeader: UIView!
    @IBOutlet weak var vwDrop: UIView!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblDisplayInfo: UILabel!
    @IBOutlet weak var lblIfContact: UILabel!
    @IBOutlet weak var btnContactUs: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(data:CategoryFaqDataModel){
        lblQuestion.text = data.question
        lblDesc.text = data.answer
//        lblDisplayInfo.text = data.displayInfo
//        lblIfContact.text = data.ifContact
    }

}
