//
//  InputAccessoryPresenterView.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 05/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit

public final class InputAccessoryPresenterView: UIView {
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var stackView: UIStackView!
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  public convenience init(view: UIView) {
    self.init(frame: .zero)
    
    attachView(view)
  }
  
  private func commonInit() {
    loadNib(InputAccessoryPresenterView.self)
    addSubview(view)
    view.addSideConstraintsWithContainer()
    autoresizingMask = [.flexibleHeight]
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    invalidateIntrinsicContentSize()
  }
  
  public func attachView(_ view: UIView) {
    stackView.removeAllArrangedSubviews()
    stackView.addArrangedSubview(view)
  }

  public override var intrinsicContentSize: CGSize {
    return CGSize(width: bounds.width, height: view.bounds.height)
  }
}
