//
//  AppInfoTableViewCell.swift
//  Aim
//
//  Created by Alexandru Turcanu on 17/06/2019.
//  Copyright © 2019 Alexandru Turcanu. All rights reserved.
//

import UIKit

class AppInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var buildLabel: UILabel!
    @IBOutlet weak var operatingSystemLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        appIconImageView.image = UIImage(assetIdentifier: .roundedIcon)

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Version \(version)"
        }

        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildLabel.text = "Build \(build)"
        }
        
        operatingSystemLabel.text = "iOS \(UIDevice.current.systemVersion)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
