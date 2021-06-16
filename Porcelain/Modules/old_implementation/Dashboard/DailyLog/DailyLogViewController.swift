//
//  DailyLogViewController.swift
//  Porcelain
//
//  Created by Justine Rangel on 16/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct Constant {
  static let barTitle = "DAILY LOG".localized()
}

public class DailyLogViewController: UITableViewController {
  
  fileprivate var viewModel: DailyLogViewModelProtocol!
  
  public func configure(viewModel: DailyLogViewModelProtocol) {
    viewModel.attachView(self)
    self.viewModel = viewModel
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    //Testing
    var trackings: [DailyLogTrackingViewModel] = []
    trackings.append(DailyLogTrackingViewModel(sectionTitle: "Apply product X cleanser",
                                               incrementValue: 10,
                                               progress: 20,
                                               target: 100,
                                               isTrackingFulfilled: false,
                                               trackingFulfillmentDescription: "The quick BROWN fox jumps over the lazy dog"))
    trackings.append(DailyLogTrackingViewModel(sectionTitle: "Did you apply product X tonight?",
                                               incrementValue: 10,
                                               progress: 30,
                                               target: 100,
                                               isTrackingFulfilled: false,
                                               trackingFulfillmentDescription: "The quick brown fox jumps over the LAZY dog"))
    trackings.append(DailyLogTrackingViewModel(sectionTitle: "Did you apply product Y tonight?",
                                               incrementValue: 10,
                                               progress: 50,
                                               target: 100,
                                               isTrackingFulfilled: false,
                                               trackingFulfillmentDescription: "The quick brown fox jumps over the lazy DOG"))
    configure(viewModel: DailyLogViewModel(trackings: trackings))
    
    setup()
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
extension DailyLogViewController: ControllerProtocol, NavigationProtocol {
  public static var segueIdentifier: String {
    return "showDailyLog"
  }
  
  public func setupUI() {
    title = Constant.barTitle
    view.backgroundColor = UIColor(hex: 0xe9f0f1)
  }
  
  public func setupController() {
    if refreshControl == nil {
      refreshControl = UIRefreshControl()
      refreshControl?.tintColor = UIColor.Porcelain.blueGrey
      refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
    }
    generateLeftNavigationButton(image: #imageLiteral(resourceName: "dashboard-icon"), selector: #selector(dismissViewController))
  }
  
  public func setupObservers() {
  }
}

// MARK: - DailyLogView
extension DailyLogViewController: DailyLogView {
  public func reload() {
    tableView.reloadData()
  }
}

// MARK: - UITableViewDatasource
extension DailyLogViewController {
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.trackings.count
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let dailyLogTrackingCell = tableView.dequeueReusableCell(DailyLogTrackingCell.self, atIndexPath: indexPath)
    dailyLogTrackingCell.configure(viewModel: viewModel.trackings[indexPath.row])
    switch indexPath.row {
    case 0:
      dailyLogTrackingCell.backgroundColor = UIColor(hex: 0xf9fcfd)
    case 1:
      dailyLogTrackingCell.backgroundColor = UIColor(hex: 0xf5f8f9)
    case 2:
      dailyLogTrackingCell.backgroundColor = UIColor(hex: 0xe9f0f1)
    default: break
    }
    return dailyLogTrackingCell
  }
}

// MARK: - UITableViewDelegate
extension DailyLogViewController {
  public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return DailyLogTrackingCell.defaultSize.height
  }
  
  public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = UIView()
    header.backgroundColor = UIColor(hex: 0xf9fcfd)
    return header
  }
  
  public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30.0
  }
  
  
}

public protocol DailyLogTrackingViewProtocol {
  var sectionTitle: String { get }
  var incrementValue: Float { get }
  var progress: Float { get set }
  var target: Float { get }
  var isTrackingFulfilled: Bool { get set }
  var trackingFulfillmentDescription: String { get }
}

extension DailyLogTrackingViewProtocol {
  public var multiplier: CGFloat {
    return CGFloat(progress/target)
  }
  
  public var isCompleted: Bool {
    return progress >= target
  }
}

public class DailyLogTrackingCell: UITableViewCell {
  @IBOutlet private weak var sectionTitleLabel: DesignableLabel!
  @IBOutlet private weak var trackingLineView: UIView!
  @IBOutlet private weak var trackingProgressWidthConstraint: NSLayoutConstraint!
  @IBOutlet private weak var checkIndicatorButton: DesignableButton!
  @IBOutlet private weak var trackingFulfillmentLabel: DesignableLabel!
  @IBOutlet private weak var trackingFulfillButton: DesignableButton!
  
  fileprivate var viewModel: DailyLogTrackingViewProtocol!
  
  public func configure(viewModel: DailyLogTrackingViewProtocol) {
    self.viewModel = viewModel
    sectionTitleLabel.attributedText = NSAttributedString(content: viewModel.sectionTitle,
                                                          font: UIFont.Porcelain.idealSans(16.0, weight: .book),
                                                          foregroundColor: UIColor.Porcelain.greyishBrown,
                                                          paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 24.0, characterSpacing: 0.5))
    layoutIfNeeded()
    trackingProgressWidthConstraint.constant = trackingLineView.bounds.width * viewModel.multiplier
    checkIndicatorButton.isEnabled = viewModel.isCompleted
    if viewModel.isTrackingFulfilled {
      trackingFulfillmentLabel.isHidden = false
      trackingFulfillButton.isHidden = true
      trackingFulfillmentLabel.attributedText = NSAttributedString(content: viewModel.trackingFulfillmentDescription,
                                                                   font: UIFont.Porcelain.idealSans(12.0, weight: .book),
                                                                   foregroundColor: UIColor.Porcelain.blueGrey,
                                                                   paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 16.0, characterSpacing: 0.2))
    } else {
      trackingFulfillmentLabel.isHidden = true
      trackingFulfillButton.isHidden = false
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    checkIndicatorButton.setImage(#imageLiteral(resourceName: "circle-check-enabled-icon"), for: .normal)
    checkIndicatorButton.setImage(#imageLiteral(resourceName: "circle-check-disabled-icon"), for: .disabled)
    trackingFulfillButton.backgroundColor = UIColor.Porcelain.blueGrey
    trackingFulfillButton.setAttributedTitle(NSAttributedString(content: "Done".localized(),
                                                                font: UIFont.Porcelain.idealSans(14.0, weight: .book),
                                                                foregroundColor: UIColor.Porcelain.whiteTwo,
                                                                paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 14.0, characterSpacing: 0.5)), for: .normal)
  }
  
  @IBAction func fulfillTapped(_ sender: Any) {
    let newProgress = viewModel.progress + viewModel.incrementValue
    viewModel.progress = newProgress
    viewModel.isTrackingFulfilled = true
  }
}

extension DailyLogTrackingCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 170.0)
  }
}
