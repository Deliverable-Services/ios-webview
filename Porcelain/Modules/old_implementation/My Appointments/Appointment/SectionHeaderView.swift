//
//  SectionHeaderView.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 03/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import UIKit

class SectionHeaderView: UIView {
  static var estimatedHeight: CGFloat = 44
  
  @IBOutlet weak var titleLabel: UILabel!
  
  private var view: UIView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    xibSetup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    xibSetup()
  }
  
  private func xibSetup() {
    view = loadViewFromNib()
    view.frame = bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    
    addSubview(view)
  }
  
  private func loadViewFromNib() -> UIView {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: String(describing: SectionHeaderView.self), bundle: bundle)
    let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    
    return view
  }
}
