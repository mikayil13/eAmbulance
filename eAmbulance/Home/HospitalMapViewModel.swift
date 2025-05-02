import Foundation
import MapKit
import CoreLocation

class HospitalMapViewModel {
    var hospitals: [HospitalModel] = []
    var filteredHospitals: [HospitalModel] = []
    var selectedHospital: HospitalModel?
    var onDataUpdated: (() -> Void)?
    var routeCoordinates: [CLLocationCoordinate2D] = []
    var currentSegmentIndex: Int = 0
    var segmentStartTime: TimeInterval = 0
    var hasUserRequestedAmbulance = false
    var hospitalLocation: CLLocationCoordinate2D?
     var currentRoute: MKPolyline?
    var lastRotation: CGFloat = 0
    var ambulanceAnnotationView: MKAnnotationView?
    var animationTimer: Timer?
    var currentRegion: MKCoordinateRegion?
    var ambulanceAnnotation: MKPointAnnotation?
    var lastUserLocation: CLLocation?
     var userAnnotation: MKPointAnnotation?
     var isPanelExpanded = false
     let halfExpandedHeight: CGFloat = UIScreen.main.bounds.height * 0.3
     let expandedHeight: CGFloat = UIScreen.main.bounds.height * 0.9
     let locationManager = CLLocationManager()
    var totalAnimationDuration: TimeInterval = 10.0
    var segmentDuration: TimeInterval {
        totalAnimationDuration / TimeInterval(max(routeCoordinates.count - 1, 1))
    }
    func searchForHospitals(near location: CLLocation) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "hospital"
        request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        let search = MKLocalSearch(request: request)
        
        search.start { [weak self] response, error in
            guard let self = self else { return }
            if let error = error {
                print("Xəstəxana tapılmadı: \(error.localizedDescription)")
                return
            }
            guard let items = response?.mapItems, !items.isEmpty else {
                print("Heç bir xəstəxana tapılmadı")
                return
            }
            self.hospitals = items.compactMap { item in
                guard let name = item.name,
                      let address = item.placemark.title else { return nil }
                let coordinate = item.placemark.coordinate
                return HospitalModel(
                    name: name,
                    coordinate: coordinate,
                    address: address,
                    distance: nil,
                    region: nil,
                    phoneNumber: item.phoneNumber,
                    websiteURL: item.url
                )
            }
            self.filteredHospitals = self.hospitals
            self.onDataUpdated?()
        }
    }
    
    func filterHospitals(with text: String) {
        if text.isEmpty {
            filteredHospitals = hospitals
        } else {
            filteredHospitals = hospitals.filter { $0.name.lowercased().contains(text.lowercased()) }
        }
        onDataUpdated?()
    }
    
    func selectHospital(at index: Int) {
        selectedHospital = filteredHospitals[index]
        onDataUpdated?()
    }
    
    func callAmbulance() {
        guard let selectedHospital = selectedHospital else { return }
        print("Ambulans çağırıldı: \(selectedHospital.name)")
    }
    
    func hospital(at index: Int) -> HospitalModel {
        return filteredHospitals[index]
    }
    
    var numberOfHospitals: Int {
        return filteredHospitals.count
    }
    func updateAmbulancePosition() -> CLLocationCoordinate2D? {
        let now = CACurrentMediaTime()
        let elapsed = now - segmentStartTime
        
        if elapsed >= segmentDuration {
            currentSegmentIndex += 1
            if currentSegmentIndex >= routeCoordinates.count - 1 {
                resetAmbulanceAnimation()
                return routeCoordinates.last
            }
            segmentStartTime = now
        }

        guard currentSegmentIndex + 1 < routeCoordinates.count else {
            return routeCoordinates.last
        }

        let start = routeCoordinates[currentSegmentIndex]
        let end = routeCoordinates[currentSegmentIndex + 1]
        let t = min(elapsed / segmentDuration, 1.0)
        
        let lat = start.latitude + (end.latitude - start.latitude) * t
        let lon = start.longitude + (end.longitude - start.longitude) * t
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }

    func resetAmbulanceAnimation() {
        currentSegmentIndex = 0
        segmentStartTime = CACurrentMediaTime()
    }
    func calculateBearing(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) -> CLLocationDirection {
        let loc1 = CLLocation(latitude: source.latitude, longitude: source.longitude)
        let loc2 = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        return loc1.bearing(to: loc2)
    }
    func openMapForHospital(hospital: HospitalModel, userCoordinate: CLLocationCoordinate2D) {
        let hospLocation = CLLocation(latitude: hospital.coordinate.latitude, longitude: hospital.coordinate.longitude)
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        let regionDistance: CLLocationDistance = 10000
        let centerCoordinate = CLLocationCoordinate2D(latitude: (userLocation.coordinate.latitude + hospLocation.coordinate.latitude) / 2,
                                                      longitude: (userLocation.coordinate.longitude + hospLocation.coordinate.longitude) / 2)
        let regionSpan = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue,
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center)
        ] as [String: Any]
        MKMapItem(placemark: MKPlacemark(coordinate: hospLocation.coordinate)).openInMaps(launchOptions: options)
    }
    func createRoutePolyline(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> MKPolyline {
        routeCoordinates = [start, end]
        return MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
    }
    func generateAmbulanceRoute(from hospital: CLLocation, to user: CLLocation) -> MKPolyline {
        routeCoordinates = [hospital.coordinate, user.coordinate]
        return MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
    }
    func createRoutePolyline(from start: CLLocation, to end: CLLocation) -> MKPolyline {
        routeCoordinates = [start.coordinate, end.coordinate]
        return MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
    }
    func findNearestHospital(to userCoordinate: CLLocationCoordinate2D) -> HospitalModel? {
        let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
        return hospitals.min(by: {
            let loc1 = CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            let loc2 = CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude)
            return loc1.distance(from: userLocation) < loc2.distance(from: userLocation)
        })
    }
    
    func prepareAmbulanceRequest(to hospital: HospitalModel) {
        selectedHospital = hospital
        hasUserRequestedAmbulance = true
    }
    func cancelAmbulanceRequest(currentLocation: CLLocationCoordinate2D, hospitalLocation: CLLocationCoordinate2D) {
        hasUserRequestedAmbulance = false
        
        // Yeni marşrut təyin edilir: Ambulanın indiki mövqeyi ilə xəstəxana arasındakı yol
        routeCoordinates = [currentLocation, hospitalLocation]
        
        // Animasiya müddəti təyin edilir
        totalAnimationDuration = 3.0 // qısa animasiya
        
        // Animasiya sıfırlanır
        resetAmbulanceAnimation()
    }
}
extension CLLocation {
    func bearing(to destinationLocation: CLLocation) -> CLLocationDirection {
        let lat1 = self.coordinate.latitude * .pi / 180
        let lon1 = self.coordinate.longitude * .pi / 180
        let lat2 = destinationLocation.coordinate.latitude * .pi / 180
        let lon2 = destinationLocation.coordinate.longitude * .pi / 180
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let initialBearing = atan2(y, x)
        let bearing = (initialBearing * 180 / .pi + 360).truncatingRemainder(dividingBy: 360)
        return bearing
    }
}

