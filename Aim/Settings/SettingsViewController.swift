//
//  SettingsViewController.swift
//  Aim
//
//  Created by Alexandru Turcanu on 15/06/2019.
//  Copyright © 2019 Alexandru Turcanu. All rights reserved.
//

import UIKit
import TapticEngine
import MessageUI

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private lazy var bulletinManager = BulletinHelper.bullentinManager(isDismissable: true)

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(assetIdentifier: .chevron),
            style: .done,
            target: self,
            action: #selector(dismissVC)
        )
        navigationItem.leftBarButtonItem?.tintColor = UIColor.label

        tableView.layer.cornerRadius = 16
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)

        view.backgroundColor = UIColor.systemGroupedBackground
        tableView.backgroundColor = UIColor.secondarySystemGroupedBackground
    }

    // MARK: - Methods
    @objc private  func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let percentage = max(gesture.translation(in: view).x, 0) / view.frame.width

        switch gesture.state {
        case .ended:
            let velocity = gesture.velocity(in: view).x

            if percentage > Constant.SwipeGesture.minPercentage ||
                velocity > Constant.SwipeGesture.minVelocity {
                dismissVC()
            }

        default:
            break
        }
    }

    @objc private func dismissVC() {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController as? HabitsViewController {
            rootVC.darkStatusBar = false
            rootVC.setNeedsStatusBarAppearanceUpdate()
        } else {
            fatalError("Could not typecast rootVC to \(String(describing: HabitsViewController.self))")
        }

        TapticEngine.impact.feedback(.light)
        dismiss(animated: true, completion: nil)
    }

    private func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["alexandru.turcanu@icloud.com"])
            mail.setSubject("Feedback Form")
            mail.setMessageBody("<p>Tell us what you like, what you hate, don't be shy!</p> </p> Feedback is the most valuable thing you can give us.", isHTML: true)

            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }

    private func openAppStore() {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1423771095"),
            UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:])
        }
    }

    private func openPersonalWebsite() {
        if let url = URL(string: "https://alexandruturcanu.com"),
            UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:])
        }
    }

    private func openPrivacyPolicy() {
        if let url = URL(string:
            "https://docs.google.com/document/d/1NwS6rD9ZBk5uJLpVGl69tgFCE9Z3pKJr7p8FqXHoNBE/mobilebasic"),
            UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url, options: [:])
        }
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 5,
            let cell = tableView.dequeueReusableCell(withIdentifier: "AppInfo", for: indexPath) as? AppInfoTableViewCell {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            return cell
        }

        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: nil)

        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        cell.backgroundColor = UIColor.secondarySystemGroupedBackground

        switch indexPath.row {

        case 0:
            cell.textLabel?.text = "Tutorial"
            cell.imageView?.image = UIImage(assetIdentifier: .book)
            cell.imageView?.tintColor = UIColor.systemIndigo
        case 1:
            cell.textLabel?.text = "Contact Us"
            cell.imageView?.image = UIImage(assetIdentifier: .mail)
            cell.imageView?.tintColor = UIColor.systemBlue
        case 2:
            cell.textLabel?.text = "About the Developer"
            cell.imageView?.image = UIImage(assetIdentifier: .man)
            cell.imageView?.tintColor = UIColor.systemBlue
        case 3:
            cell.textLabel?.text = "Privacy Policy"
            cell.imageView?.image = UIImage(assetIdentifier: .padlock)
            cell.imageView?.tintColor = UIColor.systemPink
        case 4:
            cell.textLabel?.text = "Rate Envision"
            cell.imageView?.image = UIImage(assetIdentifier: .star)
            cell.imageView?.tintColor = UIColor.systemYellow

        default:
            assertionFailure("unknown row")
        }

        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            bulletinManager.showBulletin(above: self)
        case 1:
            sendEmail()
        case 2:
            openPersonalWebsite()
        case 3:
            openPrivacyPolicy()
        case 4:
            openAppStore()
        case 5:
            return
        default:
            assertionFailure("unknown row")
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
