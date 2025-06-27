import UIKit
import FirebaseAuth

class PhoneNumberVc: UIViewController {
    private let topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo") // Burada asset-ə yüklədiyin adla əvəz et
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        let baseFont = UIFont.boldSystemFont(ofSize: 24)
        label.font = UIFontMetrics.default.scaledFont(for: baseFont)
        label.adjustsFontForContentSizeCategory = true
        label.text = "Xoş gəlmisiniz!"
        label.textColor = UIColor(red: 31/255, green: 41/255, blue: 51/255, alpha: 1)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hesaba daxil olmaq  və ya qeydiyyat üçün\nnömrənizi daxil edin"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = UIColor(red: 108/255, green: 103/255, blue: 103/255, alpha: 1)
        label.numberOfLines = 0
        return label
    }()

    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "Mobil nömrəniz"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()

    private let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "+994 XX XXX XX XX"
        textField.backgroundColor = UIColor(red: 243/255, green: 243/255, blue: 247/255, alpha: 1)
        textField.layer.cornerRadius = 12
        textField.font = .systemFont(ofSize: 16)
        textField.keyboardType = .phonePad
        textField.setLeftPaddingPoints(12)
        return textField
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Təsdiqlə", for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 14
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.isEnabled = false
        button.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        phoneTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        navigationItem.hidesBackButton = true
    }

    // MARK: - Layout
    private func setupLayout() {
        [topImageView, titleLabel, subtitleLabel, phoneLabel, phoneTextField, confirmButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            topImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            topImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topImageView.widthAnchor.constraint(equalToConstant: 80),
            topImageView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.topAnchor.constraint(equalTo: topImageView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),

            phoneLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 36),
            phoneLabel.leadingAnchor.constraint(equalTo: subtitleLabel.leadingAnchor),

            phoneTextField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 8),
            phoneTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            phoneTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            phoneTextField.heightAnchor.constraint(equalToConstant: 50),

            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Actions
    @objc private func textFieldDidChange() {
        let text = phoneTextField.text ?? ""
        if text.count >= 13 {
            confirmButton.isEnabled = true
            confirmButton.backgroundColor = UIColor(red: 20/255, green: 109/255, blue: 191/255, alpha: 1)
            confirmButton.setTitleColor(.white, for: .normal)
        } else {
            confirmButton.isEnabled = false
            confirmButton.backgroundColor = .lightGray
            confirmButton.setTitleColor(.darkGray, for: .normal)
        }
    }

    @objc private func confirmButtonTapped() {
        guard let number = phoneTextField.text, !number.isEmpty else { return }
        UserDefaults.standard.set(number, forKey: "userPhoneNumber")

        sendOTP(to: number)
    }


    private func sendOTP(to phoneNumber: String) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] vid, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("OTP göndərmə xətası: \(error.localizedDescription)")
                    return
                }
                guard let verificationID = vid, let self = self else { return }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                print("OTP göndərildi")

                let otpVC = OtpVc()
                otpVC.verificationID = verificationID
                self.navigationController?.pushViewController(otpVC, animated: true) 

            }
        }
    }
}

// MARK: - UITextField Padding Extension
extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
}


