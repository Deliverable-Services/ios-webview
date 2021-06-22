//
//  MyProductsViewModel.swift
//  Porcelain
//
//  Created by Justine Rangel on 14/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation

public protocol MyProductsView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func scrollToIndex(_ index: Int)
  func goToProducts()
}

public protocol MyProductsViewModelProtocol: MyProductsSegmentedViewModelProtocol, MyEmptyProductsViewModelProtocol {
  var products: [MyProductsItemViewModel] { get set }
  
  func attachView(_ view: MyProductsView)
  func initializeContent()
}

extension MyProductsViewModelProtocol {
  public func generateProducts() {
    let myProducts = Product.getMyProducts(isActive: true)
    products = myProducts.map({ MyProductsItemViewModel(product: $0) })
    previewImagesURL = products.map({ $0.imageURL })
  }
}

public class MyProductsViewModel: MyProductsViewModelProtocol {
  private lazy var networkRequest: PorcelainNetworkRequest = {
    let request = PorcelainNetworkRequest()
    request.delegate = self
    return request
  }()
  
  private weak var view: MyProductsView?
  
  init(selectedItemIndex: Int? = nil) {
    self.products = []
    if let selectedItemIndex = selectedItemIndex {
      self.selectedItemIndex = selectedItemIndex
    } else if !products.isEmpty {
      self.selectedItemIndex = 0
    }
  }
  
  public var selectedItemIndex: Int? {
    didSet {
      guard let selectedItemIndex = selectedItemIndex else { return }
      view?.scrollToIndex(selectedItemIndex)
    }
  }
  
  public var products: [MyProductsItemViewModel] = []
  
  public var previewImagesURL: [String?] = []
}

extension MyProductsViewModel {
  public func attachView(_ view: MyProductsView) {
    self.view = view
  }
  
  public func initializeContent() {
    view?.reload()
    networkRequest.getMyProducts()
  }
  
  public func goToProductsTapped() {
    view?.goToProducts()
  }
}

// MARK: - PorcelainNetworkRequestDelegateProtocol
extension MyProductsViewModel: PorcelainNetworkRequestDelegateProtocol {
  internal func requestWillStart(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction) {
    guard let productRequestAction = action as? ProductRequestAction else { return }
    switch productRequestAction {
    case .getMyProducts:
      view?.showLoading()
    default: break
    }
  }
  
  internal func requestDidFail(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, error: Error?, statusCode: Int?, errorMessage: String?) {
    guard let productRequestAction = action as? ProductRequestAction else { return }
    switch productRequestAction {
    case .getMyProducts:
      view?.hideLoading()
    default: break
    }
  }
  
  internal func requestSuccessful(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, result: Any?) {
    guard let productRequestAction = action as? ProductRequestAction else { return }
    switch productRequestAction {
    case .getMyProducts:
      CoreDataUtil.performBackgroundTask({ (moc) in
        Product.parseMyProducts(result, inMOC: moc)
      }, completion: { (_) in
        self.view?.hideLoading()
        self.view?.reload()
      })
    default: break
    }
  }
}
