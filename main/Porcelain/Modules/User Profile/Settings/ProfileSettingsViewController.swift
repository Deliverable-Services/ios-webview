//
//  ProfileSettingsViewController.swift
//  Porcelain
//
//  Created by Jean on 6/16/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import SwiftyAttributes

struct ProfileSwitchSettings {
  var isSubbedToNotifications = false
  var isSubbedToEmailOpt = false
  var isSubbedToNewsLetter = false
}

class ProfileSettingsViewController: UITableViewController, NavigationConfigurable {
  var currentUser: User!
  var profileSwitchSettings = ProfileSwitchSettings()
  
  private var profileSettings: [[ProfileSetting]] {
    get {
      if AppConfiguration.profileUI_usePhase1 == true {
        return [
          [ProfileSetting(.contactUs),
            ProfileSetting(.privacyPolicy),
            ProfileSetting(.version,
                           type: .detail("\(AppConstant.VersionInfo.version) (\(AppConstant.VersionInfo.build))"))],
          [ProfileSetting(.logout)
          ]
        ]
      } else {
        return [
          [ProfileSetting(.pushNotifications, type: .boolean(currentUser.isSubbedToNotifications)),
           ProfileSetting(.transactionalEmail, type: .boolean(currentUser.isSubbedToEmailOpt)),
           ProfileSetting(.newsletter, type: .boolean(currentUser.isSubbedToNewsLetter))],
          [ProfileSetting(.contactUs),
            ProfileSetting(.privacyPolicy),
            ProfileSetting(.version, type: .detail("\(AppConstant.VersionInfo.version) (\(AppConstant.VersionInfo.build))"))],
          [ProfileSetting(.logout)
          ]
        ]
      }
    }
  }
  
  fileprivate lazy var networkRequest: PorcelainNetworkRequest = {
    var request = PorcelainNetworkRequest()
    request.delegate = self
    return request
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    registerCells()
    style()
    
  }
  
  private func registerCells() {
    tableView.register(UINib(nibName: SettingsDetailCell.identifier,
                             bundle: nil), forCellReuseIdentifier: SettingsDetailCell.identifier)
    tableView.register(UINib(nibName: SettingsSwitchCell.identifier,
                             bundle: nil), forCellReuseIdentifier: SettingsSwitchCell.identifier)
    tableView.register(UINib(nibName: SettingsDetailIndicatorCell.identifier,
                             bundle: nil), forCellReuseIdentifier: SettingsDetailIndicatorCell.identifier)
  }
  
  private func style() {
    tableView.showsVerticalScrollIndicator = false
    tableView.tableFooterView = UIView()
    tableView.separatorColor = UIColor.Porcelain.greySeparator
    tableView.separatorInset = .zero
    tableView.backgroundColor = UIColor.Porcelain.white
    
    navigationController?.navigationBar.tintColor = UIColor.Porcelain.greyishBrown
    generateLeftNavigationButton(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), selector: #selector(popViewController))
    
    let navLabel = UILabel()
    let navTitle: NSAttributedString = "SETTINGS"
      .withFont(UIFont.Porcelain.openSans(14.5, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(2)
    
    navLabel.attributedText = navTitle
    self.navigationItem.titleView = navLabel
  }
  
  private func logout() {
    let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out of Porcelain?", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { (_) in
      AppDelegate.logout()
      AppNotificationCenter.default.post(name: AppNotificationNames.appointmentsDidChange, object: nil)
      appDelegate.mainViewController.dismissViewController()
//      self.view.window?.rootViewController?.dismissViewController()
//      let mainStoryboard: UIStoryboard? = UIStoryboard.get(.main)
//      let vc: UIViewController = (mainStoryboard?.instantiateInitialViewController())!
//      self.view.window?.rootViewController = vc
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    
    self.present(alert, animated: true)
  }
}

// MARK: - Datasource
extension ProfileSettingsViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return profileSettings.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return profileSettings[section].count
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == (AppConfiguration.profileUI_usePhase1 == true ? 0 : 1) {
      let sectionView = tableView.dequeueReusableCell(withIdentifier: SettingsDetailCell.identifier) as! SettingsDetailCell
      sectionView.backgroundColor = UIColor.Porcelain.white
      sectionView.title.attributedText = "Support"
        .withFont(UIFont.Porcelain.idealSans(18))
        .withTextColor(UIColor.Porcelain.greyishBrown)
        .withKern(0.5)
      sectionView.detail.isHidden = true
      return sectionView
    }
    return nil
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section == (AppConfiguration.profileUI_usePhase1 == true ? 0 : 1) ? 55 : 15
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let setting = profileSettings[indexPath.section][indexPath.row]
    switch setting.type {
    case .basic:
      let cell = tableView.dequeueReusableCell(withIdentifier: SettingsDetailCell.identifier) as! SettingsDetailCell
      cell.title.text = setting.name.rawValue
      cell.detail.isHidden = true
      return cell
    case let .detail(detailStr):
      let cell = tableView.dequeueReusableCell(withIdentifier: SettingsDetailCell.identifier) as! SettingsDetailCell
      cell.title.text = setting.name.rawValue
      cell.detail.text = detailStr
      return cell
    case let .detailIndicator(detailStr):
      let cell = tableView.dequeueReusableCell(withIdentifier: SettingsDetailIndicatorCell.identifier) as! SettingsDetailIndicatorCell
      cell.title.text = setting.name.rawValue
      cell.detail.text = detailStr
      return cell
    case let .boolean(isOn):
      let cell = tableView.dequeueReusableCell(withIdentifier: SettingsSwitchCell.identifier) as! SettingsSwitchCell
      cell.title.text = setting.name.rawValue
      cell.cellSwitch.isOn = isOn
      cell.delegate = self
      if indexPath.section == 0 { cell.setTag(indexPath.row) }
      return cell
    }
  }
}

// MARK: - Tableview Delegate
extension ProfileSettingsViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let setting = profileSettings[indexPath.section][indexPath.row]
    switch setting.name {
    case .reviews: navigate(.toReviews)
    case .contactUs: navigate(.toContactUs)
    case .privacyPolicy: navigate(.toPrivacyPolicy)
    case .logout: logout()
    default: break
    }
  }
}

// MARK: - Cell delegates
extension ProfileSettingsViewController: SettingsSwitchCellDelegate {
  func didChange(_ on: Bool, tag: Int) {
    guard let theTag = SwitchSetting(rawValue: tag) else { return }
    switch theTag {
    case .notifications:
      networkRequest.updateNotifications(on: on)
      profileSwitchSettings.isSubbedToNotifications = on
      print("did change notifications to \(on)")
    case .emailOpt:
      print("did change emailOpt to \(on)")
      networkRequest.updateTransEmail(on: on)
      profileSwitchSettings.isSubbedToEmailOpt = on
    case .newsletter:
      networkRequest.updateMarketingEmail(on: on)
      profileSwitchSettings.isSubbedToNewsLetter = on
      print("did change newsletter to \(on)")
    }
  }
}

/****************************************************************/

private enum StoryboardIdentifier: String {
  case toReviews = "ProfileSettingsToReviews"
  case toContactUs = "ProfileSettingsToContactUs"
  case toPrivacyPolicy = "ProfileSettingsToPrivacyPolicy"
}

extension ProfileSettingsViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = StoryboardIdentifier(rawValue: segue.identifier ?? "") else {
      return
    }
    var destinationVC: UIViewController? = segue.destination
    if let navigationVC = segue.destination as? UINavigationController {
      destinationVC = navigationVC.childViewControllers.first
    }
    
    switch identifier {
//    case .toContactUs:
//      guard let dvc = destinationVC as? ContactUsViewController else { return }
//      dvc.setDefault(website: URL(string: "http://porcelainfacespa.com")!)
    default: break
    }
  }
  
  fileprivate func navigate(_ identifier: StoryboardIdentifier) {
    DispatchQueue.main.async {
      self.performSegue(withIdentifier: identifier.rawValue, sender: nil)
    }
  }
}

extension ProfileSettingsViewController: PorcelainNetworkRequestDelegateProtocol {
  func requestWillStart(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction) {
    
  }
  
  func requestDidFail(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, error: Error?, statusCode: Int?, errorMessage: String?) {
    
  }
  
  func requestSuccessful(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, result: Any?) {
    switch action as! ProfileRequestAction {
    case .updateNotifications:
      currentUser.isSubbedToNotifications =  profileSwitchSettings.isSubbedToNotifications
    case .updateMarketingEmail:
      currentUser.isSubbedToNewsLetter = profileSwitchSettings.isSubbedToNewsLetter
    case .updateTransEmail:
      currentUser.isSubbedToEmailOpt = profileSwitchSettings.isSubbedToEmailOpt
    default: break
    }
  }
}
