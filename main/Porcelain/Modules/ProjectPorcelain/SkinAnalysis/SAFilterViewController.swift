//
//  SAFilterViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 12/12/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class SAFilterViewController: UIViewController {
  public enum SAFilterType {
    case filter
    case changeView
  }
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 13.0))
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var mainChoiceStack: UIStackView!
  @IBOutlet private weak var specificsContainerStack: UIStackView!
  @IBOutlet private weak var specificAreaLabel: UILabel! {
    didSet {
      specificAreaLabel.font = .openSans(style: .regular(size: 12.0))
      specificAreaLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var specificsStack: UIStackView!
  @IBOutlet private weak var applyButton: DesignableButton! {
    didSet {
      applyButton.cornerRadius = 7.0
      applyButton.backgroundColor = .greyblue
      applyButton.setAttributedTitle(
        "APPLY".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 13.0)))]),
        for: .normal)
    }
  }
  
  private var isApplyEnabled: Bool = true {
    didSet {
      guard isApplyEnabled != oldValue else { return }
      if isApplyEnabled {
        applyButton.cornerRadius = 7.0
        applyButton.backgroundColor = .greyblue
        applyButton.setAttributedTitle(
          "APPLY".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 13.0)))]),
          for: .normal)
      } else {
        applyButton.cornerRadius = 7.0
        applyButton.backgroundColor = .whiteThree
        applyButton.setAttributedTitle(
          "APPLY".attributed.add([.color(.bluishGrey), .font(.openSans(style: .semiBold(size: 13.0)))]),
          for: .normal)
      }
    }
  }
  
  fileprivate var selectedValue: String?
  fileprivate var type: SAFilterType = .filter
  fileprivate var applyDidTapped: ((SAFilterViewController.SAFilterType, String) -> Void)?
  private var specifics: [String] = [] {
    didSet {
      reloadSpecificChoices()
    }
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  private func reloadSpecificChoices() {
    specificsStack.removeAllArrangedSubviews()
    let selectedValues = selectedValue?.components(separatedBy: ",")
    specifics.enumerated().forEach { (indx, title) in
      let specificButton = UIButton()
      specificButton.tag = indx + 10
      specificButton.setAttributedTitle(
        UIImage.icCheckBoxUnSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    \(title)".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .normal)
      specificButton.setAttributedTitle(
        UIImage.icCheckBoxSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    \(title)".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .selected)
      specificButton.addTarget(self, action: #selector(specificsTapped(_:)), for: .touchUpInside)
      if selectedValues?.contains(title) ?? false || selectedValue == "" {
        specificButton.isSelected = true
      }
      specificsStack.addArrangedSubview(specificButton)
    }
  }
  
  @IBAction private func closeTapped(_ sender: Any) {
    dismissPresenter()
  }
  
  @objc
  private func mainChoiceTapped(_ sender: UIButton) {
    switch type {
    case .filter:
      sender.isSelected = !sender.isSelected
      specificsStack.subviews.compactMap({ $0 as? UIButton }).forEach { (button) in
        button.isSelected = sender.isSelected
      }
      isApplyEnabled = specificsStack.subviews.compactMap({ $0 as? UIButton }).contains(where: { $0.isSelected })
    case .changeView:
      mainChoiceStack.subviews.compactMap({ $0 as? UIButton }).forEach { (button) in
        button.isSelected = button == sender
      }
    }
  }
  
  @objc
  private func specificsTapped(_ sender: UIButton) {
    switch type {
     case .filter:
      sender.isSelected = !sender.isSelected
      let hasSelected = specificsStack.subviews.compactMap({ $0 as? UIButton }).contains(where: { !$0.isSelected })
      mainChoiceStack.subviews.compactMap({ $0 as? UIButton }).first?.isSelected = !hasSelected
      isApplyEnabled = specificsStack.subviews.compactMap({ $0 as? UIButton }).contains(where: { $0.isSelected })
     case .changeView:
       break
     }
  }
  
  @IBAction private func applyTapped(_ sender: Any) {
    guard isApplyEnabled else { return }
    dismissPresenter()
    switch type {
    case .filter:
      let values = specificsStack.subviews.compactMap({ $0 as? UIButton }).filter({ $0.isSelected }).map({ $0.tag - 10 }).compactMap({ specifics[$0] })
      if values.count == specifics.count {
        applyDidTapped?(type, "All")
      } else {
        applyDidTapped?(type, values.joined(separator: ","))
      }
    case .changeView:
      guard let tag = mainChoiceStack.subviews.compactMap({ $0 as? UIButton }).filter({ $0.isSelected }).first?.tag else { return }
      if tag == 1110 {
        applyDidTapped?(type, "monthly")
      } else {
        applyDidTapped?(type, "yearly")
      }
    }
  }
}

// MARK: - ControllerProtocol
extension SAFilterViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("SAFilterViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    switch type {
    case .filter:
      titleLabel.text = "FILTER"
      specificsContainerStack.isHidden = false
      mainChoiceStack.removeAllArrangedSubviews()
      let allButton = UIButton()
      allButton.setAttributedTitle(
        UIImage.icCheckBoxUnSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    All".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .normal)
      allButton.setAttributedTitle(
        UIImage.icCheckBoxSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    All".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .selected)
      allButton.addTarget(self, action: #selector(mainChoiceTapped(_:)), for: .touchUpInside)
      if selectedValue == "" {
        allButton.isSelected = true
      }
      mainChoiceStack.addArrangedSubview(allButton)
      appDelegate.showLoading()
      PPAPIService.User.getMySkinAnalysisAreaSelection().call { (response) in
        switch response {
        case .success(let result):
          self.specifics = result.data.arrayValue.compactMap({ $0.area.string })
          self.selectedValue = nil
          appDelegate.hideLoading()
        case .failure(let error):
          appDelegate.hideLoading()
          self.showAlert(title: "Oops!", message: error.localizedDescription)
          self.selectedValue = nil
        }
      }
    case .changeView:
      titleLabel.text = "CHANGE VIEW"
      specificsContainerStack.isHidden = true
      mainChoiceStack.removeAllArrangedSubviews()
      let monthlyButton = UIButton()
      monthlyButton.tag = 1110
      monthlyButton.setAttributedTitle(
        UIImage.icRadioUnselected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    Monthly".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .normal)
      monthlyButton.setAttributedTitle(
        UIImage.icRadioSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    Monthly".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .selected)
      monthlyButton.addTarget(self, action: #selector(mainChoiceTapped(_:)), for: .touchUpInside)
      mainChoiceStack.addArrangedSubview(monthlyButton)
      let yearlyButton = UIButton()
      yearlyButton.tag = 1111
      yearlyButton.setAttributedTitle(
        UIImage.icRadioUnselected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    Yearly".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .normal)
      yearlyButton.setAttributedTitle(
        UIImage.icRadioSelected.attributed.add(.baseline(offset: -3.0)).append(
          attrs: "    Yearly".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .regular(size: 13.0))),
            .baseline(offset: 3.0)])),
        for: .selected)
      yearlyButton.addTarget(self, action: #selector(mainChoiceTapped(_:)), for: .touchUpInside)
      if selectedValue == "monthly" {
        monthlyButton.isSelected = true
      } else {
        yearlyButton.isSelected = true
      }
      mainChoiceStack.addArrangedSubview(yearlyButton)
    }
  }
  
  public func setupObservers() {
  }
}

// MARK: - PresentedControllerProtocol
extension SAFilterViewController: PresentedControllerProtocol {
  public var presenterType: PresenterType? {
    switch type {
    case .filter:
      return .popover(size: CGSize(width: UIScreen.main.bounds.width - 48.0, height: 550.0))
    case .changeView:
      return .popover(size: CGSize(width: UIScreen.main.bounds.width - 48.0, height: 244.0))
    }
  }
}

public protocol SAFilterPresenterProtocol {
  func saFilterDidApply(type: SAFilterViewController.SAFilterType, value: String)
  func saFilterSelectedValue(type: SAFilterViewController.SAFilterType) -> String
}

extension SAFilterPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showSAFilter(type: SAFilterViewController.SAFilterType) {
    let saFilterViewController = UIStoryboard.get(.projectPorcelain).getController(SAFilterViewController.self)
    saFilterViewController.type = type
    saFilterViewController.applyDidTapped = { [weak self] (type, value) in
      guard let `self` = self else { return }
      self.saFilterDidApply(type: type, value: value)
    }
    saFilterViewController.selectedValue = saFilterSelectedValue(type: type)
    PresenterViewController.show(
      presentVC: saFilterViewController,
      settings: [
        .appearance(.default)],
      onVC: self)
  }
}
