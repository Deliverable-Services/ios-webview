//
//  PackageCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 10/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import SwiftyJSON

public struct IndividualData {
  var id: String?
  var name: String?
  var sessionsLeft: Int
  var sessionsTotal: Int
  
  init(data: JSON) {
    id = data.id.string
    name = data.name.string
    sessionsLeft = data.sessionLeft.intValue
    sessionsTotal = data.sessionsTotal.intValue
  }
}

public struct PackageData {
  var id: String?
  var name: String?
  var invoiceID: String?
  var purchaseAt: Date?
  var expiresAt: Date?
  var treatments: [IndividualData]?
  
  init(data: JSON) {
    id = data.packageID.string
    name = data.name.string
    invoiceID = data.invoiceID.string
    purchaseAt = data.purchaseAt.toDate(format: .ymdhmsDateFormat)
    expiresAt = data.expiresAt.toDate(format: .ymdhmsDateFormat)
    treatments = data.treatments.array?.map({ IndividualData(data: $0) })
  }
  
  public static func parseData(_ data: JSON) -> [PackageData]? {
    return data.array?.map({ PackageData(data: $0) })
  }
}

public final class PackageCell: UITableViewCell {
  @IBOutlet private weak var shadowView: DesignableView!
  @IBOutlet private weak var containerView: DesignableView!
  @IBOutlet private weak var groupedView: GroupedView!
  @IBOutlet private weak var individualStack: UIStackView!
  
  public var isGrouped: Bool = true {
    didSet {
      groupedView.isHidden = !isGrouped
      individualStack.isHidden = isGrouped
    }
  }
  
  public var color: UIColor = .clear {
    didSet {
      groupedView.color = color
    }
  }
  
  public var data: PackageData? {
    didSet {
      groupedView.data = data
      generateIndividuals()
    }
  }
  
  public override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    if isGrouped {
      groupedView.isSelected = selected
      individualStack.isHidden = !selected
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    if isGrouped {
      if isSelected  {
        shadowView.removeShadow()
        containerView.cornerRadius = 7.0
        containerView.borderWidth = 1.0
        containerView.borderColor = .whiteThree
        containerView.backgroundColor = .whiteSix
      } else {
        shadowView.addShadow(appearance: .default)
        containerView.cornerRadius = 7.0
        containerView.borderWidth = 0.0
        containerView.borderColor = .clear
        containerView.backgroundColor = .clear
      }
    } else {
      shadowView.removeShadow()
      containerView.cornerRadius = 7.0
      containerView.borderWidth = 1.0
      containerView.borderColor = .whiteThree
      containerView.backgroundColor = .whiteSix
    }
  }
  
  private func generateIndividuals() {
    guard let treatments = data?.treatments, !treatments.isEmpty else { return }
    individualStack.removeAllArrangedSubviews()
    treatments.enumerated().forEach { (indx, data) in
      let individualView = IndividualView(frame: .zero)
      individualView.addHeightConstraint(52.0)
      individualView.isSeparatorShown = (treatments.count - 1) > indx
      individualView.data = data
      individualStack.addArrangedSubview(individualView)
    }
  }
}

// MARK: - CellProtocol
extension PackageCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 52.0)
  }
}

public final class GroupedView: DesignableView {
  @IBOutlet private weak var colorView: UIView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 14.0))
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var expiryLabel: UILabel! {
    didSet {
      expiryLabel.font = .openSans(style: .regular(size: 12.0))
      expiryLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var expandImageView: UIImageView!
  
  public var color: UIColor = .clear {
    didSet {
      colorView.backgroundColor = color
    }
  }
  public var data: PackageData? {
    didSet {
      titleLabel.text = data?.name
      expiryLabel.text = String(format: "Expiry: %@", data?.expiresAt?.toString(WithFormat: "MM/dd/yyyy") ?? "")
    }
  }
  
  public var isSelected: Bool = false {
    didSet {
      expandImageView.image = isSelected ? UIImage.icChevronUp.maskWithColor(.gunmetal): UIImage.icChevronDown.maskWithColor(.gunmetal)
    }
  }
}

public final class IndividualView: DesignableView {
  @IBOutlet private weak var view: UIView! {
    didSet {
      view.backgroundColor = .clear
    }
  }
  @IBOutlet private weak var separatorView: UIView! {
    didSet {
      separatorView.backgroundColor = .whiteThree
    }
  }
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .light(size: 13.0))
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var countLabel: UILabel! {
    didSet {
      countLabel.font = .idealSans(style: .book(size: 16.0))
      countLabel.textColor = .gunmetal
    }
  }
  
  public var data: IndividualData? {
    didSet {
      titleLabel.text = data?.name
      countLabel.text = "x \(data?.sessionsLeft ?? 0)"
    }
  }
  
  public var isSeparatorShown: Bool = false  {
    didSet {
      separatorView.isHidden = !isSeparatorShown
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
    loadNib(IndividualView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
    backgroundColor = .whiteSix
  }
}
