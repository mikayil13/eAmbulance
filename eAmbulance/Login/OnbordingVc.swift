//
//  OnbordingVc.swift
//  eAmbulance
//
//  Created by Mikayil on 29.04.25.
//

import UIKit

class OnbordingVc: UIViewController {
  
        let titleLabel: UILabel = {
            let label = UILabel()
            let baseFont = UIFont.boldSystemFont(ofSize: 24)
            label.font = UIFontMetrics.default.scaledFont(for: baseFont)
            label.adjustsFontForContentSizeCategory = true
            label.text = "Xoş gəlmisiniz!"
            label.textColor = UIColor(red: 31/255, green: 41/255, blue: 51/255, alpha: 1)
            label.textAlignment = .center
            return label
        }()
        
        let subtitleLabel: UILabel = {
            let label = UILabel()
            label.text = "Medicell ilə\nXəstəxanalar daha yaxın,\nhər kəs daha sağlam !"
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = UIColor(red: 108/255, green: 103/255, blue: 103/255, alpha: 1)
            label.font = .systemFont(ofSize: 16)
            return label
        }()
        
        let illustrationImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "Onboarding")
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
        private lazy var startButton: UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Başla", for: .normal)
            button.backgroundColor = UIColor(red: 20/255, green: 109/255, blue: 191/255, alpha: 1)
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 12
            button.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
            button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
            return button
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            setupLayout()
        }
        
        func setupLayout() {
            // Elementləri əlavə et
            [titleLabel, subtitleLabel, illustrationImageView, startButton].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            }
            
            // Constraint-lər
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
                titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
                
                illustrationImageView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
                illustrationImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                illustrationImageView.heightAnchor.constraint(equalToConstant: 343),
                illustrationImageView.widthAnchor.constraint(equalToConstant: 400),
                
                startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
                startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                startButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }
        @objc func startButtonTapped() {
            let phoneVC = PhoneNumberVc()
            navigationController?.pushViewController(phoneVC, animated: true)
        }
        
    }

