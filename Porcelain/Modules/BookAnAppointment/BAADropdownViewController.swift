//
//  BAADropdownViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 23/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public protocol BAADropdownViewProtocol: class {
  var contents: [String]? { get set }
  var selectedRows: [Int]? { get set }
  
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public typealias BAADropdownRowsCompletion = ([Int]) -> Void
public typealias BAADropdownAsyncCompletion = (BAADropdownViewProtocol) -> Void

public final class BAADropdownHandler {
  public var title: String?
  public var defaultTitle: String?
  public var didSelectRows: BAADropdownRowsCompletion?
  public var didSelectNoPreference: VoidCompletion?
  public var asyncCompletion: BAADropdownAsyncCompletion?
}

public final class BAADropdownViewController: UIViewController, BAADropdownViewProtocol, ActivityIndicatorProtocol {
  public var activityIndicatorView: UIActivityIndicatorView?
  
  @IBOutlet private weak var headerView: BAAHeaderView!
  @IBOutlet private weak var tableView: DesignableBAADropdownTableView! {
    didSet {
      tableView.cornerRadius = 7.0
      tableView.setAutomaticDimension()
      tableView.separatorColor = .whiteThree
      tableView.allowsMultipleSelection = true
      tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 0.0)
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  @IBOutlet private weak var noPreferenceButton: DesignableButton! {
    didSet {
      noPreferenceButton.cornerRadius = 7.0
      noPreferenceButton.setAttributedTitle(
        handler.defaultTitle?.attributed.add([
          .color(.bluishGrey),
          .font(.openSans(style: .regular(size: 14.0)))]),
        for: .normal)
      noPreferenceButton.backgroundColor = .white
    }
  }
  
  public var contents: [String]?
  
  public var selectedRows: [Int]? {
    didSet {
      selectedRows?.forEach { (row) in
        tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
      }
      headerView.isEnabled = !(tableView.indexPathsForSelectedRows?.isEmpty ?? true)
    }
  }
  
  private var handler: BAADropdownHandler!
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    reload()
    handler.asyncCompletion?(self)
  }
  
  @IBAction private func noPreferenceTapped(_ sender: Any) {
    handler.didSelectNoPreference?()
    dismissPresenter()
  }
  
  public func reload() {
    if contents?.isEmpty ?? true {
      tableView.isHidden = true
      reloadPresenter()
    } else {
      tableView.isHidden = false
      tableView.reloadData()
    }
  }
  
  public func showLoading() {
    showActivityOnView(view)
  }
  
  public func hideLoading() {
    hideActivity()
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
}

// MARK: - ControllerProtocol
extension BAADropdownViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("BAADropdownViewController segueIdentifier not sets")
  }
  
  public func setupUI() {
    view.backgroundColor = .clear
  }
  
  public func setupController() {
    headerView.isEnabled = false
  }
  
  public func setupObservers() {
    headerView.okDidTapped = { [weak self] in
      guard let `self` = self else { return }
      if let rows = self.tableView.indexPathsForSelectedRows?.map({ $0.row }) {
        self.handler.didSelectRows?(rows)
        self.dismissPresenter()
      } else {
        self.handler.didSelectNoPreference?()
        self.dismissPresenter()
      }
    }
  }
}

// MARK: - UITableViewDataSource
extension BAADropdownViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return contents?.count ?? 0
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let baaDropdownTCell = tableView.dequeueReusableCell(BAADropdownTCell.self, atIndexPath: indexPath)
    baaDropdownTCell.title = contents?[indexPath.row]
    return baaDropdownTCell
  }
}

// MARK: - UITableViewDelegate
extension BAADropdownViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    headerView.isEnabled = !(tableView.indexPathsForSelectedRows?.isEmpty ?? true)
  }
  
  public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    headerView.isEnabled = !(tableView.indexPathsForSelectedRows?.isEmpty ?? true)
  }
  
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    headerView.title = handler.title
    return headerView
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 64.0
  }
}

// MARK: - PresentedControllerProtocol
extension BAADropdownViewController: PresentedControllerProtocol {
  public var presenterType: PresenterType? {
    var size = CGSize(width: 345.0, height: tableView.contentSize.height + 64.0)
    if tableView.isHidden {
      size.height = 56.0
    }
    return .popover(size: size)
  }
}

extension BAADropdownViewController {
  public static func load(handler: BAADropdownHandler) -> BAADropdownViewController {
    let baaDropdownViewController = UIStoryboard.get(.bookAnAppointment).getController(BAADropdownViewController.self)
    baaDropdownViewController.handler = handler
    return baaDropdownViewController
  }
}

public final class BAADropdownTCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .regular(size: 14.0))
    }
  }
  @IBOutlet private weak var checkLabel: UILabel! {
    didSet {
      checkLabel.attributedText = MaterialDesignIcon.check.attributed.add([
        .color(.lightNavy),
        .font(.materialDesign(size: 18.0))])
    }
  }
  
  public var title: String? {
    didSet {
      updateSelection(isSelected)
      titleLabel.text = title
    }
  }
  
  public override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    updateSelection(selected)
  }
  
  public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
    
    alpha = highlighted ? 0.8: 1.0
  }
  
  private func updateSelection(_ selected: Bool = false)  {
    titleLabel.textColor = selected ? .lightNavy: .gunmetal
    checkLabel.isHidden = !selected
  }
}

// MARK: - CellProtocol
extension BAADropdownTCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 52.0)
  }
}

public final class BAAHeaderView: UIView  {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 16.0))
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var okButton: UIButton! {
    didSet {
      okButton.setAttributedTitle(
        "OK".attributed.add([.color(.lightNavy), .font(.idealSans(style: .book(size: 16.0)))]),
        for: .normal)
    }
  }
  @IBOutlet private weak var separatorView: UIView! {
    didSet {
      separatorView.backgroundColor = .whiteThree
    }
  }
  
  public var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
  
  public var isEnabled: Bool = true {
    didSet {
      okButton.isHidden = !isEnabled
    }
  }
  
  public var okDidTapped: VoidCompletion?
  
  @IBAction private func okTapped(_ sender: Any) {
    okDidTapped?()
  }
}

public final class DesignableBAADropdownTableView: ResizingContentTableView, Designable {
  public var cornerRadius: CGFloat = 0.0 {
    didSet {
      updateLayer()
    }
  }
  public var borderWidth: CGFloat = 0.0
  public var borderColor: UIColor = .clear
}
