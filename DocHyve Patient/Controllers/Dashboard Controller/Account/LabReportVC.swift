//
//  LabReportVC.swift
//  DocHyve Patient
//

import UIKit
import UniformTypeIdentifiers

// MARK: - Models (API will replace dummy data later)

enum LabReportStatus {
    case normal
    case borderline
    case critical
    
    var color: UIColor {
        switch self {
        case .normal:
            return UIColor(named: "customGreenColor") ?? UIColor(hex: "2ECC71")
        case .borderline:
            return UIColor(named: "customOrange") ?? UIColor(hex: "F5A623")
        case .critical:
            return UIColor(named: "customRed") ?? UIColor(hex: "E74C3C")
        }
    }
}

struct LabReportRow {
    let test: String
    let results: String
    let range: String
    let status: LabReportStatus
}

// MARK: - LabReportVC

final class LabReportVC: ParentViewController {
    
    // MARK: UI
    
    private let navBar = UIView()
    private let btnBack = UIButton(type: .system)
    private let lblHeading = UILabel()
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    private let introLabel = UILabel()
    private let uploadContainer = UIView()
    private let lblUpload = UILabel()
    private let previewImage = UIImageView()
    private let btnRemove = UIButton(type: .custom)
    private let btnChooseFile = UIButton(type: .system)
    private let fileNameLabel = UILabel()
    
    private let summaryTitleLabel = UILabel()
    private let summaryView = LabReportSummaryView()
    
    private let suggestedDoctorsView = HealthCheckRecommendedDoctorsView()
    
    // MARK: State
    
    private var selectedFileURL: URL?
    private var selectedImage: UIImage?
    
    private let dummySummary: [LabReportRow] = [
        LabReportRow(test: "Hemoglobin", results: "13.5 g/dL", range: "12.0 - 15.5", status: .normal),
        LabReportRow(test: "Hemoglobin", results: "13.5 g/dL", range: "12.0 - 15.5", status: .borderline),
        LabReportRow(test: "Hemoglobin", results: "13.5 g/dL", range: "12.0 - 15.5", status: .critical),
        LabReportRow(test: "Hemoglobin", results: "13.5 g/dL", range: "12.0 - 15.5", status: .critical),
        LabReportRow(test: "Hemoglobin", results: "13.5 g/dL", range: "12.0 - 15.5", status: .critical)
    ]
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        summaryView.configure(rows: dummySummary)
        suggestedDoctorsView.delegate = self
        suggestedDoctorsView.configureHeader(
            title: "Suggested Doctors",
            note: "These doctors are suggested based on your lab report. This is not a 100% result."
        )
        suggestedDoctorsView.loadDummyDoctors()
        updateUploadState()
    }
    
    // MARK: Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor(named: "customBGColor")
            ?? UIColor(named: "screenBackgroundColor")
            ?? UIColor(hex: "F7F7F8")
        
        setupNavBar()
        setupScrollContent()
    }
    
    private func setupNavBar() {
        navBar.backgroundColor = UIColor(named: "customNavbarColor")
        navBar.translatesAutoresizingMaskIntoConstraints = false
        
        btnBack.setImage(UIImage(named: "iconBack"), for: .normal)
        btnBack.tintColor = UIColor(named: "customGreyColor") ?? .gray
        btnBack.translatesAutoresizingMaskIntoConstraints = false
        btnBack.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        
        lblHeading.text = "Lab Report"
        lblHeading.font = .systemFont(ofSize: 16, weight: .semibold)
        lblHeading.textColor = UIColor(named: "customBlueColor")
        lblHeading.textAlignment = .center
        lblHeading.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(navBar)
        navBar.addSubview(btnBack)
        navBar.addSubview(lblHeading)
        
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 100),
            
            btnBack.leadingAnchor.constraint(equalTo: navBar.leadingAnchor, constant: 12),
            btnBack.bottomAnchor.constraint(equalTo: navBar.bottomAnchor, constant: -12),
            btnBack.widthAnchor.constraint(equalToConstant: 36),
            btnBack.heightAnchor.constraint(equalToConstant: 36),
            
            lblHeading.centerXAnchor.constraint(equalTo: navBar.centerXAnchor),
            lblHeading.centerYAnchor.constraint(equalTo: btnBack.centerYAnchor),
            lblHeading.leadingAnchor.constraint(greaterThanOrEqualTo: btnBack.trailingAnchor, constant: 8),
            lblHeading.trailingAnchor.constraint(lessThanOrEqualTo: navBar.trailingAnchor, constant: -48)
        ])
    }
    
    private func setupScrollContent() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -30)
        ])
        
        introLabel.text = "Upload your lab report to get an AI-powered summary and doctor suggestions."
        introLabel.font = .systemFont(ofSize: 14, weight: .regular)
        introLabel.textColor = UIColor(named: "customDarkgreyColor") ?? .darkGray
        introLabel.numberOfLines = 0
        
        setupUploadButton()
        
        fileNameLabel.font = .systemFont(ofSize: 12, weight: .regular)
        fileNameLabel.textColor = UIColor(named: "customGreyColor") ?? .gray
        fileNameLabel.numberOfLines = 1
        fileNameLabel.isHidden = true
        
        summaryTitleLabel.text = "Lab Report Summary"
        summaryTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        summaryTitleLabel.textColor = UIColor(named: "customDarkgreyColor") ?? .darkGray
        
        summaryView.translatesAutoresizingMaskIntoConstraints = false
        
        suggestedDoctorsView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStack.addArrangedSubview(introLabel)
        contentStack.addArrangedSubview(uploadContainer)
        contentStack.addArrangedSubview(fileNameLabel)
        contentStack.addArrangedSubview(summaryTitleLabel)
        contentStack.addArrangedSubview(summaryView)
        contentStack.addArrangedSubview(suggestedDoctorsView)
        
        contentStack.setCustomSpacing(10, after: summaryTitleLabel)
        contentStack.setCustomSpacing(8, after: uploadContainer)
        
        NSLayoutConstraint.activate([
            uploadContainer.heightAnchor.constraint(equalToConstant: 65),
            suggestedDoctorsView.heightAnchor.constraint(equalToConstant: HealthCheckRecommendedDoctorsView.preferredHeight)
        ])
    }
    
    /// Matches Add Insurance "Choose File" upload row design.
    private func setupUploadButton() {
        uploadContainer.backgroundColor = .white
        uploadContainer.layer.cornerRadius = 12
        uploadContainer.layer.borderWidth = 1
        uploadContainer.layer.borderColor = (UIColor(named: "customBlueColor") ?? UIColor(hex: "0D257B")).cgColor
        uploadContainer.clipsToBounds = true
        uploadContainer.translatesAutoresizingMaskIntoConstraints = false
        
        lblUpload.text = "Upload Lab Report"
        lblUpload.font = .systemFont(ofSize: 13, weight: .regular)
        lblUpload.textColor = UIColor(named: "customDarkgreyColor") ?? .black
        lblUpload.translatesAutoresizingMaskIntoConstraints = false
        
        previewImage.contentMode = .scaleAspectFill
        previewImage.clipsToBounds = true
        previewImage.layer.cornerRadius = 12
        previewImage.backgroundColor = UIColor(white: 0.95, alpha: 1)
        previewImage.isHidden = true
        previewImage.translatesAutoresizingMaskIntoConstraints = false
        
        btnRemove.setImage(UIImage(named: "cross"), for: .normal)
        btnRemove.isHidden = true
        btnRemove.translatesAutoresizingMaskIntoConstraints = false
        btnRemove.addTarget(self, action: #selector(removeFileTapped), for: .touchUpInside)
        
        btnChooseFile.setTitle("  Choose File ", for: .normal)
        btnChooseFile.setImage(UIImage(systemName: "paperclip"), for: .normal)
        btnChooseFile.titleLabel?.font = .systemFont(ofSize: 13, weight: .regular)
        btnChooseFile.tintColor = .white
        btnChooseFile.setTitleColor(.white, for: .normal)
        btnChooseFile.backgroundColor = UIColor(named: "customBlueColor")
        btnChooseFile.translatesAutoresizingMaskIntoConstraints = false
        btnChooseFile.addTarget(self, action: #selector(chooseFileTapped), for: .touchUpInside)
        
        uploadContainer.addSubview(lblUpload)
        uploadContainer.addSubview(previewImage)
        uploadContainer.addSubview(btnRemove)
        uploadContainer.addSubview(btnChooseFile)
        
        NSLayoutConstraint.activate([
            btnChooseFile.topAnchor.constraint(equalTo: uploadContainer.topAnchor),
            btnChooseFile.trailingAnchor.constraint(equalTo: uploadContainer.trailingAnchor),
            btnChooseFile.bottomAnchor.constraint(equalTo: uploadContainer.bottomAnchor),
            btnChooseFile.widthAnchor.constraint(equalToConstant: 136),
            
            lblUpload.leadingAnchor.constraint(equalTo: uploadContainer.leadingAnchor, constant: 10),
            lblUpload.centerYAnchor.constraint(equalTo: uploadContainer.centerYAnchor),
            lblUpload.trailingAnchor.constraint(lessThanOrEqualTo: btnChooseFile.leadingAnchor, constant: -12),
            
            previewImage.leadingAnchor.constraint(equalTo: uploadContainer.leadingAnchor, constant: 10),
            previewImage.centerYAnchor.constraint(equalTo: uploadContainer.centerYAnchor),
            previewImage.widthAnchor.constraint(equalToConstant: 55),
            previewImage.heightAnchor.constraint(equalToConstant: 55),
            
            btnRemove.topAnchor.constraint(equalTo: previewImage.topAnchor, constant: -5),
            btnRemove.trailingAnchor.constraint(equalTo: previewImage.trailingAnchor, constant: 5),
            btnRemove.widthAnchor.constraint(equalToConstant: 15),
            btnRemove.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    private func updateUploadState() {
        let hasFile = selectedFileURL != nil || selectedImage != nil
        lblUpload.isHidden = hasFile && selectedImage != nil
        previewImage.isHidden = selectedImage == nil
        btnRemove.isHidden = !hasFile
        
        if let image = selectedImage {
            previewImage.image = image
            lblUpload.isHidden = true
            fileNameLabel.text = "Image selected"
            fileNameLabel.isHidden = false
        } else if let url = selectedFileURL {
            previewImage.image = nil
            previewImage.isHidden = true
            lblUpload.isHidden = false
            lblUpload.text = url.lastPathComponent
            fileNameLabel.text = url.lastPathComponent
            fileNameLabel.isHidden = false
        } else {
            lblUpload.isHidden = false
            lblUpload.text = "Upload Lab Report"
            fileNameLabel.isHidden = true
            previewImage.image = nil
        }
    }
    
    // MARK: Actions
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func chooseFileTapped() {
        presentUploadOptions()
    }
    
    @objc private func removeFileTapped() {
        selectedFileURL = nil
        selectedImage = nil
        updateUploadState()
    }
    
    private func presentUploadOptions() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.openCamera()
        })
        sheet.addAction(UIAlertAction(title: "Gallery", style: .default) { [weak self] _ in
            self?.openGallery()
        })
        sheet.addAction(UIAlertAction(title: "Document", style: .default) { [weak self] _ in
            self?.openDocumentPicker()
        })
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = btnChooseFile
            popover.sourceRect = btnChooseFile.bounds
        }
        present(sheet, animated: true)
    }
    
    private func openDocumentPicker() {
        let types: [UTType] = [.pdf, .image, .jpeg, .png, .heic]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    private func openCamera() {
        showImagePicker(sourceType: .camera) { [weak self] images, _ in
            self?.applySelectedImage(images?.first)
        }
    }
    
    private func openGallery() {
        showImagePicker(sourceType: .photoLibrary) { [weak self] images, _ in
            self?.applySelectedImage(images?.first)
        }
    }
    
    private func applySelectedImage(_ image: UIImage?) {
        guard let image else { return }
        selectedImage = image
        selectedFileURL = nil
        updateUploadState()
        // API upload will be wired later.
    }
}

// MARK: - Document picker

extension LabReportVC: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        selectedFileURL = url
        selectedImage = nil
        
        if let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            selectedImage = image
        }
        updateUploadState()
        // API upload will be wired later.
    }
}

// MARK: - Suggested doctors

extension LabReportVC: HealthCheckRecommendedDoctorsViewDelegate {
    func recommendedDoctorsViewDidSelectDoctor(_ doctor: RecommendedDoctorModel) {
        let nextVC = HomeVC.getDoctorDetailVC()
        nextVC.providerID = doctor.id
        navigationController?.pushViewController(nextVC, animated: true)
    }
}

// MARK: - Summary table card (image 2)

private final class LabReportSummaryView: UIView {
    
    private let card = UIView()
    private let stack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func configure(rows: [LabReportRow]) {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        stack.addArrangedSubview(makeHeaderRow())
        rows.forEach { stack.addArrangedSubview(makeDataRow($0)) }
    }
    
    private func setup() {
        card.backgroundColor = .white
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = (UIColor(named: "customTFBorderColor") ?? UIColor(white: 0.9, alpha: 1)).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false
        
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(card)
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
    }
    
    private func makeHeaderRow() -> UIView {
        makeRow(
            test: "Test",
            results: "Results",
            range: "Range",
            statusView: {
                let label = UILabel()
                label.text = "Status"
                label.font = .systemFont(ofSize: 13, weight: .bold)
                label.textColor = UIColor(named: "customDarkgreyColor") ?? .black
                label.textAlignment = .center
                return label
            }(),
            isHeader: true
        )
    }
    
    private func makeDataRow(_ row: LabReportRow) -> UIView {
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = row.status.color
        dot.layer.cornerRadius = 6
        
        let wrap = UIView()
        wrap.addSubview(dot)
        NSLayoutConstraint.activate([
            dot.centerXAnchor.constraint(equalTo: wrap.centerXAnchor),
            dot.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
            dot.widthAnchor.constraint(equalToConstant: 12),
            dot.heightAnchor.constraint(equalToConstant: 12)
        ])
        
        return makeRow(
            test: row.test,
            results: row.results,
            range: row.range,
            statusView: wrap,
            isHeader: false
        )
    }
    
    private func makeRow(
        test: String,
        results: String,
        range: String,
        statusView: UIView,
        isHeader: Bool
    ) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill
        row.spacing = 4
        
        let font: UIFont = .systemFont(ofSize: 13, weight: isHeader ? .bold : .regular)
        let color = UIColor(named: "customDarkgreyColor") ?? .black
        
        let testLabel = label(test, font: font, color: color)
        let resultsLabel = label(results, font: font, color: color)
        let rangeLabel = label(range, font: font, color: color)
        
        testLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        resultsLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        rangeLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        statusView.setContentHuggingPriority(.required, for: .horizontal)
        
        row.addArrangedSubview(testLabel)
        row.addArrangedSubview(resultsLabel)
        row.addArrangedSubview(rangeLabel)
        row.addArrangedSubview(statusView)
        
        testLabel.widthAnchor.constraint(equalTo: row.widthAnchor, multiplier: 0.28).isActive = true
        resultsLabel.widthAnchor.constraint(equalTo: row.widthAnchor, multiplier: 0.28).isActive = true
        rangeLabel.widthAnchor.constraint(equalTo: row.widthAnchor, multiplier: 0.28).isActive = true
        statusView.widthAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        
        return row
    }
    
    private func label(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }
}
