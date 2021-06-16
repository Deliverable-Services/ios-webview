//
//  MyProductPrescriptionViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 27/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class MyProductPrescriptionViewController: UIViewController, RefreshHandlerProtocol {
  public var refreshControl: UIRefreshControl?
  
  public var refreshScrollView: UIScrollView?
  
  @IBOutlet private weak var tableView: UITableView! {
    didSet {
      tableView.setAutomaticDimension()
      tableView.registerWithNib(MyProductPrescriptionTCell.self)
      tableView.registerWithNib(EmptyNotificationActionTCell.self)
      tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 18.0, right: 0.0)
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  @IBOutlet private weak var headerView: MyProductPrescriptionHeaderView! {
    didSet {
      headerView.viewModel = viewModel
    }
  }
  
  private lazy var viewModel: MyProductPrescriptionViewModelProtocol = MyProductPrescriptionViewModel()

  private lazy var frcHandler = FetchResultsControllerHandler<Prescription>(type: .tableView(tableView))
  
  private var estimatedHeightDict: [String: CGFloat] = [:]
  
  private var hasContent: Bool = true {
    didSet {
      view.backgroundColor = hasContent ? .white: .whiteFive
    }
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    viewModel.initialize()
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    viewModel.initialize()
  }
}

// MARK: - NavigationProtocol
extension MyProductPrescriptionViewController: NavigationProtocol {
}

// MARK: - MyProductsPresenterProtocol
extension MyProductPrescriptionViewController: MyProductsPresenterProtocol {
}

// MARK: - SkinQuizPresenterProtocol
extension MyProductPrescriptionViewController: SkinQuizPresenterProtocol {
}

// MARK: - ControllerProtocol
extension MyProductPrescriptionViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("MyProductPrescriptionViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popOrDismissViewController))
    viewModel.attachView(self)
  }
  
  public func setupObservers() {
    observeRefresh(scrollView: tableView)
  }
}

// MARK: - MyProductPrescriptionView
extension MyProductPrescriptionViewController: MyProductPrescriptionView {
  public func reload() {
    hasContent = viewModel.emptyNotificationActionData == nil
    frcHandler.reload(recipe: viewModel.prescriptionsRecipe)
  }
  
  public func showLoading() {
    if frcHandler.numberOfObjectsInSection(0) == 0 {
      startRefreshing()
    }
  }
  
  public func hideLoading() {
    endRefreshing()
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
  
  public func navigateToShop() {
    appDelegate.mainView.goToTab(.shop)?.getChildController(ShopViewController.self)?.showSection(.products)
  }
  
  public func navigateToMyProducts() {
    showMyProducts()
  }
}

// MARK: - UITableViewDataSource
extension MyProductPrescriptionViewController: UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return frcHandler.numberOfObjectsInSection(section)
    } else {
      return NSNumber(value: viewModel.emptyNotificationActionData != nil).intValue
    }
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let myProductPrescriptionCell = tableView.dequeueReusableCell(MyProductPrescriptionTCell.self, atIndexPath: indexPath)
      myProductPrescriptionCell.prescription = frcHandler.object(at: indexPath)
      if indexPath.row == 0 {
        myProductPrescriptionCell.notes = viewModel.note
        myProductPrescriptionCell.position = .top
      } else if (indexPath.row + 1) == frcHandler.numberOfObjectsInSection(indexPath.section) {
        myProductPrescriptionCell.notes = nil
        myProductPrescriptionCell.position = .bottom
      } else {
        myProductPrescriptionCell.notes = nil
        myProductPrescriptionCell.position = .middle
      }
      return myProductPrescriptionCell
    } else {
      let emptyNotificationActionTCell = tableView.dequeueReusableCell(EmptyNotificationActionTCell.self, atIndexPath: indexPath)
      emptyNotificationActionTCell.emptyNotificationActionData = viewModel.emptyNotificationActionData
      emptyNotificationActionTCell.actionDidTapped = { [weak self] data in
        guard let `self` =  self else { return }
        if data.action == "START SKIN QUIZ" {
          self.showSkinQuiz()
        } else {
          self.viewModel.initialize()
        }
      }
      return emptyNotificationActionTCell
    }
  }
}

// MARK: - UITableViewDelegate
extension MyProductPrescriptionViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return estimatedHeightDict["\(indexPath.row)"] ?? MyProductPrescriptionTCell.defaultSize.height
    } else {
      return max(106.0, tableView.bounds.height - (125.0 * 2))
    }
  }
  
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      estimatedHeightDict["\(indexPath.row)"] = cell.bounds.height
    }
  }
  
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return tableView.rowHeight
    } else {
      return max(106.0, tableView.bounds.height - (125.0 * 2))
    }
  }
  
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard section == 0 else { return nil }
    return headerView
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard section == 0 else { return .leastNonzeroMagnitude }
    return 125.0
  }
}

public protocol MyProductPrescriptionPresenter {
}

extension MyProductPrescriptionPresenter where Self: ControllerProtocol & UIViewController {
  @discardableResult
  public func showMyProductPrescriptions(animated: Bool = true) -> MyProductPrescriptionViewController {
    let myProductPrescriptionViewController = UIStoryboard.get(.projectPorcelain).getController(MyProductPrescriptionViewController.self)
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(myProductPrescriptionViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: myProductPrescriptionViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
    return myProductPrescriptionViewController
  }
}
