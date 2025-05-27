//
//  StartController.swift
//  eAmbulance
//
//  Created by Mikayil on 28.05.25.
//

import UIKit

class StartController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Xoş Gəldiniz!"
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Bu platforma, sizə və yaxınlarınıza təcili tibbi yardımın tez və effektiv şəkildə çatdırılmasını təmin edir."
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var getStartedButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Başla", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.backgroundColor = UIColor(red: 20/255, green: 109/255, blue: 191/255, alpha: 1)
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleGetStarted), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let phoneImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "start") // Şəkli proyektə "mockup" adı ilə əlavə et
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 230/255, green: 240/255, blue: 255/255, alpha: 1) // Açıq mavi rəng
        setupLayout()
        phoneImageView.transform = CGAffineTransform(translationX: 0, y: 100)
        phoneImageView.alpha = 0

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIView.animate(withDuration: 1.5, // daha yavaş
                       delay: 0.7,        // daha gec başlasın
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.3,
                       options: [.curveEaseOut],
                       animations: {
            self.phoneImageView.transform = .identity
            self.phoneImageView.alpha = 1
        }, completion: nil)
    }

    
    private func setupLayout() {
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(getStartedButton)
        view.addSubview(phoneImageView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            
            getStartedButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            getStartedButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            getStartedButton.widthAnchor.constraint(equalToConstant: 160),
            getStartedButton.heightAnchor.constraint(equalToConstant: 44),
            
            phoneImageView.topAnchor.constraint(equalTo: getStartedButton.bottomAnchor, constant: 30),
               phoneImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
               phoneImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            phoneImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)


        ])
    }
    @objc private func handleGetStarted() {
            let otpVC = PhoneNumberVc()
            navigationController?.pushViewController(otpVC, animated: true)
        }
}
