//
//  SettingsViewController.swift
//  Aim
//
//  Created by Alexandru Turcanu on 15/06/2019.
//  Copyright © 2019 Alexandru Turcanu. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: Constant.ImageName.chevron),
            style: .done,
            target: self,
            action: #selector(dismissVC)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor.black

        tableView.layer.cornerRadius = 16
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let percent = max(gesture.translation(in: view).x, 0) / view.frame.width

        switch gesture.state {
        case .ended:
            let velocity = gesture.velocity(in: view).x

            if percent > 0.5 || velocity > 1000 {
                dismiss(animated: true, completion: nil)
            }

        default:
            break
        }
    }

    @objc func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)

        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

        switch indexPath.row {

        case 0:
            cell.textLabel?.text = "Tutorial"
            cell.imageView?.image = UIImage(named: "Book")
            cell.imageView?.tintColor = #colorLiteral(red: 0.3450980392, green: 0.337254902, blue: 0.8392156863, alpha: 1)
        case 1:
            cell.textLabel?.text = "Contact Us"
            cell.imageView?.image = UIImage(named: "Info")
            cell.imageView?.tintColor = #colorLiteral(red: 0.3529411765, green: 0.7843137255, blue: 0.9803921569, alpha: 1)
        case 2:
            cell.textLabel?.text = "About the Developer"
            cell.imageView?.image = UIImage(named: "Man")
            cell.imageView?.tintColor = #colorLiteral(red: 0.3529411765, green: 0.7843137255, blue: 0.9803921569, alpha: 1)
        case 3:
            cell.textLabel?.text = "Rate Envision"
            cell.imageView?.image = UIImage(named: "Star")
            cell.imageView?.tintColor = #colorLiteral(red: 1, green: 0.8, blue: 0, alpha: 1)

//            let imageView = UIImageView(image: UIImage(named: "Chevron"))
//            cell.addSubview(imageView)
//
//            imageView.translatesAutoresizingMaskIntoConstraints = false
//            imageView.topAnchor.constraint(equalTo: cell.textLabel!.bottomAnchor).isActive = true
//            imageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
//            imageView.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true

        default:
            assertionFailure("unknown row")
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {

}
