//
//  MyProductsItemCell.swift
//  Porcelain
//
//  Created by Justine Rangel on 14/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage
import SwiftyJSON

public struct ProductConsumption {
  var id: String?
  var zID: String?
  var isDone: Bool
  var name: String?
  var percentage: Double
  var productID: String?
  var purchaseID: String?
  var createdAt: String?
  var updatedAt: String?
  
  init(json: JSON) {
    id = json[PorcelainAPIConstant.Key.id].string
    zID = json[PorcelainAPIConstant.Key.zID].string
    isDone = json[PorcelainAPIConstant.Key.isDone].boolValue
    name = json[PorcelainAPIConstant.Key.name].string
    percentage = json[PorcelainAPIConstant.Key.percentage].string?.toNumber().doubleValue ?? 0.0
    productID = json[PorcelainAPIConstant.Key.productID].string
    purchaseID = json[PorcelainAPIConstant.Key.purchaseID].string
    createdAt = json[PorcelainAPIConstant.Key.created_at].string
    updatedAt = json[PorcelainAPIConstant.Key.updated_at].string
  }
}

extension ProductConsumption {
  public static func generateConsumptions(json: JSON) -> [ProductConsumption] {
    guard let array = json.array, !array.isEmpty else { return [] }
    return array.map({ ProductConsumption(json: $0) })
  }
}

public protocol MyProductsItemViewModelProtocol {
  var product: Product { get }
  var imageURL: String? { get }
  var title: String? { get }
  var price: String? { get }
  var purchaseDate: String? { get }
  var quantity: String { get }
  var description: String? { get }
  var usage: String? { get }
  var benefits: [String]? { get }
  var ingredients: [String]? { get }
  var frequency: String? { get }
  var numberOfPumps: String? { get }
  var consumptions: [ProductConsumption] { get }
}

public struct MyProductsItemViewModel: MyProductsItemViewModelProtocol {
  init(product: Product) {
    self.product = product
    imageURL = product.imageURL
    title = product.name
    price = product.price
    quantity = concatenate(product.quantity)
    description = product.desc
    usage = product.usage
    if product.benefits?.trimmingCharacters(in: CharacterSet.whitespaces).count ?? 0 > 0 {
      benefits = product.benefits?.components(separatedBy: ",")
    }
    if product.ingredients?.trimmingCharacters(in: CharacterSet.whitespaces).count ?? 0 > 0 {
      ingredients = product.ingredients?.components(separatedBy: ",")
    }
    frequency = product.frequency
    numberOfPumps = product.numberOfPumps
    consumptions = ProductConsumption.generateConsumptions(json: JSON(parseJSON: product.consumptions ?? ""))
  }
  
  public private(set) var product: Product
  public private(set) var imageURL: String?
  public private(set) var title: String?
  public private(set) var price: String?
  public private(set) var quantity: String
  public var purchaseDate: String? {
    return product.purchaseDate?.toDate(format: "yyyy-MM-dd HH:mm:ss")?.toString(WithFormat: "MM/dd/yy")
  }
  public private(set) var description: String?
  public private(set) var usage: String?
  public private(set) var benefits: [String]?
  public private(set) var ingredients: [String]?
  public private(set) var frequency: String?
  public private(set) var numberOfPumps: String?
  public private(set) var consumptions: [ProductConsumption]
}

public final class MyProductsItemCell: UICollectionViewCell, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var purchaseDateLabel: UILabel!
  @IBOutlet private weak var quantityLabel: UILabel!
  @IBOutlet private weak var usageLabel: UILabel!
  @IBOutlet private weak var benefitsTableView: PorcelainEnumeratedTableView!
  @IBOutlet private weak var benefitsTableHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var ingredientLabelContainer: UIView!
  @IBOutlet private weak var ingredientsLabel: UILabel!
  @IBOutlet private weak var ingredientsTableView: PorcelainEnumeratedTableView!
  @IBOutlet private weak var ingredientsTableHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var frequencyContainerView: UIView!
  @IBOutlet private weak var numberOfPumpsLabel: UILabel!
  @IBOutlet private weak var frequencyLabel: UILabel!
  @IBOutlet private weak var productUsageStack: UIStackView!
  @IBOutlet private weak var productUsageTitleLabel: UILabel!
  @IBOutlet private weak var productUsageTableView: MyProductsUsageTableView!
  @IBOutlet private weak var productUsageTableHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var addAReviewButton: UIButton!
  
  public var addAReviewDidTapped: StringCompletion?
  
  private var viewModel: MyProductsItemViewModelProtocol!
  
  public func configure(viewModel: MyProductsItemViewModelProtocol) {
    self.viewModel = viewModel
    let attributedTitle = NSMutableAttributedString()
    if let title = viewModel.title {
      attributedTitle.append(NSAttributedString(
        content: title,
        font: UIFont.Porcelain.openSans(14.0, weight: .semiBold),
        foregroundColor: UIColor.Porcelain.metallicBlue,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 20.0,
          characterSpacing: 0.6,
          lineBreakMode: .byWordWrapping)))
    }
    if let titlePrice = viewModel.price {
      attributedTitle.append(NSAttributedString(
        content: concatenate("\n", AppConstant.currencySymbol, titlePrice),
        font: UIFont.Porcelain.openSans(14.0, weight: .semiBold),
        foregroundColor: UIColor.Porcelain.greyishBrown,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 20.0,
          characterSpacing: 0.6,
          lineBreakMode: .byWordWrapping)))
    }
    titleLabel.attributedText = attributedTitle
    if let imageURL = URL(string: viewModel.imageURL ?? "") {
      imageView.af_setImage(withURL: imageURL)
    }
    if let purchaseDate = viewModel.purchaseDate {
      purchaseDateLabel.isHidden = false
      let attributedText = NSMutableAttributedString(attributedString: NSAttributedString(
        content: "Purchase Date: ",
        font: UIFont.Porcelain.openSans(13.0, weight: .regular),
        foregroundColor: UIColor.Porcelain.warmGrey,
        paragraphStyle: .makeCustomStyle(
          lineHeight: 20.0,
          characterSpacing: 0.46)))
      attributedText.append(NSAttributedString(
        content: purchaseDate,
        font: UIFont.Porcelain.openSans(13.0, weight: .semiBold),
        foregroundColor: UIColor.Porcelain.warmGrey,
        paragraphStyle: .makeCustomStyle(
          lineHeight: 20.0,
          characterSpacing: 0.46)))
      purchaseDateLabel.attributedText = attributedText
    } else {
      purchaseDateLabel.isHidden = true
    }
    let attributedQtyText = NSMutableAttributedString(attributedString: NSAttributedString(
      content: "Qty: ",
      font: UIFont.Porcelain.openSans(13.0, weight: .regular),
      foregroundColor: UIColor.Porcelain.warmGrey,
      paragraphStyle: .makeCustomStyle(
        lineHeight: 20.0,
        characterSpacing: 0.46)))
    attributedQtyText.append(NSAttributedString(
      content: viewModel.quantity,
      font: UIFont.Porcelain.openSans(13.0, weight: .semiBold),
      foregroundColor: UIColor.Porcelain.warmGrey,
      paragraphStyle: .makeCustomStyle(
        lineHeight: 20.0,
        characterSpacing: 0.46)))
    quantityLabel.attributedText = attributedQtyText
    if let usage = viewModel.usage {
      usageLabel.isHidden = false
      usageLabel.attributedText = NSAttributedString(
        content: usage,
        font: UIFont.Porcelain.openSans(13.0, weight: .regular),
        foregroundColor: UIColor.Porcelain.warmGrey,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 20.0,
          characterSpacing: 0.5))
    } else {
      usageLabel.isHidden = true
    }
    if let benefits = viewModel.benefits {
      benefitsTableView.iconImage = #imageLiteral(resourceName: "tick-icon").withRenderingMode(.alwaysTemplate)
      benefitsTableView.fontColor = UIColor.Porcelain.greyishBrown
      benefitsTableView.font = UIFont.Porcelain.idealSans(12.0, weight: .light)
      benefitsTableView.isHidden = false
      benefitsTableView.contents = benefits
      benefitsTableHeightConstraint.constant = benefitsTableView.height
    } else {
      benefitsTableView.isHidden = true
    }
    if let ingredients = viewModel.ingredients, ingredients.count > 0 {
      ingredientLabelContainer.isHidden = false
      ingredientsTableView.isHidden = false
      ingredientsLabel.attributedText = NSAttributedString(
        content: "KEY INGREDIENTS".localized(),
        font: UIFont.Porcelain.idealSans(12.0, weight: .book),
        foregroundColor: UIColor.Porcelain.blueGrey,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 22.0,
          characterSpacing: 0.5,
          lineBreakMode: .byWordWrapping))
      ingredientsTableView.iconImage = #imageLiteral(resourceName: "motif-blue-icon").withRenderingMode(.alwaysTemplate)
      ingredientsTableView.fontColor = UIColor.Porcelain.blueGrey
      ingredientsTableView.font = UIFont.Porcelain.idealSans(12.0, weight: .book)
      
      ingredientsTableView.contents = ingredients
      ingredientsTableHeightConstraint.constant = ingredientsTableView.height
    } else {
      ingredientLabelContainer.isHidden = true
      ingredientsTableView.isHidden = true
    }
    var isFrequencyContainerHidden = true
    if let numberOfPumps = viewModel.numberOfPumps, !numberOfPumps.isEmpty {
      let attributedText = NSMutableAttributedString(attributedString: NSAttributedString(
        content: "No of pumps: ",
        font: UIFont.Porcelain.openSans(13.0, weight: .regular),
        foregroundColor: UIColor.Porcelain.warmGrey,
        paragraphStyle: .makeCustomStyle(
          lineHeight: 20.0,
          characterSpacing: 0.46)))
      attributedText.append(NSAttributedString(
        content: numberOfPumps,
        font: UIFont.Porcelain.openSans(13.0, weight: .semiBold),
        foregroundColor: UIColor.Porcelain.warmGrey,
        paragraphStyle: .makeCustomStyle(
          lineHeight: 20.0,
          characterSpacing: 0.46)))
      numberOfPumpsLabel.attributedText = attributedText
      numberOfPumpsLabel.isHidden = false
      isFrequencyContainerHidden = false
    } else {
      numberOfPumpsLabel.isHidden = true
    }
    if let frequency = viewModel.frequency, !frequency.isEmpty {
      frequencyContainerView.isHidden = false
      let attributedText = NSMutableAttributedString(attributedString: NSAttributedString(
        content: "Every after ",
        font: UIFont.Porcelain.openSans(13.0, weight: .regular),
        foregroundColor: UIColor.Porcelain.warmGrey,
        paragraphStyle: .makeCustomStyle(
          lineHeight: 20.0,
          characterSpacing: 0.46)))
      attributedText.append(NSAttributedString(
        content: frequency,
        font: UIFont.Porcelain.openSans(13.0, weight: .semiBold),
        foregroundColor: UIColor.Porcelain.warmGrey,
        paragraphStyle: .makeCustomStyle(
          lineHeight: 20.0,
          characterSpacing: 0.46)))
      frequencyLabel.attributedText = attributedText
      frequencyLabel.isHidden = false
      isFrequencyContainerHidden = false
    } else {
      frequencyLabel.isHidden = true
    }
    frequencyContainerView.isHidden = isFrequencyContainerHidden
    if !viewModel.consumptions.isEmpty && AppConfiguration.enableMyProductsUsage {
      productUsageStack.isHidden = false
      productUsageTitleLabel.attributedText = NSAttributedString(
        content: "Product Usage",
        font: UIFont.Porcelain.openSans(13.0, weight: .semiBold),
        foregroundColor: UIColor.Porcelain.warmGrey,
        paragraphStyle: .makeCustomStyle(
          lineHeight: 20.0,
          characterSpacing: 0.4))
      productUsageTableView.contents = viewModel.consumptions
      productUsageTableHeightConstraint.constant = productUsageTableView.height
    } else {
      productUsageStack.isHidden = true
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    addShadow(cornerRadius: 7.0)
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    addAReviewButton.setAttributedTitle(NSAttributedString(
      content: "LEAVE A REVIEW",
      font: UIFont.Porcelain.idealSans(14.0, weight: .book),
      foregroundColor: UIColor.Porcelain.metallicBlue,
      paragraphStyle: .makeCustomStyle(
        lineHeight: 14.0,
        characterSpacing: 1.0)), for: .normal)
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    
    scrollView.contentOffset = .zero
  }
  
  @IBAction private func addAReviewTapped(_ sender: Any) {
    guard let productID = viewModel.product.id else { return }
    addAReviewDidTapped?(productID)
  }
}

// MARK: - CellConfigurable
extension MyProductsItemCell: CellConfigurable {
  public static var defaultSize: CGSize {
    return .zero
  }
}
