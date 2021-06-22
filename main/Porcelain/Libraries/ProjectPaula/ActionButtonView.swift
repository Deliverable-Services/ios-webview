//
//  AddReviewView.swift
//  Porcelain
//
//  Created by Justine Rangel on 24/11/2018.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit

public final class ActionButtonView: UIView {
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var actionButton: DesignableButton! {
    didSet {
      actionButton.cornerRadius = 7.0
      actionButton.backgroundColor = .greyblue
      actionButton.setAttributedTitle(
        "Button".attributed.add(.appearance(DialogButtonAttributedTitleAppearance())),
        for: .normal)
    }
  }
  
  public var actionDidTapped: VoidCompletion?
  
  public var title: String? {
    didSet {
      guard let title = title else { return }
      actionButton.setAttributedTitle(
        title.attributed.add(.appearance(DialogButtonAttributedTitleAppearance())),
        for: .normal)
    }
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  private func commonInit() {
    loadNib(ActionButtonView.self)
    addSubview(view)
    view.addSideConstraintsWithContainer()
  }
  
  @IBAction private func actionTapped(_ sender: Any) {
    actionDidTapped?()
  }
}
