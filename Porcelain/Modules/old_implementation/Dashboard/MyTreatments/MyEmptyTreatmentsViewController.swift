//
//  MyEmptyTreatmentsViewController.swift
//  Porcelain
//
//  Created by Justine Rangel on 16/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public class MyEmptyTreatmentsViewController: UIViewController {
  @IBOutlet private weak var descriptionLabel: DesignableLabel!
  @IBOutlet private weak var actionButton: DesignableButton!
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  @IBAction func actionTapped(_ sender: Any) {
    //TODO: go to my products
  }
}

extension MyEmptyTreatmentsViewController: ControllerProtocol, NavigationProtocol {
  public static var segueIdentifier: String {
    return "showMyEmptyTreatments"
  }
  
  public func setupUI() {
    hideBarSeparator()
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.backgroundColor = .clear
    generateLeftNavigationButton(image: #imageLiteral(resourceName: "dashboard-icon"), selector: #selector(dismissViewController))
    view.backgroundColor = UIColor.Porcelain.whiteFour
    descriptionLabel.attributedText = NSAttributedString(content: "The quick brown fox jumps over the lazy dog",
                                                         font: UIFont.Porcelain.idealSans(14.0, weight: .book),
                                                         foregroundColor: UIColor.Porcelain.warmGrey,
                                                         paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 24.0, characterSpacing: 0.2, alignment: .center, lineBreakMode: .byWordWrapping))
    actionButton.setAttributedTitle(NSAttributedString(content: "GO TO TREATMENTS".localized(),
                                                       font: UIFont.Porcelain.idealSans(13.0, weight: .book),
                                                       foregroundColor: UIColor.Porcelain.whiteTwo,
                                                       paragraphStyle: ParagraphStyle.makeCustomStyle(lineHeight: 13.0, characterSpacing: 1.5)), for: .normal)
  }
  
  public func setupController() {
  }
  
  public func setupObservers() {
  }
  
  public override func dismissViewController() {
    navigationController?.dismissViewController()
  }
}
