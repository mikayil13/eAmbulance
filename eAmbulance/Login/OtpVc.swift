//
//  OtpVc.swift
//  eAmbulance
//
//  Created by Mikayil on 29.04.25.
//

import UIKit
import FirebaseAuth

class OtpVc: UIViewController {
    var verificationID: String?

    // Timer properties
    private var timer: Timer?
    private var remainingSeconds: Int = 119

    // UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        let baseFont = UIFont.boldSystemFont(ofSize: 24)
        label.font = UIFontMetrics.default.scaledFont(for: baseFont)
        label.adjustsFontForContentSizeCategory = true
        label.text = "Qeydiyyat"
        label.textColor = UIColor(red: 31/255, green: 41/255, blue: 51/255, alpha: 1)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Qeydiyyat üçün nömrənizə 6 rəqəmli\nkod göndərdik zəhmət olmasa onu daxil edin"
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(red: 108/255, green: 103/255, blue: 103/255, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let resendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Yenidən göndər", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(.lightGray, for: .normal)
        button.isEnabled = false
        return button
    }()

    private let timerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()

    private var codeFields: [UITextField] = []

    // Confirm button with action wired
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Təsdiqlə", for: .normal)
        button.backgroundColor = .lightGray
        button.setTitleColor(.darkGray, for: .normal)
        button.layer.cornerRadius = 14
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        startTimer()
        // Resend action
        resendButton.addTarget(self, action: #selector(resendCode), for: .touchUpInside)
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - UI Setup
    private func setupUI() {
        [titleLabel, subtitleLabel, resendButton, timerLabel, confirmButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            resendButton.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 24),
            resendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            timerLabel.topAnchor.constraint(equalTo: resendButton.bottomAnchor, constant: 8),
            timerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        setupCodeFields()
        updateTimerLabel()
    }

    private func setupCodeFields() {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 24),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.heightAnchor.constraint(equalToConstant: 50),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])

        for _ in 0..<6 {
            let field = UITextField()
            field.translatesAutoresizingMaskIntoConstraints = false
            field.backgroundColor = .lightGray
            field.layer.cornerRadius = 8
            field.textAlignment = .center
            field.keyboardType = .numberPad
            field.font = .systemFont(ofSize: 24)
            field.delegate = self
            field.addTarget(self, action: #selector(codeChanged), for: .editingChanged)
            NSLayoutConstraint.activate([
                field.widthAnchor.constraint(equalToConstant: 50),
                field.heightAnchor.constraint(equalToConstant: 50)
            ])
            stack.addArrangedSubview(field)
            codeFields.append(field)
        }
    }

    // MARK: - Confirm Action
    @objc private func confirmTapped() {
        let code = codeFields.compactMap { $0.text }.joined() // OTP kodunu toplayın
        guard let vid = verificationID else { return } // Verification ID əldə edin
        let credential = PhoneAuthProvider.provider()
            .credential(withVerificationID: vid, verificationCode: code)

        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Kod səhvdir: \(error.localizedDescription)") // Hata mesajını göstərin
                    self?.highlightCodeFieldsWithError(true)
                    self?.shakeCodeFields()
                } else {
                    print("Kod doğrudur, keçid edilir…") // Kod doğru olduğunda
                    self?.highlightCodeFieldsWithError(false)
                    
                    // HospitalMapController-a keçid edin
                    let tabBarController = TabBarContoller()
                    tabBarController.modalPresentationStyle = .fullScreen
                    self?.present(tabBarController, animated: true)
                }
            }
        }
    }


    // MARK: - Timer Methods
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(timerTick),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc private func timerTick() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            updateTimerLabel()
        } else {
            timer?.invalidate()
            resendButton.isEnabled = true
            resendButton.setTitleColor(.systemBlue, for: .normal)
        }
    }

    private func updateTimerLabel() {
        timerLabel.text = "Kod \(remainingSeconds) saniyə sonra keçərsiz olacaqdır"
    }

    // MARK: - Resend Action
    @objc private func resendCode() {
        remainingSeconds = 119
        updateTimerLabel()
        resendButton.isEnabled = false
        resendButton.setTitleColor(.lightGray, for: .normal)
        startTimer()
    }

    // MARK: - Code Field Handling
    @objc private func codeChanged() {
        let code = codeFields.compactMap { $0.text }.joined()
        confirmButton.isEnabled = (code.count == 6)
        confirmButton.backgroundColor = confirmButton.isEnabled
            ? UIColor(red: 20/255, green: 109/255, blue: 191/255, alpha: 1)
            : .lightGray
        confirmButton.setTitleColor(confirmButton.isEnabled ? .white : .darkGray, for: .normal)

        // Clear red borders when editing
        codeFields.forEach {
            $0.layer.borderWidth = 0
        }
    }

    func shakeCodeFields() {
        UIView.animate(withDuration: 0.05, animations: {
            self.codeFields.forEach {
                $0.transform = CGAffineTransform(translationX: 5, y: 0)
                $0.layer.borderColor = UIColor.red.cgColor
                $0.layer.borderWidth = 1.5
            }
        }) { _ in
            UIView.animate(withDuration: 0.05) {
                self.codeFields.forEach {
                    $0.transform = .identity
                }
            }
        }
    }

    func highlightCodeFieldsWithError(_ isError: Bool) {
        codeFields.forEach {
            $0.layer.borderWidth = isError ? 1.5 : 0
            $0.layer.borderColor = isError ? UIColor.red.cgColor : UIColor.clear.cgColor
        }
    }

    // MARK: - Focus Helpers
    private func moveFocus(to index: Int) {
        if index < codeFields.count {
            codeFields[index].becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
    }

    private func moveFocusBack(from index: Int) {
        if index > 0 {
            codeFields[index - 1].becomeFirstResponder()
        }
    }
}

// MARK: - UITextFieldDelegate
extension OtpVc: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard let index = codeFields.firstIndex(of: textField) else { return false }

        if string.count == 1 {
            textField.text = string
            moveFocus(to: index + 1)
            codeChanged()
            return false
        } else if string.isEmpty {
            if textField.text?.isEmpty == false {
                textField.text = ""
            } else {
                moveFocusBack(from: index)
                if index > 0 {
                    codeFields[index - 1].text = ""
                }
            }
            codeChanged()
            return false
        }
        return false
    }
}

