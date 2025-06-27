//
//   SettingsItem.swift
//  eAmbulance
//
//  Created by Mikayil on 09.06.25.
//

import Foundation
struct SettingsItem {
    let title: String
    let hasSwitch: Bool
}

struct SettingsSection {
    let title: String? // "Daha çox" kimi başlıqlar üçün
    let items: [SettingsItem]
}

struct SettingsDataProvider {
    static let sections: [SettingsSection] = [
        SettingsSection(title: nil, items: [
            SettingsItem(title: "Şəxsi məlumatlarım", hasSwitch: false),
            SettingsItem(title: "Smart saat", hasSwitch: true),
            SettingsItem(title: "Face ID", hasSwitch: true),
            SettingsItem(title: "Gizlilik & Şərtlər", hasSwitch: false)
        ]),
        SettingsSection(title: "Daha çox", items: [
            SettingsItem(title: "Yardım & Dəstək", hasSwitch: false),
            SettingsItem(title: "Haqqımızda", hasSwitch: false)
        ])
    ]
}
