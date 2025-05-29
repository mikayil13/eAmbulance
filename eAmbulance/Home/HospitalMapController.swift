import UIKit
import MapKit
import CoreLocation
import Instructions
class HospitalMapController: UIViewController, MKMapViewDelegate {
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()
    
    public  lazy var sosButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "s"), for: .normal)
        button.addTarget(self, action: #selector(sosButtonTapped), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let panelView: UIView = {
        let panelView = UIView()
        panelView.backgroundColor = .systemBackground
        panelView.layer.cornerRadius = 24
        panelView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        panelView.layer.shadowColor = UIColor.black.cgColor
        panelView.layer.shadowOpacity = 0.1
        panelView.layer.shadowOffset = CGSize(width: 0, height: -4)
        panelView.layer.shadowRadius = 12
        panelView.translatesAutoresizingMaskIntoConstraints = false
        return panelView
    }()
    
    private let panelHandle: UIView = {
        let handle = UIView()
        handle.backgroundColor = UIColor.systemGray3
        handle.layer.cornerRadius = 3
        handle.translatesAutoresizingMaskIntoConstraints = false
        return handle
    }()
    
    public lazy var destinationButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = UIColor.systemGray6
        btn.setTitle("Xəstəxana seçin və ya axtarın", for: .normal)
        btn.setTitleColor(.label, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        btn.layer.cornerRadius = 20
        btn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        btn.tintColor = .gray
        btn.imageView?.contentMode = .scaleAspectFit
        btn.contentHorizontalAlignment = .left
        btn.addTarget(self, action: #selector(destinationTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    public let hospitalListContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let ambulanceStatusContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    private let topStatusView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemRed
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let topStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Təcili yardım yoldadır  •  4 dq"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let hospitalNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Medistyle Hospital"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 240/255, green: 245/255, blue: 255/255, alpha: 1)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Təcili yardımın vəziyyəti"
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let etaLabel: UILabel = {
        let label = UILabel()
        label.text = "⏱️Təxmini çatma vaxtı: 12 dq"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = .systemBlue
        progress.trackTintColor = .lightGray
        progress.progress = 0.0  // Başlanğıcda 0 olaraq təyin et
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    private let preparingLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Hazırlanır"
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .gray
        lbl.textAlignment = .left
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let onTheWayLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Yolda"
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .gray
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private let arrivedLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Çatdı"
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .gray
        lbl.textAlignment = .right
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private lazy var statusLabelsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [preparingLabel, onTheWayLabel, arrivedLabel])
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Gedişi ləğv et", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setImage(UIImage(systemName: "circle.slash"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        return button
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "⚠️Sui-istifadə halında məsuliyyətə cəlb olunacağınızı nəzərə alın."
        label.font = .systemFont(ofSize: 12)
        label.textColor = .systemOrange
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public  lazy var helpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Yardım", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(red: 0.22, green: 0.78, blue: 0.35, alpha: 1.0) // Yaşıl rəng
        button.layer.cornerRadius = 20
        button.setImage(UIImage(systemName: "questionmark.circle.fill"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    
    private let overlayView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        v.alpha = 0
        v.isUserInteractionEnabled = false
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let topPanelView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 25
        v.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    private let panelLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Axtarış"
        lbl.textColor = .black
        lbl.font = .boldSystemFont(ofSize: 18)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    private let searchBar: UISearchBar = {
        let search = UISearchBar()
        search.backgroundImage = UIImage()
        search.searchTextField.backgroundColor = UIColor(red: 0.93, green: 0.94, blue: 0.96, alpha: 1.0)
        search.searchTextField.layer.cornerRadius = 15
        search.searchTextField.clipsToBounds = true
        search.translatesAutoresizingMaskIntoConstraints = false
        search.searchTextField.textColor = .darkText
        search.searchTextField.font = UIFont.systemFont(ofSize: 16)
        search.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "Xəstəxana axtar",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        )
        return search
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15
        button.backgroundColor = .systemGray6
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    private let ambulanceStatusStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    public let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemGray6
        table.separatorStyle = .none
        table.register(HospitalCell.self, forCellReuseIdentifier: "HospitalCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ambulans ləğv edilir"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .black
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Zəhmət olmasa gözləyin..."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .darkGray
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let cancelCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let cancelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
        let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()
    
    let viewModel = HospitalMapViewModel()
    let coachMarksController = CoachMarksController()
    private let faceIDController = FaceIDVc()
    private var panelTopConstraint: NSLayoutConstraint!
    private var topPanelTopConstraint: NSLayoutConstraint!
    private var panelHeightConstraint: NSLayoutConstraint!
    private var searchOverlayView: UIView?
    var coordinator: HospitalMapCoordinator?
    private var topPanelHeight: CGFloat { viewModel.expandedHeight - viewModel.halfExpandedHeight }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
        addPanGesture()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.coachMarksController.start(in: .window(over: self))
        }
        NotificationCenter.default.addObserver(self, selector: #selector(showSOSCoachMark), name: Notification.Name("ShowSOSCoachMark"), object: nil)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel.onUpdate = { [weak self] progress, minutes in
            DispatchQueue.main.async {
                self?.progressView.progress = progress
                self?.etaLabel.text = "⏱️Təxmini çatma vaxtı: \(minutes) dq"
                self?.topStatusLabel.text = "Təcili yardım yoldadır • \(minutes) dq"
            }
        }
        viewModel.onDataUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updateAmbulance()
                self?.addHospitalAnnotations()
                self?.tableView.reloadData()
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        authenticateUser()
    }
    private func setupUI() {
        view.backgroundColor = .white
        mapView.delegate = self
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        coachMarksController.dataSource = self
        helpButton.isHidden = true
        view.addSubview(mapView)
        view.addSubview(overlayView)
        view.addSubview(panelView)
        view.addSubview(topPanelView)
        view.addSubview(sosButton)
        view.addSubview(helpButton)
        // 2) panelView içərisi
        panelView.addSubview(destinationButton)
        panelView.addSubview(tableView)
        panelView.addSubview(hospitalListContainer)
        panelView.addSubview(ambulanceStatusContainer)
        // 3) Ambulans status elementləri yalnız ambulanceStatusContainer daxilində
        ambulanceStatusContainer.addSubview(topStatusView)
        topStatusView.addSubview(topStatusLabel)
        ambulanceStatusContainer.addSubview(hospitalNameLabel)
        ambulanceStatusContainer.addSubview(statusContainer)
        statusContainer.addSubview(statusTitleLabel)
        statusContainer.addSubview(etaLabel)
        statusContainer.addSubview(statusLabelsStack)
        statusContainer.addSubview(progressView)
        statusContainer.addSubview(statusTitleLabel)
        statusContainer.addSubview(etaLabel)
        statusContainer.addSubview(progressView)
        statusContainer.addSubview(statusLabelsStack)
        ambulanceStatusContainer.addSubview(warningLabel)
        ambulanceStatusContainer.addSubview(cancelButton)
        // 4) Search panel
        topPanelView.addSubview(panelLabel)
        topPanelView.addSubview(closeButton)
        topPanelView.addSubview(searchBar)
        // 5) Constraint hazırlığı
        panelHeightConstraint = panelView.heightAnchor.constraint(equalToConstant: viewModel.halfExpandedHeight)
        topPanelTopConstraint = topPanelView.topAnchor.constraint(equalTo: view.topAnchor, constant: -topPanelHeight)
        cancelStack.addArrangedSubview(titleLabel)
        cancelStack.addArrangedSubview(subtitleLabel)
        cancelStack.addArrangedSubview(spinner)
        cancelCardView.addSubview(cancelStack)
        // 7. Add to main view and set constraints
        view.addSubview(cancelCardView)
        // 6) Auto Layout
        NSLayoutConstraint.activate([
            // mapView
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: panelView.topAnchor),
            // overlayView
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: panelView.topAnchor),
            // panelView
            panelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            panelView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            panelHeightConstraint,
            // destinationButton & tableView
            destinationButton.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 20),
            destinationButton.leadingAnchor.constraint(equalTo: panelView.leadingAnchor, constant: 10),
            destinationButton.trailingAnchor.constraint(equalTo: panelView.trailingAnchor, constant: -10),
            destinationButton.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: destinationButton.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: panelView.bottomAnchor),
            
            statusLabelsStack.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 4),
            statusLabelsStack.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 12),
            statusLabelsStack.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -12),
            statusLabelsStack.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: -12),
            ambulanceStatusContainer.topAnchor.constraint(equalTo: panelView.topAnchor),
            ambulanceStatusContainer.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            ambulanceStatusContainer.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            ambulanceStatusContainer.bottomAnchor.constraint(equalTo: panelView.bottomAnchor),
            topStatusView.topAnchor.constraint(equalTo: ambulanceStatusContainer.topAnchor),
            topStatusView.leadingAnchor.constraint(equalTo: ambulanceStatusContainer.leadingAnchor),
            topStatusView.trailingAnchor.constraint(equalTo: ambulanceStatusContainer.trailingAnchor),
            topStatusView.heightAnchor.constraint(equalToConstant: 40),
            topStatusLabel.centerXAnchor.constraint(equalTo: topStatusView.centerXAnchor),
            topStatusLabel.centerYAnchor.constraint(equalTo: topStatusView.centerYAnchor),
            hospitalNameLabel.topAnchor.constraint(equalTo: topStatusView.bottomAnchor, constant: 12),
            hospitalNameLabel.leadingAnchor.constraint(equalTo: ambulanceStatusContainer.leadingAnchor, constant: 16),
            statusContainer.topAnchor.constraint(equalTo: hospitalNameLabel.bottomAnchor, constant: 12),
            statusContainer.leadingAnchor.constraint(equalTo: ambulanceStatusContainer.leadingAnchor, constant: 16),
            statusContainer.trailingAnchor.constraint(equalTo: ambulanceStatusContainer.trailingAnchor, constant: -16),
            statusContainer.heightAnchor.constraint(equalToConstant: 100),
            
            statusTitleLabel.topAnchor.constraint(equalTo: statusContainer.topAnchor, constant: 12),
            statusTitleLabel.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 12),
            etaLabel.topAnchor.constraint(equalTo: statusTitleLabel.bottomAnchor, constant: 4),
            etaLabel.leadingAnchor.constraint(equalTo: statusTitleLabel.leadingAnchor),
            
            // — progressView
            progressView.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 12),
            progressView.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -12),
            progressView.topAnchor.constraint(equalTo: etaLabel.bottomAnchor, constant: 8),
            progressView.heightAnchor.constraint(equalToConstant: 10),
            
            // — statusLabelsStack
            statusLabelsStack.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 4),
            statusLabelsStack.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor, constant: 12),
            statusLabelsStack.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor, constant: -12),
            statusLabelsStack.bottomAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: -12),
            
            // cancelButton & warningLabel
            warningLabel.topAnchor.constraint(equalTo: statusContainer.bottomAnchor, constant: 16),
            warningLabel.leadingAnchor.constraint(equalTo: ambulanceStatusContainer.leadingAnchor, constant: 16),
            warningLabel.trailingAnchor.constraint(equalTo: ambulanceStatusContainer.trailingAnchor, constant: -16),
            cancelButton.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 4),
            cancelButton.leadingAnchor.constraint(equalTo: statusContainer.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: statusContainer.trailingAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 64),
            topPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topPanelView.heightAnchor.constraint(equalToConstant: 160),
            topPanelTopConstraint,
            panelLabel.topAnchor.constraint(equalTo: topPanelView.topAnchor, constant: 63),
            panelLabel.centerXAnchor.constraint(equalTo: topPanelView.centerXAnchor),
            searchBar.topAnchor.constraint(equalTo: panelLabel.bottomAnchor, constant: 12),
            searchBar.leadingAnchor.constraint(equalTo: topPanelView.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: topPanelView.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            closeButton.centerYAnchor.constraint(equalTo: panelLabel.centerYAnchor),
            closeButton.trailingAnchor.constraint(equalTo: topPanelView.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 25),
            closeButton.heightAnchor.constraint(equalToConstant: 25),
            sosButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            sosButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            sosButton.widthAnchor.constraint(equalToConstant: 80),
            sosButton.heightAnchor.constraint(equalToConstant: 80),
            cancelCardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelCardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cancelCardView.widthAnchor.constraint(equalToConstant: 225),
            cancelCardView.heightAnchor.constraint(equalToConstant: 130),
            cancelStack.centerXAnchor.constraint(equalTo: cancelCardView.centerXAnchor),
            cancelStack.centerYAnchor.constraint(equalTo: cancelCardView.centerYAnchor),
            helpButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            helpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
      
        view.bringSubviewToFront(sosButton)
        view.bringSubviewToFront(panelView)
        view.bringSubviewToFront(topPanelView)
        topPanelView.bringSubviewToFront(closeButton)
        topPanelView.bringSubviewToFront(searchBar)
        panelView.bringSubviewToFront(panelHandle)
        panelView.bringSubviewToFront(destinationButton)
        panelView.bringSubviewToFront(tableView)
    
}
    func authenticateUser() {
        faceIDController.authenticateUser(success: {
            self.sosButtonTapped()
        }, failure: {
            self.faceIDController.presentAuthFailureAlert()
        })
    }
    
    @objc private func closeButtonTapped() {
        collapsePanels()
    }
    @objc func showSOSCoachMark() {
        sosButton.isHidden = false // Coach mark görünməsi üçün düymə gizlədilməməlidir
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.coachMarksController.start(in: .window(over: self))
        }
    }

    @objc func startSOSCoachMark() {
        sosButton.isHidden = false
        coachMarksController.start(in: .window(over: self))
    }

    
    func addHospitalAnnotations() {
        let existingHospitalAnnotations = mapView.annotations.filter { $0.title != "Ambulans" }
        mapView.removeAnnotations(existingHospitalAnnotations)
        for hospital in viewModel.filteredHospitals {
            let annotation = MKPointAnnotation()
            annotation.title = hospital.name
            annotation.subtitle = hospital.address
            annotation.coordinate = hospital.coordinate
            if viewModel.hospitalLocation == nil {
                viewModel.hospitalLocation = hospital.coordinate
            }
            mapView.addAnnotation(annotation)
        }
    }
    
    private func addPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panelView.addGestureRecognizer(pan)
    }
    
    @objc private func destinationTapped() {
        expandPanels()
    }
    
    private func setupLocationManager() {
        viewModel.locationManager.delegate = self
        viewModel.locationManager.requestWhenInUseAuthorization()
        viewModel.locationManager.startUpdatingLocation()
    }
    
    public func animatePanel(to height: CGFloat) {
        let animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.8) {
            self.panelHeightConstraint.constant = height
            self.panelView.layer.cornerRadius = (height == self.viewModel.expandedHeight) ? 0 : 16
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    @objc func helpButtonTapped() {
        // Yardım səhifəsinə yönləndir və ya popup aç
    }
    @objc func startAmbulanceAnimation() {
        guard viewModel.routeCoordinates.count > 1 else {
            print("Route koordinatları boşdur!")
            return
        }
        resetAnimation()
        viewModel.animationTimer?.invalidate()
        viewModel.segmentStartTime = CACurrentMediaTime()
        viewModel.animationTimer = Timer.scheduledTimer(
            timeInterval: 0.016,
            target: self,
            selector: #selector(updateAmbulance),
            userInfo: nil,
            repeats: true
        )
    }
    func resetAnimation() {
        viewModel.resetAmbulanceAnimation()
        if let first = viewModel.routeCoordinates.first {
            viewModel.ambulanceAnnotation?.coordinate = first
        }
        viewModel.ambulanceAnnotationView?.transform = .identity
    }
    func showCancelAmbulanceAlert(onConfirm: @escaping (String?) -> Void) {
           let alert = UIAlertController(
               title: "Ambulansı ləğv etmək istəyirsiniz?",
               message: "Əgər ləğv etmək istəyirsinizsə, səbəbini qeyd edin.",
               preferredStyle: .alert
           )
           alert.addTextField { textField in
               textField.placeholder = "Səbəbi buraya yazın..."
           }
           alert.addAction(UIAlertAction(title: "İmtina", style: .cancel, handler: nil))
           alert.addAction(UIAlertAction(title: "Ləğv et", style: .destructive, handler: { _ in
               let reason = alert.textFields?.first?.text
               onConfirm(reason)
           }))
           present(alert, animated: true, completion: nil)
       }

    @objc func cancelButtonTapped() {
        showCancelAmbulanceAlert { [weak self] reason in
            guard let self = self else { return }

            // 1. Spiner və mesaj görünür
            self.cancelCardView.isHidden = false
            self.spinner.startAnimating()
            self.spinner.isHidden = false
            self.titleLabel.isHidden = false
           self.subtitleLabel.isHidden = false


            // 2. 1-2 saniyəlik süni gecikmə (spiner görünsün deyə)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                // 3. Əməliyyatlar yerinə yetirilir
                self.viewModel.animationTimer?.invalidate()
                self.viewModel.animationTimer = nil
                self.viewModel.resetAmbulanceAnimation()

                if let ambulanceAnnotation = self.viewModel.ambulanceAnnotation {
                    self.mapView.removeAnnotation(ambulanceAnnotation)
                    self.viewModel.ambulanceAnnotation = nil
                }
                self.removeRoute()
                self.viewModel.hasUserRequestedAmbulance = false
                self.viewModel.selectedHospital = nil
                self.viewModel.hospitalLocation = nil
                self.destinationButton.isHidden = false
                self.tableView.isHidden = false
                self.helpButton.isHidden = true
                self.hospitalListContainer.isHidden = false
                self.ambulanceStatusContainer.isHidden = true
                self.mapView.isUserInteractionEnabled = true
                self.collapsePanels()
                self.sosButton.isHidden = false
                self.addHospitalAnnotations()
                self.tabBarController?.tabBar.isHidden = false
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
                self.titleLabel.isHidden = true
                self.subtitleLabel.isHidden = true
                self.cancelCardView.isHidden = true
                print("İstifadəçi səbəb daxil etdi: \(reason ?? "yoxdur")")
            }
        }
    }
    
    @objc func updateAmbulance() {
        guard let newCoord = viewModel.updateAmbulancePosition() else {
            if let last = viewModel.routeCoordinates.last {
                viewModel.ambulanceAnnotation?.coordinate = last
            }
            viewModel.animationTimer?.invalidate()
            viewModel.animationTimer = nil
            if viewModel.hasUserRequestedAmbulance {
                notifyAmbulanceArrived()
            }
            return
        }
        viewModel.ambulanceAnnotation?.coordinate = newCoord
        let index = viewModel.currentSegmentIndex
        if index + 1 < viewModel.routeCoordinates.count {
            let start = viewModel.routeCoordinates[index]
            let end = viewModel.routeCoordinates[index + 1]
            let bearing = viewModel.calculateBearing(from: start, to: end)
            let angle = CGFloat(bearing * .pi / 180) - .pi / 2
            UIView.animate(withDuration: 0.15) {
                self.viewModel.ambulanceAnnotationView?.transform = CGAffineTransform(rotationAngle: angle)
            }
        }
    }
    func startAmbulanceRequest(for hospital: HospitalModel) {
        hospitalListContainer.isHidden = true
        hospitalNameLabel.text = hospital.name
        ambulanceStatusContainer.isHidden = false
        viewModel.hasUserRequestedAmbulance = true
        startAmbulanceAnimation()
    }
    
    @objc func sosButtonTapped() {
        hospitalListContainer.isHidden = true
        destinationButton.isHidden = true
        sosButton.isHidden = true
        tabBarController?.tabBar.isHidden = true
        tableView.isHidden = true
        
        helpButton.isHidden = false
        print("SOS düyməsi basıldı")
        guard let userCoordinate = mapView.userLocation.location?.coordinate else { return }
        guard viewModel.selectedHospital == nil else {
            print("Paneldən xəstəxana seçilib, SOS aktiv deyil.")
            return
        }
        guard let nearestHospital = viewModel.findNearestHospital(to: userCoordinate) else { return }
        viewModel.prepareAmbulanceRequest(to: nearestHospital)
        viewModel.hospitalLocation = nearestHospital.coordinate
        let ambulanceAnnotation = MKPointAnnotation()
        ambulanceAnnotation.title = "Ambulans"
        ambulanceAnnotation.coordinate = userCoordinate
        mapView.addAnnotation(ambulanceAnnotation)
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let hospLocation = CLLocation(latitude: nearestHospital.coordinate.latitude, longitude: nearestHospital.coordinate.longitude)
        showDistanceOnMap(from: userLocation, to: hospLocation)
        startAmbulanceRequest(for: nearestHospital)
        mapView.isUserInteractionEnabled = false
    }
    
    func showDistanceOnMap(from userLocation: CLLocation, to hospitalLocation: CLLocation) {
        removeRoute()
        let polyline = viewModel.createRoutePolyline(from: hospitalLocation, to: userLocation)
        if viewModel.currentRegion == nil {
            viewModel.currentRegion = mapView.region
        }
        if let region = viewModel.currentRegion {
            mapView.setRegion(region, animated: false)
        }
        mapView.addOverlay(polyline)
        viewModel.currentRoute = polyline
        startAmbulanceAnimation()
    }
    
    func moveAmbulance(to hospital: HospitalModel, userLocation: CLLocation) {
        removeRoute()
        if let ambulanceAnnotation = viewModel.ambulanceAnnotation {
            mapView.removeAnnotation(ambulanceAnnotation)
        }
        let hospitalCoordinate = hospital.coordinate
        viewModel.ambulanceAnnotation = MKPointAnnotation()
        viewModel.ambulanceAnnotation?.coordinate = hospitalCoordinate
        viewModel.ambulanceAnnotation?.title = "Ambulans"
        mapView.addAnnotation(viewModel.ambulanceAnnotation!)
        let regionDistance: CLLocationDistance = 5000
        let regionSpan = MKCoordinateRegion(center: hospitalCoordinate,
                                            latitudinalMeters: regionDistance,
                                            longitudinalMeters: regionDistance)
        mapView.setRegion(regionSpan, animated: true)
    let polyline = viewModel.generateAmbulanceRoute(from: CLLocation(latitude: hospitalCoordinate.latitude,
                                                                     longitude:hospitalCoordinate.longitude),to: userLocation)
        mapView.addOverlay(polyline)
        startAmbulanceAnimation()
    }
    
    func moveAmbulanceRoute(from startLocation: CLLocation, to endLocation: CLLocation) {
        removeRoute()
        let polyline = viewModel.createRoutePolyline(from: startLocation.coordinate, to: endLocation.coordinate)
        mapView.addOverlay(polyline)
        startAmbulanceAnimation()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return createUserLocationAnnotationView(for: annotation, in: mapView)
        }
        guard let pointAnnotation = annotation as? MKPointAnnotation else { return nil }
        if pointAnnotation.title == "Ambulans" {
            return createAmbulanceAnnotationView(for: annotation, in: mapView)
        } else {
            return createHospitalAnnotationView(for: annotation, in: mapView)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            renderer.lineDashPattern = nil
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func removeRoute() {
        if let overlays = mapView.overlays as? [MKPolyline] {
            mapView.removeOverlays(overlays)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
       guard let annotation = view.annotation as? MKPointAnnotation,
         let title = annotation.title else { return }
           if let selectedHospital = viewModel.hospitals.first(where: { $0.name == title }) {
               guard let userLocation = viewModel.locationManager.location else { return }
               coordinator?.showDetail(for: selectedHospital, userLocation: userLocation)
           }
       }
    func openMapForHospital(hospital: HospitalModel) {
        guard let userCoordinate = mapView.userLocation.location?.coordinate else { return }
        viewModel.openMapForHospital(hospital: hospital, userCoordinate: userCoordinate)
    }
}
extension HospitalMapController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.first else { return }
        let region = MKCoordinateRegion(center: userLocation.coordinate,
                                        latitudinalMeters: 5000,
                                        longitudinalMeters: 5000)
        mapView.setRegion(region, animated: true)
        viewModel.searchForHospitals(near: userLocation)
        if let firstHospital = viewModel.filteredHospitals.first {
            viewModel.hospitalLocation = firstHospital.coordinate
            let hospLocation = CLLocation(latitude: firstHospital.coordinate.latitude, longitude: firstHospital.coordinate.longitude)
            showDistanceOnMap(from: userLocation, to: hospLocation)
        }
    }
}
extension HospitalMapController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfHospitals
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HospitalCell", for: indexPath) as! HospitalCell
        let hospital = viewModel.hospital(at: indexPath.row)
        cell.backgroundColor = .white
        cell.configure(name: hospital.name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator?.didSelectHospital(at: indexPath, from: viewModel)
    }

}
extension HospitalMapController: CoachMarksControllerDataSource {
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        guard let sosButton = self.view.subviews.first(where: { $0 is UIButton && $0 == self.sosButton }) as? UIButton else {
            fatalError("SOS button could not be found.")
        }
        var coachMarkView: CoachMark?
        if index == 0 {
            coachMarkView = coachMarksController.helper.makeCoachMark(for: sosButton)
        }
        return coachMarkView ?? coachMarksController.helper.makeCoachMark()
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (any UIView & CoachMarkBodyView), arrowView: (any UIView & CoachMarkArrowView)?) {
        let bodyView = ModernCoachMarkBodyView()
        let arrowView = CoachMarkArrowDefaultView(orientation: coachMark.arrowOrientation!)

        switch index {
        case 0:
            bodyView.hintLabel.text = "Təcili yardım çağırmaq üçün bu SOS düyməsini basın."
        default:
            bodyView.hintLabel.text = "Başlamaq üçün hazırsınız!"
        }
        return (bodyView: bodyView, arrowView: arrowView)
    }
}
extension HospitalMapController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterHospitals(with: searchText)
    }

    func searchBarShouldBeginEditing(_ sb: UISearchBar) -> Bool {
        expandPanels()
        return true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder()
           collapsePanels()
       }
   }
extension HospitalMapController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
          guard scrollView == tableView else { return }
          if viewModel.hasUserRequestedAmbulance { return }
          let offsetY = scrollView.contentOffset.y
          if offsetY > 10 && !viewModel.isPanelExpanded {
              expandPanels()
          }
      }
  }
// MARK: - Panel Handling (Gesture & Animations)
extension HospitalMapController {
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        if viewModel.hasUserRequestedAmbulance && translation.y < 0 {
            gesture.setTranslation(.zero, in: view)
            return
        }
        switch gesture.state {
        case .changed:
            let rawHeight = panelHeightConstraint.constant - translation.y
            panelHeightConstraint.constant = max(
                viewModel.halfExpandedHeight,
                min(viewModel.expandedHeight, rawHeight)
            )
            let progress = (panelHeightConstraint.constant - viewModel.halfExpandedHeight)
                / (viewModel.expandedHeight - viewModel.halfExpandedHeight)
            topPanelTopConstraint.constant = -topPanelHeight + topPanelHeight * progress
            overlayView.alpha = progress
            view.layoutIfNeeded()
        case .ended, .cancelled:
            let velocityY = gesture.velocity(in: view).y
            if velocityY > 500 {
                collapsePanels()
            } else if velocityY < -500 {
                expandPanels()
            } else {
                let threshold = viewModel.halfExpandedHeight +
                    (viewModel.expandedHeight - viewModel.halfExpandedHeight) * 0.3
                panelHeightConstraint.constant < threshold
                    ? collapsePanels()
                    : expandPanels()
            }
        default: break
        }
    }

    private func expandPanels() {
        guard viewModel.hasUserRequestedAmbulance == false else { return }
        viewModel.isPanelExpanded = true
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .allowUserInteraction) {
            self.panelHeightConstraint.constant = self.viewModel.expandedHeight
            self.topPanelTopConstraint.constant = 0
            self.overlayView.alpha = 1
            self.panelHandle.alpha = 0
            self.sosButton.alpha = 0
            self.view.layoutIfNeeded()
        }
    }


    @objc  func collapsePanels() {
        viewModel.isPanelExpanded = false
        UIView.animate(withDuration: 0.5,delay: 0,usingSpringWithDamping: 0.8,initialSpringVelocity: 0.5,
                       options: .allowUserInteraction) {
            self.panelHeightConstraint.constant = self.viewModel.halfExpandedHeight
            self.topPanelTopConstraint.constant = -self.topPanelHeight
            self.overlayView.alpha = 0
            self.panelHandle.alpha = 1
            self.sosButton.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
}
// MARK: - Notifications
extension HospitalMapController {
    private func notifyAmbulanceArrived() {
        NotificationManager.shared.scheduleAmbulanceArrivedNotification()
    }

    private func notifyAmbulanceCancelled() {
        NotificationManager.shared.scheduleAmbulanceCancelledNotification()
    }
}
// MARK: - Annotation View Factory
private extension HospitalMapController {
func createUserLocationAnnotationView(for annotation: MKAnnotation,in mapView: MKMapView) -> MKAnnotationView {
        let id = "userLocationAnnotation"
        let view: MKAnnotationView
        if let dequeued = mapView.dequeueReusableAnnotationView(withIdentifier: id) {
            view = dequeued
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.canShowCallout = false
        }
        view.image = UIImage(named: "u")
        view.layer.zPosition = 1
        return view
    }
    func createHospitalAnnotationView(for annotation: MKAnnotation,in mapView: MKMapView) -> MKAnnotationView {
        let id = "hospitalAnnotation"
        let view: MKAnnotationView
        if let dequeued = mapView.dequeueReusableAnnotationView(withIdentifier: id) {
            view = dequeued
            view.annotation = annotation
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: id)
            view.canShowCallout = true
        }
        if let img = UIImage(named: "c") {
            let size = CGSize(width: 35, height: 35)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            img.draw(in: CGRect(origin: .zero, size: size))
            view.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        } else {
            print("Şəkil 'HospitalMarker' tapılmadı!")
        }
        view.layer.zPosition = 1
        return view
    }
    func createAmbulanceAnnotationView(for annotation: MKAnnotation,in mapView: MKMapView) -> MKAnnotationView {
        let id = "ambulanceAnnotation"
        if let dequeued = mapView.dequeueReusableAnnotationView(withIdentifier: id) {
            dequeued.annotation = annotation
            return dequeued
        }
        let view = MKAnnotationView(annotation: annotation, reuseIdentifier: id)
        view.canShowCallout = false

        if let img = UIImage(named: "Ambulans") {
            let size = CGSize(width: 80, height: 30)
            UIGraphicsBeginImageContextWithOptions(size, false, 0)
            img.draw(in: CGRect(origin: .zero, size: size))
            view.image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        viewModel.ambulanceAnnotationView = view
        view.layer.zPosition = 2
        return view
    }
}
