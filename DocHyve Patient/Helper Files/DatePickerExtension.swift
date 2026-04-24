//
//  DatePickerExtension.swift
//  PIC
//
//  Created by Adeel on 6/12/23.
//

import Foundation
import UIKit

class DatePickerUtility {
    
    static func showDatePicker(
        onViewController viewController: UIViewController,
        mode: UIDatePicker.Mode = .date,
        minDate: Date? = nil,
        maxDate: Date? = nil,
        completion: @escaping (Date?) -> Void
    ) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = mode
      
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        if let minDate = minDate {
            datePicker.minimumDate = minDate
        }

        if let maxDate = maxDate {
            datePicker.maximumDate = maxDate
        }
        datePicker.timeZone =  TimeZone(identifier: "GMT")
        
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        alertController.view.addSubview(datePicker)

        let okAction = UIAlertAction(title: "Done", style: .default) { _ in
            let selectedDate = datePicker.date
            completion(selectedDate)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        viewController.present(alertController, animated: true, completion: nil)
    }
}





final class MonthYearPickerSheet: UIViewController {
    enum PickerType { case month, year, monthAndYear }

    var pickerType: PickerType = .monthAndYear
    var minYear = 1900
    var maxYear = Calendar.current.component(.year, from: Date())
    var preselectedMonth: Int?
    var preselectedYear: Int?
    var completion: ((_ monthName: String?, _ year: Int?) -> Void)?   // ← returns month name now!

    private let picker = UIPickerView()
    private var months: [String] = []
    private var years: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
    }

    private func setupData() {
        months = Calendar.current.monthSymbols   // ["January", "February", ...]
        years = Array(minYear...maxYear)
        picker.dataSource = self
        picker.delegate = self

        let now = Date()
        let m = preselectedMonth ?? Calendar.current.component(.month, from: now)
        let y = preselectedYear ?? Calendar.current.component(.year, from: now)
        if pickerType != .year { picker.selectRow(m - 1, inComponent: 0, animated: false) }
        if pickerType != .month {
            let idx = years.firstIndex(of: y) ?? 0
            let comp = pickerType == .monthAndYear ? 1 : 0
            picker.selectRow(idx, inComponent: comp, animated: false)
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)

        let container = UIView()
        container.backgroundColor = .systemBackground
        container.layer.cornerRadius = 12
        container.translatesAutoresizingMaskIntoConstraints = false

        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        toolbar.setItems([cancel, flex, done], animated: false)

        picker.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(toolbar)
        container.addSubview(picker)
        view.addSubview(container)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbar.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            toolbar.topAnchor.constraint(equalTo: container.topAnchor),
            picker.topAnchor.constraint(equalTo: toolbar.bottomAnchor),
            picker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            picker.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            picker.heightAnchor.constraint(equalToConstant: 216)
        ])
    }

    @objc private func doneTapped() {
        var monthName: String? = nil
        var year: Int? = nil

        switch pickerType {
        case .month:
            monthName = months[picker.selectedRow(inComponent: 0)]
        case .year:
            year = years[picker.selectedRow(inComponent: 0)]
        case .monthAndYear:
            monthName = months[picker.selectedRow(inComponent: 0)]
            year = years[picker.selectedRow(inComponent: 1)]
        }

        dismiss(animated: true) { self.completion?(monthName, year) }
    }

    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
}

extension MonthYearPickerSheet: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        switch pickerType {
        case .month: return 1
        case .year: return 1
        case .monthAndYear: return 2
        }
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerType {
        case .month: return months.count
        case .year: return years.count
        case .monthAndYear: return component == 0 ? months.count : years.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerType {
        case .month: return months[row]
        case .year: return "\(years[row])"
        case .monthAndYear: return component == 0 ? months[row] : "\(years[row])"
        }
    }
}


