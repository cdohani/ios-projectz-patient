//
//  PracticeProviderTCell.swift
//  DocHyve Patient
//

import UIKit

struct PracticeProviderDisplayModel {
    let name: String
    let designation: String
    let date: String
    let rating: String
    let reviewCount: String
    let appointmentSummary: String
    let address: String
    let networkStatus: String
}

class PracticeProviderTCell: UITableViewCell {
    static let reuseIdentifier = "PracticeProviderTCell"

    private let cardView = UIView()
    private let doctorImageView = UIImageView()
    private let nameLabel = UILabel()
    private let designationLabel = UILabel()
    private let dateLabel = UILabel()
    private let ratingIconLabel = UILabel()
    private let ratingLabel = UILabel()
    private let reviewCountLabel = UILabel()
    private let appointmentsLabel = UILabel()
    private let addressIcon = UIImageView()
    private let addressLabel = UILabel()
    private let networkIcon = UIImageView()
    private let networkLabel = UILabel()
    private let availabilityButton = UIButton(type: .system)

    private var blueColor: UIColor { UIColor(named: "customBlueColor") ?? UIColor(hex: "0D257B") }
    private var greenColor: UIColor { UIColor(named: "customGreenColor") ?? UIColor(hex: "12B76A") }
    private var greyColor: UIColor { UIColor(named: "customGreyColor") ?? UIColor(hex: "6D6D6D") }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    func setData(_ item: PracticeProviderDisplayModel) {
        nameLabel.text = item.name
        designationLabel.text = item.designation
        dateLabel.text = item.date
        ratingLabel.text = item.rating
        reviewCountLabel.text = item.reviewCount
        appointmentsLabel.text = item.appointmentSummary
        addressLabel.text = item.address
        networkLabel.text = item.networkStatus
    }

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 3
        cardView.layer.borderWidth = 0.5
        cardView.layer.borderColor = UIColor(named: "customTFBorderColor")?.cgColor ?? UIColor(hex: "D2D2D2").cgColor
        contentView.addSubview(cardView)

        doctorImageView.translatesAutoresizingMaskIntoConstraints = false
        doctorImageView.image = UIImage(named: "dummyProfile1") ?? UIImage(named: "dummyImage")
        doctorImageView.contentMode = .scaleAspectFill
        doctorImageView.clipsToBounds = true
        doctorImageView.layer.cornerRadius = 4

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.mySystemFont(ofSize: 17, weight: .bold)
        nameLabel.textColor = UIColor(named: "customDarkgreyColor") ?? UIColor(hex: "323232")
        nameLabel.numberOfLines = 1
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.8

        designationLabel.translatesAutoresizingMaskIntoConstraints = false
        designationLabel.font = UIFont.mySystemFont(ofSize: 13, weight: .regular)
        designationLabel.textColor = greyColor

        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.font = UIFont.mySystemFont(ofSize: 11, weight: .regular)
        dateLabel.textColor = blueColor
        dateLabel.textAlignment = .right

        ratingIconLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingIconLabel.text = "★"
        ratingIconLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        ratingIconLabel.textColor = UIColor(named: "customYellowDark") ?? UIColor(hex: "F9CB74")

        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingLabel.font = UIFont.mySystemFont(ofSize: 12, weight: .regular)
        ratingLabel.textColor = UIColor(named: "customDarkgreyColor") ?? UIColor(hex: "323232")
        ratingLabel.textAlignment = .right

        reviewCountLabel.translatesAutoresizingMaskIntoConstraints = false
        reviewCountLabel.font = UIFont.mySystemFont(ofSize: 11, weight: .regular)
        reviewCountLabel.textColor = greyColor
        reviewCountLabel.textAlignment = .right

        appointmentsLabel.translatesAutoresizingMaskIntoConstraints = false
        appointmentsLabel.font = UIFont.mySystemFont(ofSize: 13, weight: .medium)
        appointmentsLabel.textColor = greenColor

        addressIcon.translatesAutoresizingMaskIntoConstraints = false
        addressIcon.image = UIImage(systemName: "mappin.circle.fill")
        addressIcon.tintColor = blueColor
        addressIcon.contentMode = .scaleAspectFit

        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.font = UIFont.mySystemFont(ofSize: 12, weight: .regular)
        addressLabel.textColor = greyColor
        addressLabel.numberOfLines = 1

        networkIcon.translatesAutoresizingMaskIntoConstraints = false
        networkIcon.image = UIImage(systemName: "point.3.connected.trianglepath.dotted")
        networkIcon.tintColor = blueColor
        networkIcon.contentMode = .scaleAspectFit

        networkLabel.translatesAutoresizingMaskIntoConstraints = false
        networkLabel.font = UIFont.mySystemFont(ofSize: 12, weight: .regular)
        networkLabel.textColor = greyColor
        networkLabel.numberOfLines = 1

        availabilityButton.translatesAutoresizingMaskIntoConstraints = false
        availabilityButton.setTitle("View All Availability", for: .normal)
        availabilityButton.setTitleColor(.white, for: .normal)
        availabilityButton.titleLabel?.font = UIFont.mySystemFont(ofSize: 14, weight: .bold)
        availabilityButton.backgroundColor = blueColor
        availabilityButton.layer.cornerRadius = 4

        [doctorImageView, nameLabel, designationLabel, dateLabel, ratingIconLabel, ratingLabel, reviewCountLabel, appointmentsLabel, addressIcon, addressLabel, networkIcon, networkLabel, availabilityButton].forEach {
            cardView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            doctorImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            doctorImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 22),
            doctorImageView.widthAnchor.constraint(equalToConstant: 56),
            doctorImageView.heightAnchor.constraint(equalToConstant: 56),

            dateLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -22),
            dateLabel.widthAnchor.constraint(equalToConstant: 52),

            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            nameLabel.leadingAnchor.constraint(equalTo: doctorImageView.trailingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: dateLabel.leadingAnchor, constant: -8),

            designationLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            designationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            designationLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            ratingIconLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 6),
            ratingIconLabel.trailingAnchor.constraint(equalTo: ratingLabel.leadingAnchor, constant: -3),
            ratingIconLabel.widthAnchor.constraint(equalToConstant: 13),

            ratingLabel.centerYAnchor.constraint(equalTo: ratingIconLabel.centerYAnchor),
            ratingLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -22),
            ratingLabel.widthAnchor.constraint(equalToConstant: 26),

            reviewCountLabel.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 2),
            reviewCountLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -22),

            appointmentsLabel.topAnchor.constraint(equalTo: designationLabel.bottomAnchor, constant: 8),
            appointmentsLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            appointmentsLabel.trailingAnchor.constraint(lessThanOrEqualTo: reviewCountLabel.leadingAnchor, constant: -8),

            addressIcon.topAnchor.constraint(equalTo: doctorImageView.bottomAnchor, constant: 16),
            addressIcon.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 22),
            addressIcon.widthAnchor.constraint(equalToConstant: 14),
            addressIcon.heightAnchor.constraint(equalToConstant: 14),

            addressLabel.centerYAnchor.constraint(equalTo: addressIcon.centerYAnchor),
            addressLabel.leadingAnchor.constraint(equalTo: addressIcon.trailingAnchor, constant: 8),
            addressLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -22),

            networkIcon.topAnchor.constraint(equalTo: addressIcon.bottomAnchor, constant: 10),
            networkIcon.leadingAnchor.constraint(equalTo: addressIcon.leadingAnchor),
            networkIcon.widthAnchor.constraint(equalToConstant: 14),
            networkIcon.heightAnchor.constraint(equalToConstant: 14),

            networkLabel.centerYAnchor.constraint(equalTo: networkIcon.centerYAnchor),
            networkLabel.leadingAnchor.constraint(equalTo: networkIcon.trailingAnchor, constant: 8),
            networkLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -22),

            availabilityButton.topAnchor.constraint(equalTo: networkLabel.bottomAnchor, constant: 14),
            availabilityButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 22),
            availabilityButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -22),
            availabilityButton.heightAnchor.constraint(equalToConstant: 38),
            availabilityButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }
}
