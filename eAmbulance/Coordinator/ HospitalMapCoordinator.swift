import UIKit
import CoreLocation

class HospitalMapCoordinator: Coordinator {
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let mapVC = HospitalMapController()
        mapVC.coordinator = self
        navigationController.pushViewController(mapVC, animated: false)
    }

    func showDetail(for hospital: HospitalModel, userLocation: CLLocation) {
        let detailVC = DetailController()
        detailVC.hospitalDetail = hospital
        detailVC.userLocation = userLocation

        detailVC.onAmbulanceRequested = { [weak self] hospital in
            guard let mapVC = self?.navigationController.viewControllers.first(where: { $0 is HospitalMapController }) as? HospitalMapController else { return }
            mapVC.moveAmbulance(to: hospital, userLocation: userLocation)
        }

        let navController = UINavigationController(rootViewController: detailVC)
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            navController.isModalInPresentation = true
        }

        navigationController.present(navController, animated: true)
    }
    func didSelectHospital(at indexPath: IndexPath, from viewModel: HospitalMapViewModel) {
        let selectedHospital = viewModel.hospital(at: indexPath.row)
        guard let userLocation = viewModel.locationManager.location else { return }
        guard let mapVC = navigationController.viewControllers
            .compactMap({ $0 as? HospitalMapController }).first else { return }
        mapVC.animatePanel(to: mapVC.viewModel.halfExpandedHeight)
        let hospitalLocation = CLLocation(latitude: selectedHospital.coordinate.latitude,
                                          longitude: selectedHospital.coordinate.longitude)
        mapVC.showDistanceOnMap(from: userLocation, to: hospitalLocation)
        mapVC.hospitalListContainer.isHidden = true
        mapVC.destinationButton.isHidden = true
        mapVC.tableView.isHidden = true
        mapVC.collapsePanels()
        let detailVC = DetailController()
        detailVC.hospitalDetail = selectedHospital
        detailVC.userLocation = userLocation
        detailVC.onAmbulanceRequested = { [weak mapVC] hospital in
            mapVC?.moveAmbulance(to: hospital, userLocation: userLocation)
            mapVC?.startAmbulanceRequest(for: hospital)
        }
        detailVC.onDismiss = { [weak mapVC] ambulanceCalled in
            if !ambulanceCalled {
                DispatchQueue.main.async {
                    mapVC?.tableView.isHidden = false
                    mapVC?.hospitalListContainer.isHidden = false
                    mapVC?.destinationButton.isHidden = false
                }
            }
        }
        let nav = UINavigationController(rootViewController: detailVC)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            nav.isModalInPresentation = true
        }

        navigationController.present(nav, animated: true)
    }

}

