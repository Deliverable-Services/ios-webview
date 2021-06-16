//
//  ContactUsViewController.swift
//  Porcelain
//
//  Created by Jean on 6/19/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import Pulley
import KRProgressHUD
import SwiftyJSON

extension ContactUsViewController: NavigationConfigurable { }
class ContactUsViewController: PulleyViewController {
  private enum StoryboardIdentifier: String {
    case embedMap = "ContactUsEmbedMap"
    case embedDrawer = "ContactUsEmbedDrawer"
  }
  
  @IBOutlet var draweContainer: UIView!
  @IBOutlet var mapContainer: UIView!
  
  lazy var handler: ContactUsHandler = {
    let handler = ContactUsHandler()
    handler.delegate = self
    return handler
  }()
  
  var selectedBranch: Branch?
  private var defWebsite: URL?
  private var porcelainBranches: [Branch] = [] {
    didSet {
      guard porcelainBranches.count > 0 else {
        print("no branches")
        return
      }
      (self.primaryContentViewController as? MapViewController)?
        .configure(initBranch: selectedBranch ?? porcelainBranches[0],
                   branches: porcelainBranches,
                   didSelectBranch: { [weak self] (branch) in
          if let strongSelf = self {
            let drawerVC = strongSelf.drawerContentViewController as? ContactUsDrawerViewController
            strongSelf.selectedBranch = branch
            drawerVC?.update(branch, defWebsite: strongSelf.defWebsite)
          }
        }
      )
      
      (self.primaryContentViewController as? ContactUsDrawerViewController)?
        .configure(selectedBranch ?? porcelainBranches[0],
                   defWebsite: defWebsite,
                   toggleDrawer: { [weak self] in
          if let strongSelf = self {
            strongSelf.setDrawerPosition(
              position: strongSelf.drawerPosition == .collapsed ? .partiallyRevealed : .collapsed,
              animated: true)
          }
        }
      )
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    style()
    initDatasource()
  }
  
  public func setDefault(website: URL) {
    defWebsite = website
  }
  
  // MARK: - Private methods
  private func style() {
    mapContainer.translatesAutoresizingMaskIntoConstraints = false
    draweContainer.translatesAutoresizingMaskIntoConstraints = false
    drawerCornerRadius = 0.0
    drawerBackgroundVisualEffectView = nil
    shadowOpacity = 0.0
    
    let navLabel = UILabel()
    let navTitle: NSAttributedString = "CONTACT US"
      .withFont(UIFont.Porcelain.openSans(14.5, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(2)
    
    navLabel.attributedText = navTitle
    self.navigationItem.titleView = navLabel
    
    navigationController?.navigationBar.barTintColor = UIColor.Porcelain.white
    navigationController?.navigationBar.tintColor = UIColor.Porcelain.greyishBrown
    generateLeftNavigationButton(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), selector: #selector(popViewController))
  }
  
  private func initDatasource() {
    KRProgressHUD.showHUD()
    handler.getBranches()
    self.setDrawerPosition(position: .partiallyRevealed, animated: true)
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = StoryboardIdentifier(rawValue: segue.identifier ?? "") else {
      return
    }
    let destVC = segue.destination
    switch identifier {
    case .embedMap: break
    case .embedDrawer:
      let vc = destVC as? ContactUsDrawerViewController
      delegate = vc
    }
  }
}

/****************************************************************/
// MARK: - ContactUsHandlerDelegate
extension ContactUsViewController: ContactUsHandlerDelegate {
  func contactUsHandlerWillStart(_ handler: ContactUsHandler, action: ContactUsAction) {

  }
  
  func contactUsHandlerSuccessful(_ handler: ContactUsHandler, action: ContactUsAction,
                                  response: JSON) {
    print("response \(response)")
    CoreDataUtil.performBackgroundTask({ (moc) in
      guard let theData = response.array?[0].dictionary?["data"]?.arrayValue
        else {
          self.contactUsHandlerDidFail(handler, action: action, error: nil)
          return
      }
      let _ = theData.compactMap({ Branch.object(from: $0, inMOC: moc) })
      
    }) { (_) in
      self.porcelainBranches = CoreDataUtil.list(Branch.self)
      KRProgressHUD.hideHUD()
    }
  }
  
  func contactUsHandlerDidFail(_ handler: ContactUsHandler, action: ContactUsAction,
                               error: Error?) {
    switch action {
    case .getBranches:
      KRProgressHUD.hideHUD()
      self.porcelainBranches = CoreDataUtil.list(Branch.self)
      if porcelainBranches.count == 0 {
        DispatchQueue.main.async() {
          self.displayAlert(title: AppConstant.Text.defaultErrorTitle,
                       message: error?.localizedDescription ?? AppConstant.Text.defaultErrorMessage) { [weak self] (_) in
            if let strongSelf = self { strongSelf.popViewController() }
          }
        }
      }
    }
  }
}
