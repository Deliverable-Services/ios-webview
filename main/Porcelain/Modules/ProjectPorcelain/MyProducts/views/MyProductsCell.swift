//
//  MyProductsCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 27/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import R4pidKit

private struct AttributedReplenishTextAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.4
  var alignment: NSTextAlignment? = .left
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? = 20.0
  var font: UIFont? = .openSans(style: .semiBold(size: 13.0))
  var color: UIColor? = .lightNavy
}

public final class MyProductsCell: UICollectionViewCell, Shadowable, Designable {
  public var shadowLayer: CAShapeLayer!
  public var cornerRadius: CGFloat = 0.0
  public var borderWidth: CGFloat = 0.0
  public var borderColor: UIColor = .clear
  
  @IBOutlet private weak var scrollView: UIScrollView! {
    didSet {
      scrollView.alwaysBounceVertical = false
    }
  }
  @IBOutlet private weak var imageView: LoadingImageView! {
    didSet {
      imageView.cornerRadius = 1.0
      imageView.contentMode = .scaleAspectFit
    }
  }
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 16.0))
      titleLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var priceLabel: UILabel! {
    didSet {
      priceLabel.font = .openSans(style: .regular(size: 14.0))
      priceLabel.textColor = .gunmetal
      priceLabel.isHidden = true
    }
  }
  @IBOutlet private weak var quantityEditView: QuantityEditView!
  @IBOutlet private weak var purchaseDateLabel: UILabel!
  @IBOutlet private weak var benefitsTableView: PorcelainEnumeratedTableView!
  @IBOutlet private weak var usageView: MyProductUsageView!
  @IBOutlet private weak var replenishStack: UIStackView!
  @IBOutlet private weak var replenishLabel: UILabel!
  @IBOutlet private weak var replenishButton: DesignableButton! {
    didSet {
      replenishButton.setAttributedTitle(
        "REPLENISH NOW".attributed.add(.appearance(DialogButtonAttributedTitleAppearance())),
        for: .normal)
      var appearance = ShadowAppearance.default
      appearance.fillColor = .greyblue
      replenishButton.shadowAppearance = appearance
    }
  }
  @IBOutlet private weak var leaveAReviewButton: UIButton! {
    didSet {
      var appearance = DialogButtonAttributedTitleAppearance()
      appearance.color = .lightNavy
      leaveAReviewButton.setAttributedTitle("Leave a Review".attributed.add(.appearance(appearance)), for: .normal)
    }
  }
  
  private var hasQuantity: Bool = false {
    didSet {
      if hasQuantity {
        backgroundColor = .clear
        addShadow(appearance: .default)
      } else {
        backgroundColor = .whiteFive
        cornerRadius = 7.0
        updateLayer()
        removeShadow()
      }
    }
  }
  
  public var didRemoveProductQuantity: ((CustomerProduct, Int) -> Void)?
  public var doneDidTapped: StringCompletion?
  public var replenishDidTapped: StringCompletion?
  public var leaveAReviewDidTapped: ((CustomerProduct) -> Void)?
  
  public var product: CustomerProduct? {
    didSet {
      imageView.url = product?.image
      titleLabel.text = [product?.categoryName, product?.name].compactMap({ $0 }).joined(separator: ", ")
      priceLabel.text = String(format: "%@%.2f", AppConstant.currencySymbol, product?.price ?? 0.0)
      quantityEditView.quantity = Int(product?.quantity ?? 0)
      purchaseDateLabel.attributedText = "Purchase Date: ".attributed.add([
        .color(.bluishGrey), .font(.openSans(style: .regular(size: 13.0)))]).append(
          attrs: "\(product?.datePurchased?.toString(WithFormat: "MM/dd/yy") ?? "")".attributed.add([
            .color(.bluishGrey),
            .font(.openSans(style: .semiBold(size: 13.0)))]))
      if let benefits = product?.benefits {
        benefitsTableView.isHidden = false
        benefitsTableView.iconText = .check
        benefitsTableView.fontColor = .bluishGrey
        benefitsTableView.font = .openSans(style: .regular(size: 13.0))
        benefitsTableView.contents = benefits
      } else {
        benefitsTableView.isHidden = true
      }
      if (product?.quantity ?? 0) == 0 {
        hasQuantity = false
        replenishStack.isHidden = false
        replenishLabel.attributedText = """
          It seems like you’ve replenished all your
          \([product?.categoryName, product?.name].compactMap({ $0 }).joined(separator: ", ")).

          Replenish now and get 10% off!
          """.attributed.add(.appearance(AttributedReplenishTextAppearance()))
        usageView.product = nil
      } else {
        hasQuantity = true
        replenishStack.isHidden = true
        usageView.product = nil//product //hides
      }
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    quantityEditView.didRemoveQuantity = { [weak self] quantity in //return negative if removed; return + if add and zero no changes
      guard let `self` = self else { return }
      guard let product = self.product else { return }
      self.didRemoveProductQuantity?(product, quantity)
    }
    usageView.doneDidTapped = { [weak self] in
      guard let `self` = self else { return }
      guard let productID = self.product?.id else { return }
      self.doneDidTapped?(productID)
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    if hasQuantity {
      backgroundColor = .clear
      addShadow(appearance: .default)
    } else {
      backgroundColor = .whiteFive
      cornerRadius = 7.0
      updateLayer()
      removeShadow()
    }
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    
    imageView.image = nil
    hasQuantity = false
  }
  
  @IBAction private func replenishTapped(_ sender: Any) {
    guard let productID = product?.id else { return }
    replenishDidTapped?(productID)
  }
  
  @IBAction private func leaveAReviewTapped(_ sender: Any) {
    guard let product = product else { return }
    leaveAReviewDidTapped?(product)
  }
}

// MARK: - CellProtocol
extension MyProductsCell: CellProtocol {
  public static var defaultSize: CGSize {
    fatalError("MyProductsCell defaultSize not set")
  }
}

public final class QuantityEditView: UIView {
  @IBOutlet private weak var quantityLabel: UILabel!
  @IBOutlet private weak var cancelButton: UIButton!
  @IBOutlet private weak var editContainerStack: UIStackView!
  @IBOutlet private weak var editButton: UIButton!
  @IBOutlet private weak var editStack: UIStackView!
  @IBOutlet private weak var incrementLabel: UILabel!
  
  public var didRemoveQuantity: IntCompletion?
  
  private var tempQuantity: Int = 0
  
  private var isEditing: Bool = false {
    didSet {
      updateUI()
    }
  }
  
  public var quantity: Int = 0 {
    didSet {
      tempQuantity = 1
      isEditing = false
    }
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    updateUI()
  }
  
  private func updateUI() {
    quantityLabel.attributedText = "Qty: ".attributed.add([.color(.bluishGrey), .font(.openSans(style: .regular(size: 13.0)))]).append(
      attrs: "\(quantity)".attributed.add([.color(.bluishGrey), .font(.openSans(style: .semiBold(size: 13.0)))]))
    incrementLabel.text = "\(tempQuantity)"
    editContainerStack.isHidden = quantity == 0
    editButton.setImage(isEditing ? UIImage.icEditConfirm: UIImage.icEdit, for: .normal)
    editStack.isHidden = !isEditing
    cancelButton.isHidden = !isEditing
  }
  
  @IBAction private func incrementTapped(_ sender: Any) {
    guard tempQuantity < quantity else { return }
    tempQuantity += 1
    updateUI()
  }
  
  @IBAction private func decrementTapped(_ sender: Any) {
    guard tempQuantity > 1 else { return }
    tempQuantity -= 1
    updateUI()
  }
  
  @IBAction private func cancelTapped(_ sender: Any) {
    tempQuantity = 1
    isEditing = false
  }
  
  @IBAction private func editTapped(_ sender: Any) {
    let isEditing = self.isEditing
    self.isEditing = !isEditing
    if isEditing {
      didRemoveQuantity?(tempQuantity)
    }
  }
}

public final class MyProductUsageView: UIView {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .semiBold(size: 13.0))
      titleLabel.textColor = .gunmetal
      titleLabel.text = "Product Usage"
    }
  }
  @IBOutlet private weak var descriptionLabel: UILabel!
  @IBOutlet private weak var progressContainerView: DesignableView! {
    didSet {
      progressContainerView.cornerRadius = 7.0
      progressContainerView.backgroundColor = .whiteThree
    }
  }
  @IBOutlet private weak var progressView: DesignableView! {
    didSet {
      progressView.cornerRadius = 7.0
      progressView.backgroundColor = .greenishTealTwo
    }
  }
  @IBOutlet private weak var progressConstraint: NSLayoutConstraint!
  @IBOutlet private weak var doneButton: UIButton! {
    didSet {
      doneButton.setAttributedTitle(
        "DONE".attributed.add([.color(.lightNavy), .font(.openSans(style: .semiBold(size: 12.0)))]),
        for: .normal)
    }
  }
  
  private var usage: Double = 0.0 {
    didSet {
      progressConstraint.constant = progressContainerView.bounds.width * CGFloat(usage/100)
    }
  }
  
  public var doneDidTapped: VoidCompletion?
  
  public var product: CustomerProduct? {
    didSet {
      if let usage = product?.usage, usage > -1 {
        isHidden = false
        descriptionLabel.attributedText = "\(product?.name ?? ""): ".attributed.add([
          .color(.bluishGrey), .font(.openSans(style: .regular(size: 13.0)))]).append(
            attrs: String(format: "%.2f%@", usage, "%").attributed.add([
              .color(.greenishTealTwo), .font(.openSans(style: .semiBold(size: 13.0)))]))
        self.usage = usage
      } else {
        isHidden = true
      }
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    progressConstraint.constant = progressContainerView.bounds.width * CGFloat(usage/100)
  }
  
  @IBAction private func doneTapped(_ sender: Any) {
    doneDidTapped?()
  }
}
