//
//  NotificationManager.swift
//  eAmbulance
//
//  Created by Mikayil on 01.05.25.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

   
    func scheduleAmbulanceArrivedNotification() {
        scheduleNotification(
            title: "Ambulans çatdı!",
            body: "Ambulans ünvanınıza çatdı. Xahiş olunur hazır olun."
        )
    }

    func scheduleAmbulanceCancelledNotification() {
        scheduleNotification(
            title: "Ambulans ləğv edildi",
            body: "Ambulans çağırışınız uğurla ləğv edildi."
        )
    }
    private func scheduleNotification(title: String, body: String) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                print("Bildiriş icazəsi yoxdur")
                return
            }

            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default
            content.badge = 1

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Bildiriş xətası: \(error.localizedDescription)")
                } else {
                    print("\(title) bildirişi göndərildi.")
                }
            }
        }
    }
}
