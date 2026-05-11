//
//  FindDoctorTCell.swift
//  DocHyve Patient
//
//  Created by MacBook Pro on 01/03/2024.
//

import UIKit

class FindDoctorTCell: UITableViewCell {
    @IBOutlet weak var vwContianer: UIView!
    @IBOutlet weak var imgDoctor: UIImageView!
    @IBOutlet weak var lblDoctorName: UILabel!
    @IBOutlet weak var lblDesg: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblNetwork: UILabel!
    @IBOutlet weak var cvAvailableSlot: UICollectionView!
    @IBOutlet var btnViewAllSlots: UIButton!
    @IBOutlet var lblBookingType: UILabel!
    @IBOutlet var iconBookingType: UIImageView!
    
    var arrSlots = [Slots]()
    var onSlotSelected: ((_ slotId: Int) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cvAvailableSlot.delegate = self
        cvAvailableSlot.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func SetData(item:SearchDoctorModel){
        let imageURL = Constants.URLs.imagePath + item.providerImage
        imgDoctor.loadImage(from: imageURL)
        lblDoctorName.text =  "\(item.firstName) \(item.lastName)"
        lblDesg.text = item.specialities
        lblAddress.text = formattedAddress(from: item.slotAddress)
        lblReview.text = "\(item.avgRating) (\(item.totalReviews) Reviews)"
        arrSlots = item.availableSlots.slots
        lblNetwork.text = item.inNetwork ? "In Network" : "Out of Network"
        if item.bookingType.id == 1{
            iconBookingType.image = UIImage(systemName: "video.fill")
        }else if item.bookingType.id == 2 {
            iconBookingType.image = UIImage(systemName: "person.fill")
        }else{
            iconBookingType.image = UIImage(named: "iconBoth")
        }
       
        lblBookingType.text = item.bookingType.name.capitalized
        cvAvailableSlot.reloadData()
    }
    
    func formattedAddress(from address: LocationDataModel) -> String {
        // Collect non-empty parts of the address
        let components = [
            address.address1,
            address.address2,
            address.city,
            address.stateName,
            address.zipCode
        ].filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        // Join components with a comma and space
        return components.joined(separator: ", ")
    }

}
extension FindDoctorTCell: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return arrSlots.count > 8 ? 8 : arrSlots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvialableSlotCCell", for: indexPath) as! AvialableSlotCCell
        cell.lblTime.text = arrSlots[indexPath.item].time
        cell.lblTime.textColor = arrSlots[indexPath.item].isBooked  ? UIColor(named: "customGreyColor") : UIColor.white
        cell.vwBackground.backgroundColor =   arrSlots[indexPath.item].isBooked  ? UIColor(named: "customNavbarColor") : UIColor(named: "customGold")
        return cell
       
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !arrSlots[indexPath.item].isBooked{
            let selectedId = arrSlots[indexPath.item].id
               onSlotSelected?(selectedId)
        }
       
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 40)
    }
}
