//
//  PracticeProfileVC.swift
//  DocHyve Patient
//

import UIKit

class PracticeProfileVC: ParentViewController {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let providerTableView = UITableView(frame: .zero, style: .plain)
    private var providerTableHeightConstraint: NSLayoutConstraint?

    private let providers: [PracticeProviderDisplayModel] = [
        PracticeProviderDisplayModel(
            name: "Dr. Ayesha Rashid",
            designation: "MD",
            date: "May 14",
            rating: "4.5",
            reviewCount: "(102)",
            appointmentSummary: "15 Appointments last week",
            address: "112 W 72nd St, New York, NY 10023",
            networkStatus: "Check in-network status"
        ),
        PracticeProviderDisplayModel(
            name: "Dr. Ayesha Rashid",
            designation: "MD",
            date: "May 14",
            rating: "4.5",
            reviewCount: "(102)",
            appointmentSummary: "15 Appointments last week",
            address: "112 W 72nd St, New York, NY 10023",
            networkStatus: "Check in-network status"
        ),
        PracticeProviderDisplayModel(
            name: "Dr. Ayesha Rashid",
            designation: "MD",
            date: "May 14",
            rating: "4.5",
            reviewCount: "(102)",
            appointmentSummary: "15 Appointments last week",
            address: "112 W 72nd St, New York, NY 10023",
            networkStatus: "Check in-network status"
        )
    ]

    private var blueColor: UIColor { UIColor(named: "customBlueColor") ?? UIColor(hex: "0D257B") }
    private var navbarColor: UIColor { UIColor(named: "customNavbarColor") ?? UIColor(hex: "E4E8F3") }
    private var greenColor: UIColor { UIColor(named: "customGreenColor") ?? UIColor(hex: "12B76A") }
    private var greyColor: UIColor { UIColor(named: "customGreyColor") ?? UIColor(hex: "6D6D6D") }
    private var borderColor: UIColor { UIColor(named: "customTFBorderColor") ?? UIColor(hex: "D2D2D2") }
    private var titleColor: UIColor { UIColor(named: "customDarkgreyColor") ?? UIColor(hex: "323232") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        populateContent()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        providerTableHeightConstraint?.constant = CGFloat(providers.count) * 194
    }

    private func setupLayout() {
        view.backgroundColor = UIColor(named: "customBGColor") ?? UIColor(hex: "F9F9F9")
        navigationController?.setNavigationBarHidden(true, animated: false)

        let headerView = makeHeaderView()
        view.addSubview(headerView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        headerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        contentStack.axis = .vertical
        contentStack.spacing = 22
        contentStack.alignment = .fill
        contentStack.layoutMargins = UIEdgeInsets(top: 28, left: 0, bottom: 28, right: 0)
        contentStack.isLayoutMarginsRelativeArrangement = true

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 72),

            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func populateContent() {
        contentStack.addArrangedSubview(makePracticeHeader())
        contentStack.addArrangedSubview(makeDivider())
        contentStack.addArrangedSubview(makeAboutSection())
        contentStack.addArrangedSubview(makeLocationsSection())
        contentStack.addArrangedSubview(makeMetricsSection())
        contentStack.addArrangedSubview(makeAmenitiesSection())
        contentStack.addArrangedSubview(makeSpecialtiesSection())
        contentStack.addArrangedSubview(makeProvidersSection())
        contentStack.addArrangedSubview(makeContactSection())
    }

    private func makeHeaderView() -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = navbarColor

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Practice Profile"
        titleLabel.textAlignment = .center
        titleLabel.textColor = blueColor
        titleLabel.font = UIFont.mySystemFont(ofSize: 17, weight: .bold)

        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = greyColor
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 18),
            backButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -14),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 16)
        ])

        return headerView
    }

    private func makePracticeHeader() -> UIView {
        let container = paddedContainer()
        let logoView = UIView()
        logoView.translatesAutoresizingMaskIntoConstraints = false
        logoView.backgroundColor = UIColor(hex: "2553B7")
        logoView.layer.cornerRadius = 45

        let logoLabel = UILabel()
        logoLabel.translatesAutoresizingMaskIntoConstraints = false
        logoLabel.text = "Health\nCare"
        logoLabel.numberOfLines = 2
        logoLabel.textAlignment = .center
        logoLabel.textColor = .white
        logoLabel.font = UIFont.mySystemFont(ofSize: 17, weight: .bold)
        logoView.addSubview(logoLabel)

        let textStack = UIStackView()
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 5

        let nameLabel = label("Health Care Clinic", fontSize: 20, weight: .bold, color: titleColor)
        let ownerLabel = label("Owned by Dr. Jane Doe", fontSize: 16, weight: .regular, color: titleColor)
        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(ownerLabel)

        container.addSubview(logoView)
        container.addSubview(textStack)

        NSLayoutConstraint.activate([
            logoView.topAnchor.constraint(equalTo: container.topAnchor),
            logoView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 22),
            logoView.widthAnchor.constraint(equalToConstant: 90),
            logoView.heightAnchor.constraint(equalToConstant: 90),
            logoView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            logoLabel.centerXAnchor.constraint(equalTo: logoView.centerXAnchor),
            logoLabel.centerYAnchor.constraint(equalTo: logoView.centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: 18),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -22),
            textStack.centerYAnchor.constraint(equalTo: logoView.centerYAnchor)
        ])

        return container
    }

    private func makeAboutSection() -> UIView {
        let stack = sectionStack(title: "About the Practice")
        let body = label("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since 1966, when designers at Letraset and James Mosley, the librarian... read more", fontSize: 16, weight: .regular, color: titleColor)
        body.numberOfLines = 0
        stack.addArrangedSubview(body)
        return paddedStack(stack)
    }

    private func makeLocationsSection() -> UIView {
        let stack = sectionStack(title: "All Office Locations")

        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8

        let addressStack = UIStackView()
        addressStack.axis = .vertical
        addressStack.spacing = 5
        addressStack.addArrangedSubview(label("Walk-In Medical Care", fontSize: 15, weight: .semibold, color: titleColor))
        addressStack.addArrangedSubview(label("1, 12011 Lee Jackson Memorial Hwy.\nFairfax. VA 22033", fontSize: 12, weight: .regular, color: greyColor))

        let previousButton = UIButton(type: .system)
        previousButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        previousButton.tintColor = borderColor
        let nextButton = UIButton(type: .system)
        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.tintColor = greyColor

        row.addArrangedSubview(addressStack)
        row.addArrangedSubview(previousButton)
        row.addArrangedSubview(nextButton)
        previousButton.widthAnchor.constraint(equalToConstant: 28).isActive = true
        nextButton.widthAnchor.constraint(equalToConstant: 28).isActive = true
        stack.addArrangedSubview(row)

        let directionsButton = UIButton(type: .system)
        directionsButton.contentHorizontalAlignment = .left
        directionsButton.setTitle("Get Directions", for: .normal)
        directionsButton.setTitleColor(blueColor, for: .normal)
        directionsButton.titleLabel?.font = UIFont.mySystemFont(ofSize: 14, weight: .regular)
        stack.addArrangedSubview(directionsButton)

        stack.addArrangedSubview(makeMapPlaceholder())
        return paddedStack(stack)
    }

    private func makeMetricsSection() -> UIView {
        let stack = sectionStack(title: "Practice Metrics")
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 12

        let firstRow = UIStackView()
        firstRow.axis = .horizontal
        firstRow.spacing = 14
        firstRow.distribution = .fillEqually
        firstRow.addArrangedSubview(makeMetricCard(title: "Total Patients", value: "2.4k+"))
        firstRow.addArrangedSubview(makeMetricCard(title: "Total Apps", value: "12k"))

        let secondRow = UIStackView()
        secondRow.axis = .horizontal
        secondRow.spacing = 14
        secondRow.distribution = .fillEqually
        secondRow.addArrangedSubview(makeMetricCard(title: "Rating", value: "4.8/5"))
        secondRow.addArrangedSubview(UIView())

        grid.addArrangedSubview(firstRow)
        grid.addArrangedSubview(secondRow)
        stack.addArrangedSubview(grid)
        return paddedStack(stack)
    }

    private func makeAmenitiesSection() -> UIView {
        let stack = sectionStack(title: "Practice Amenities")
        let amenities = ["Wheelchair Access", "Waiting Lounge", "Patient Parking", "Free Wi-Fi", "Telehealth Options", "Multilingual Staff"]
        stack.addArrangedSubview(makeTwoColumnList(items: amenities))
        return paddedStack(stack)
    }

    private func makeSpecialtiesSection() -> UIView {
        let stack = sectionStack(title: "Specialties Offered")
        let specialties = ["Pediatrics", "Cardiology", "Dermatology", "Dermatology", "General Medicine", "Oncology", "General Medicine"]
        stack.addArrangedSubview(makeChipWrap(items: specialties))
        return paddedStack(stack)
    }

    private func makeProvidersSection() -> UIView {
        let stack = sectionStack(title: "Associated Providers")
        providerTableView.translatesAutoresizingMaskIntoConstraints = false
        providerTableView.backgroundColor = .clear
        providerTableView.separatorStyle = .none
        providerTableView.isScrollEnabled = false
        providerTableView.dataSource = self
        providerTableView.delegate = self
        providerTableView.register(PracticeProviderTCell.self, forCellReuseIdentifier: PracticeProviderTCell.reuseIdentifier)
        providerTableHeightConstraint = providerTableView.heightAnchor.constraint(equalToConstant: CGFloat(providers.count) * 194)
        providerTableHeightConstraint?.isActive = true
        stack.addArrangedSubview(providerTableView)
        return stack
    }

    private func makeContactSection() -> UIView {
        let stack = sectionStack(title: "Contact info")
        stack.addArrangedSubview(makeContactRow(icon: "phone.fill", title: "Phone:", value: "+1 (555) 123-4567"))
        stack.addArrangedSubview(makeContactRow(icon: "envelope", title: "Email:", value: "info@examplebusiness.com"))
        stack.addArrangedSubview(makeContactRow(icon: "globe", title: "Website:", value: "www.examplebusiness.com"))
        stack.addArrangedSubview(makeContactRow(icon: "calendar.badge.clock", title: "Working Hours:", value: "Monday-Friday: 9:00 AM - 6:00 PM\nSaturday: 10:00 AM - 4:00 PM\nSunday: Closed"))
        return paddedStack(stack)
    }

    private func makeMapPlaceholder() -> UIView {
        let mapView = UIView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.backgroundColor = UIColor(hex: "EEF1F3")
        mapView.clipsToBounds = true
        mapView.layer.cornerRadius = 3
        mapView.heightAnchor.constraint(equalToConstant: 172).isActive = true

        let mapImage = UIImageView(image: UIImage(systemName: "map"))
        mapImage.translatesAutoresizingMaskIntoConstraints = false
        mapImage.tintColor = UIColor(hex: "CAD2DC")
        mapImage.contentMode = .scaleAspectFit

        let pinContainer = UIView()
        pinContainer.translatesAutoresizingMaskIntoConstraints = false
        pinContainer.backgroundColor = blueColor.withAlphaComponent(0.18)
        pinContainer.layer.cornerRadius = 25

        let pinIcon = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        pinIcon.translatesAutoresizingMaskIntoConstraints = false
        pinIcon.tintColor = blueColor
        pinContainer.addSubview(pinIcon)

        mapView.addSubview(mapImage)
        mapView.addSubview(pinContainer)

        NSLayoutConstraint.activate([
            mapImage.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 20),
            mapImage.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20),
            mapImage.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 16),
            mapImage.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -16),

            pinContainer.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            pinContainer.centerYAnchor.constraint(equalTo: mapView.centerYAnchor),
            pinContainer.widthAnchor.constraint(equalToConstant: 50),
            pinContainer.heightAnchor.constraint(equalToConstant: 50),

            pinIcon.centerXAnchor.constraint(equalTo: pinContainer.centerXAnchor),
            pinIcon.centerYAnchor.constraint(equalTo: pinContainer.centerYAnchor),
            pinIcon.widthAnchor.constraint(equalToConstant: 28),
            pinIcon.heightAnchor.constraint(equalToConstant: 28)
        ])

        return mapView
    }

    private func makeMetricCard(title: String, value: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 6
        card.layer.borderColor = borderColor.cgColor
        card.layer.borderWidth = 1
        card.heightAnchor.constraint(equalToConstant: 72).isActive = true

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        card.addSubview(stack)
        stack.addArrangedSubview(label(title, fontSize: 12, weight: .regular, color: greyColor))
        stack.addArrangedSubview(label(value, fontSize: 20, weight: .bold, color: titleColor))

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        return card
    }

    private func makeTwoColumnList(items: [String]) -> UIView {
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 14

        stride(from: 0, to: items.count, by: 2).forEach { index in
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = 18
            row.addArrangedSubview(makeAmenityItem(items[index]))
            if index + 1 < items.count {
                row.addArrangedSubview(makeAmenityItem(items[index + 1]))
            } else {
                row.addArrangedSubview(UIView())
            }
            grid.addArrangedSubview(row)
        }

        return grid
    }

    private func makeAmenityItem(_ text: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8

        let check = UILabel()
        check.text = "✓"
        check.textAlignment = .center
        check.textColor = .white
        check.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        check.backgroundColor = greenColor
        check.layer.cornerRadius = 1
        check.clipsToBounds = true
        check.widthAnchor.constraint(equalToConstant: 14).isActive = true
        check.heightAnchor.constraint(equalToConstant: 14).isActive = true

        let textLabel = label(text, fontSize: 12, weight: .regular, color: greyColor)
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.minimumScaleFactor = 0.75
        row.addArrangedSubview(check)
        row.addArrangedSubview(textLabel)
        return row
    }

    private func makeChipWrap(items: [String]) -> UIView {
        let wrapper = UIStackView()
        wrapper.axis = .vertical
        wrapper.spacing = 9

        var currentRow = UIStackView()
        currentRow.axis = .horizontal
        currentRow.spacing = 8
        currentRow.alignment = .leading
        wrapper.addArrangedSubview(currentRow)
        var rowWidth: CGFloat = 0
        let maxRowWidth = UIScreen.main.bounds.width - 44

        items.forEach { item in
            let chip = makeChip(title: item)
            let estimatedWidth = CGFloat(item.count * 8 + 32)
            if rowWidth + estimatedWidth > maxRowWidth, currentRow.arrangedSubviews.isEmpty == false {
                currentRow.addArrangedSubview(UIView())
                currentRow = UIStackView()
                currentRow.axis = .horizontal
                currentRow.spacing = 8
                currentRow.alignment = .leading
                wrapper.addArrangedSubview(currentRow)
                rowWidth = 0
            }
            currentRow.addArrangedSubview(chip)
            rowWidth += estimatedWidth + 8
        }
        currentRow.addArrangedSubview(UIView())
        return wrapper
    }

    private func makeChip(title: String) -> UIView {
        let chip = UILabel()
        chip.text = title
        chip.textAlignment = .center
        chip.textColor = blueColor
        chip.font = UIFont.mySystemFont(ofSize: 13, weight: .medium)
        chip.layer.cornerRadius = 14
        chip.layer.borderWidth = 1
        chip.layer.borderColor = blueColor.cgColor
        chip.clipsToBounds = true
        chip.heightAnchor.constraint(equalToConstant: 30).isActive = true
        chip.widthAnchor.constraint(greaterThanOrEqualToConstant: CGFloat(title.count * 8 + 32)).isActive = true
        return chip
    }

    private func makeContactRow(icon: String, title: String, value: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 10

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .black
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 18).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 18).isActive = true

        let titleLabel = label(title, fontSize: 13, weight: .semibold, color: titleColor)
        titleLabel.widthAnchor.constraint(equalToConstant: 105).isActive = true

        let valueLabel = label(value, fontSize: 13, weight: .regular, color: greyColor)
        valueLabel.numberOfLines = 0

        row.addArrangedSubview(iconView)
        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(valueLabel)
        return row
    }

    private func sectionStack(title: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.addArrangedSubview(label(title, fontSize: 17, weight: .bold, color: titleColor))
        return stack
    }

    private func paddedStack(_ stack: UIStackView) -> UIView {
        let container = paddedContainer()
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -22),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
    }

    private func paddedContainer() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        return container
    }

    private func makeDivider() -> UIView {
        let divider = UIView()
        divider.backgroundColor = borderColor
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return paddedStack({
            let stack = UIStackView()
            stack.addArrangedSubview(divider)
            return stack
        }())
    }

    private func label(_ text: String, fontSize: CGFloat, weight: UIFont.Weight, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = UIFont.mySystemFont(ofSize: fontSize, weight: weight)
        label.numberOfLines = text.contains("\n") ? 0 : 1
        return label
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}

extension PracticeProfileVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        providers.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        194
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PracticeProviderTCell.reuseIdentifier, for: indexPath) as? PracticeProviderTCell ?? PracticeProviderTCell(style: .default, reuseIdentifier: PracticeProviderTCell.reuseIdentifier)
        cell.setData(providers[indexPath.row])
        return cell
    }
}
