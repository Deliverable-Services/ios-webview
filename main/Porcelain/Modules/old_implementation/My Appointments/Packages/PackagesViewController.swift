//
//  PackagesViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 04/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import UIKit
import DropDown

private struct Constant {
  static let barTitle = "Existing sessions".localized()
}

fileprivate enum Section: String {
  case individual = "Individual (sessions left)"
  case grouped = "Grouped (sessions left)"
}

class PackagesViewController: UIViewController {
  @IBOutlet private var dropdownBtn: DropDownButton!
  @IBOutlet weak var individualPackagesContainerView: UIView!
  @IBOutlet weak var groupedPackagesContainerView: UIView!
  
  weak var groupedChild: PackageHolder?
  weak var individualChild: PackageHolder?
  
  private var dropdown: DropDown?
  private var sections: [Section] = [.individual, .grouped]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setUpUI()
  }
  
  // MARK: - Private methods
  private func setUpUI() {
    self.view.backgroundColor = UIColor.Porcelain.whiteFour
    self.initNavBar()
    self.initButton()
  }
  
  private func initButton() {
    dropdownBtn.backgroundColor = UIColor.Porcelain.metallicBlue
    dropdownBtn.semanticContentAttribute = .forceRightToLeft
    dropdownBtn.addTarget(self, action: #selector(showSections), for: .touchUpInside)
    
    dropdown = DropDown()
    dropdown?.anchorView = individualPackagesContainerView
    dropdown?.direction = .bottom
    dropdown?.dataSource = sections.compactMap({ $0.rawValue })
    dropdown?.dismissMode = .onTap
    dropdown?.selectionAction = { [unowned self] (index: Int, item: String) in
      let selectedSection = self.sections[index]
      self.select(section: selectedSection)
    }
    dropdown?.textColor = UIColor.Porcelain.metallicBlue
    dropdown?.textFont = UIFont.Porcelain.openSans(13, weight: .semiBold)
    dropdown?.selectionBackgroundColor = UIColor.Porcelain.whiteFour
    dropdown?.separatorColor = UIColor.Porcelain.whiteFour
    dropdown?.backgroundColor = UIColor.Porcelain.whiteTwo
    dropdown?.shadowOpacity = 0.2
    dropdown?.cellHeight = 48
    dropdown?.dimmedBackgroundColor = UIColor.clear
    
    self.select(section: sections[0])
  }
  
  private func select(section: Section) {
    dropdown?.hide()
    let pStyle = ParagraphStyle()
    pStyle.alignment = .left
    let attTitle = section.rawValue
      .withFont(UIFont.Porcelain.openSans(13, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.whiteTwo)
      .withKern(2.0)
      .withParagraphStyle(pStyle)
    dropdownBtn.imageView?.tintColor = UIColor.Porcelain.whiteTwo
    dropdownBtn.setAttributedTitle(attTitle, for: .normal)
    dropdownBtn.setImage(#imageLiteral(resourceName: "arrowDown").withRenderingMode(.alwaysTemplate), for: .normal)
    didSelect(section: section)
  }
  
  private func didSelect(section: Section) {
    self.individualPackagesContainerView.isHidden = section == .grouped
    self.groupedPackagesContainerView.isHidden = section == .individual
    self.individualChild?.isActive = section == .individual
    self.groupedChild?.isActive = section == .grouped
  }
  
  private func initNavBar() {
    let closeBarButtonItem =
      UIBarButtonItem(image: #imageLiteral(resourceName: "ic-close").withRenderingMode(.alwaysOriginal),
                      style: .plain, target: self,
                      action: #selector(TreatmentHistoryViewController.dismissViewController)
    )
    self.navigationItem.leftBarButtonItem = closeBarButtonItem
    self.navigationController?.navigationBar.barTintColor = UIColor.Porcelain.whiteFour
    
    let navLabel = UILabel()
    let navTitle: NSAttributedString = Constant.barTitle.uppercased()
      .withFont(UIFont.Porcelain.openSans(14.5, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(2)
    
    navLabel.attributedText = navTitle
    self.navigationItem.titleView = navLabel
  }
  
  // MARK: - Action methods
  @objc func showSections() {
    dropdownBtn.imageView?.tintColor = UIColor.Porcelain.whiteTwo
    dropdownBtn.setImage(#imageLiteral(resourceName: "arrow_up").withRenderingMode(.alwaysOriginal), for: .normal)
    dropdown?.show()
  }
  
  fileprivate func navigate(_ identifier: StoryboardIdentifier) {
    DispatchQueue.main.async {
      self.performSegue(withIdentifier: identifier.rawValue, sender: nil)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = StoryboardIdentifier(rawValue: segue.identifier ?? "") else {
      return
    }
    var destinationVC: UIViewController? = segue.destination
    if let navigationVC = segue.destination as? UINavigationController {
      destinationVC = navigationVC.childViewControllers.first
    }
    
    switch identifier {
    case .toIndividual:
      let vc = destinationVC as? PackageHolder
      individualChild = vc
    case .toGrouped:
      let vc = destinationVC as? PackageHolder
      groupedChild = vc
    }
  }
}

private enum StoryboardIdentifier: String {
  case toIndividual = "embedIndividual"
  case toGrouped = "embedGrouped"
}

