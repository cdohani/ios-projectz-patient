//
//  PracticeProviderTCell.swift
//  DocHyve Patient
//

import UIKit

struct PracticeProviderDisplayModel {
    let name: String
    let designation: [String]
    let date: String
    let rating: String
    let reviewCount: String
    let appointmentSummary: String
    let address: String
    let networkStatus: String
    var providerImage: String = ""
    var providerId: Int = -1
}

class PracticeProviderTCell: UITableViewCell {
    static let reuseIdentifier = "PracticeProviderTCell"

    private let cardView = UIView()
    private let doctorImageView = UIImageView()
    private let nameLabel = UILabel()
    private let designationLabel = UILabel()
    private let nextImageView = UIImageView()

    private var blueColor: UIColor { UIColor(named: "customBlueColor") ?? UIColor(hex: "0D257B") }
    private var greyColor: UIColor { UIColor(named: "customGreyColor") ?? UIColor(hex: "6D6D6D") }
    private var titleColor: UIColor { UIColor(named: "customDarkgreyColor") ?? UIColor(hex: "323232") }

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
        designationLabel.text = item.designation.joined(separator: ", ")
        if !item.providerImage.isEmpty {
            doctorImageView.loadImage(from: item.providerImage)
        } else {
            doctorImageView.image = UIImage(named: "dummyImage")
        }
    }

    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        contentView.addSubview(cardView)

        doctorImageView.translatesAutoresizingMaskIntoConstraints = false
        doctorImageView.image = UIImage(named: "dummyImage")
        doctorImageView.contentMode = .scaleAspectFill
        doctorImageView.clipsToBounds = true
        doctorImageView.layer.cornerRadius = 25
        doctorImageView.layer.borderWidth = 1
        doctorImageView.layer.borderColor = blueColor.withAlphaComponent(0.2).cgColor

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.mySystemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = titleColor
        nameLabel.numberOfLines = 1
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.75

        designationLabel.translatesAutoresizingMaskIntoConstraints = false
        designationLabel.font = UIFont.mySystemFont(ofSize: 12, weight: .regular)
        designationLabel.textColor = greyColor
        designationLabel.numberOfLines = 1

        nextImageView.translatesAutoresizingMaskIntoConstraints = false
        nextImageView.image = UIImage(systemName: "chevron.right")
        nextImageView.tintColor = greyColor
        nextImageView.contentMode = .scaleAspectFit

        [doctorImageView, nameLabel, designationLabel, nextImageView].forEach {
            cardView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            doctorImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            doctorImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            doctorImageView.widthAnchor.constraint(equalToConstant: 50),
            doctorImageView.heightAnchor.constraint(equalToConstant: 50),

            nextImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            nextImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            nextImageView.widthAnchor.constraint(equalToConstant: 16),
            nextImageView.heightAnchor.constraint(equalToConstant: 16),

            nameLabel.leadingAnchor.constraint(equalTo: doctorImageView.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: nextImageView.leadingAnchor, constant: -8),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.centerYAnchor, constant: -2),

            designationLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            designationLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            designationLabel.topAnchor.constraint(equalTo: cardView.centerYAnchor, constant: 2)
        ])
    }
}
