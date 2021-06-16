//
//  MyEmptyProductsViewController.swift
//  Porcelain
//
//  Created by Justine Rangel on 16/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

public protocol MyEmptyProductsViewModelProtocol: class {
  func goToProductsTapped()
}

public class MyEmptyProductsViewController: UIViewController {
  @IBOutlet private weak var titleLabel: DesignableLabel!
  @IBOutlet private weak var descriptionLabel: DesignableLabel!
  @IBOutlet private weak var subInfoLabel: DesignableLabel!
  
  @IBOutlet private weak var actionButton: DesignableButton!
  
  private var viewModel: MyEmptyProductsViewModelProtocol!
  
  public func configure(viewModel: MyEmptyProductsViewModelProtocol) {
    self.viewModel = viewModel
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  @IBAction private func actionTapped(_ sender: Any) {
    viewModel.goToProductsTapped()
  }
}

extension MyEmptyProductsViewController: ControllerConfigurable, NavigationConfigurable {
  public static var segueIdentifier: String {
    return "showMyEmptyProducts"
  }
  
  public func setupUI() {
    view.backgroundColor = UIColor.Porcelain.mainBackground
    let titleContent = "Hello {customer_name},\n".replacingOccurrences(of: "{customer_name}", with: User.getUserAccount()?.firstname ?? "")

    let attributedTitle = NSMutableAttributedString(
      attributedString: NSAttributedString(
        content: titleContent,
        font: UIFont.Porcelain.openSans(14.0, weight: .regular),
        foregroundColor: UIColor.Porcelain.greyishBrown,
        paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 22.0, characterSpacing: 0.5, alignment: .center, lineBreakMode: .byWordWrapping)))
    attributedTitle.append(NSAttributedString(
      content: "Welcome to Porcelain!",
      font: UIFont.Porcelain.openSans(16.0, weight: .regular),
      foregroundColor: UIColor.Porcelain.greyishBrown,
      paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 22.0, characterSpacing: 1.0, alignment: .center, lineBreakMode: .byWordWrapping)))
    
    titleLabel.attributedText = attributedTitle
    let description = "By harnessing some of nature's most powerful ingredients and distilling them into technologically advanced formulations, Porcelain now houses 14 products that are suited for all skin types. Reawaken your skin's remarkable, innate healing abilities with the best of nature and technology."
    descriptionLabel.attributedText = NSAttributedString(
      content: description,
      font: UIFont.Porcelain.openSans(14.0, weight: .regular),
      foregroundColor: UIColor.Porcelain.warmGrey,
      paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 22.0, characterSpacing: 0.5, alignment: .center, lineBreakMode: .byWordWrapping))
    subInfoLabel.attributedText = NSAttributedString(
      content: "THE FINE BALANCE AND\nTHE POWER OF BOTH.\n\nTHE ESSENCE OF EVERYTHING\nWE DO.",
      font: UIFont.Porcelain.idealSans(14.0, weight: .book),
      foregroundColor: UIColor.Porcelain.metallicBlue,
      paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 22.0, characterSpacing: 3.0, alignment: .center, lineBreakMode: .byWordWrapping))
    actionButton.setAttributedTitle(NSAttributedString(
      content: "START YOUR JOURNEY NOW".localized(),
      font: UIFont.Porcelain.idealSans(14.0, weight: .book),
      foregroundColor: UIColor.Porcelain.whiteTwo,
      paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 14.0, characterSpacing: 1.0)), for: .normal)
  }
  
  public func setupController() {
  }
  
  public func setupObservers() {
  }
}
