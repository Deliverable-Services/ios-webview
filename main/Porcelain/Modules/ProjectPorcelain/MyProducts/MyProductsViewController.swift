//
//  MyProductsViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 27/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import R4pidKit

public final class MyProductsViewController: UIViewController, EmptyNotificationActionIndicatorProtocol {
  public var emptyNotificationActionView: EmptyNotificationActionView? {
    didSet {
      emptyNotificationActionView?.backgroundColor = .whiteFive
    }
  }
  
  @IBOutlet private weak var collectionView: CenteredCollectionView! {
    didSet {
      collectionView.registerWithNib(MyProductsCell.self)
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  
  private lazy var frcHandler = FetchResultsControllerHandler<CustomerProduct>(type: .collectionView(collectionView))
  
  public var emptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let emptyNotificationActionData = emptyNotificationActionData  {
        showEmptyNotificationActionOnView(view, type: .centered(data: emptyNotificationActionData))
      } else {
        hideEmptyNotificationAction()
      }
    }
  }
  
  private lazy var viewModel: MyProductsViewModelProtocol = MyProductsViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setNavigationTheme(.white)
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
    appDelegate.mainView.goToTab(.shop)?.getChildController(ShopViewController.self)?.showSection(.products)
  }
}

// MARK: - NavigationProtocol
extension MyProductsViewController: NavigationProtocol {
}

// MARK: - MakeReviewPresenterProtocol
extension MyProductsViewController: MakeReviewPresenterProtocol {
}

// MARK: - MyProductRemovePresenterProtocol
extension MyProductsViewController: MyProductRemovePresenterProtocol {
}

// MARK: - MyProductCompletionPresenterProtocol
extension MyProductsViewController: MyProductCompletionPresenterProtocol {
}

// MARK: - ShopCartPresenterProtocol
extension MyProductsViewController: ShopCartPresenterProtocol {
}

// MARK: - ProductViewPresenterProtocol
extension MyProductsViewController: ProductViewPresenterProtocol {
}

// MARK: - ControllerProtocol
extension MyProductsViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("MyProductsViewController segueIdentifier not set")
  }
  
  public func setupUI() {
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

// MARK: - MyProductsView
extension MyProductsViewController: MyProductsView {
  public func reload() {
    frcHandler.reload(recipe: viewModel.myProductsRecipe)
  }
  
  public func showLoading() {
    if frcHandler.numberOfObjectsInSection(0) == 0 {
      appDelegate.showLoading()
    }
  }
  
  public func hideLoading() {
    appDelegate.hideLoading()
    collectionView.isHidden = viewModel.emptyNotificationActionData != nil
    emptyNotificationActionData = viewModel.emptyNotificationActionData
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
}

// MARK: - UICollectionViewDataSource
extension MyProductsViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return frcHandler.numberOfObjectsInSection(section)
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let myProductsCell = collectionView.dequeueReusableCell(MyProductsCell.self, atIndexPath: indexPath)
    myProductsCell.product = frcHandler.object(at: indexPath)
    myProductsCell.didRemoveProductQuantity = { [weak self] (product, quantity) in
      guard let `self` = self else { return }
      self.showMyProductRemove(data: MyProductRemoveData(product: product, removeQuantity: quantity))
    }
    myProductsCell.doneDidTapped = { [weak self] (productID) in
      guard let `self` = self else { return }
      self.showMyProductCompletion(productID: productID)
    }
    myProductsCell.replenishDidTapped = { [weak self] (productID) in
      guard let `self` = self else { return }
      if let product = Product.getProduct(id: productID) {
        self.showProductView(product: product)
      } else {
        appDelegate.showLoading()
        PPAPIService.getProducts().call { (response) in
          switch response {
          case .success(let result):
            CoreDataUtil.performBackgroundTask({ (moc) in
              result.data.arrayValue.forEach { (data) in
                guard let category = data.name.string else { return }
                Product.parseProductsFromData(data.products, category: category, inMOC: moc)
              }
            }, completion: { (_) in
              appDelegate.hideLoading()
              if let product = Product.getProduct(id: productID) {
                self.showProductView(product: product)
              } else {
                self.showError(message: "Product not available.")
              }
            })
          case .failure(let error):
            appDelegate.hideLoading()
            self.showError(message: error.localizedDescription)
          }
        }
      }
    }
    myProductsCell.leaveAReviewDidTapped = { [weak self] (product) in
      guard let `self` = self else { return }
      self.showMakeReview(type: .customerProductReview(product: product))
    }
    return myProductsCell
  }
}

// MARK: - UICollectionViewDelegate
extension MyProductsViewController: UICollectionViewDelegate {
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyProductsViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    var size = collectionView.bounds.size
    size.width = max(0.0, size.width - 76.0)
    size.height = max(0.0, size.height - 48.0)
    return size
  }
}

public protocol  MyProductsPresenterProtocol {
}

extension MyProductsPresenterProtocol where Self: ControllerProtocol & UIViewController {
  @discardableResult
  public func showMyProducts(animated: Bool = true) -> MyProductsViewController {
    let myProductsViewController = UIStoryboard.get(.projectPorcelain).getController(MyProductsViewController.self)
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(myProductsViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: myProductsViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
    return myProductsViewController
  }
}
