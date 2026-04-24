//
//  popularDoctorCCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 27/02/2024.
//

import UIKit

class popularDoctorCCell: UICollectionViewCell {
    @IBOutlet weak var imgOption: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    func setUpCell(with model: SpecialityResponseModel) {
        imgOption.loadImage(from: model.icon)
        lblTitle.text = model.name
    }
    
}
