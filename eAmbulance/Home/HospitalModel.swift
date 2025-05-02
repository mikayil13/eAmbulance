//
//  HospitalModel.swift
//  eAmbulance
//
//  Created by Mikayil on 29.04.25.
//

import Foundation
import MapKit
struct HospitalModel {
    var name: String
    var coordinate: CLLocationCoordinate2D
    var address: String
    var distance: Double?
    var region: MKCoordinateRegion?
    var phoneNumber: String?
    var websiteURL: URL?
}
