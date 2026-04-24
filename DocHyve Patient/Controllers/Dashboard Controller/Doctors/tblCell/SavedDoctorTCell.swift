//
//  SavedDoctorTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 21/03/2024.
//

import UIKit
import Cosmos

class SavedDoctorTCell: UITableViewCell {
    @IBOutlet weak var imgDoc: UIImageView!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnFavourit: UIButton!
    @IBOutlet weak var lblDocName: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var vwRating: CosmosView!
    @IBOutlet weak var lblPhonNo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setData(item: FavouriteProviderModel){
        let imageURL = Constants.URLs.imagePath + item.providerImage
        imgDoc.loadImage(from: imageURL)
        lblDocName.text = item.fullName
        lblCategory.text = item.providerSpeciality.joined(separator: ", ")
        lblPhonNo.text = item.phoneNo
        vwRating.rating = item.rating
    }
    
    func SetCellData(item: FavouriteProviderModel){
        let imageURL = Constants.URLs.imagePath + item.providerImage
        imgDoc.loadImage(from: imageURL)
        lblDocName.text = item.fullName
        lblCategory.text = item.providerSpeciality.joined(separator: ", ")
        lblPhonNo.text = item.phoneNo
        vwRating.rating = item.rating
    }

}
