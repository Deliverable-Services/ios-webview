//
//  ContactUsTCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 19/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class ContactUsTCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .semiBold(size: 13.0))
    }
  }
  
  @IBOutlet private weak var subtitleLabel: UILabel! {
    didSet {
      subtitleLabel.font = .openSans(style: .regular(size: 13.0))
    }
  }
  
  public var branch: Branch? {
    didSet {
      titleLabel.text = branch?.name
      subtitleLabel.text = branch?.address1
    }
  }
  
  public override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    titleLabel.textColor = selected ? .white: .bluishGrey
    subtitleLabel.textColor = selected ? .white: .bluishGrey
    backgroundColor = selected ? .greyblue: .white
  }
}

// MARK: - CellProtocol
extension ContactUsTCell: CellProtocol {
  public static var defaultSize: CGSize {
    fatalError("ContactUsTCell defaultSize not set")
  }
}
