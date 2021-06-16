//
//  SelectTreatmentViewController.swift
//  Porcelain
//
//  Created by Justine Rangel on 11/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public typealias TreatmentCompletion = (TreatmentModel) -> ()

private struct Constant {
  static let barTitle = "SELECT TREATMENT".localized()
}

public class SelectTreatmentViewController: UITableViewController {
  
  public var didSelectTreatment: TreatmentCompletion?
  
  fileprivate var viewModel: SelectTreatmentViewModelProtocol!
  
  public func configure(viewModel: SelectTreatmentViewModelProtocol) {
    viewModel.attachView(self)
    self.viewModel = viewModel
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setNavigationTheme(.white)
    showBarSeparator()
  }
  
  deinit {
    debugPrint("deinit SelectTreatmentViewController")
  }
  
  @objc
  func reloadData() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.reload()
      self.refreshControl?.endRefreshing()
    }
  }
}

// MARK: - ControllerProtocol
extension SelectTreatmentViewController: ControllerProtocol, NavigationProtocol {
  public static var segueIdentifier: String {
    return "showSelectTreatment"
  }
  
  public func setupUI() {
    title = Constant.barTitle
    view.backgroundColor = UIColor.Porcelain.mainBackground
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), selector: #selector(popViewController))
    if refreshControl == nil {
      refreshControl = UIRefreshControl()
      refreshControl?.tintColor = UIColor.Porcelain.blueGrey
      refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
    }
    tableView.setAutomaticDimension()
  }
  
  public func setupObservers() {
  }
}

// MARK: - SelectTreatmentView
extension SelectTreatmentViewController: SelectTreatmentView {

  public func reload() {
    tableView.reloadData()
  }
  
  public func didSelectTreatment(_ treatment: TreatmentModel) {
    didSelectTreatment?(treatment)
    popViewController()
  }
}

// MARK: - UITableViewDatasource
extension SelectTreatmentViewController {
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.treatmentCategories.count
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let selectTreatmentCategoryCell = tableView.dequeueReusableCell(SelectTreatmentCategoryCell.self, atIndexPath: indexPath)
    selectTreatmentCategoryCell.configure(viewModel: viewModel.treatmentCategories[indexPath.row])
    return selectTreatmentCategoryCell
  }
}

// MARK: - UITableViewDelegate
extension SelectTreatmentViewController {
  public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return nil
  }
  
  public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30.0
  }
}

public class SelectTreatmentCategoryCell: UITableViewCell {
  @IBOutlet private weak var titleView: UIView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var treatmentTableView: DesignableTableView!
  @IBOutlet private weak var treatmentTableHeightConstraint: NSLayoutConstraint!
  
  fileprivate var viewModel: SelectTreatmentCategoryViewModelProtocol!
  
  public func configure(viewModel: SelectTreatmentCategoryViewModelProtocol) {
    self.viewModel = viewModel
    
    if let title = viewModel.title {
      titleView.isHidden = false
      titleLabel.attributedText = NSAttributedString(
        content: title,
        font: UIFont.Porcelain.idealSans(16.0, weight: .book),
        foregroundColor: UIColor.Porcelain.greyishBrown,
        paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 16.0, characterSpacing: 1.0))
    } else {
      titleView.isHidden = true
    }
    treatmentTableHeightConstraint.constant = SelectTreatmentCell.defaultSize.height * CGFloat(viewModel.treatments.count)
    treatmentTableView.reloadData()
  }

  public override func awakeFromNib() {
    super.awakeFromNib()

    treatmentTableView.cornerRadius = 7.0
    treatmentTableView.dataSource = self
    treatmentTableView.delegate = self
  }
}

extension SelectTreatmentCategoryCell: CellProtocol {
  public static var defaultSize: CGSize {
    return .zero
  }
}

// MARK: - UITableViewDataSource
extension SelectTreatmentCategoryCell: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.treatments.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let selectTreatmentCell = tableView.dequeueReusableCell(SelectTreatmentCell.self, atIndexPath: indexPath)
    selectTreatmentCell.treatment = viewModel.treatments[indexPath.row]
    return selectTreatmentCell
  }
}

// MARK: - UITableViewDelegate
extension SelectTreatmentCategoryCell: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    viewModel.treatmentTapped(treatment: viewModel.treatments[indexPath.row])
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return SelectTreatmentCell.defaultSize.height
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return .leastNonzeroMagnitude
  }
  
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNonzeroMagnitude
  }
}


public class SelectTreatmentCell: UITableViewCell {
  @IBOutlet private weak var treatmentLabel: UILabel!
  
  public var treatment: TreatmentModel? {
    didSet {
      updateUI()
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
  }
  
  public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(animated, animated: animated)

    updateUI(isSelected: highlighted)
  }
  
  public override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    updateUI(isSelected: selected)
  }
  
  private func updateUI(isSelected: Bool = false) {
    guard let title = treatment?.title else { return }
    treatmentLabel.attributedText = NSAttributedString(content: title,
                                                       font: UIFont.Porcelain.idealSans(14.0, weight: .book),
                                                       foregroundColor: isSelected ? UIColor.Porcelain.whiteTwo: UIColor.Porcelain.greyishBrown,
                                                       paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 14.0, characterSpacing: 0.5))
    backgroundColor = isSelected ? UIColor.Porcelain.blueGrey: UIColor.Porcelain.whiteTwo
  }
}

extension SelectTreatmentCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 48.0)
  }
}

