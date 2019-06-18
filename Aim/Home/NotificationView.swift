//
//  NotificationView.swift
//  Aim
//
//  Created by Alexandru Turcanu on 17/06/2019.
//  Copyright © 2019 Alexandru Turcanu. All rights reserved.
//

import UIKit

class NotificationView: UIView {
    // MARK: - Properties
    private let backgroundView: UIView = {
        let view = UIView()

        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()

        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()

        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    // MARK: - Initialziers
    convenience init(title: String, subtitle: String) {
        self.init(frame: CGRect.zero)

        titleLabel.text = title
        subtitleLabel.text = subtitle
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        addSubview(backgroundView)

        backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 24).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 16).isActive = true

        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(subtitleLabel)

        titleLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 8).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 8).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8).isActive = true

        subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 8).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -8).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -8).isActive = true

        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        subtitleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
