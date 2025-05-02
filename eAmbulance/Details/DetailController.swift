import UIKit
import CoreLocation

class DetailController: UIViewController {
    var onAmbulanceRequested: ((HospitalModel) -> Void)?
    var hospitalDetail: HospitalModel?
    var hospitalMapController: HospitalMapController?
    var selectedHospital: HospitalModel?
    var userLocation: CLLocation?
    var onDismiss: ((_ ambulanceCalled: Bool) -> Void)?
    
    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(DetailsCell.self, forCellReuseIdentifier: "DetailsCell")
        return table
    }()
    
    private let customNavBar: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 20
        button.backgroundColor = .systemGray6
        button.addTarget(nil, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let buttonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        titleLabel.text = hospitalDetail?.name ?? "Xəstəxana Adı"
        setupCustomNavBar()
        setupTableView()
        setupButtonContainer()
    }
    
    private func setupCustomNavBar() {
        view.addSubview(customNavBar)
        customNavBar.addSubview(closeButton)
        customNavBar.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 70),
            
            titleLabel.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),
            
            closeButton.trailingAnchor.constraint(equalTo: customNavBar.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 35),
            closeButton.heightAnchor.constraint(equalToConstant: 35)
        ])
    }
    @objc func closeButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onDismiss?(false) 
        }
    }
    
    private func setupButtonContainer() {
        buttonContainer.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        
        let websiteButton = UIButton(type: .system)
        websiteButton.configuration = createButtonConfig(title: "Web sitesi", imageName: "safari")
        websiteButton.addTarget(self, action: #selector(openWebsite), for: .touchUpInside)
        
        let ambulanceButton = UIButton(type: .system)
        ambulanceButton.configuration = createButtonConfig(title: "Ambulans çağır", imageName: "cross")
        ambulanceButton.addTarget(self, action: #selector(callAmbulance), for: .touchUpInside)
        
        let buttonStack = UIStackView(arrangedSubviews: [websiteButton, ambulanceButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 16
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        buttonContainer.addSubview(buttonStack)
        
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: buttonContainer.topAnchor, constant: 8),
            buttonStack.leadingAnchor.constraint(equalTo: buttonContainer.leadingAnchor, constant: 16),
            buttonStack.trailingAnchor.constraint(equalTo: buttonContainer.trailingAnchor, constant: -16),
            buttonStack.bottomAnchor.constraint(equalTo: buttonContainer.bottomAnchor, constant: -8)
        ])
        
        buttonContainer.layoutIfNeeded()
        tableView.tableHeaderView = buttonContainer
    }
    
    
    private func createButtonConfig(title: String, imageName: String) -> UIButton.Configuration {
        var config = UIButton.Configuration.filled()
        config.baseForegroundColor = .systemBlue
        config.baseBackgroundColor = .systemGray6
        config.image = UIImage(systemName: imageName)?.withTintColor(.systemBlue, renderingMode: .alwaysOriginal)
        config.imagePadding = 12
        config.imagePlacement = .top
        config.title = title
        config.titleAlignment = .center
        config.background.cornerRadius = 16
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        return config
    }
    @objc private func openWebsite() {
        guard let websiteURL = hospitalDetail?.websiteURL else { return }
        UIApplication.shared.open(websiteURL, options: [:], completionHandler: nil)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc private func callAmbulance() {
        guard let detail = hospitalDetail else { return }

        self.dismiss(animated: true) {
            let window = UIApplication.shared.windows.first { $0.isKeyWindow }

            let customAlertView = UIView()
            customAlertView.backgroundColor = .systemGray6
            customAlertView.layer.cornerRadius = 15
            customAlertView.layer.shadowColor = UIColor.black.cgColor
            customAlertView.layer.shadowOpacity = 0.3
            customAlertView.layer.shadowOffset = CGSize(width: 0, height: 2)
            customAlertView.layer.shadowRadius = 5
            customAlertView.translatesAutoresizingMaskIntoConstraints = false

            let titleLabel = UILabel()
            titleLabel.text = "Təcili Yardım Çağırılır"
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            titleLabel.textAlignment = .center
            titleLabel.translatesAutoresizingMaskIntoConstraints = false

            let messageLabel = UILabel()
            messageLabel.text = "Təcili yardım göndərilir, lütfən gözləyin..."
            messageLabel.font = UIFont.systemFont(ofSize: 14)
            messageLabel.textAlignment = .center
            messageLabel.numberOfLines = 0
            messageLabel.translatesAutoresizingMaskIntoConstraints = false

            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.startAnimating()

            customAlertView.addSubview(titleLabel)
            customAlertView.addSubview(messageLabel)
            customAlertView.addSubview(spinner)

            window?.addSubview(customAlertView)

            NSLayoutConstraint.activate([
                customAlertView.centerXAnchor.constraint(equalTo: window!.centerXAnchor),
                customAlertView.centerYAnchor.constraint(equalTo: window!.centerYAnchor),
                customAlertView.widthAnchor.constraint(equalToConstant: 250),
                customAlertView.heightAnchor.constraint(equalToConstant: 130),

                titleLabel.topAnchor.constraint(equalTo: customAlertView.topAnchor, constant: 16),
                titleLabel.leadingAnchor.constraint(equalTo: customAlertView.leadingAnchor, constant: 12),
                titleLabel.trailingAnchor.constraint(equalTo: customAlertView.trailingAnchor, constant: -12),

                messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                messageLabel.leadingAnchor.constraint(equalTo: customAlertView.leadingAnchor, constant: 12),
                messageLabel.trailingAnchor.constraint(equalTo: customAlertView.trailingAnchor, constant: -12),

                spinner.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
                spinner.centerXAnchor.constraint(equalTo: customAlertView.centerXAnchor)
            ])

            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                customAlertView.removeFromSuperview()
                self.onAmbulanceRequested?(detail)
            }
        }
    }

}
extension DetailController: UITableViewDataSource, UITableViewDelegate  {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
         return "Təfərrüatlar"
     }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsCell", for: indexPath) as! DetailsCell
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                cell.configure(title: "Telefon", subtitle: hospitalDetail?.phoneNumber ?? "Telefon numarası bulunamadı!")
            case 1:
                cell.configure(title: "Website", subtitle: hospitalDetail?.websiteURL?.absoluteString ?? "Web sitesi bulunamadı!")
            case 2:
                cell.configure(title: "Adres", subtitle: hospitalDetail?.address ?? "Adres bulunamadı!")
            default:
                break
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            header.textLabel?.textColor = .darkText
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          tableView.deselectRow(at: indexPath, animated: true)
          if let website = hospitalDetail?.websiteURL {
              UIApplication.shared.open(website)
          }
      }
}

