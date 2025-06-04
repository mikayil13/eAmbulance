//
//  FaceIDVc.swift
//  eAmbulance
//
//  Created by Mikayil on 02.05.25.
//

import UIKit
import LocalAuthentication


class FaceIDVc: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    func authenticateUser(success: @escaping () -> Void, failure: @escaping () -> Void) {
          let context = LAContext()
          var error: NSError?
          
          guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
              failure()
              return
          }
          
          let reason = "Xəritəyə giriş üçün Face ID istifadə edin"
          
          context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { successResult, _ in
              DispatchQueue.main.async {
                  if successResult {
                      success()
                  } else {
                      failure()
                  }
              }
          }
      }
      
      func presentAuthFailureAlert() {
          let alert = UIAlertController(
              title: "Doğrulama alınmadı",
              message: "Face ID ilə giriş mümkün olmadı.",
              preferredStyle: .alert
          )
          alert.addAction(.init(title: "Yenidən cəhd et", style: .default, handler: nil))
          alert.addAction(.init(title: "Çıxış", style: .destructive) { _ in
              exit(0)
          })
          present(alert, animated: true)
      }
}
