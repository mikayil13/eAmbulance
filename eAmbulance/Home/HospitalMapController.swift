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
    
    private lazy var sosButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "s"), for: .normal)
        button.addTarget(self, action: #selector(sosButtonTapped), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let panelView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 30
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let panelHandle: UIView = {
        let handle = UIView()
        handle.backgroundColor = UIColor.systemGray3
        handle.layer.cornerRadius = 3
        handle.translatesAutoresizingMaskIntoConstraints = false
        return handle
    }()
    
    private lazy var destinationButton: UIButton = {
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
    
    private let hospitalListContainer: UIView = {
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
    
    private let hospitalNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Xəstəxana Adı"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let ambulanceCountdownLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = .systemGray
        label.text = "Sizin ambulans artıq yola çıxıb. Bu müddət ərzində ilkin tibbi yardımı süni intellekt vasitəsilə əldə edə bilərsiniz."
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let ambulanceStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Tecili Tibbi yardim yoldadir"
        label.textColor = .systemRed
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 1.0
        return label
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
    private var topPanelHeight: CGFloat { viewModel.expandedHeight - viewModel.halfExpandedHeight }
    private lazy var cancelAmbulanceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Ləğv et", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
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
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemGray6
        table.separatorStyle = .none
        table.register(HospitalCell.self, forCellReuseIdentifier: "HospitalCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    let viewModel = HospitalMapViewModel()
    let coachMarksController = CoachMarksController()
    private let faceIDController = FaceIDVc()
    private var panelTopConstraint: NSLayoutConstraint!
    private var topPanelTopConstraint: NSLayoutConstraint!
    private var panelHeightConstraint: NSLayoutConstraint!
    private var searchOverlayView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
        addPanGesture()
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
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.coachMarksController.start(in: .window(over: self))
        }
    }
    private func setupUI() {
        view.backgroundColor = .white
        mapView.delegate = self
        searchBar.delegate = self
        tableView.delegate = self
        coachMarksController.dataSource = self
        tableView.dataSource = self
        view.addSubview(mapView)
        view.addSubview(overlayView)
        view.addSubview(panelView)
        view.addSubview(topPanelView)
        view.addSubview(sosButton)
        topPanelView.addSubview(panelLabel)
        topPanelView.addSubview(closeButton)
        topPanelView.addSubview(searchBar)
        panelView.addSubview(panelHandle)
        panelView.addSubview(destinationButton)
        panelView.addSubview(tableView)
        panelView.addSubview(hospitalListContainer)
        panelView.addSubview(ambulanceStatusContainer)
        ambulanceStatusContainer.addSubview(ambulanceStatusStack)
        ambulanceStatusStack.addArrangedSubview(hospitalNameLabel)
        ambulanceStatusStack.addArrangedSubview(ambulanceCountdownLabel)
        ambulanceStatusContainer.addSubview(ambulanceStatusLabel)
        ambulanceStatusContainer.addSubview(cancelAmbulanceButton)
        panelHeightConstraint = panelView.heightAnchor.constraint(equalToConstant: viewModel.halfExpandedHeight)
        topPanelTopConstraint = topPanelView.topAnchor.constraint(equalTo: view.topAnchor, constant: -topPanelHeight)
        
        NotificationCenter.default.addObserver(self, selector: #selector(startSOSCoachMark), name: Notification.Name("ShowSOSCoachMark"), object: nil)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: panelView.topAnchor),
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: panelView.topAnchor),
            topPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topPanelView.heightAnchor.constraint(equalToConstant: 160),
            topPanelTopConstraint,
            panelLabel.centerXAnchor.constraint(equalTo: topPanelView.centerXAnchor),
            panelLabel.topAnchor.constraint(equalTo: topPanelView.topAnchor, constant: 63),
            searchBar.leadingAnchor.constraint(equalTo: topPanelView.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: topPanelView.trailingAnchor, constant: -16),
            searchBar.topAnchor.constraint(equalTo: panelLabel.bottomAnchor, constant: 12),
            searchBar.heightAnchor.constraint(equalToConstant: 50),
            closeButton.trailingAnchor.constraint(equalTo: topPanelView.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: panelLabel.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 25),
            closeButton.heightAnchor.constraint(equalToConstant: 25),
            panelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            panelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            panelView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            panelHeightConstraint,
            panelHandle.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 8),
            panelHandle.centerXAnchor.constraint(equalTo: panelView.centerXAnchor),
            panelHandle.widthAnchor.constraint(equalToConstant: 40),
            panelHandle.heightAnchor.constraint(equalToConstant: 5),
            destinationButton.topAnchor.constraint(equalTo: panelView.topAnchor, constant: 20),
            destinationButton.leadingAnchor.constraint(equalTo: panelView.leadingAnchor, constant: 10),
            destinationButton.trailingAnchor.constraint(equalTo: panelView.trailingAnchor, constant: -10),
            destinationButton.heightAnchor.constraint(equalToConstant: 50),
            tableView.topAnchor.constraint(equalTo: destinationButton.bottomAnchor, constant: 10),
            tableView.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: panelView.bottomAnchor),
            sosButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            sosButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            sosButton.widthAnchor.constraint(equalToConstant: 80),
            sosButton.heightAnchor.constraint(equalToConstant: 80),
            ambulanceStatusContainer.topAnchor.constraint(equalTo: hospitalListContainer.topAnchor),
            ambulanceStatusContainer.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            ambulanceStatusContainer.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            ambulanceStatusContainer.bottomAnchor.constraint(equalTo: panelView.bottomAnchor),
            ambulanceStatusStack.topAnchor.constraint(equalTo: ambulanceStatusContainer.topAnchor, constant: 20),
            ambulanceStatusStack.leadingAnchor.constraint(equalTo: ambulanceStatusContainer.leadingAnchor, constant: 20),
            ambulanceStatusStack.trailingAnchor.constraint(equalTo: ambulanceStatusContainer.trailingAnchor, constant: -20),
            ambulanceStatusLabel.topAnchor.constraint(equalTo: ambulanceStatusContainer.topAnchor, constant: 20),
            ambulanceStatusLabel.trailingAnchor.constraint(equalTo: ambulanceStatusContainer.trailingAnchor, constant: -20),
            cancelAmbulanceButton.topAnchor.constraint(equalTo: ambulanceStatusStack.bottomAnchor, constant: 20),
            cancelAmbulanceButton.centerXAnchor.constraint(equalTo: ambulanceStatusContainer.centerXAnchor),
            cancelAmbulanceButton.widthAnchor.constraint(equalToConstant: 150),
            cancelAmbulanceButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        [hospitalListContainer, ambulanceStatusContainer].forEach { container in
            container.topAnchor.constraint(equalTo: panelView.topAnchor).isActive = true
            container.bottomAnchor.constraint(equalTo: panelView.bottomAnchor).isActive = true
            container.leadingAnchor.constraint(equalTo: panelView.leadingAnchor).isActive = true
            container.trailingAnchor.constraint(equalTo: panelView.trailingAnchor).isActive = true
        }
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
        sosButton.isHidden = true
        DispatchQueue.main.async {
            self.coachMarksController.start(in: .window(over: self))
        }
    }
    @objc func startSOSCoachMark() {
        sosButton.isHidden = true
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
    func startFlashingTextAnimation() {
        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       options: [.repeat, .autoreverse],
                       animations: {
            self.ambulanceStatusLabel.alpha = 0.2
        }, completion: nil)
    }
    private func setupLocationManager() {
        viewModel.locationManager.delegate = self
        viewModel.locationManager.requestWhenInUseAuthorization()
        viewModel.locationManager.startUpdatingLocation()
    }
    private func animatePanel(to height: CGFloat) {
        let animator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.8) {
            self.panelHeightConstraint.constant = height
            self.panelView.layer.cornerRadius = (height == self.viewModel.expandedHeight) ? 0 : 16
            self.view.layoutIfNeeded()
        }
        animator.startAnimation()
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
    @objc func cancelButtonTapped() {
        viewModel.animationTimer?.invalidate()
        viewModel.animationTimer = nil
        viewModel.resetAmbulanceAnimation()
        notifyAmbulanceCancelled()
        let reversedRouteCoordinates = viewModel.routeCoordinates.reversed()
        viewModel.routeCoordinates = Array(reversedRouteCoordinates)
        startAmbulanceAnimation()
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
        startFlashingTextAnimation()
        viewModel.hasUserRequestedAmbulance = true
        startAmbulanceAnimation()
    }
    @objc func sosButtonTapped() {
        hospitalListContainer.isHidden = true
        destinationButton.isHidden = true
        tableView.isHidden = true
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
            let detailVC = DetailController()
            detailVC.userLocation = userLocation
            detailVC.hospitalDetail = selectedHospital
            detailVC.onAmbulanceRequested = { [weak self] hospital in
                self?.moveAmbulance(to: hospital, userLocation: userLocation)
            }
            let navController = UINavigationController(rootViewController: detailVC)
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                navController.isModalInPresentation = true
            }
            present(navController, animated: true)
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
        let selectedHospital = viewModel.hospital(at: indexPath.row)
        guard let userLocation = viewModel.locationManager.location else { return }
        animatePanel(to: viewModel.halfExpandedHeight)
        
        let hospLocation = CLLocation(latitude: selectedHospital.coordinate.latitude, longitude: selectedHospital.coordinate.longitude)
        showDistanceOnMap(from: userLocation, to: hospLocation)
        let detailVC = DetailController()
        detailVC.userLocation = userLocation
        detailVC.hospitalDetail = selectedHospital
        hospitalListContainer.isHidden = true
        destinationButton.isHidden = true
        tableView.isHidden = true
        collapsePanels()
        detailVC.onAmbulanceRequested = { [weak self] hospital in
            self?.moveAmbulance(to: hospital, userLocation: userLocation)
            self?.startAmbulanceRequest(for: hospital)
        }
        
        let navController = UINavigationController(rootViewController: detailVC)
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            navController.isModalInPresentation = true
        }
        present(navController, animated: true)
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
        gesture.setTranslation(.zero, in: view)

        switch gesture.state {
        case .changed:
            let rawHeight = panelHeightConstraint.constant - translation.y
            panelHeightConstraint.constant = max(viewModel.halfExpandedHeight,
                                                 min(viewModel.expandedHeight, rawHeight))
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
        default:
            break
        }
    }

    private func expandPanels() {
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

    @objc private func collapsePanels() {
        viewModel.isPanelExpanded = false
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
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
