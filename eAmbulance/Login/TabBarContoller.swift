//
//  TabBarContoller.swift
//  eAmbulance
//
//  Created by Mikayil on 29.04.25.
//

import UIKit
import Instructions

  class TabBarContoller: UITabBarController {

    let coachMarksController = CoachMarksController()
    var hospitalMapCoordinator: HospitalMapCoordinator?

     override func viewDidLoad() {
      super.viewDidLoad()
        setupTabBar()
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
     }

     override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
       DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        self.coachMarksController.start(in: .window(over: self))
    }
}
   
    private func setupTabBar() {
        let mapVC = HospitalMapController()
        let locationNav = createNavController(viewController: mapVC, title: "Xəritə", image: "mappin.and.ellipse")
        let coordinator = HospitalMapCoordinator(navigationController: locationNav)
        mapVC.coordinator = coordinator
        self.hospitalMapCoordinator = coordinator
        let aiVC = createNavController(viewController: AIViewController(), title: "Chat", image: "bubble.left.and.bubble.right.fill")
        let drugScanVC = createNavController(viewController: DrugScanViewController(), title: "Tanınma", image: "camera.viewfinder")
        let settingsVC = createNavController(viewController: SettingsViewController(), title: "Ayarlar", image: "gearshape.fill")
        viewControllers = [locationNav, aiVC, drugScanVC, settingsVC]
        let selectedColor = UIColor(red: 20/255.0, green: 109/255.0, blue: 191/255.0, alpha: 1)
        tabBar.tintColor = selectedColor
        tabBar.backgroundColor = .white
    }
    
    private func createNavController(viewController: UIViewController, title: String, image: String) -> UINavigationController {
        let nav = UINavigationController(rootViewController: viewController)
        nav.tabBarItem.title = title
        let configuration = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
        nav.tabBarItem.image = UIImage(systemName: image, withConfiguration: configuration)
        nav.tabBarItem.selectedImage = UIImage(systemName: image, withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold))
        nav.tabBarItem.imageInsets = UIEdgeInsets(top: -2, left: 0, bottom: 2, right: 0)
        nav.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 6)
        nav.isNavigationBarHidden = false
        return nav
    }
}
extension TabBarContoller: CoachMarksControllerDataSource,CoachMarksControllerDelegate {
func coachMarksController(_ coachMarksController: CoachMarksController, didFinishShowingAndWasSkipped skipped: Bool) {
       NotificationCenter.default.post(name: Notification.Name("ShowSOSCoachMark"), object: nil)
        coachMarksController.stop(immediately: true)
   }
 
func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
    return 4
}

  func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
    let sortedTabBarButtons = self.tabBar.subviews
        .filter { $0 is UIControl }
        .sorted(by: { $0.frame.origin.x < $1.frame.origin.x })
      guard index < sortedTabBarButtons.count else {
        return coachMarksController.helper.makeCoachMark()
    }
    return coachMarksController.helper.makeCoachMark(for: sortedTabBarButtons[index])
}

func coachMarksController(_ coachMarksController: CoachMarksController,coachMarkViewsAt index: Int,madeFrom coachMark: CoachMark
) -> (bodyView: (any UIView & CoachMarkBodyView), arrowView: (any UIView & CoachMarkArrowView)?) {
    
    let bodyView = ModernCoachMarkBodyView()
    let arrowView = CoachMarkArrowDefaultView(orientation: coachMark.arrowOrientation!)
    
    switch index {
    case 0:
        bodyView.hintLabel.text = "Bu düymə ilə Ambulans çağırışı edə bilərsən və ya xəstəxanalar haqqında məlumat əldə edə bilərsən."
    case 1:
        bodyView.hintLabel.text = "Chat funksiyası ilə suallarını soruşa və həkimlə əlaqə qura bilərsən."
    case 2:
        bodyView.hintLabel.text = "Dərman tanınması üçün kameranı aç və dərmanları tanı."
    case 3:
        bodyView.hintLabel.text = "Ayarlar bölməsində profilini yeniləyə bilərsən və tətbiq seçimlərini tənzimləyə bilərsən."
    default:
        bodyView.hintLabel.text = "Hazırsansa başlayaq!"
    }
    return (bodyView: bodyView, arrowView: arrowView)
   }
 }
