//
//  UIFont+Extension.swift
//  VaultsPay_iOS
//
//  Created by Ahtazaz Khan on 01/07/2021.
//

import Foundation
import UIKit


struct AppFontName {
   
    static let black = "Montserrat-Black"
    static let medium = "Montserrat-Medium"
    static let bold = "Montserrat-Bold"
    static let light = "Montserrat-Light"
    static let regular = "Montserrat-Regular"
    static let semibold = "Montserrat-SemiBold"
   
}

extension UIFontDescriptor.AttributeName {
   static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

extension UIFont {
   static var isOverrided: Bool = false
   
   @objc class func mySystemFont(ofSize fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
       var tempFont = AppFontName.regular
       switch weight{
       case .regular, .thin:
           tempFont = AppFontName.regular
       case .semibold:
           tempFont = AppFontName.semibold
       case .bold, .heavy, .black:
           tempFont = AppFontName.bold
       case .medium:
           tempFont = AppFontName.medium
       case .light, .ultraLight:
           tempFont = AppFontName.light
           
       default:
           tempFont = AppFontName.regular
       }
       return UIFont(name: tempFont, size: fontSize)!
   }
   
   @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
       return UIFont(name: AppFontName.regular, size: size)!
   }
   
   @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
       return UIFont(name: AppFontName.bold, size: size)!
   }
   
   
   @objc convenience init(myCoder aDecoder: NSCoder) {
       guard
           let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
           let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String else {
           self.init(myCoder: aDecoder)
           
           return
       }
    //CTFontUltraLightUsage,CTFontThinUsage,CTFontLightUsage,CTFontMediumUsage,CTFontDemiUsage
//        print(fontDescriptor)
       var fontName = ""
       switch fontAttribute {
       case "CTFontRegularUsage":
           fontName = AppFontName.regular
       case "CTFontDemiUsage":
           fontName = AppFontName.semibold
       case "CTFontEmphasizedUsage", "CTFontBoldUsage":
           fontName = AppFontName.bold
       case "CTFontMediumUsage":
           fontName = AppFontName.medium
       case "CTFontLightUsage":
           fontName = AppFontName.light
        
       default:
           fontName = AppFontName.regular
           print(fontDescriptor)
       }
       self.init(name: fontName, size: fontDescriptor.pointSize)!
   }
   
   class func overrideInitialize() {
       guard self == UIFont.self, !isOverrided else { return }
       
       isOverrided = true
       
       if let systemFontMethodWithWeight = class_getClassMethod(self, #selector(systemFont(ofSize: weight:))),
          let mySystemFontMethodWithWeight = class_getClassMethod(self, #selector(mySystemFont(ofSize: weight:))) {
           method_exchangeImplementations(systemFontMethodWithWeight, mySystemFontMethodWithWeight)
       }
       
       
       if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
          let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:))) {
           method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
       }
       
       if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
          let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:))) {
           method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
       }
       
       if let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))), // Trick to get over the lack of
          let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:))) {
           method_exchangeImplementations(initCoderMethod, myInitCoderMethod)
       }
       
   }
   
}

//protocol FontApplicable {
//    func setFont(name: String, size: CGFloat)
//}
//
//extension FontApplicable where Self: UIView {
//    func setFont(name: String, size: CGFloat) {
//        if let textField = self as? UITextField {
//            textField.font = UIFont(name: name, size: size)
//        } else if let label = self as? UILabel {
//            label.font = UIFont(name: name, size: size)
//        } else if let button = self as? UIButton {
//            button.titleLabel?.font = UIFont(name: name, size: size)
//        }
//    }
//}
//
//// Common extension for UITextField, UILabel, and UIButton
//extension UITextField: FontApplicable {}
//extension UILabel: FontApplicable {}
//extension UIButton: FontApplicable {}
//
//extension UIView {
////    @IBInspectable
////    var montBlack: CGFloat {
////        set {
////            (self as? FontApplicable)?.setFont(name: "Montserrat-Black", size: newValue)
////        }
////        get {
////            return 0.0
////        }
////    }
//    @IBInspectable
//    var montBold: CGFloat {
//        set {
//            (self as? FontApplicable)?.setFont(name: "Montserrat-Bold", size: newValue)
//        }
//        get {
//            return 0.0
//        }
//    }
//    @IBInspectable
//    var montSemiBold: CGFloat {
//        set {
//            (self as? FontApplicable)?.setFont(name: "Montserrat-SemiBold", size: newValue)
//        }
//        get {
//            return 0.0
//        }
//    }
//    @IBInspectable
//    var montMedium: CGFloat {
//        set {
//            (self as? FontApplicable)?.setFont(name: "Montserrat-Medium", size: newValue)
//        }
//        get {
//            return 0.0
//        }
//    }
//    @IBInspectable
//    var montRegular: CGFloat {
//        set {
//            (self as? FontApplicable)?.setFont(name: "Montserrat-Regular", size: newValue)
//        }
//        get {
//            return 0.0
//        }
//    }
////    @IBInspectable
////    var montLight: CGFloat {
////        set {
////            (self as? FontApplicable)?.setFont(name: "Montserrat-Light", size: newValue)
////        }
////        get {
////            return 0.0
////        }
////    }
//    
//   
//}




