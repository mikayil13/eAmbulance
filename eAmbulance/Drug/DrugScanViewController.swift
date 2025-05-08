import UIKit
import Vision

final class DrugScanViewController: UIViewController {
    
    private lazy var modeControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Derman Şəkil Seç", "Derman adi Yaz"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor =  UIColor(red: 20/255, green: 109/255, blue: 191/255, alpha: 1)
        control.setTitleTextAttributes([.foregroundColor: UIColor.darkGray], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.backgroundColor = UIColor.systemGray6
        control.layer.cornerRadius = 35
        control.layer.masksToBounds = true
        control.layer.shadowColor = UIColor.black.cgColor
        control.layer.shadowOpacity = 0.1
        control.layer.shadowOffset = CGSize(width: 0, height: 2)
        control.layer.shadowRadius = 4
        control.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    private lazy var imageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var drugImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "photo.on.rectangle"))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGray3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private lazy var pickButton: UIButton = {
        let btn = makeButton(title: "Şəkil Seç", action: #selector(selectImageTapped))
        btn.backgroundColor = UIColor(red: 20/255, green: 109/255, blue: 191/255, alpha: 1)
        return btn
    }()

    private lazy var textContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
   
    private lazy var manualField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Dərman adını daxil edin"
        tf.backgroundColor = .white
        tf.layer.cornerRadius = 12
        tf.layer.masksToBounds = true
        let icon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        icon.tintColor = .systemGray
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        icon.center = container.center
        container.addSubview(icon)
        tf.leftView = container
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    private lazy var searchButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Axtar", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 20/255, green: 109/255, blue: 191/255, alpha: 1)
        btn.layer.cornerRadius = 10
        btn.layer.shadowColor = UIColor.systemBlue.cgColor
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 6
        btn.titleLabel?.font = .boldSystemFont(ofSize: 17)
        btn.addTarget(self, action: #selector(manualSearchTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // Result
    private lazy var resultContainer: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.07
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.layer.shadowRadius = 4
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private lazy var resultTextView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 16)
        tv.textColor = .label
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var loadingOverlay: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .regular)
        let view = UIVisualEffectView(effect: blur)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.contentView.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.contentView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.contentView.centerYAnchor)
        ])
        return view
    }()

    private let imagePicker = UIImagePickerController()
    private var resultTopToPickButton: NSLayoutConstraint!
    private var resultTopToModeControl: NSLayoutConstraint!
    private var resultContainerHeightConstraint: NSLayoutConstraint!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dərman Məlumatları"
        view.backgroundColor = .systemGroupedBackground
        setupUI()
        imagePicker.delegate = self
    }
    private func setupUI() {
        view.addSubview(modeControl)
        view.addSubview(imageContainer)
        imageContainer.addSubview(drugImageView)
        view.addSubview(pickButton)
        view.addSubview(resultContainer)
        resultContainer.addSubview(resultTextView)
        view.addSubview(textContainer)
        textContainer.addSubview(manualField)
        textContainer.addSubview(searchButton)
        view.addSubview(loadingOverlay)
        textContainer.isHidden = true

        NSLayoutConstraint.activate([
            modeControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            modeControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modeControl.widthAnchor.constraint(equalToConstant: 240),
            modeControl.heightAnchor.constraint(equalToConstant: 30),

            imageContainer.topAnchor.constraint(equalTo: modeControl.bottomAnchor, constant: 20),
            imageContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageContainer.widthAnchor.constraint(equalToConstant: 240),
            imageContainer.heightAnchor.constraint(equalToConstant: 200),
            drugImageView.topAnchor.constraint(equalTo: imageContainer.topAnchor),
            drugImageView.bottomAnchor.constraint(equalTo: imageContainer.bottomAnchor),
            drugImageView.leadingAnchor.constraint(equalTo: imageContainer.leadingAnchor),
            drugImageView.trailingAnchor.constraint(equalTo: imageContainer.trailingAnchor),
            pickButton.topAnchor.constraint(equalTo: imageContainer.bottomAnchor, constant: 16),
            pickButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickButton.widthAnchor.constraint(equalToConstant: 180),
            pickButton.heightAnchor.constraint(equalToConstant: 44),
            textContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textContainer.heightAnchor.constraint(equalToConstant: 70),

            manualField.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 16),
            manualField.centerYAnchor.constraint(equalTo: textContainer.centerYAnchor),
            manualField.heightAnchor.constraint(equalToConstant: 44),

            searchButton.leadingAnchor.constraint(equalTo: manualField.trailingAnchor, constant: 8),
            searchButton.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -16),
            searchButton.centerYAnchor.constraint(equalTo: manualField.centerYAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 80),
            searchButton.heightAnchor.constraint(equalToConstant: 44),

            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        resultTopToPickButton = resultContainer.topAnchor.constraint(equalTo: pickButton.bottomAnchor, constant: 24)
        resultTopToModeControl = resultContainer.topAnchor.constraint(equalTo: modeControl.bottomAnchor, constant: 24)
        resultTopToModeControl.isActive = false
        resultContainerHeightConstraint = resultContainer.heightAnchor.constraint(equalToConstant: 400)
        resultContainerHeightConstraint.isActive = false

        NSLayoutConstraint.activate([
            resultTopToPickButton,
            resultContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            resultContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            resultContainer.bottomAnchor.constraint(equalTo: textContainer.topAnchor, constant: -16),

            resultTextView.topAnchor.constraint(equalTo: resultContainer.topAnchor, constant: 12),
            resultTextView.bottomAnchor.constraint(equalTo: resultContainer.bottomAnchor, constant: -12),
            resultTextView.leadingAnchor.constraint(equalTo: resultContainer.leadingAnchor, constant: 12),
            resultTextView.trailingAnchor.constraint(equalTo: resultContainer.trailingAnchor, constant: -12),
        ])
    }
    private func makeButton(title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.backgroundColor = UIColor(red: 20/255, green: 109/255, blue: 191/255, alpha: 1)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.1
        btn.layer.shadowOffset = CGSize(width: 0, height: 2)
        btn.layer.shadowRadius = 4
        btn.addTarget(self, action: action, for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }

    @objc private func modeChanged() {
        let manual = modeControl.selectedSegmentIndex == 1
        imageContainer.alpha = manual ? 0 : 1
        pickButton.alpha = manual ? 0 : 1
        textContainer.alpha = manual ? 1 : 0
        resultTopToPickButton.isActive = !manual
        resultTopToModeControl.isActive = manual
        resultContainerHeightConstraint.isActive = manual
        self.view.layoutIfNeeded()
        imageContainer.isHidden = manual
        pickButton.isHidden = manual
        textContainer.isHidden = !manual
        resultTextView.text = ""
    }
    @objc private func selectImageTapped() {
        let sheet = UIAlertController(title: "Şəkil Seçimi", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sheet.addAction(.init(title: "Kamera", style: .default) { _ in self.openPicker(.camera) })
        }
        sheet.addAction(.init(title: "Şəkil seç", style: .default) { _ in self.openPicker(.photoLibrary) })
        sheet.addAction(.init(title: "İmtina", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func manualSearchTapped() {
      guard let text = manualField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
        showAlert("Xəta", "Dərman adı boş ola bilməz.")
        return
      }
      showLoading(true)
      DrugManager.shared.fetchDrugInfo(for: text) { [weak self] result in
        DispatchQueue.main.async {
          self?.showLoading(false)
          switch result {
          case .success(let info):   self?.updateResult(info)
          case .failure(let error):  self?.showAlert("Xəta", error.localizedDescription)
          }
        }
      }
    }
    
    private func recognizeText(on image: UIImage) {
      guard let cg = image.cgImage else { return }
      let request = VNRecognizeTextRequest { [weak self] req, _ in
        guard let candidate = (req.results as? [VNRecognizedTextObservation])?
                                  .first?.topCandidates(1).first else {
          DispatchQueue.main.async { self?.updateResult("Şəkildə mətn tapılmadı.") }
          return
        }
        DispatchQueue.main.async { self?.showLoading(true) }
        DrugManager.shared.fetchDrugInfo(for: candidate.string) { [weak self] result in
          DispatchQueue.main.async {
            self?.showLoading(false)
            switch result {
            case .success(let info): self?.updateResult(info)
            case .failure(let error):self?.showAlert("Xəta", error.localizedDescription)
            }
          }
        }
      }
      request.recognitionLevel = .accurate
      DispatchQueue.global(qos: .userInitiated).async {
        try? VNImageRequestHandler(ciImage: CIImage(cgImage: cg), options: [:])
               .perform([request])
      }
    }

        private func openPicker(_ type: UIImagePickerController.SourceType) {
            imagePicker.sourceType = type
            present(imagePicker, animated: true)
        }

    private func showLoading(_ show: Bool) {
        DispatchQueue.main.async { self.loadingOverlay.isHidden = !show }
    }

    private func updateResult(_ text: String) {
        DispatchQueue.main.async { self.resultTextView.text = text }
    }

    private func showAlert(_ title: String, _ msg: String) {
        let a = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        a.addAction(.init(title: "Bağla", style: .default))
        present(a, animated: true)
    }
}

extension DrugScanViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let img = info[.originalImage] as? UIImage {
            drugImageView.image = img
            recognizeText(on: img)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}


