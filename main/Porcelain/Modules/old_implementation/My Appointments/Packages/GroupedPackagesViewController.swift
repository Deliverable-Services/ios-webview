//
//  GroupedPackagesViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 05/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import UIKit
import LUExpandableTableView
import KRProgressHUD
import SwiftyJSON

extension GroupedPackagesViewController: PackageHolder { }
class GroupedPackagesViewController: UIViewController {
  @IBOutlet fileprivate weak var tableView: LUExpandableTableView! {
    didSet {
      self.tableView.addSubview(self.refreshControl)
    }
  }
  
  var isActive = false
  
  lazy var handler: PackagesHandler = {
    let handler = PackagesHandler()
    handler.delegate = self
    return handler
  }()
  
  lazy private var refreshControl: UIRefreshControl! = {
    let refreshControl = UIRefreshControl()
    refreshControl.tintColor = UIColor.Porcelain.blueGrey
    refreshControl.addTarget(self, action: #selector(AppointmentViewController.reloadData), for: .valueChanged)
    return refreshControl
  }()
  
  var packages: [Package] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setUpUI()
    self.handler.getExistingPackages()
  }
  
  // MARK: - Private methods
  private func setUpUI() {
    self.navigationController?.navigationBar.barTintColor = UIColor.Porcelain.whiteFour
    self.view.backgroundColor = UIColor.Porcelain.whiteFour
    self.setUpTableViewUI()
    self.addBarButtonItems()
    self.view.backgroundColor = UIColor.Porcelain.white
  }
  
  private func setUpTableViewUI() {
    self.tableView.tableFooterView = UIView()
    self.tableView.rowHeight = PackageCell.estimatedCellHeight
    self.tableView.sectionFooterHeight = 1.0
    self.tableView.estimatedSectionFooterHeight = 1.0
    self.tableView.backgroundColor = UIColor.Porcelain.white
    self.tableView.separatorStyle = .none
    self.tableView.expandableTableViewDataSource = self
    self.tableView.expandableTableViewDelegate = self
    self.registerNib()
    
    let uiview = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 15))
    self.tableView.tableHeaderView = uiview
  }
  
  private func registerNib() {
    let nibNames = [PackageCell.identifier]
    
    for identifier in nibNames {
      let nib = UINib(nibName: identifier, bundle: nil)
      tableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    tableView.register(UINib(nibName: PackageCellHeader.identifier,
                             bundle: Bundle.main),
                       forHeaderFooterViewReuseIdentifier: PackageCellHeader.identifier)
    tableView.register(UINib(nibName: PackageEmptyCell.identifier,
                             bundle: Bundle.main),
                       forHeaderFooterViewReuseIdentifier: PackageEmptyCell.identifier)
  }
  
  private func addBarButtonItems() {
    let dashboardBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "home").withRenderingMode(.alwaysOriginal),
                                                 style: .plain, target: self,
                                                 action: #selector(AppointmentViewController.popViewController))
    let historyBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "history").withRenderingMode(.alwaysOriginal),
                                               style: .plain, target: self,
                                               action: #selector(AppointmentViewController.goToTreatmentHistoryScreen))
    let layersBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "layers").withRenderingMode(.alwaysOriginal),
                                              style: .plain, target: self,
                                              action: #selector(AppointmentViewController.goToPackagesScreen))
    self.navigationItem.leftBarButtonItem = dashboardBarButtonItem
    self.navigationItem.rightBarButtonItems = [layersBarButtonItem, historyBarButtonItem]
  }
  
  // MARK: - Action methods
  @objc func reloadData() {
    self.handler.getExistingPackages()
  }
}

extension GroupedPackagesViewController: LUExpandableTableViewDataSource {
  func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
    return max(packages.count, 1)
  }
  
  func expandableTableView(_ expandableTableView: LUExpandableTableView,
                           numberOfRowsInSection section: Int) -> Int {
    return packages[section].treatments.count
  }
  
  func expandableTableView(_ expandableTableView: LUExpandableTableView,
                           cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: PackageCell.identifier) as! PackageCell
    let data = packages[indexPath.section]
      cell.configure(treatmentName: data.treatments[indexPath.row].name,
                     sessions: data.treatments[indexPath.row].sessionsLeft,
                     expiration: data.expiryDate,
                     isSubgroup: true)
    if indexPath.section == packages.count - 1 &&
        indexPath.row == data.treatments.count - 1 &&
        data.opened == true {
      cell.roundBottom()
    } else {
      cell.removeRound()
    }
    cell.selectionStyle = .none
    return cell
  }
  
  func expandableTableView(_ expandableTableView: LUExpandableTableView,
                           sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
    guard packages.count > 0 else {
      let cell = expandableTableView.dequeueReusableHeaderFooterView(withIdentifier: PackageEmptyCell.identifier) as! PackageEmptyCell
      cell.configure(text: "No treatment packages".localized())
      return cell
    }
    
    let cell = expandableTableView.dequeueReusableHeaderFooterView(withIdentifier: PackageCellHeader.identifier) as! PackageCellHeader
    let data = packages[section]
    if data.group == nil {
      cell.configure(data.treatments.first!.name,
                     "x\(data.treatments.first!.sessionsLeft)",
        toggable: false)
    } else {
      cell.configure(data.group!, "", toggable: true)
    }
    
    if section == 0 { cell.roundTop() }
    else if section == numberOfSections(in: expandableTableView) - 1 &&
      data.opened == false { cell.roundBottom() }
    else {
      cell.removeRound()
      
    }
    return cell
  }
}

extension GroupedPackagesViewController: LUExpandableTableViewDelegate {
  func expandableTableView(_ expandableTableView: LUExpandableTableView,
                           heightForRowAt indexPath: IndexPath) -> CGFloat {
    return tableView.rowHeight
  }
  
  func expandableTableView(_ expandableTableView: LUExpandableTableView,
                           heightForHeaderInSection section: Int) -> CGFloat {
    guard packages.count > 0 else { return UITableViewAutomaticDimension }
    return 56.0
  }
}

/****************************************************************/
// MARK: - PackagesHandlerDelegate
extension GroupedPackagesViewController: PackagesHandlerDelegate {
  func packagesHandlerWillStart(_ handler: PackagesHandler,
                                action: PackagesAction) {
    if isActive == true {
      KRProgressHUD.showHUD()
    }
  }
  
  func packagesHandlerSuccessful(_ handler: PackagesHandler,
                                 action: PackagesAction,
                                 response: JSON) {
    if isActive == true {
      KRProgressHUD.hideHUD()
    }
    if self.refreshControl.isRefreshing == true {
      self.refreshControl.endRefreshing()
    }
    
    DispatchQueue.main.async() {
      print("response \(response)")
      guard let theData = response.array?[0].dictionary?["data"],
        let pckgs = try? JSONDecoder().decode([Package].self, from: theData.rawData())
        else {
          self.packagesHandlerDidFail(handler, action: action, error: nil)
          return
      }
      
      self.packages = pckgs
      self.tableView.reloadData()
    }
  }
  
  func packagesHandlerDidFail(_ handler: PackagesHandler,
                              action: PackagesAction,
                              error: Error?) {
    switch action {
    case .getExistingPackages:
      DispatchQueue.main.async() {
        if self.isActive == true {
          KRProgressHUD.hideHUD()
        }
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
