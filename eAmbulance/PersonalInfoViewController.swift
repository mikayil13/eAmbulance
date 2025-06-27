//
//  PersonalInfoViewController.swift
//  eAmbulance
//
//  Created by Mikayil on 25.06.25.
//

import UIKit

class PersonalInfoViewController: UIViewController {
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.text = "Telefon nömrəsi"
            label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let iconImageView: UIImageView = {
            let imageView = UIImageView(image: UIImage(systemName: "iphone"))
            imageView.tintColor = .black
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        private let cardView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(red: 75/255, green: 117/255, blue: 233/255, alpha: 0.03)
            view.layer.cornerRadius = 16
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private let subtitleLabel: UILabel = {
            let label = UILabel()
            label.text = "Qeydiyyatlı nömrə"
            label.textColor = .lightGray
            label.font = UIFont.systemFont(ofSize: 13)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let phoneNumberLabel: UILabel = {
            let label = UILabel()
            label.text = "" // Dinamik olacaq
            label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let checkmarkImageView: UIImageView = {
            let imageView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            imageView.tintColor = UIColor(hex: "#2ACB29")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        private let infoCardView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(hex: "#EDF0FF")
            view.layer.cornerRadius = 12
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        private let infoLabel: UILabel = {
            let label = UILabel()
            label.text = "Bu telefon nömrəsi, təcili hallarda sizi axtarmaq və mövqeyinizi təyin etmək üçün istifadə olunur. Təhlükəsizlik səbəbi ilə nömrə dəyişikliyi bu tətbiq vasitəsilə edilə bilməz."
            label.font = UIFont.systemFont(ofSize: 13)
            label.textColor = .darkGray
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        private let infoIcon: UIImageView = {
            let imageView = UIImageView(image: UIImage(systemName: "info.circle"))
            imageView.tintColor = UIColor(hex: "#3A57E8")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Şəxsi məlumatlarım"
        view.backgroundColor = .white

        // 📲 İstifadəçinin qeyd etdiyi nömrəni göstər
        if let number = UserDefaults.standard.string(forKey: "userPhoneNumber") {
            phoneNumberLabel.text = number
        } else {
            phoneNumberLabel.text = "Nömrə tapılmadı"
        }

        setupLayout()
    }

        
        private func setupLayout() {
            view.addSubview(iconImageView)
            view.addSubview(titleLabel)
            view.addSubview(cardView)
            cardView.addSubview(subtitleLabel)
            cardView.addSubview(phoneNumberLabel)
            cardView.addSubview(checkmarkImageView)
            view.addSubview(infoCardView)
            infoCardView.addSubview(infoLabel)
            infoCardView.addSubview(infoIcon)
            
            NSLayoutConstraint.activate([
                iconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                iconImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                iconImageView.widthAnchor.constraint(equalToConstant: 20),
                iconImageView.heightAnchor.constraint(equalToConstant: 20),
                
                titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
                
                cardView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 20),
                cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                cardView.heightAnchor.constraint(equalToConstant: 90),
                
                subtitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
                subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
                
                phoneNumberLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
                phoneNumberLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
                
                checkmarkImageView.centerYAnchor.constraint(equalTo: phoneNumberLabel.centerYAnchor),
                checkmarkImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
                checkmarkImageView.widthAnchor.constraint(equalToConstant: 20),
                checkmarkImageView.heightAnchor.constraint(equalToConstant: 20),
                
                infoCardView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20),
                infoCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                infoCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                
                infoLabel.topAnchor.constraint(equalTo: infoCardView.topAnchor, constant: 16),
                infoLabel.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 16),
                infoLabel.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -40),
                infoLabel.bottomAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: -16),
                
                infoIcon.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -12),
                infoIcon.bottomAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: -12),
                infoIcon.widthAnchor.constraint(equalToConstant: 18),
                infoIcon.heightAnchor.constraint(equalToConstant: 18),
            ])
        }
    }

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
