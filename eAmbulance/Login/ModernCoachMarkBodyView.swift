//
//  ModernCoachMarkBodyView.swift
//  eAmbulance
//
//  Created by Mikayil on 29.04.25.
//

import Foundation
import UIKit
import Instructions

class ModernCoachMarkBodyView: UIView, CoachMarkBodyView {

    var highlightArrowDelegate: (any CoachMarkBodyHighlightArrowDelegate)?
    weak var nextControl: UIControl? { return nextButton }

    let hintLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular) 
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Anladım", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 20/255.0, green: 109/255.0, blue: 191/255.0, alpha: 1)
        button.layer.cornerRadius = 18 // Daha yumşaq künclər
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 20/255.0, green: 109/255.0, blue: 191/255.0, alpha: 1).cgColor,
                                UIColor(red: 15/255.0, green: 86/255.0, blue: 159/255.0, alpha: 1).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = button.bounds
        button.layer.insertSublayer(gradientLayer, at: 0)
        
        return button
    }()

    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16 // Daha çox aralıq
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        layer.cornerRadius = 24
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        stack.addArrangedSubview(hintLabel)
        stack.addArrangedSubview(nextButton)
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            hintLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 280)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 300, height: 140)
    }
}

