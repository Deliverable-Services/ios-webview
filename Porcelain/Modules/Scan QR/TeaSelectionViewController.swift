//
//  TeaSelectionViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 01/10/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import UPCarouselFlowLayout

private struct AttributedTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 1.0
  }
  var alignment: NSTextAlignment? {
    return .center
  }
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? {
    return 36.0
  }
  var font: UIFont? {
    return .idealSans(style: .book(size: 24.0))
  }
  var color: UIColor? {
    return .gunmetal
  }
}

private struct AttributedButtonAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 1.0
  }
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? {
    return 18.0
  }
  var font: UIFont? {
    return .idealSans(style: .book(size: 13.0))
  }
  var color: UIColor? {
    return .white
  }
}

public protocol TeaSelectionDelegate: class {
  func teaSelectionDidSelectTea(_ tea: TeaItemData, index: Int)
  func teaSelectionDidOrderTea(_ tea: TeaItemData, index: Int)
}

public final class TeaSelectionViewController: UIViewController, ActivityIndicatorProtocol, EmptyNotificationActionIndicatorProtocol {
  public var emptyNotificationActionView: EmptyNotificationActionView?
  
  public var activityIndicatorView: UIActivityIndicatorView? {
    didSet {
      activityIndicatorView?.color = .gunmetal
      activityIndicatorView?.backgroundColor = .white
    }
  }
  
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.attributedText = "Please select\nyour drink".attributed.add(.appearance(AttributedTitleAppearance()))
    }
  }
  @IBOutlet private weak var collectionView: UICollectionView! {
    didSet {
      collectionView.registerWithNib(TeaSelectionCCell.self)
      let layout = UPCarouselFlowLayout()
      layout.itemSize = TeaSelectionCCell.defaultSize
      layout.scrollDirection = .horizontal
      layout.spacingMode = .fixed(spacing: 8.0)
      collectionView.collectionViewLayout = layout
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  @IBOutlet private weak var chooseButton: DesignableButton! {
    didSet {
      chooseButton.cornerRadius = 24.0
      chooseButton.backgroundColor = .lightNavy
      chooseButton.setAttributedTitle(
        "CHOOSE".attributed.add(.appearance(AttributedButtonAppearance())),
        for: .normal)
    }
  }
  
  public var emptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let emptyNotificationActionData = emptyNotificationActionData {
        showEmptyNotificationActionOnView(view, type: .centered(data: emptyNotificationActionData))
      } else {
        hideEmptyNotificationAction()
      }
    }
  }
  
  private lazy var viewModel: TeaSelectionViewModelProtocol = TeaSelectionViewModel()
  
  public weak var delegate: TeaSelectionDelegate?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
    viewModel.initialize()
  }
  
  @IBAction private func chooseTapped(_ sender: Any) {
    guard let indexPath = collectionView.indexPathForItem(at: view.convert(view.center, to: collectionView)) else { return }
    delegate?.teaSelectionDidOrderTea(viewModel.teas[indexPath.row], index: indexPath.row)
    showSMTreatments(beatyTips: viewModel.beautyTips, animated: false)
  }
}

// MARK: - SMTreatmentsPresenterProtocol
extension TeaSelectionViewController: SMTreatmentsPresenterProtocol {
}

// MARK: - ControllerProtocol
extension TeaSelectionViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("TeaSelectionViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
  }
}

// MARK: - TeaSelectionView
extension TeaSelectionViewController: TeaSelectionView {
  public func reload() {
    if !viewModel.teas.isEmpty {
      collectionView.isHidden = false
      collectionView.reloadData()
      hideEmptyNotificationAction()
      delegate?.teaSelectionDidSelectTea(viewModel.teas[0], index: 0)//select first tea
    } else {
      collectionView.isHidden = true
      emptyNotificationActionData = EmptyNotificationActionData(
        title: "Nothing here yet.",
        subtitle: "Tea selected couldn't be loaded.",
        action: "RELOAD")
    }
  }
  
  public func showLoading() {
    showActivityOnView(view)
    if let activityIndicatorView = activityIndicatorView {
      view.bringSubview(toFront: activityIndicatorView)
    }
  }
  
  public func hideLoading() {
    hideActivity()
  }
  
  public func showError(message: String) {
    collectionView.isHidden = true
    emptyNotificationActionData = EmptyNotificationActionData(
       title: "Oops!",
       subtitle: message,
       action: "RELOAD")
  }
}

// MARK: - UICollectionViewDataSource
extension TeaSelectionViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.teas.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let teaSelectionCCell = collectionView.dequeueReusableCell(TeaSelectionCCell.self, atIndexPath: indexPath)
    teaSelectionCCell.data = viewModel.teas[indexPath.row]
    return teaSelectionCCell
  }
}

// MARK: - UICollectionViewDelegate
extension TeaSelectionViewController: UICollectionViewDelegate {
}

extension TeaSelectionViewController {
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    guard let indexPath = collectionView.indexPathForItem(at: view.convert(view.center, to: collectionView)) else { return }
    delegate?.teaSelectionDidSelectTea(viewModel.teas[indexPath.row], index: indexPath.row)
  }
}

