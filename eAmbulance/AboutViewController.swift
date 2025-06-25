import UIKit
import MapKit
import CoreLocation

class AboutViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Haqqımızda"
        setupView()
        setupLayout()
        setupContent()
    }

    private func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }

    private func setupContent() {
        stackView.addArrangedSubview(headerSection())
        stackView.addArrangedSubview(descriptionLabel())
        stackView.addArrangedSubview(statsBox())
        stackView.addArrangedSubview(featuresSection())
        stackView.addArrangedSubview(supportSection())
    }

    private func headerSection() -> UIView {
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 12
        container.alignment = .top

        let image = UIImageView(image: UIImage(named: "logo"))
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = 8
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        image.widthAnchor.constraint(equalToConstant: 48).isActive = true
        image.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = "Təcili yardım çağırma tətbiqi"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 0

        let versionLabel = UILabel()
        versionLabel.text = "Versiya 1.1.0"
        versionLabel.font = UIFont.systemFont(ofSize: 14)
        versionLabel.textColor = .gray

        let textStack = UIStackView(arrangedSubviews: [titleLabel, versionLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        container.addArrangedSubview(image)
        container.addArrangedSubview(textStack)

        return container
    }

    private func descriptionLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "\"eAmbulance\" tətbiqi 2025-ci ildə Azərbaycanda təcili tibbi yardım xidmətlərini modernləşdirmək məqsədi ilə yaradılmışdır. Biz texnologiya vasitəsilə həyat xilas etməyə kömək edirik və təcili hallarda sürətli reaksiya təmin edirik."
        return label
    }

    private func statsBox() -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor(red: 75/255, green: 117/255, blue: 233/255, alpha: 0.03)
        container.layer.borderColor = UIColor.systemBlue.cgColor
        container.layer.borderWidth = 1
        container.layer.cornerRadius = 12

        let titles = ["13,000", "10,000+", "7/24", "3 dq"]
        let subtitles = ["Aktiv istifadəçi", "Uğurlu çağırış", "Xidmət vaxtı", "Orta cavab vaxtı"]

        let grid = UIStackView()
        grid.axis = .horizontal
        grid.distribution = .fillEqually
        grid.spacing = 8
        grid.translatesAutoresizingMaskIntoConstraints = false

        for (i, title) in titles.enumerated() {
            let label1 = UILabel()
            label1.text = title
            label1.font = UIFont.boldSystemFont(ofSize: 16)
            label1.textAlignment = .center

            let label2 = UILabel()
            label2.text = subtitles[i]
            label2.font = UIFont.systemFont(ofSize: 12)
            label2.textColor = .gray
            label2.textAlignment = .center
            label2.numberOfLines = 2

            let vstack = UIStackView(arrangedSubviews: [label1, label2])
            vstack.axis = .vertical
            vstack.alignment = .center
            vstack.spacing = 4

            grid.addArrangedSubview(vstack)
        }

        container.addSubview(grid)
        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            grid.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            grid.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            grid.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12)
        ])

        return container
    }

    private func featuresSection() -> UIStackView {
        let features = [
            ("bolt.fill", "Sürətli çağırış", "Bir toxunuşla təcili yardım"),
            ("location.fill", "Real vaxt izləmə", "Ambulansın gəlişini canlı izləyin"),
            ("shield.fill", "Təhlükəsizlik", "Tibbi məlumatlarınız qorunur")
        ]

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16

        for item in features {
            let icon = UIImageView(image: UIImage(systemName: item.0))
            icon.tintColor = .systemBlue
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.widthAnchor.constraint(equalToConstant: 24).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 24).isActive = true

            let title = UILabel()
            title.text = item.1
            title.font = UIFont.boldSystemFont(ofSize: 15)

            let subtitle = UILabel()
            subtitle.text = item.2
            subtitle.font = UIFont.systemFont(ofSize: 13)
            subtitle.textColor = .gray

            let textStack = UIStackView(arrangedSubviews: [title, subtitle])
            textStack.axis = .vertical
            textStack.spacing = 2

            let hStack = UIStackView(arrangedSubviews: [icon, textStack])
            hStack.axis = .horizontal
            hStack.spacing = 16
            hStack.alignment = .top

            stack.addArrangedSubview(hStack)
        }

        return stack
    }

    private func supportSection() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8

        let titleLabel = UILabel()
        titleLabel.text = "Dəstək məlumatları"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        stackView.addArrangedSubview(titleLabel)

        let data: [(String, String)] = [
            ("Əlaqə nömrəsi", "814 qısa nömrəsi"),
            ("Email", "support@e-health.gov.az"),
            ("Website", "https://e-health.gov.az"),
            ("Ünvan", "Azərbaycan, Bakı AZ 1022 akad. M.Miraqsimov küç. 1A")
        ]

        for (key, value) in data {
            if key == "Website" {
                let button = UIButton(type: .system)
                button.setTitle(value, for: .normal)
                button.contentHorizontalAlignment = .left
                button.addTarget(self, action: #selector(openWebsite(_:)), for: .touchUpInside)
                stackView.addArrangedSubview(button)
            } else if key == "Ünvan" {
                let button = UIButton(type: .system)
                button.setTitle(value, for: .normal)
                button.contentHorizontalAlignment = .left
                button.addTarget(self, action: #selector(openMap(_:)), for: .touchUpInside)
                stackView.addArrangedSubview(button)
            } else {
                let label = UILabel()
                label.text = "\(key): \(value)"
                stackView.addArrangedSubview(label)
            }
        }

        return stackView
    }

    @objc private func openWebsite(_ sender: UIButton) {
        guard let urlString = sender.title(for: .normal),
              let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    @objc private func openMap(_ sender: UIButton) {
        guard let address = sender.title(for: .normal) else { return }

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let placemark = placemarks?.first,
               let location = placemark.location {
                let coordinate = location.coordinate

                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
                mapItem.name = address
                mapItem.openInMaps(launchOptions: nil)
            }
        }
    }
}

