//
//  ResizingListingView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 23/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public struct ResizingListingData {
  public var title: String?
  public var contents: [String]?
}

public final class ResizingListingView: ResizingContentTableView {
  public var data: ResizingListingData? {
    didSet {
      reloadData()
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    setAutomaticDimension()
    registerWithNib(ResizingListingTCell.self)
    dataSource = self
    delegate = self
  }
}

// MARK: - UITableViewDataSource
extension ResizingListingView: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data?.contents?.count ?? 0
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let resizingListTCell = tableView.dequeueReusableCell(ResizingListingTCell.self, atIndexPath: indexPath)
    resizingListTCell.title = data?.contents?[indexPath.row]
    return resizingListTCell
  }
}

extension ResizingListingView: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let title = data?.title else { return nil }
    let button = UIButton(frame: .zero)
    button.isUserInteractionEnabled = false
    button.contentHorizontalAlignment = .left
    button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 10.0, right: 0.0)
    button.setAttributedTitle(
      title.attributed.add([
        .color(.lightNavy),
        .font(.idealSans(style: .book(size: 12.0)))]),
      for: .normal)
    return button
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    guard data?.title != nil else { return .leastNonzeroMagnitude }
    return 22.0
  }
}

public final class ResizingListingTCell: UITableViewCell {
  @IBOutlet private weak var bulletLabel: UILabel! {
    didSet {
      bulletLabel.font = .openSans(style: .bold(size: 16.0))
      bulletLabel.textColor = .bluishGrey
      bulletLabel.text = "•"
    }
  }
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .regular(size: 12.0))
      titleLabel.textColor = .bluishGrey
    }
  }
  
  public var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
}

// MARK: - CellProtocol
extension ResizingListingTCell: CellProtocol {
}
