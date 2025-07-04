import UIKit



final class CancelBottomSheetController: UIViewController {

    var onReasonSelected: ((String?) -> Void)?

    private let reasons = [
        "Yanlışlıqla çağırdım",
        "Şəxsin vəziyyətin yüngülləşməsi",
        "Xəstə xəstəxanaya aparıldı",
        "Təcili yardım xidmətini ləğv etməyi qərara aldım",
        "Yanlış ünvana çağırılması",
        "Digər səbəb"
    ]

    private var selectedIndex: Int?

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .black
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ləğv etmək istəyirsiniz?"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Əgər istəyirsinizsə səbəbini qeyd edin"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()

    private lazy var reasonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }()

    private let otherReasonTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Səbəbi yazın"
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.isHidden = true
        return tf
    }()

    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ləğv et", for: .normal)
        button.backgroundColor = UIColor(red: 20/255, green: 109/255, blue: 191/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 10
        return button
    }()

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20
        view.clipsToBounds = true

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])

        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        let topStack = UIStackView(arrangedSubviews: [backButton, UIView()])
        topStack.axis = .horizontal

        let headerStack = UIStackView(arrangedSubviews: [topStack, titleLabel, subtitleLabel])
        headerStack.axis = .vertical
        headerStack.spacing = 8

        contentStackView.addArrangedSubview(headerStack)

        for (index, reason) in reasons.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(reason, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.backgroundColor = .systemGray6
            button.layer.cornerRadius = 8
            button.tag = index
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
            button.addTarget(self, action: #selector(reasonTapped(_:)), for: .touchUpInside)
            reasonStackView.addArrangedSubview(button)
        }
        contentStackView.addArrangedSubview(reasonStackView)

        contentStackView.addArrangedSubview(otherReasonTextField)
        otherReasonTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true

        contentStackView.addArrangedSubview(confirmButton)
        confirmButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(dismissSheet), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
    }

    @objc private func reasonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag

        for case let btn as UIButton in reasonStackView.arrangedSubviews {
            btn.backgroundColor = .systemGray6
            btn.layer.borderWidth = 0
        }

        sender.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        sender.layer.borderColor = UIColor.systemBlue.cgColor
        sender.layer.borderWidth = 2

        if reasons[sender.tag] == "Digər səbəb" {
            otherReasonTextField.isHidden = false
            otherReasonTextField.becomeFirstResponder()
        } else {
            otherReasonTextField.isHidden = true
            otherReasonTextField.resignFirstResponder()
            otherReasonTextField.text = nil
        }
    }

    @objc private func confirmTapped() {
        guard let selected = selectedIndex else { return }

        let reason: String
        if reasons[selected] == "Digər səbəb" {
            guard let text = otherReasonTextField.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            reason = text
        } else {
            reason = reasons[selected]
        }

        onReasonSelected?(reason)
        dismiss(animated: true)
    }

    @objc private func dismissSheet() {
        dismiss(animated: true)
    }
}
