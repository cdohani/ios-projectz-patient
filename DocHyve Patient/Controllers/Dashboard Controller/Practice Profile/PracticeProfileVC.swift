//
//  PracticeProfileVC.swift
//  DocHyve Patient
//

import UIKit
import GoogleMaps
import MapKit

class PracticeProfileVC: ParentViewController {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let providerTableView = UITableView(frame: .zero, style: .plain)
    private var providerTableHeightConstraint: NSLayoutConstraint?
    
    var providerID = -1
    var onProviderSelected: ((Int) -> Void)?
    private var practiceData = PracticeProfileData()
    private var providers = [PracticeProviderDisplayModel]()
    
    // Location navigation
    private var currentLocationIndex = 0
    private var locationNameLabel: UILabel?
    private var locationAddressLabel: UILabel?
    private var previousButton: UIButton?
    private var nextButton: UIButton?
    private var directionsButton: UIButton?
    private var mapView: GMSMapView?

    private var blueColor: UIColor { UIColor(named: "customBlueColor") ?? UIColor(hex: "0D257B") }
    private var navbarColor: UIColor { UIColor(named: "customNavbarColor") ?? UIColor(hex: "E4E8F3") }
    private var greenColor: UIColor { UIColor(named: "customGreenColor") ?? UIColor(hex: "12B76A") }
    private var greyColor: UIColor { UIColor(named: "customGreyColor") ?? UIColor(hex: "6D6D6D") }
    private var borderColor: UIColor { UIColor(named: "customTFBorderColor") ?? UIColor(hex: "D2D2D2") }
    private var titleColor: UIColor { UIColor(named: "customDarkgreyColor") ?? UIColor(hex: "323232") }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        getPracticeProfile()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let rowHeight: CGFloat = 80
        providerTableHeightConstraint?.constant = CGFloat(providers.count) * rowHeight
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
        contentStack.spacing = 20
        contentStack.alignment = .fill
        contentStack.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 28, right: 0)
        contentStack.isLayoutMarginsRelativeArrangement = true

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),

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

    private func getPracticeProfile() {
        showLoadingView("")
        GetPracticeProfileService().getData(providerId: providerID, completion: { (response) in
            DispatchQueue.main.async { [self] in
                self.removeLoadingView()
                if let data = response as? PracticeProfileResponseModel {
                    self.practiceData = data.data
                    self.mapProviders()
                    self.populateContent()
                }
            }
        }) { (failure) in
            DispatchQueue.main.async {
                self.removeLoadingView()
                self.showAlertView(message: failure ?? Constants.GenericStrings.somethingWentWrong)
            }
        }
    }
    
    private func mapProviders() {
        providers = practiceData.providers.map { provider in
            let name = "\(provider.firstname) \(provider.lastname)"
            let designation = provider.speciality
            let rating = provider.rating > 0 ? String(format: "%.1f", provider.rating) : ""
            let reviewCount = provider.reviewCount > 0 ? "(\(provider.reviewCount))" : ""
            let appointmentSummary = provider.appointmentsLast7Days > 0 ? "\(provider.appointmentsLast7Days) Appointments last week" : ""
            let address = provider.address?.address ?? ""
            let networkStatus = provider.inNetwork ? "In-Network" : "Check in-network status"
            let nextAvailable = provider.nextAvailableDate
            let providerImage = provider.providerImage
            let providerId = provider.providerId
            
            return PracticeProviderDisplayModel(
                name: name,
                designation: designation,
                date: nextAvailable,
                rating: rating,
                reviewCount: reviewCount,
                appointmentSummary: appointmentSummary,
                address: address,
                networkStatus: networkStatus,
                providerImage: providerImage,
                providerId: providerId
            )
        }
    }
    
    private func populateContent() {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentStack.addArrangedSubview(makePracticeHeader())
        contentStack.addArrangedSubview(makeDivider())
        contentStack.addArrangedSubview(makeAboutSection())
        contentStack.addArrangedSubview(makeLocationsSection())
        contentStack.addArrangedSubview(makeMetricsSection())
        contentStack.addArrangedSubview(makeAmenitiesSection())
        contentStack.addArrangedSubview(makeProvidersSection())
        contentStack.addArrangedSubview(makeContactSection())
    }

    // MARK: - Header
    private func makeHeaderView() -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = navbarColor

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Practice Profile"
        titleLabel.textAlignment = .center
        titleLabel.textColor = blueColor
        titleLabel.font = UIFont.mySystemFont(ofSize: 16, weight: .bold)

        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = greyColor
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        headerView.addSubview(backButton)
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            backButton.centerYAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -25),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 16)
        ])

        return headerView
    }

    // MARK: - Practice Header
    private func makePracticeHeader() -> UIView {
        let container = paddedContainer()
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.backgroundColor = UIColor(hex: "2553B7")
        logoImageView.layer.cornerRadius = 40
        logoImageView.clipsToBounds = true
        logoImageView.contentMode = .scaleAspectFill
        
        if !practiceData.practiceLogo.isEmpty {
            logoImageView.loadImage(from: practiceData.practiceLogo)
        }

        let textStack = UIStackView()
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 4

        let nameLabel = label(practiceData.practiceName.isEmpty ? "Practice" : practiceData.practiceName, fontSize: 17, weight: .bold, color: titleColor)
        nameLabel.numberOfLines = 2
        let ownerLabel = label("Owned by \(practiceData.ownerName)", fontSize: 13, weight: .regular, color: greyColor)
        textStack.addArrangedSubview(nameLabel)
        textStack.addArrangedSubview(ownerLabel)

        container.addSubview(logoImageView)
        container.addSubview(textStack)

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: container.topAnchor),
            logoImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            logoImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            textStack.leadingAnchor.constraint(equalTo: logoImageView.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            textStack.centerYAnchor.constraint(equalTo: logoImageView.centerYAnchor)
        ])

        return container
    }

    // MARK: - About
    private func makeAboutSection() -> UIView {
        let stack = sectionStack(title: "About the Practice")
        let aboutText = !practiceData.description.isEmpty ? practiceData.description : (!practiceData.about.isEmpty ? practiceData.about : "No description available.")
        let body = label(aboutText, fontSize: 13, weight: .regular, color: greyColor)
        body.numberOfLines = 0
        stack.addArrangedSubview(body)
        return paddedStack(stack)
    }

    // MARK: - Locations
    private func makeLocationsSection() -> UIView {
        let stack = sectionStack(title: "All Office Locations")

        if !practiceData.officeLocations.isEmpty {
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = 8

            let addressStack = UIStackView()
            addressStack.axis = .vertical
            addressStack.spacing = 4

            let locNameLabel = UILabel()
            locNameLabel.font = UIFont.mySystemFont(ofSize: 14, weight: .semibold)
            locNameLabel.textColor = titleColor
            locNameLabel.numberOfLines = 1
            self.locationNameLabel = locNameLabel

            let locAddressLabel = UILabel()
            locAddressLabel.font = UIFont.mySystemFont(ofSize: 12, weight: .regular)
            locAddressLabel.textColor = greyColor
            locAddressLabel.numberOfLines = 0
            self.locationAddressLabel = locAddressLabel

            addressStack.addArrangedSubview(locNameLabel)
            addressStack.addArrangedSubview(locAddressLabel)

            let prevBtn = UIButton(type: .system)
            prevBtn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            prevBtn.tintColor = borderColor
            prevBtn.addTarget(self, action: #selector(previousLocationTapped), for: .touchUpInside)
            self.previousButton = prevBtn

            let nextBtn = UIButton(type: .system)
            nextBtn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            nextBtn.tintColor = greyColor
            nextBtn.addTarget(self, action: #selector(nextLocationTapped), for: .touchUpInside)
            self.nextButton = nextBtn

            row.addArrangedSubview(addressStack)
            row.addArrangedSubview(prevBtn)
            row.addArrangedSubview(nextBtn)
            prevBtn.widthAnchor.constraint(equalToConstant: 28).isActive = true
            nextBtn.widthAnchor.constraint(equalToConstant: 28).isActive = true
            stack.addArrangedSubview(row)

            let dirBtn = UIButton(type: .system)
            dirBtn.contentHorizontalAlignment = .left
            dirBtn.setTitle("Get Directions", for: .normal)
            dirBtn.setTitleColor(blueColor, for: .normal)
            dirBtn.titleLabel?.font = UIFont.mySystemFont(ofSize: 13, weight: .medium)
            dirBtn.addTarget(self, action: #selector(getDirectionsTapped), for: .touchUpInside)
            self.directionsButton = dirBtn
            stack.addArrangedSubview(dirBtn)

            // Update location display
            updateLocationDisplay()
        }

        // Google Map
        let gmsMapView = GMSMapView()
        gmsMapView.translatesAutoresizingMaskIntoConstraints = false
        gmsMapView.layer.cornerRadius = 8
        gmsMapView.clipsToBounds = true
        gmsMapView.isUserInteractionEnabled = false
        gmsMapView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        self.mapView = gmsMapView
        stack.addArrangedSubview(gmsMapView)

        // Show pin for first location
        if let firstLocation = practiceData.officeLocations.first {
            let lat = Double(firstLocation.latitude) ?? 0.0
            let long = Double(firstLocation.longitude) ?? 0.0
            addMapPin(lat: lat, long: long)
        }

        return paddedStack(stack)
    }

    private func updateLocationDisplay() {
        guard !practiceData.officeLocations.isEmpty else { return }
        let location = practiceData.officeLocations[currentLocationIndex]
        locationNameLabel?.text = location.locationName
        locationAddressLabel?.text = "\(currentLocationIndex + 1). \(location.address)\n\(location.city), \(location.stateName) \(location.zipCode)"
        
        // Update button states
        previousButton?.tintColor = currentLocationIndex > 0 ? greyColor : borderColor
        nextButton?.tintColor = currentLocationIndex < practiceData.officeLocations.count - 1 ? greyColor : borderColor
    }

    private func addMapPin(lat: Double, long: Double) {
        guard let mapView = mapView else { return }
        mapView.clear()

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.icon = UIImage(named: "mappin")
        marker.map = mapView

        let camera = GMSCameraUpdate.setCamera(
            GMSCameraPosition(latitude: lat, longitude: long, zoom: 14)
        )
        mapView.animate(with: camera)
    }

    @objc private func previousLocationTapped() {
        guard currentLocationIndex > 0 else { return }
        currentLocationIndex -= 1
        updateLocationDisplay()
        let location = practiceData.officeLocations[currentLocationIndex]
        let lat = Double(location.latitude) ?? 0.0
        let long = Double(location.longitude) ?? 0.0
        addMapPin(lat: lat, long: long)
    }

    @objc private func nextLocationTapped() {
        guard currentLocationIndex < practiceData.officeLocations.count - 1 else { return }
        currentLocationIndex += 1
        updateLocationDisplay()
        let location = practiceData.officeLocations[currentLocationIndex]
        let lat = Double(location.latitude) ?? 0.0
        let long = Double(location.longitude) ?? 0.0
        addMapPin(lat: lat, long: long)
    }

    @objc private func getDirectionsTapped() {
        guard !practiceData.officeLocations.isEmpty else { return }
        let location = practiceData.officeLocations[currentLocationIndex]
        let lat = Double(location.latitude) ?? 0.0
        let long = Double(location.longitude) ?? 0.0

        let googleMapsURLString = "comgooglemaps://?daddr=\(lat),\(long)&directionsmode=driving"

        if let googleMapsURL = URL(string: googleMapsURLString),
           UIApplication.shared.canOpenURL(googleMapsURL) {
            UIApplication.shared.open(googleMapsURL, options: [:], completionHandler: nil)
            return
        }

        let destination = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long))
        let mapItem = MKMapItem(placemark: destination)
        mapItem.name = location.locationName
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    // MARK: - Metrics
    private func makeMetricsSection() -> UIView {
        let stack = sectionStack(title: "Practice Metrics")
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 12

        let firstRow = UIStackView()
        firstRow.axis = .horizontal
        firstRow.spacing = 12
        firstRow.distribution = .fillEqually
        let patientCount = practiceData.metrics.totalPatients
        let patientValue = patientCount >= 1000 ? String(format: "%.1fk+", Double(patientCount) / 1000.0) : "\(patientCount)"
        firstRow.addArrangedSubview(makeMetricCard(title: "Total Patients", value: patientValue))
        let ratingValue = practiceData.metrics.rating > 0 ? String(format: "%.1f/5", practiceData.metrics.rating) : "N/A"
        firstRow.addArrangedSubview(makeMetricCard(title: "Rating", value: ratingValue))

        grid.addArrangedSubview(firstRow)
        stack.addArrangedSubview(grid)
        return paddedStack(stack)
    }

    // MARK: - Amenities
    private func makeAmenitiesSection() -> UIView {
        let stack = sectionStack(title: "Practice Amenities")
        let amenityNames = practiceData.amenities.map { $0.name }
        if amenityNames.isEmpty {
            stack.addArrangedSubview(label("No amenities listed.", fontSize: 13, weight: .regular, color: greyColor))
        } else {
            stack.addArrangedSubview(makeTwoColumnList(items: amenityNames))
        }
        return paddedStack(stack)
    }

    // MARK: - Providers
    private func makeProvidersSection() -> UIView {
        let stack = sectionStack(title: "Associated Providers")
        providerTableView.translatesAutoresizingMaskIntoConstraints = false
        providerTableView.backgroundColor = .clear
        providerTableView.separatorStyle = .none
        providerTableView.isScrollEnabled = false
        providerTableView.dataSource = self
        providerTableView.delegate = self
        providerTableView.register(PracticeProviderTCell.self, forCellReuseIdentifier: PracticeProviderTCell.reuseIdentifier)
        let rowHeight: CGFloat = 80
        providerTableHeightConstraint = providerTableView.heightAnchor.constraint(equalToConstant: CGFloat(providers.count) * rowHeight)
        providerTableHeightConstraint?.isActive = true
        stack.addArrangedSubview(providerTableView)
        return paddedStack(stack)
    }

    // MARK: - Contact
    private func makeContactSection() -> UIView {
        let stack = sectionStack(title: "Contact Info")
        let contact = practiceData.contactInfo
        stack.addArrangedSubview(makeContactRow(icon: "phone.fill", title: "Phone:", value: contact.phone.isEmpty ? "N/A" : contact.phone))
        stack.addArrangedSubview(makeContactRow(icon: "envelope", title: "Email:", value: contact.email.isEmpty ? "N/A" : contact.email))
        stack.addArrangedSubview(makeContactRow(icon: "globe", title: "Website:", value: contact.website.isEmpty ? "N/A" : contact.website))
        
//        let workingHoursText = formatWorkingHours(contact.workingHours)
//        stack.addArrangedSubview(makeContactRow(icon: "calendar.badge.clock", title: "Working Hours:", value: workingHoursText))
        return paddedStack(stack)
    }
    
    private func formatWorkingHours(_ hours: [PracticeWorkingHourModel]) -> String {
        if hours.isEmpty { return "N/A" }
        return hours.map { hour in
            let day = hour.dayOfWeek.capitalized
            let from = formatTime(hour.timeFrom)
            let to = formatTime(hour.timeTo)
            return "\(day): \(from) - \(to)"
        }.joined(separator: "\n")
    }
    
    private func formatTime(_ time: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        if let date = formatter.date(from: time) {
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        }
        return time
    }

    // MARK: - Metric Card
    private func makeMetricCard(title: String, value: String) -> UIView {
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 8
        card.layer.borderColor = borderColor.cgColor
        card.layer.borderWidth = 1
        card.heightAnchor.constraint(equalToConstant: 72).isActive = true

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 4
        card.addSubview(stack)
        stack.addArrangedSubview(label(title, fontSize: 12, weight: .regular, color: greyColor))
        stack.addArrangedSubview(label(value, fontSize: 22, weight: .bold, color: titleColor))

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            stack.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        return card
    }

    // MARK: - Amenity List
    private func makeTwoColumnList(items: [String]) -> UIView {
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 10

        stride(from: 0, to: items.count, by: 2).forEach { index in
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = 12
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
        row.spacing = 6

        let check = UILabel()
        check.text = "\u{2713}"
        check.textAlignment = .center
        check.textColor = .white
        check.font = UIFont.systemFont(ofSize: 8, weight: .bold)
        check.backgroundColor = greenColor
        check.layer.cornerRadius = 2
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

    // MARK: - Contact Row
    private func makeContactRow(icon: String, title: String, value: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .top
        row.spacing = 8

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = blueColor
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 16).isActive = true

        let titleLabel = label(title, fontSize: 13, weight: .semibold, color: titleColor)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        let valueLabel = label(value, fontSize: 13, weight: .regular, color: greyColor)
        valueLabel.numberOfLines = 0

        row.addArrangedSubview(iconView)
        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(valueLabel)
        return row
    }

    // MARK: - Helpers
    private func sectionStack(title: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.addArrangedSubview(label(title, fontSize: 16, weight: .bold, color: titleColor))
        return stack
    }

    private func paddedStack(_ stack: UIStackView) -> UIView {
        let container = paddedContainer()
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
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

// MARK: - TableView
extension PracticeProfileVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        providers.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PracticeProviderTCell.reuseIdentifier, for: indexPath) as? PracticeProviderTCell ?? PracticeProviderTCell(style: .default, reuseIdentifier: PracticeProviderTCell.reuseIdentifier)
        cell.setData(providers[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProviderID = providers[indexPath.row].providerId
        onProviderSelected?(selectedProviderID)
        navigationController?.popViewController(animated: true)
    }
}
