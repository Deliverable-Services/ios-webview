//
//  TreatmentHistoryViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 04/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import UIKit
import KRProgressHUD
import SwiftyJSON
import CoreData
import R4pidKit

private struct Constant {
  static let barTitle = "Past Appointments".localized()
}

private struct MonthTreatmentHistory {
  var month: String
  var treatments: [TreatmentHistory]
}

class TreatmentHistoryViewController: UIViewController, NavigationProtocol {
  lazy var handler: TreatmentHistoryHandler = {
    let handler = TreatmentHistoryHandler()
    handler.delegate = self
    return handler
  }()
  
  private var history: [MonthTreatmentHistory] = []
  
  @IBOutlet fileprivate  weak var tableView: UITableView! {
    didSet {
      self.tableView.addSubview(self.refreshControl)
    }
  }
  
  lazy private var refreshControl: UIRefreshControl! = {
    let refreshControl = UIRefreshControl()
    refreshControl.tintColor = UIColor.Porcelain.blueGrey
    refreshControl.addTarget(self, action: #selector(TreatmentHistoryViewController.reloadData), for: .valueChanged)
    return refreshControl
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setUpUI()
    self.fetchTreatmentHistory()
    self.initDatasource()
  }
  
  private func initDatasource() {
    handler.getTreatmentHistory()
  }
  
  private func setUpUI() {
    self.title = Constant.barTitle
    self.navigationController?.navigationBar.barTintColor = UIColor.Porcelain.whiteFour
    self.view.backgroundColor = UIColor.Porcelain.white
    
    generateLeftNavigationButton(image: #imageLiteral(resourceName: "back-icon").withRenderingMode(.alwaysOriginal), selector: #selector(popViewController))
    
    let navLabel = UILabel()
    let navTitle: NSAttributedString = Constant.barTitle.uppercased()
      .withFont(UIFont.Porcelain.openSans(14, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(2)
    
    navLabel.attributedText = navTitle
    self.navigationItem.titleView = navLabel
    self.setUpTableViewUI()
  }
  
  private func setUpTableViewUI() {
    self.tableView.backgroundColor = UIColor.Porcelain.white

    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedRowHeight = 200
    self.tableView.estimatedSectionFooterHeight = 1.0
    
    self.tableView.tableFooterView = UIView()
    self.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
    
    self.tableView.sectionFooterHeight = 1.0
    self.tableView.register(
      UINib(nibName: DefaultEmptyCell.identifier, bundle: Bundle.main),
      forCellReuseIdentifier: DefaultEmptyCell.identifier)
  }
  
  private func fetchTreatmentHistory() {
    self.history = []
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TreatmentHistory")
    var recipe = CoreDataRecipe()
    recipe.sorts = [CoreDataRecipe.Sort.custom(key: "month", isAscending: false)]
    recipe.distinctProperties = ["month"]
    let months = CoreDataUtil
      .fetchObjects(for: request,
                    recipe: recipe,
                    inMOC: CoreDataUtil.mainMOC)
    for month in months {
      let monthInt = (month as! [String: Int16])["month"] ?? 0
      let userid = AppUserDefaults.customer?.id ?? ""
      var prevRecipe = CoreDataRecipe()
      prevRecipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates:
        [ .isEqual(key: "user.id", value: userid),
          .isEqual(key: "month", value: monthInt)
        ]).rawValue
      prevRecipe.sorts = [
        .custom(key: "startDate", isAscending: false),
        .custom(key: "endDate", isAscending: false),
        .custom(key: "name", isAscending: true)
      ]
      let treatmentsInMonth = CoreDataUtil
        .listObjects(TreatmentHistory.self, recipe: prevRecipe)
        as! [TreatmentHistory]
      
      if treatmentsInMonth.count == 0 { continue }
      let monthHistory = MonthTreatmentHistory(month: DateFormatter().monthSymbols[Int(monthInt-1)],
                                               treatments: treatmentsInMonth)
      self.history.append(monthHistory)
    }
    self.tableView.reloadData()
  }
  
  private func endRefreshing() {
    DispatchQueue.main.async {
      KRProgressHUD.hideHUD()
      if self.refreshControl.isRefreshing == true {
        self.refreshControl.endRefreshing()
      }
    }
  }
  
  @objc func reloadData() {
    self.refreshControl.beginRefreshing()
    self.handler.getTreatmentHistory()
  }
}

// MARK: - Segues
extension TreatmentHistoryViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let bookAppointmentViewController = (segue.destination as? NavigationController)?.getChildController(BookAppointmentViewController.self){
      bookAppointmentViewController.rebookData = sender as? ReBookAppointmentData
    }
  }
}

extension TreatmentHistoryViewController: TreatmentHistoryCellDelegate {
  func rebook(with treatmentID: String, therapistID: String?, locationID: String) {
    let data = ReBookAppointmentData(
      locationID: locationID,
      treatmentID: treatmentID,
      therapistID: therapistID)
    performSegue(withIdentifier: BookAppointmentViewController.segueIdentifier, sender: data)
  }
}


/****************************************************************/
// MARK: - TreatmentHistoryHandlerDelegate
extension TreatmentHistoryViewController: TreatmentHistoryHandlerDelegate {
  func treatmentHistoryHandlerWillStart(_ handler: TreatmentHistoryHandler,
                                        action: TreatmentHistoryAction) {
    if history.count == 0 { KRProgressHUD.showHUD() }
  }
  
  func treatmentHistoryHandlerSuccessful(_ handler: TreatmentHistoryHandler,
                                         action: TreatmentHistoryAction, response: JSON) {
    guard let responseData = response.array?[0].dictionary?["data"]
      else {
        self.treatmentHistoryHandlerDidFail(handler, action: action, error: nil)
        return
    }
    
    endRefreshing()
    CoreDataUtil.performBackgroundTask({ (moc) in
      let toDelete = CoreDataUtil.list(TreatmentHistory.self, inMOC: moc)
      CoreDataUtil.deleteEntities(toDelete, inMOC: moc)
    }) { [weak self] (_) in
      CoreDataUtil.performBackgroundTask({(moc) in
        for monthData in responseData.arrayValue {
          let history = JSON(monthData["treatments"]).arrayValue
          let _ = history.compactMap({ TreatmentHistory.object(from: $0, inMOC: moc) })
        }
      }) { (_) in
        guard let strongSelf = self else { return }
        strongSelf.fetchTreatmentHistory()
      }
    }
  }
  
  func treatmentHistoryHandlerDidFail(_ handler: TreatmentHistoryHandler, action: TreatmentHistoryAction, error: Error?) {
    switch action {
    case .getTreatmentHistory:
      DispatchQueue.main.async() {
        self.endRefreshing()
        self.displayAlert(title: AppConstant.Text.defaultErrorTitle,
                          message: error?.localizedDescription ?? AppConstant.Text.defaultErrorMessage,
                          handler: nil)
      }
    }
  }
}

extension TreatmentHistoryViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 1.0
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView(frame: .zero)
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return max(history.count, 1)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 && history.count == 0 { return 1 }
    return history[section].treatments.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard history.count > 0 else {
      let cell = tableView.dequeueReusableCell(withIdentifier: DefaultEmptyCell.identifier) as! DefaultEmptyCell
      cell.configure(text: "No past appointments".localized())
      return cell
    }
    let cell  = tableView.dequeueReusableCell(withIdentifier: TreatmentHistoryCell.identifier) as! TreatmentHistoryCell
    let month = history[indexPath.section]
    cell.configure(treatment: month.treatments[indexPath.row])
    cell.delegate = self
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if history.count == 0 { return 0 }
    return SectionHeaderView.estimatedHeight
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if history.count == 0 { return nil }
    let view = SectionHeaderView(frame:
      CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: SectionHeaderView.estimatedHeight))
    view.backgroundColor = UIColor.Porcelain.white
    view.titleLabel.attributedText = history[section].month
      .withFont(UIFont.Porcelain.idealSans(16))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.5)
    return view
  }
}
