//
//  SettingsCelll.swift
//  eAmbulance
//
//  Created by Mikayil on 10.06.25.
//

import UIKit

class SettingsCell: UITableViewCell {
    
    private let titleLabel = UILabel()
    private let switchControl = UISwitch()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor =  UIColor(red: 75/255, green: 117/255, blue: 233/255, alpha: 0.03)
        selectionStyle = .none
        layer.borderColor = UIColor(red: 53/255, green: 204/255, blue: 41/255, alpha: 0.165).cgColor
        layer.cornerRadius = 12
        layer.masksToBounds = true

        titleLabel.font = .systemFont(ofSize: 16)
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(switchControl)
        switchControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    func configure(with item: SettingsItem) {
        titleLabel.text = item.title
        switchControl.isHidden = !item.hasSwitch
        accessoryType = item.hasSwitch ? .none : .disclosureIndicator
    }
}
