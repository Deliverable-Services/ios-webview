//
//  ProductPrescriptionCell.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 18/01/2019.
//  Copyright © 2019 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

class ProductPrescriptionCell: UITableViewCell {
  @IBOutlet weak var productImageView: UIImageView!
  @IBOutlet weak var productNameLabel: UILabel!
  @IBOutlet weak var productOtherInfoLabel: UILabel!
  @IBOutlet weak var productPumpsLabel: UILabel!
  @IBOutlet weak var productDosageLabel: UILabel!
  @IBOutlet weak var lastPurchasedLabel: UILabel!
  
  private var model: ProductPrescriptionModel?
  
  @IBOutlet weak var containerView: UIView! {
    didSet {
      containerView.layer.borderWidth = 1.0
      containerView.layer.cornerRadius = 7.0
      containerView.layer.borderColor = UIColor.Porcelain.whiteFour.cgColor
    }
  }
  
  public func configure(_ model: ProductPrescriptionModel) {
    self.model = model
    productNameLabel.attributedText = model.name
    productOtherInfoLabel.attributedText = model.otherInfo
    productPumpsLabel.attributedText = model.pumps
    productDosageLabel.attributedText = model.dosage
    lastPurchasedLabel.attributedText = model.lastPurchaseDate
    
    if let imageURL = URL(string: model.imageURL) {
      productImageView.af_setImage(withURL: imageURL, placeholderImage: #imageLiteral(resourceName: "photo-placeholder"))
    } else {
      productImageView.image = #imageLiteral(resourceName: "photo-placeholder")
    }
    productImageView.contentMode = .scaleAspectFit
  }
}

/************************************************************************/

struct ProductPrescriptionModel {
  var productPrescription: ProductPrescription
  
  var imageURL: String {
    return productPrescription.productImageURL ?? ""
  }
  
  var name: NSAttributedString {
    let attributedTitle = (productPrescription.productName ?? "")
      .withFont(UIFont.Porcelain.openSans(14.0, weight: .bold))
      .withTextColor(UIColor.Porcelain.greyishBrown)
      .withKern(0.5)
    return attributedTitle
  }
  
  var otherInfo: NSAttributedString {
    let attributedTitle = NSMutableAttributedString(string: "")
    productPrescription.size != nil ?
      attributedTitle.append(concatenate(productPrescription.size!, " | ")
        .withFont(UIFont.Porcelain.openSans(14.0, weight: .regular))
        .withTextColor(UIColor.Porcelain.warmGrey)
        .withKern(0.5)) : nil
    
    productPrescription.price != nil ?
      attributedTitle.append(concatenate("$", productPrescription.price!)
        .withFont(UIFont.Porcelain.openSans(14.0, weight: .semiBold ))
        .withTextColor(UIColor.Porcelain.warmGrey)
        .withKern(0.5)) : nil
    
    return attributedTitle
  }
  
  var pumps: NSAttributedString {
    let attributedTitle = NSMutableAttributedString(string: "")
    attributedTitle.append(concatenate("No. of pumps: ")
      .withFont(UIFont.Porcelain.openSans(14.0, weight: .regular))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5))
    
    attributedTitle.append(concatenate(String(productPrescription.numberOfPumps))
      .withFont(UIFont.Porcelain.openSans(14.0, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5))
    
    return attributedTitle
  }
  
  var dosage: NSAttributedString {
    let attributedTitle = NSMutableAttributedString(string: "")
    
    attributedTitle.append(concatenate("Every after ")
      .withFont(UIFont.Porcelain.openSans(14.0, weight: .regular))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5))
    
    attributedTitle.append(concatenate(String(productPrescription.afterNumberOfDays), " days | ")
      .withFont(UIFont.Porcelain.openSans(14.0, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5))
    
    if let frequency = productPrescription.frequency {
      if frequency.contains( "day") {
        let imageAttachment = textAttachment(font: UIFont.Porcelain.openSans(14, weight: .semiBold), image: UIImage(named: "day-icon")!)
        attributedTitle.append(NSAttributedString(attachment: imageAttachment))
        attributedTitle.append(NSAttributedString(string: "  "))
      }
      
      if frequency.contains("night") {
        let imageAttachment = textAttachment(font: UIFont.Porcelain.openSans(14, weight: .semiBold), image: UIImage(named: "night-icon")!)
        attributedTitle.append(NSAttributedString(attachment: imageAttachment))
      }
    }
    return attributedTitle
  }
  
  var lastPurchaseDate: NSAttributedString {
    let attributedTitle = NSMutableAttributedString(string: "")
    attributedTitle.append(concatenate("Last purchased ")
      .withFont(UIFont.Porcelain.openSans(13.0, weight: .regular))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5))    
   attributedTitle.append((productPrescription.lastPurchaseDate?.toString(WithFormat: "MM/dd/yy") ?? "Unknown")
      .withFont(UIFont.Porcelain.openSans(13.0, weight: .semiBold))
      .withTextColor(UIColor.Porcelain.warmGrey)
      .withKern(0.5))
    
    return attributedTitle
  }
  
  func textAttachment(font: UIFont, image: UIImage) -> NSTextAttachment {
    let font = font //set accordingly to your font, you might pass it in the function
    let textAttachment = NSTextAttachment()
    let image = image
    textAttachment.image = image
    let mid = font.descender + font.capHeight
    textAttachment.bounds = CGRect(x: 0, y: font.descender - image.size.height / 2 + mid + 2, width: image.size.width, height: image.size.height)
    return textAttachment
  }
}
