//
//  CartCouponListView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/22/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class CartCouponListView: ResizingContentTableView {
  public var coupons: [CartCouponData] = [] {
    didSet {
      reloadData()
    }
  }
  
  public var didRemoveCoupons: VoidCompletion?
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    setAutomaticDimension()
    registerWithNib(CartCouponTCell.self)
    dataSource = self
    delegate = self
  }
}

// MARK: - UITableViewDataSource
extension CartCouponListView: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return coupons.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cartCouponTCell = tableView.dequeueReusableCell(CartCouponTCell.self, atIndexPath: indexPath)
    cartCouponTCell.data = coupons[indexPath.row]
    cartCouponTCell.removeDidTapped = { [weak self] in
      guard let `self` = self else { return }
      self.coupons.removeAll()
      self.reloadData()
      self.didRemoveCoupons?()
    }
    return cartCouponTCell
  }
}

// MARK: - UITableViewDelegate
extension CartCouponListView: UITableViewDelegate {
}
