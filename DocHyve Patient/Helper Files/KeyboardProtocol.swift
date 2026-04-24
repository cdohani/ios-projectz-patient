//
//  KeyboardProtocol.swift
//  ICT
//
//  Created by Jawad Ali on 31/12/2019.
//  Copyright © 2019 Jawad Ali. All rights reserved.
//

import Foundation
import UIKit

typealias EmptyEvent = () -> ()
typealias CGFloatEvent = (CGFloat) -> Void

protocol KeyboardProtocol {
}

extension KeyboardProtocol where Self: UIViewController {
    
    func addKeyboardShowObserver( completion: EmptyEvent? = nil, onShowEvent: CGFloatEvent?) {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil ) { [weak self] notification in
            let userInfo = notification.userInfo! as NSDictionary
            if let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                
                let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
                let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
                
                self?.view.setNeedsLayout()
                onShowEvent?(keyboardHeight)
                self?.view.setNeedsUpdateConstraints()
                
                UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                    self!.view.layoutIfNeeded()
                }) { _ in
                    completion?()
                }
            }
        }
    }
    
    func addKeyboardHideObserver(onHideEvent: EmptyEvent?) {
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil ) { [weak self] notification in
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
            let curve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
            
            self?.view.setNeedsLayout()
            onHideEvent?()
            self?.view.setNeedsUpdateConstraints()
            
            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curve), animations: {
                self!.view.layoutIfNeeded()
            }
            )
        }
    }
    
}
