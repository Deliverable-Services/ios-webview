//
//  IndividualPackagesViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 04/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import KRProgressHUD

protocol PackageHolder: class {
  var isActive: Bool { get set }
}

extension IndividualPackagesViewController: PackageHolder { }
class IndividualPackagesViewController: UIViewController {
  private var packages: [Package] = []
  private var treatments: [[CodableTreatment]] = []
  var isActive: Bool = true
  var isFetching: Bool = false
  
  lazy var handler: PackagesHandler = {
    let handler = PackagesHandler()
    handler.delegate = self
    return handler
  }()
  
  @IBOutlet fileprivate  weak var tableView: UITableView! {
    didSet {
      self.tableView.addSubview(self.refreshControl)
    }
  }
  
  lazy private var refreshControl: UIRefreshControl! = {
    let refreshControl = UIRefreshControl()
    refreshControl.tintColor = UIColor.Porcelain.blueGrey
    refreshControl.addTarget(self, action: #selector(AppointmentViewController.reloadData), for: .valueChanged)
    return refreshControl
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setUpUI()
    self.setupDatasource()
    self.reloadData()
  }
  
  private func setupDatasource() {
    var allTrtmnts: [CodableTreatment] = []
    for pckg in packages { allTrtmnts.append(contentsOf: pckg.treatments) }
    var merged: [[CodableTreatment]] = []
    if allTrtmnts.count > 0 { merged = [[allTrtmnts.removeFirst()]] }
    while allTrtmnts.count > 0 {
      let theTrtmnt = allTrtmnts.removeFirst()
      for i in 0..<merged.count {
        if merged[i].first?.id == theTrtmnt.id {
          merged[i].append(theTrtmnt)
          break
        }
        if i == merged.count - 1 { merged.append([theTrtmnt]) }
      }
    }
    treatments = merged
    tableView.reloadData()
    if refreshControl.isRefreshing == true {
      refreshControl.endRefreshing()
    }
    if isActive == true && KRProgressHUD.isVisible && isFetching == false {
      KRProgressHUD.hideHUD()
    }
  }
  
  private func setUpUI() {
    self.navigationController?.navigationBar.barTintColor = UIColor.Porcelain.whiteFour
    self.view.backgroundColor = UIColor.Porcelain.whiteFour
    self.setUpTableViewUI()
  }
  
  private func setUpTableViewUI() {
    self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    self.tableView.rowHeight = PackageCell.estimatedCellHeight
    self.registerNib()
    let uiview = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 15))
    self.tableView.tableHeaderView = uiview
  }
  
  private func registerNib() {
    let nibNames = [PackageCell.identifier, DefaultEmptyCell.identifier]
    
    for identifier in nibNames {
      let nib = UINib(nibName: identifier, bundle: nil)
      tableView.register(nib, forCellReuseIdentifier: identifier)
    }
  }

  @objc func reloadData() {
    self.handler.getExistingPackages()
  }
}

extension IndividualPackagesViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return max(treatments.count, 1)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard treatments.count > 0 else {
      let cell = tableView.dequeueReusableCell(withIdentifier: DefaultEmptyCell.identifier) as! DefaultEmptyCell
      cell.configure(text: "No treatment packages".localized())
      return cell
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: PackageCell.identifier) as! PackageCell
    let treatment = treatments[indexPath.row]
    
    let sum = treatment.reduce(0) { $0 + $1.sessionsLeft }
    let package = packages.first(where: { $0.treatments.contains(where: { $0.id == treatment.first!.id })})
    cell.configure(
      treatmentName: treatment.first!.name,
      sessions: sum,
      expiration: package?.expiryDate,
      isSubgroup: false)
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard !treatments.isEmpty else { return UITableViewAutomaticDimension }
    return tableView.rowHeight
  }
}

/****************************************************************/
// MARK: - PackagesHandlerDelegate
extension IndividualPackagesViewController: PackagesHandlerDelegate {
  func packagesHandlerWillStart(_ handler: PackagesHandler,
                                action: PackagesAction) {
    isFetching = true
    if isActive == true {
      KRProgressHUD.showHUD()
    }
  }
  
  func packagesHandlerSuccessful(_ handler: PackagesHandler,
                                 action: PackagesAction,
                                 response: JSON) {
    isFetching = false
    print("response \(response)")
    guard let theData = response.array?[0].dictionary?["data"],
      let pckgs = try? JSONDecoder().decode([Package].self, from: theData.rawData())
      else {
        packagesHandlerDidFail(handler, action: action, error: nil)
        return
    }
    
    packages = pckgs
    setupDatasource()
  }
  
  func packagesHandlerDidFail(_ handler: PackagesHandler,
                              action: PackagesAction,
                              error: Error?) {
    isFetching = false
    if KRProgressHUD.isVisible {
      KRProgressHUD.hideHUD()
    }
    switch action {
    case .getExistingPackages:
      DispatchQueue.main.async() {
        if self.refreshControl.isRefreshing == true {
          self.refreshControl.endRefreshing()
        }
        self.displayAlert(title: AppConstant.Text.defaultErrorTitle,
                          message: error?.localizedDescription ?? AppConstant.Text.defaultErrorMessage) { [weak self] (_) in
                            if let strongSelf = self { strongSelf.popViewController() }
        }
      }
    }
  }
}
