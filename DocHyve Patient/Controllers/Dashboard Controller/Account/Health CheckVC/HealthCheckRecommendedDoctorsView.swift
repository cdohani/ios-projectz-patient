//
//  HealthCheckRecommendedDoctorsView.swift
//  DocHyve Patient
//

import UIKit

protocol HealthCheckRecommendedDoctorsViewDelegate: AnyObject {
    func recommendedDoctorsViewDidSelectDoctor(_ doctor: RecommendedDoctorModel)
}

/// Home-style Suggested Doctors strip used under the health meter.
final class HealthCheckRecommendedDoctorsView: UIView {
    
    static let preferredHeight: CGFloat = 248
    
    weak var delegate: HealthCheckRecommendedDoctorsViewDelegate?
    
    private let titleLabel = UILabel()
    private let noteLabel = UILabel()
    private var collectionView: UICollectionView!
    
    private(set) var doctors = [RecommendedDoctorModel]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        isHidden = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        isHidden = true
    }
    
    /// Fill Suggested Doctors from gauge / lab API (hides when empty).
    func configure(doctors: [RecommendedDoctorModel]) {
        self.doctors = doctors
        collectionView.reloadData()
        isHidden = doctors.isEmpty
    }
    
    func configureHeader(title: String, note: String) {
        titleLabel.text = title
        noteLabel.text = note
    }
    
    /// Design placeholder for Lab Report until that API is ready.
    func loadDummyDoctors() {
        var jane = RecommendedDoctorModel()
        jane.id = 1
        jane.firstName = "Jane"
        jane.lastName = "Chang"
        jane.specialities = "Dentist"
        jane.avgRating = 4.6
        jane.totalReviews = 8
        jane.providerImage = ""
        jane.isBoosted = false
        
        var david = RecommendedDoctorModel()
        david.id = 2
        david.firstName = "David"
        david.lastName = "Chen"
        david.specialities = "Cardiologist"
        david.avgRating = 4.1
        david.totalReviews = 9
        david.providerImage = ""
        david.isBoosted = false
        
        var sarah = RecommendedDoctorModel()
        sarah.id = 3
        sarah.firstName = "Sarah"
        sarah.lastName = "Miller"
        sarah.specialities = "Dermatologist"
        sarah.avgRating = 4.8
        sarah.totalReviews = 14
        sarah.providerImage = ""
        sarah.isBoosted = false
        
        configure(doctors: [jane, david, sarah])
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        titleLabel.text = "Suggested Doctors"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = UIColor(named: "customDarkgreyColor") ?? .darkGray
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        noteLabel.text = "These doctors are suggested based on your health record."
        noteLabel.font = .systemFont(ofSize: 12, weight: .regular)
        noteLabel.textColor = UIColor(named: "customGreyColor") ?? .gray
        noteLabel.numberOfLines = 0
        noteLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 220, height: 150)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 2, left: 0, bottom: 2, right: 0)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(HealthCheckRecommendedDoctorCell.self, forCellWithReuseIdentifier: HealthCheckRecommendedDoctorCell.reuseId)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(noteLabel)
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            noteLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            noteLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            noteLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            collectionView.topAnchor.constraint(equalTo: noteLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 150),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }
}

extension HealthCheckRecommendedDoctorsView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        doctors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HealthCheckRecommendedDoctorCell.reuseId,
            for: indexPath
        ) as! HealthCheckRecommendedDoctorCell
        cell.configure(with: doctors[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.recommendedDoctorsViewDidSelectDoctor(doctors[indexPath.item])
    }
}

// MARK: - Programmatic card matching Home Recommended Doctor design
private final class HealthCheckRecommendedDoctorCell: UICollectionViewCell {
    
    static let reuseId = "HealthCheckRecommendedDoctorCell"
    
    private let cardView = UIView()
    private let imgDoctor = UIImageView()
    private let badgeView = UIView()
    private let badgeIcon = UIImageView()
    private let badgeLabel = UILabel()
    private let nameLabel = UILabel()
    private let specialtyLabel = UILabel()
    private let starIcon = UIImageView()
    private let ratingLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with model: RecommendedDoctorModel) {
        nameLabel.text = "\(model.firstName) \(model.lastName)".trimmingCharacters(in: .whitespaces)
        specialtyLabel.text = model.specialities
        
        if model.avgRating > 0, model.totalReviews > 0 {
            ratingLabel.text = "\(formatRating(model.avgRating)) (\(model.totalReviews) reviews)"
        } else if model.avgRating > 0 {
            ratingLabel.text = formatRating(model.avgRating)
        } else {
            ratingLabel.text = "—"
        }
        
        if model.isBoosted {
            badgeView.backgroundColor = UIColor(named: "customBlueColor")
            badgeLabel.text = "Super Provider"
            badgeIcon.image = UIImage(named: "iconBoost")
            badgeIcon.tintColor = .white
        } else {
            badgeView.backgroundColor = UIColor(named: "customGreenColor") ?? UIColor(hex: "2ECC71")
            badgeLabel.text = "Recommended"
            badgeIcon.image = UIImage(systemName: "star.fill")
            badgeIcon.tintColor = .white
        }
        
        if model.providerImage.isEmpty {
            imgDoctor.image = UIImage(systemName: "person.crop.circle.fill")
            imgDoctor.tintColor = UIColor(named: "customGreyColor") ?? .lightGray
            imgDoctor.contentMode = .scaleAspectFit
        } else {
            imgDoctor.contentMode = .scaleAspectFill
            imgDoctor.loadImage(from: Constants.URLs.imagePath + model.providerImage)
        }
    }
    
    private func formatRating(_ value: Double) -> String {
        if value == floor(value) {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }
    
    private func setupUI() {
        contentView.backgroundColor = .clear
        
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 14
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = (UIColor(named: "customTFBorderColor") ?? UIColor(white: 0.9, alpha: 1)).cgColor
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        imgDoctor.contentMode = .scaleAspectFill
        imgDoctor.clipsToBounds = true
        imgDoctor.layer.cornerRadius = 22
        imgDoctor.backgroundColor = UIColor(white: 0.95, alpha: 1)
        imgDoctor.translatesAutoresizingMaskIntoConstraints = false
        
        badgeView.layer.cornerRadius = 10
        badgeView.clipsToBounds = true
        badgeView.translatesAutoresizingMaskIntoConstraints = false
        
        badgeIcon.contentMode = .scaleAspectFit
        badgeIcon.translatesAutoresizingMaskIntoConstraints = false
        
        badgeLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        badgeLabel.textColor = .white
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = UIColor(named: "customDarkgreyColor") ?? .black
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        specialtyLabel.font = .systemFont(ofSize: 12, weight: .regular)
        specialtyLabel.textColor = UIColor(named: "customGreyColor") ?? .gray
        specialtyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        starIcon.image = UIImage(systemName: "star.fill")
        starIcon.tintColor = UIColor(named: "customGold") ?? .systemYellow
        starIcon.translatesAutoresizingMaskIntoConstraints = false
        
        ratingLabel.font = .systemFont(ofSize: 11, weight: .regular)
        ratingLabel.textColor = UIColor(named: "customGreyColor") ?? .gray
        ratingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(cardView)
        cardView.addSubview(imgDoctor)
        cardView.addSubview(badgeView)
        badgeView.addSubview(badgeIcon)
        badgeView.addSubview(badgeLabel)
        cardView.addSubview(nameLabel)
        cardView.addSubview(specialtyLabel)
        cardView.addSubview(starIcon)
        cardView.addSubview(ratingLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imgDoctor.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            imgDoctor.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            imgDoctor.widthAnchor.constraint(equalToConstant: 44),
            imgDoctor.heightAnchor.constraint(equalToConstant: 44),
            
            badgeView.centerYAnchor.constraint(equalTo: imgDoctor.centerYAnchor),
            badgeView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -10),
            badgeView.heightAnchor.constraint(equalToConstant: 22),
            
            badgeIcon.leadingAnchor.constraint(equalTo: badgeView.leadingAnchor, constant: 8),
            badgeIcon.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
            badgeIcon.widthAnchor.constraint(equalToConstant: 10),
            badgeIcon.heightAnchor.constraint(equalToConstant: 10),
            
            badgeLabel.leadingAnchor.constraint(equalTo: badgeIcon.trailingAnchor, constant: 4),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeView.trailingAnchor, constant: -8),
            badgeLabel.centerYAnchor.constraint(equalTo: badgeView.centerYAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: imgDoctor.bottomAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            
            specialtyLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            specialtyLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            specialtyLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            starIcon.topAnchor.constraint(equalTo: specialtyLabel.bottomAnchor, constant: 8),
            starIcon.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            starIcon.widthAnchor.constraint(equalToConstant: 12),
            starIcon.heightAnchor.constraint(equalToConstant: 12),
            
            ratingLabel.centerYAnchor.constraint(equalTo: starIcon.centerYAnchor),
            ratingLabel.leadingAnchor.constraint(equalTo: starIcon.trailingAnchor, constant: 4),
            ratingLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor)
        ])
    }
}
