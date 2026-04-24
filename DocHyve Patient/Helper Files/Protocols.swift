//
//  Protocols.swift
//  DocHyve
//
//  Created by MacBook Pro on 29/01/2025.
//

import Foundation
import UIKit

//use to update data when there is multiple screen in between
class DataManager {
    static let shared = DataManager()
    var isDataUpdated: Bool = false
}
class HomeDataManager {
    static let shared = HomeDataManager()
    var isHomeUpdated: Bool = false
}

protocol TransferDataDelegate: AnyObject {
    func sendData(_ data: Any)
}

protocol GetTextFieldFromTableDelegate: AnyObject {
    func sendData(_ cell: UITableViewCell, didUpdateText text: String)
}


