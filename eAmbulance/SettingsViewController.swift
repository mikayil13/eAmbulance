import UIKit
import SafariServices

class SettingsViewController: UIViewController {
    private let sections = SettingsDataProvider.sections

    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.isScrollEnabled = false  // vacib — scroll olmasın
        table.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
        return table
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Çıxış et", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 20/255, green: 109/255, blue: 191/255, alpha: 1)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Parametrlər"
        view.backgroundColor = .white

        setupUI()
    }

    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(logoutButton)

        // tableView hündürlüyünü hesabla: (hüceyrə sayı × hüceyrə hündürlüyü + section header hündürlükləri)

        let rowHeight: CGFloat = 44 // Hüceyrənin standart hündürlüyü, əgər fərqli hündürlük varsa özün dəyiş
        let sectionHeaderHeight: CGFloat = 50 // Təxmini header hündürlüyü, lazım olsa dəqiq ölçülə bilər

        var totalRows = 0
        for section in sections {
            totalRows += section.items.count
        }
        let totalSections = sections.count

        let tableHeight = CGFloat(totalRows) * rowHeight + CGFloat(totalSections) * sectionHeaderHeight

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.heightAnchor.constraint(equalToConstant: tableHeight),

            logoutButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func logoutButtonTapped() {
        print("Çıxış et düyməsinə basıldı")
    }
}


extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = sections[indexPath.section].items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = sections[indexPath.section].items[indexPath.row]
        
        print("Seçilmiş title:", item.title) // BURANI ƏLAVƏ ELƏ
        
        switch item.title {
        case "Şəxsi məlumatlarım":
            let personalInfoVC = PersonalInfoViewController()
            navigationController?.pushViewController(personalInfoVC, animated: true)

        case "Gizlilik & Şərtlər":
            if let url = URL(string: "https://gist.githubusercontent.com/mikayil13/46eb8bca57f1c9a7a4d529a13e1ff9ca/raw") {
                let safariVC = SFSafariViewController(url: url)
                present(safariVC, animated: true)
            }
        case "Yardım & Dəstək":
            let helpSupportVC = HelpSupportViewController()
            navigationController?.pushViewController(helpSupportVC, animated: true)

        case "Haqqımızda":
            let aboutVC = AboutViewController()
            navigationController?.pushViewController(aboutVC, animated: true)
        default:
            break
        }
    }

}
