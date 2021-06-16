//
//  ProductPrescriptionViewController.swift
//  Porcelain Therapist
//
//  Created by Patricia Marie Cesar on 11/12/2018.
//  Copyright © 2018 Augmatics Pte. Ltd. All rights reserved.
//

import Foundation
import KRProgressHUD
import SwiftyJSON
import UIKit

private struct Constant {
  static let barTitle = "PRODUCT PRESCRIPTION".localized()
}

struct ProductPrescriptionCellData {
  var productPrescription: ProductPrescription
}

class ProductPrescriptionViewController: UIViewController, NavigationConfigurable {
  @IBOutlet weak var tableView: UITableView!

  var arrayOfCellData: [ProductPrescriptionCellData]?
  
  private lazy var networkRequest: PorcelainNetworkRequest = {
    let networkRequest = PorcelainNetworkRequest()
    networkRequest.delegate = self
    return networkRequest
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    initializeUIComponents()
    loadData()
  }

  public func loadData() {
    if arrayOfCellData == nil {
      arrayOfCellData = []
    }
    initializeData()
  }

  @objc private func initializeData() {
    if let userID = AppUserDefaults.userID {
      networkRequest.getProductPrescriptions(userID)
    } else {
      assert(false)
    }
  }

  private func initializeUIComponents() {
    self.title = Constant.barTitle
    tableView.tableFooterView = UIView()
    tableView.addRefreshControl(target: self, action: #selector(ProductPrescriptionViewController.initializeData))
    generateLeftNavigationButton(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), selector: #selector(popViewController))
    registerNib()
  }

  private func showLoading() {
    DispatchQueue.main.async {
      if !KRProgressHUD.isVisible { KRProgressHUD.showHUD() }
    }
  }

  private func hideLoading() {
    DispatchQueue.main.async {
      if KRProgressHUD.isVisible { KRProgressHUD.hideHUD() }
      if self.tableView.refreshControl?.isRefreshing ?? false { self.tableView.refreshControl?.endRefreshing() }
    }
  }
  
  func reloadData() {
    if arrayOfCellData == nil {
      initializeData()
    }
    self.tableView.reloadData()
  }
  
  func clearData() {
    arrayOfCellData = nil
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }
  
  private func registerNib() {
    let nibNames = [DefaultEmptyCell.identifier]
    
    for identifier in nibNames {
      let nib = UINib(nibName: identifier, bundle: nil)
      tableView.register(nib, forCellReuseIdentifier: identifier)
    }
  }
}

extension ProductPrescriptionViewController: PorcelainNetworkRequestDelegateProtocol {
  func requestWillStart(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction) {
    guard let action = action as? ProductRequestAction else { return }
    switch action {
    case .getProductPrescriptions: showLoading()
    default: break
    }
  }

  func requestSuccessful(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, result: Any?) {
    hideLoading()

    guard let action = action as? ProductRequestAction else { return }
    switch action {
    case .getProductPrescriptions:
      if let result = result { saveProductPrescription(JSON(result)) }
    default: break
    }

    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }

  func requestDidFail(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, error: Error?, statusCode: Int?, errorMessage: String?) {
    DispatchQueue.main.async {
      self.hideLoading()
      self.displayAlert(title: nil, message: errorMessage, handler: nil)
      self.tableView.reloadData()
    }
  }
}

extension ProductPrescriptionViewController {
  private func saveProductPrescription(_ jsonResult: JSON) {
    arrayOfCellData = []
    if let jsonArray = jsonResult[0].dictionaryValue[PorcelainAPIConstant.Key.data]?.arrayValue {
      arrayOfCellData?.append(contentsOf: jsonArray
        .compactMap({ ProductPrescription.from(json: $0) })
        .compactMap({ ProductPrescriptionCellData(productPrescription: $0) }))
    }
    tableView.reloadData()
  }
}
