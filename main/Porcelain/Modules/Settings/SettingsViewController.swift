//
//  SettingsViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 19/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct LogoutButtonAttributedTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 2.0
  }
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat?
  var font: UIFont? {
    return .openSans(style: .semiBold(size: 13.0))
  }
  var color: UIColor? {
    return .coral
  }
}

public final class SettingsViewController: UITableViewController {
  @IBOutlet private weak var pushNotificationsTitleLabel: UILabel! {
    didSet {
      pushNotificationsTitleLabel.font = .idealSans(style: .light(size: 14.0))
      pushNotificationsTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var pushNotificationsSwitch: UISwitch! {
    didSet {
      pushNotificationsSwitch.onTintColor = .lightNavy
      
    }
  }
  @IBOutlet private weak var transactionalEmailTitleLabel: UILabel! {
    didSet {
      transactionalEmailTitleLabel.font = .idealSans(style: .light(size: 14.0))
      transactionalEmailTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var transactionalEmailSwitch: UISwitch! {
    didSet {
      transactionalEmailSwitch.onTintColor = .lightNavy
    }
  }
  @IBOutlet private weak var newsletterPromotionsTitleLabel: UILabel! {
    didSet {
      newsletterPromotionsTitleLabel.font = .idealSans(style: .light(size: 14.0))
      newsletterPromotionsTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var newsletterPromotionsSwitch: UISwitch! {
    didSet {
      newsletterPromotionsSwitch.onTintColor = .lightNavy
    }
  }
  @IBOutlet private weak var phoneCallsTitleLabel: UILabel! {
    didSet {
      phoneCallsTitleLabel.font = .idealSans(style: .light(size: 14.0))
      phoneCallsTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var phoneCallsSwitch: UISwitch! {
    didSet {
      phoneCallsSwitch.onTintColor = .lightNavy
    }
  }
  @IBOutlet private weak var contactUsTitleLabel: UILabel! {
    didSet {
      contactUsTitleLabel.font = .idealSans(style: .light(size: 14.0))
      contactUsTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var contactUsCalloutImageView: UIImageView!
  @IBOutlet private weak var privacyPolicyTitleLabel: UILabel! {
    didSet {
      privacyPolicyTitleLabel.font = .idealSans(style: .light(size: 14.0))
      privacyPolicyTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var versionTitleLabel: UILabel! {
    didSet {
      versionTitleLabel.font = .idealSans(style: .light(size: 14.0))
      versionTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var versionLabel: UILabel! {
    didSet {
      versionLabel.font = .openSans(style: .regular(size: 14.0))
      versionLabel.textColor = .gunmetal
      versionLabel.text = "\(AppUserDefaults.isProduction ? "": "Staging ")\(AppMainInfo.version ?? "") (\(AppMainInfo.build ?? ""))"
    }
  }
  
  @IBOutlet private weak var googleLinkUnlinkButton: GoogleSignInButton!
  @IBOutlet private weak var facebookLinkUnlinkButton: FacebookSignInButton!
  @IBOutlet private weak var logoutButton: UIButton! {
    didSet {
      logoutButton.setAttributedTitle(
        "LOG OUT".attributed.add(.appearance(LogoutButtonAttributedTitleAppearance())),
        for: .normal)
    }
  }
  
  private lazy var viewModel: SettingsViewModelProtocol = SettingsViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  @IBAction private func switchValueChanged(_ sender: UISwitch) {
    if sender == pushNotificationsSwitch {
      viewModel.optPushNotifications = sender.isOn
      viewModel.update()
    } else if sender == transactionalEmailSwitch {
      viewModel.optTransactionalEmail = sender.isOn
      viewModel.update()
    } else if sender == newsletterPromotionsSwitch {
      viewModel.optNewsletter = sender.isOn
      viewModel.update()
    } else if sender == phoneCallsSwitch {
      viewModel.optInPhoneCalls = sender.isOn
      viewModel.update()
    }
  }
  
  @IBAction private func linkUnlinkGoogleTapped(_ sender: Any) {
    if viewModel.isGoogleLinked {
      viewModel.socialUnlink(type: .google)
    } else {
      viewModel.socialLink(type: .google)
    }
  }
  
  @IBAction private func linkUnlinkFacebookTapped(_ sender: Any) {
    if viewModel.isFacebookLinked {
      viewModel.socialUnlink(type: .facebook)
    } else {
      viewModel.socialLink(type: .facebook)
    }
  }
  
  @IBAction private func logoutTapped(_ sender: Any) {
    let actionSheetViewController = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
    actionSheetViewController.addAction(UIAlertAction(title: "LOG OUT", style: .destructive, handler: { (_) in
      appDelegate.logout()
    }))
    actionSheetViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
    }))
    present(actionSheetViewController, animated: true, completion: nil)
  }
}

// MARK: - NavigationProtocol
extension SettingsViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension SettingsViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    return "showSettings"
  }
  
  public func setupUI() {
    tableView.separatorStyle = .singleLine
    tableView.separatorInset = .zero
    tableView.separatorColor = .whiteFour
    tableView.setAutomaticDimension()
    view.backgroundColor = .whiteFive
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popOrDismissViewController))
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
  }
}

// MARK: - SettingsView
extension SettingsViewController: SettingsView {
  public func reload() {
    phoneCallsSwitch.isOn = viewModel.optInPhoneCalls
    pushNotificationsSwitch.isOn = viewModel.optPushNotifications
    transactionalEmailSwitch.isOn = viewModel.optTransactionalEmail
    newsletterPromotionsSwitch.isOn = viewModel.optNewsletter
    if AppConfiguration.enableSocialLogin {
      googleLinkUnlinkButton.isHidden = false
      googleLinkUnlinkButton.title = viewModel.isGoogleLinked ? "Unlink from Google": "Connect with Google"
      facebookLinkUnlinkButton.isHidden = false
      facebookLinkUnlinkButton.title = viewModel.isFacebookLinked ? "Unlink from Facebook": "Connect with Facebook"
    } else {
      googleLinkUnlinkButton.isHidden = true
      facebookLinkUnlinkButton.isHidden = true
    }
  }
  
  public func showLoading() {
    appDelegate.showLoading()
  }
  
  public func hideLoading() {
    appDelegate.hideLoading()
  }
  
  public func showSuccess(message: String?) {
    showAlert(title: nil, message: message)
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
}

// MARK: - ContactUsPresenterProtocol
extension SettingsViewController: ContactUsPresenterProtocol {
}

// MARK: - UITableViewDelegate
extension SettingsViewController {
  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if indexPath.section == 1 {
      switch indexPath.row {
      case 0://contact us
        showContactUs()
      case 1:
        UIApplication.shared.inAppSafariOpen(url: AppConstant.privacyURL)
      default: break
      }
    }
  }

  public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let marginLabel = MarginLabel()
    switch section {
    case 1:
      marginLabel.edgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
      marginLabel.font = .openSans(style: .regular(size: 13.0))
      marginLabel.textColor = .bluishGrey
      marginLabel.text = "SUPPORT"
    default:
      marginLabel.text = nil
    }
    return marginLabel
  }
  
  public override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }
  
  public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
    case 0:
      return 24.0
    case 1:
      return 36.0
    default:
      return .leastNonzeroMagnitude
    }
  }
  
  public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 24.0
  }
}

public protocol SettingsPresenterProtocol {
}

extension SettingsPresenterProtocol where Self: ControllerProtocol & UIViewController {
  @discardableResult
  public func showSettings(animated: Bool = true) -> SettingsViewController {
    let settingsViewController = UIStoryboard.get(.settings).getController(SettingsViewController.self)
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(settingsViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: settingsViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
    return settingsViewController
  }
}
