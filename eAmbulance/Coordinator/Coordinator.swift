//
//  Coordinator.swift
//  eAmbulance
//
//  Created by Mikayil on 03.05.25.
//

import Foundation
import UIKit
protocol Coordinator {
    var navigationController: UINavigationController { get set }
    func start()
}
