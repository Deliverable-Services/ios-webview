//
//  BAASelectTreatmentViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 23/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct BAAAttributedHeaderAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 1.0
  }
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat?
  var font: UIFont? {
    return .idealSans(style: .book(size: 16.0))
  }
  var color: UIColor? {
    return .gunmetal
  }
}

public typealias BAASelectTreatmentCompletion = (Service) -> Void

public final class BAASelectTreatmentHandler {
  public var selectedCenter: Center?
  public var didSelectTreatment: BAASelectTreatmentCompletion?
}

public final class BAASelectTreatmentViewController: UITableViewController, RefreshHandlerProtocol {
  public var refreshScrollView: UIScrollView?
  
  private lazy var frcHandler = FetchResultsControllerHandler<Service>(type: .tableView(tableView), sectionKey: "categoryName")
  
  private let searchController = UISearchController(searchResultsController: nil)
  
  public var handler: BAASelectTreatmentHandler?
  
  private var filter: String? {
    didSet {
      reload()
    }
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  
    hideBarSeparator()
  }
  
  private func initialize() {
    guard let centerID = handler?.selectedCenter?.id else { return }
    if CoreDataUtil.get(
      Service.self,
      predicate: .compoundAnd(predicates: [
        .notEqual(key: "categoryName", value: nil),
        .isEqual(key: "type", value: ServiceType.treatment.rawValue),
        .isEqual(key: "centerID", value: centerID)])) != nil {
      reload()
    }
    startRefreshing()
    PPAPIService.Center.getTreatments(centerID: centerID).call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          Service.parseCenterServicesFromData(result.data, centerID: centerID, type: .treatment, inMOC: moc)
        }, completion: { (_) in
          self.endRefreshing()
          self.reload()
        })
      case .failure(let error):
        self.endRefreshing()
        self.showAlert(title: "Oops!", message: error.localizedDescription)
      }
    }
  }
  
  private func reload() {
    var recipe = CoreDataRecipe()
    var predicates: [CoreDataRecipe.Predicate] = [
      .notEqual(key: "categoryName", value: nil),
      .isEqual(key: "type", value: ServiceType.treatment.rawValue),
      .isEqual(key: "centerID", value: handler?.selectedCenter?.id)]
    if let filter = filter, !filter.isEmpty {
      predicates.append(.contains(key: "name", value: filter))
    }
    recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: predicates).rawValue
    recipe.sorts = [.custom(key: "categoryName", isAscending: true), .custom(key: "name", isAscending: true)]
    frcHandler.reload(recipe: recipe)
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    initialize()
  }
}

// MARK: - NavigationProtocol
extension BAASelectTreatmentViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension BAASelectTreatmentViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    return "showSelectTreatment"
  }
  
  public func setupUI() {
    view.backgroundColor = .whiteFive
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popViewController))
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search Treatment"
    searchController.searchBar.tintColor = .gunmetal
    navigationItem.searchController = searchController
    tableView.setAutomaticDimension()
    tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 16.0, right: 0.0)
    tableView.separatorInset = UIEdgeInsets(top: 0.0, left: 32.0, bottom: 0.0, right: 16.0)
    tableView.separatorColor = .whiteThree
    initialize()
  }
  
  public func setupObservers() {
  }
}

extension BAASelectTreatmentViewController {
  public override func numberOfSections(in tableView: UITableView) -> Int {
    return frcHandler.sections?.count ?? 0
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return frcHandler.numberOfObjectsInSection(section)
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let baaSelectTreatmentTCell = tableView.dequeueReusableCell(BAASelectTreatmentTCell.self, atIndexPath: indexPath)
    baaSelectTreatmentTCell.service = frcHandler.object(at: indexPath)
    return baaSelectTreatmentTCell
  }
  
  public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerLabel = MarginLabel(frame: .zero)
    headerLabel.edgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    headerLabel.backgroundColor = .clear
    headerLabel.attributedText = frcHandler.sections?[section].name.attributed.add(.appearance(BAAAttributedHeaderAppearance()))
    headerLabel.backgroundColor = view.backgroundColor
    return headerLabel
  }
  
  public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 54.0
  }
  
  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    handler?.didSelectTreatment?(frcHandler.object(at: indexPath))
    searchController.isActive = false
    popViewController()
  }
}

// MARK: - UISearchResultsUpdating
extension BAASelectTreatmentViewController: UISearchResultsUpdating {
  public func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filter = searchBar.text
  }
}

public final class BAASelectTreatmentTCell: UITableViewCell {
  @IBOutlet private weak var cView: DesignableView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .regular(size: 14.0))
      titleLabel.textColor = .gunmetal
    }
  }
  
  public var service: Service? {
    didSet {
      titleLabel.text = service?.name
    }
  }
  
  public override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    cView.backgroundColor = selected ? .whiteFive: .white
  }
  
  public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
    
    cView.backgroundColor = highlighted ? .whiteFive: .white
  }
}

// MARK: - CellProtocol
extension BAASelectTreatmentTCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 48.0)
  }
}
