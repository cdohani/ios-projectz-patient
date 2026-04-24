//
//  GradientButton.swift
//  PIC
//
//  Created by Adeel on 6/5/23.
//

import Foundation
import UIKit

class GradientButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient()
    }
    
    private func applyGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor(named: "CusGreen")?.cgColor ?? UIColor.systemBlue.cgColor,
            UIColor(named: "Darkgreen")?.cgColor ?? UIColor.systemGreen.cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        layer.insertSublayer(gradientLayer, at: 0)
        layer.cornerRadius = bounds.height / 2.0
        layer.masksToBounds = true
    }
}







