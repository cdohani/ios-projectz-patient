//
//  UIViewController+ICT.swift
//  ICT
//
//  Created by Jawad Ali on 27/12/2019.
//  Copyright © 2019 Jawad Ali. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    
    private enum StoryboardName: String {
        case home = "Main"
        case dashboard = "Dashboard"
        case account = "Account"
        case booking = "Book Appoinment"
    }

    class var home: UIStoryboard {
        return UIStoryboard(name: StoryboardName.home.rawValue, bundle: nil)
    }
    class var dashboard: UIStoryboard {
        return UIStoryboard(name: StoryboardName.dashboard.rawValue, bundle: nil)
    }
    class var account: UIStoryboard {
        return UIStoryboard(name: StoryboardName.account.rawValue, bundle: nil)
    } 
    class var booking: UIStoryboard {
        return UIStoryboard(name: StoryboardName.booking.rawValue, bundle: nil)
    }
    

}
