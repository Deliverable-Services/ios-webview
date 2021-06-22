//
//  DropDownViewController.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 14/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit

public enum DropDownType: Equatable {
  case singleSelection(appearance: DropDownAppearanceProtocol)
  case withCheck(appearance: DropDownAppearanceProtocol)
  case multiSelection(appearance: DropDownAppearanceProtocol)
  
  public var appearance: DropDownAppearanceProtocol {
    switch self {
    case .singleSelection(let appearance):
      return appearance
    case .withCheck(let appearance):
      return appearance
    case .multiSelection(let appearance):
      return appearance
    }
  }
  
  public var weight: Int {
    switch self {
    case .singleSelection:
      return 0
    case .withCheck:
      return 1
    case .multiSelection:
      return 2
    }
  }
  
  public static func == (lhs: DropDownType, rhs: DropDownType) -> Bool {
    return lhs.weight == rhs.weight
  }
}

public protocol DropDownDataProtocol {
  var title: String? { get }
  var subtitle: String? { get }
}

public protocol DropDownListViewProtocol: class {
  var isLoading: Bool { get }
  var errorDescription: String? { get set }
  var contents: [DropDownDataProtocol] { get set }
  var selectedIndex: Int? { get set }
  var selectedRows: [Int]? { get set }

  func showLoading()
  func hideLoading()
  func reload()
}

public enum DropDownFilterType {
  case auto(countThreshold: Int)
  case enabled
  case disabled
}

public struct DropDownTextAppearance: AttributedStringAppearanceProtocol {
  public var characterSpacing: Double?
  public var alignment: NSTextAlignment?
  public var lineBreakMode: NSLineBreakMode?
  public var minimumLineHeight: CGFloat?
  public var font: UIFont?
  public var color: UIColor?
  
  public init(characterSpacing: Double?, alignment: NSTextAlignment?, lineBreakMode: NSLineBreakMode?, minimumLineHeight: CGFloat?, font: UIFont?, color: UIColor?) {
    self.characterSpacing = characterSpacing
    self.alignment = alignment
    self.lineBreakMode = lineBreakMode
    self.minimumLineHeight = minimumLineHeight
    self.font = font
    self.color = color
  }
}

public protocol DropDownAppearanceProtocol {
  var filterAppearance: DropDownTextAppearance { get }
  var titleAppearance: DropDownTextAppearance { get }
  var titleBackgroundColor: UIColor? { get }
  var selectedTitleApperance: DropDownTextAppearance { get }
  var selectedTitleBackgroundColor: UIColor? { get }
  var subtitleAppearance: DropDownTextAppearance { get }
  var selectedSubtitleApperance: DropDownTextAppearance { get }
  var noticeApperance: DropDownTextAppearance { get }
}

private struct DropDownAppearance: DropDownAppearanceProtocol {
  var filterAppearance: DropDownTextAppearance = .init(
    characterSpacing: nil,
    alignment: nil,
    lineBreakMode: .byTruncatingTail,
    minimumLineHeight: nil,
    font: .systemFont(ofSize: 14.0, weight: .regular),
    color: UIColor(hex: 0x595e60))
  
  var titleAppearance: DropDownTextAppearance = .init(
    characterSpacing: nil,
    alignment: nil,
    lineBreakMode: .byTruncatingTail,
    minimumLineHeight: nil,
    font: .systemFont(ofSize: 14.0, weight: .regular),
    color: UIColor(hex: 0x7f888b))
  
  var titleBackgroundColor: UIColor?
  
  var selectedTitleApperance: DropDownTextAppearance = .init(
    characterSpacing: nil,
    alignment: nil,
    lineBreakMode: .byTruncatingTail,
    minimumLineHeight: nil,
    font: .systemFont(ofSize: 14.0, weight: .semibold),
    color: UIColor(hex: 0x709cb5))
  
  var selectedTitleBackgroundColor: UIColor?
  
  var subtitleAppearance: DropDownTextAppearance = .init(
    characterSpacing: nil,
    alignment: nil,
    lineBreakMode: .byTruncatingTail,
    minimumLineHeight: nil,
    font: .systemFont(ofSize: 12.0, weight: .regular),
    color: UIColor(hex: 0x7f888b))
  
  var selectedSubtitleApperance: DropDownTextAppearance = .init(
    characterSpacing: nil,
    alignment: nil,
    lineBreakMode: .byTruncatingTail,
    minimumLineHeight: nil,
    font: .systemFont(ofSize: 12.0, weight: .semibold),
    color: UIColor(hex: 0x7f888b))
  
  var noticeApperance: DropDownTextAppearance = .init(
    characterSpacing: nil,
    alignment: nil,
    lineBreakMode: .byTruncatingTail,
    minimumLineHeight: nil,
    font: .systemFont(ofSize: 14.0, weight: .regular),
    color: UIColor(hex: 0x7f888b))
}

public typealias DropDownAsyncCompletion = (String?, DropDownListViewProtocol) -> Void

public final class DropDownHandler {
  public struct Config {
    public static var width: CGFloat?
    public static var maxHeight: CGFloat?
    public static var type: DropDownType = .singleSelection(appearance: DropDownAppearance())
    public static var filterType: DropDownFilterType = .disabled
  }
  
  public init() {
  }
  
  public var width: CGFloat? = DropDownHandler.Config.width
  public var maxHeight: CGFloat? =  DropDownHandler.Config.maxHeight
  public var type: DropDownType = DropDownHandler.Config.type
  public var filterType: DropDownFilterType = DropDownHandler.Config.filterType
  public var preFilteredText: String?
  public var headerTitle: String?
  
  public var preSelectedIndex: Int?
  public var preSelectedRows: [Int]?
  public var didSelectIndex: IntCompletion?
  public var didSelectRows: (([Int]) -> Void)?
  public var asyncCompletion: DropDownAsyncCompletion?
  public var willShow: VoidCompletion?
  public var willHide: VoidCompletion?
}

public final class DropDownViewController: UIViewController {
  @IBOutlet private weak var contentStack: UIStackView!
  @IBOutlet private weak var headerView: UIView!
  @IBOutlet private weak var headerStack: UIStackView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.text = handler.headerTitle
    }
  }
  @IBOutlet private weak var filterTextField: UIDesignableTextField! {
    didSet {
      let filterAppearance = handler.type.appearance.filterAppearance
      let color = filterAppearance.color
      filterTextField.defaultTextAttributes = NSAttributedString.createAttributes([.appearance(filterAppearance)])
      filterTextField.typingAttributes = NSAttributedString.createAttributes([.appearance(filterAppearance)])
      filterTextField.generateRightImage(UIImage.icSearch.maskWithColor(color))
      filterTextField.delegate = self
    }
  }
  @IBOutlet private weak var tableView: ResizingContentTableView! {
    didSet {
      tableView.setAutomaticDimension()
      tableView.alwaysBounceVertical = false
      tableView.dataSource = self
      tableView.delegate = self
    }
  }
  public var isLoading: Bool = false
  public var errorDescription: String?
  public var contents: [DropDownDataProtocol] = []
  public var selectedIndex: Int? {
    didSet {
      handler.preSelectedIndex = selectedIndex
    }
  }
  public var selectedRows: [Int]? {
    didSet {
      handler.preSelectedRows = selectedRows
    }
  }
  private var handler: DropDownHandler!

  public override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    handler.willShow?()
    let text = filterTextField.text ?? ""
    if text.isEmpty {
      handler.asyncCompletion?(nil, self) //trigger async completion
    } else {
      handler.asyncCompletion?(text, self)
    }
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    handler.willHide?()
  }

  private func selectIndexIfNeeded() {
    guard tableView.indexPathForSelectedRow == nil else { return }
    if let selectedIndex = handler.preSelectedIndex {
      DispatchQueue.main.async {
        self.tableView.selectRow(
          at: IndexPath(row: selectedIndex, section: 0),
          animated: false,
          scrollPosition: .none)
      }
    } else if let selectedRows = handler.preSelectedRows {
      DispatchQueue.main.async {
        selectedRows.forEach { (row) in
          self.tableView.selectRow(
            at: IndexPath(row: row, section: 0),
            animated: false,
            scrollPosition: .none)
          }
       }
    }
  }
  
  @IBAction private func textFieldTextChanged(_ sender: UITextField) {
    handler.asyncCompletion?(sender.text?.emptyToNil, self)
  }
}

// MARK: - ControllerProtocol
extension DropDownViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("DropDownViewController segueIdentifier not set")
  }

  public func setupUI() {
  }

  public func setupController() {
    filterTextField.text = handler.preFilteredText
    switch handler.type {
    case .singleSelection:
      tableView.allowsMultipleSelection = false
    case .withCheck:
      tableView.allowsMultipleSelection = false
    case .multiSelection:
      tableView.allowsMultipleSelection = true
    }
    reload()
  }

  public func setupObservers() {
    tableView.observeContentSizeUpdates = { [weak self] (size) in
      guard let `self` = self else { return }
      self.reloadPresenter()
    }
  }
}

// MARK: - UITableViewDataSource
extension DropDownViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return max(1, contents.count)
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if isLoading {
      let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath)
      let label = (cell.viewWithTag(1110) as? UILabel)
      label?.attributedText = "Loading...".attributed.add(.appearance(handler.type.appearance.noticeApperance))
      return cell
    } else {
      if !contents.isEmpty {
        let dropDownListCell = tableView.dequeueReusableCell(DropDownListCell.self, atIndexPath: indexPath)
        dropDownListCell.isSelected = tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false
        dropDownListCell.type = handler.type
        dropDownListCell.data = contents[indexPath.row]
        return dropDownListCell
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeCell", for: indexPath)
        let label = (cell.viewWithTag(1110) as? UILabel)
        label?.attributedText = (errorDescription ?? "No results").attributed.add(.appearance(handler.type.appearance.noticeApperance))
        return cell
      }
    }
  }
}

// MARK: - UITableViewDelegate
extension DropDownViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard contents.count > indexPath.row else {  return }
    switch handler.type {
    case .singleSelection:
      handler.didSelectIndex?(indexPath.row)
      dismissPresenter()
    case .withCheck:
      handler.didSelectIndex?(indexPath.row)
      dismissPresenter()
    case .multiSelection:
      handler.didSelectRows?(tableView.indexPathsForSelectedRows?.map({ $0.row }) ?? [])
    }
  }
  
  public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    guard contents.count > indexPath.row else {  return }
    switch handler.type {
    case .singleSelection: break
    case .withCheck: break
    case .multiSelection:
      handler.didSelectRows?(tableView.indexPathsForSelectedRows?.map({ $0.row }) ?? [])
    }
  }
  
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNonzeroMagnitude
  }
}

// MARK: - PresetedControllerProtocol
extension DropDownViewController: PresentedControllerProtocol {
  public var presenterType: PresenterType? {
    var height: CGFloat = 0.0
    if headerStack != nil {
      headerStack.layoutIfNeeded()
      if let maxHeight = handler.maxHeight {
        height = min(maxHeight, tableView.contentSize.height + (headerView.isHidden ? 0.0: headerStack.bounds.height + 24.0))
      } else {
        height = tableView.contentSize.height + (headerView.isHidden ? 0.0: headerStack.bounds.height + 24.0)
      }
    }
    return .popover(size: CGSize(width: handler.width ?? 310.0, height: height))
  }
}

// MARK: - DropDownListViewProtocol
extension DropDownViewController: DropDownListViewProtocol {
  public func showLoading() {
    errorDescription = nil
    isLoading = true
  }

  public func hideLoading() {
    isLoading = false
  }

  public func reload() {
    switch handler.filterType {
    case .auto(let countThreshold):
      if let searchText = filterTextField.text, !searchText.isEmpty {
        filterTextField.isHidden = false //always show if searching
      } else {
        filterTextField.isHidden = contents.count < countThreshold
      }
    case .enabled:
      filterTextField.isHidden = false
    case .disabled:
      filterTextField.isHidden = true
    }
    let isHeaderShown = !filterTextField.isHidden || handler.headerTitle?.emptyToNil != nil
    headerView.isHidden = !isHeaderShown
    titleLabel.text = handler.headerTitle
    tableView.reloadData()
    selectIndexIfNeeded()
  }
}

// MARK: - UITextFieldDelegate
extension DropDownViewController: UITextFieldDelegate {
  public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return false
  }
}

extension StoryboardName {
  fileprivate static let dropdown = "Dropdown"
}

extension DropDownViewController {
  public static func load(handler: DropDownHandler) -> DropDownViewController {
    let dropDownViewController = UIStoryboard.get(.dropdown, bundle: .r4pidKit).getController(DropDownViewController.self)
    dropDownViewController.handler = handler
    return dropDownViewController
  }
}

public final class DropDownListCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.text = nil
    }
  }
  @IBOutlet private weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.text = nil
    }
  }
  @IBOutlet private weak var checkImageView: UIImageView! {
    didSet {
      checkImageView.image = UIImage.icCheck.maskWithColor(.white)
    }
  }

  public var type: DropDownType = DropDownHandler.Config.type {
    didSet {
      switch type {
      case .singleSelection:
        checkImageView.isHidden = true
      case .withCheck:
        checkImageView.isHidden = false
      case .multiSelection:
        checkImageView.isHidden = false
      }
    }
  }
  public var data: DropDownDataProtocol? {
    didSet {
      updateUI(isSelected: isSelected)
    }
  }

  public override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    updateUI(isSelected: selected)
  }

  private func updateUI(isSelected: Bool = false) {
    switch type {
    case .singleSelection(let appearance):
      backgroundColor = isSelected ? appearance.selectedTitleBackgroundColor: appearance.titleBackgroundColor
      titleLabel.attributedText = data?.title?.attributed.add(.appearance(isSelected ? appearance.selectedTitleApperance: appearance.titleAppearance))
      subtitleLabel.attributedText = data?.subtitle?.attributed.add(.appearance(isSelected ? appearance.selectedSubtitleApperance: appearance.subtitleAppearance))
    case .withCheck(let appearance):
      backgroundColor = isSelected ? appearance.selectedTitleBackgroundColor: appearance.titleBackgroundColor
      titleLabel.attributedText = data?.title?.attributed.add(.appearance(isSelected ? appearance.selectedTitleApperance: appearance.titleAppearance))
      subtitleLabel.attributedText = data?.subtitle?.attributed.add(.appearance(isSelected ? appearance.selectedSubtitleApperance: appearance.subtitleAppearance))
      checkImageView.isHidden = !isSelected
    case .multiSelection(let appearance):
      backgroundColor = isSelected ? appearance.selectedTitleBackgroundColor: appearance.titleBackgroundColor
      titleLabel.attributedText = data?.title?.attributed.add(.appearance(isSelected ? appearance.selectedTitleApperance: appearance.titleAppearance))
      subtitleLabel.attributedText = data?.subtitle?.attributed.add(.appearance(isSelected ? appearance.selectedSubtitleApperance: appearance.subtitleAppearance))
      checkImageView.isHidden = !isSelected
    }
  }
}

// MARK: - CellProtocol
extension DropDownListCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 48.0)
  }
}
