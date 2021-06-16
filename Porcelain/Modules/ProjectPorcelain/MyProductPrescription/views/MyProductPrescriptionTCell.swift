//
//  MyProductPrescriptionTCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 29/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct AttributedNotesAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.41
  var alignment: NSTextAlignment? = .left
  var lineBreakMode: NSLineBreakMode? = .byWordWrapping
  var minimumLineHeight: CGFloat? = 20.0
  var font: UIFont? = .idealSans(style: .book(size: 13.0))
  var color: UIColor? = .gunmetal
}

public final class MyProductPrescriptionTCell: UITableViewCell {
  public enum Position: Int {
    case top
    case middle
    case bottom
  }
  @IBOutlet private weak var notesLabel: UILabel!
  @IBOutlet private weak var stepLabel: UILabel! {
    didSet {
      stepLabel.font = .idealSans(style: .book(size: 12.0))
      stepLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var topLineView: UIView! {
    didSet {
      topLineView.backgroundColor = UIColor(hex: 0xdae2eb)
    }
  }
  @IBOutlet private weak var middleLineView: UIView! {
    didSet {
      middleLineView.backgroundColor = UIColor(hex: 0xdae2eb)
    }
  }
  @IBOutlet private weak var bottomLineView: UIView! {
    didSet {
      bottomLineView.backgroundColor = UIColor(hex: 0xdae2eb)
    }
  }
  @IBOutlet private weak var cardView: DesignableView!
  @IBOutlet private weak var prescriptionImageView: LoadingImageView! {
    didSet {
      prescriptionImageView.placeholderImage = .imgPrescriptionPlaceholder
    }
  }
  @IBOutlet private weak var nameLabel: UILabel! {
    didSet {
      nameLabel.font = .idealSans(style: .book(size: 13.0))
      nameLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var noOfPumpsLabel: UILabel!
  @IBOutlet private weak var dayLabel: UILabel!
  @IBOutlet private weak var frequencyLabel: UILabel!
  
  public var notes: String? {
    didSet {
      if let notes = notes?.emptyToNil {
        notesLabel.isHidden = false
        notesLabel.attributedText = notes.attributed.add(.appearance(AttributedNotesAppearance()))
      } else {
        notesLabel.isHidden = true
      }
    }
  }
  public var prescription: Prescription? {
    didSet {
      let product = prescription?.product
      stepLabel.text = "STEP\n\(String(format: "%02d", prescription?.sequenceNumber ?? 0))"
      prescriptionImageView.url = product?.images?.first
      nameLabel.text = prescription?.product?.name ?? "-"
      noOfPumpsLabel.attributedText = "NO. OF PUMPS ".attributed.add([
        .color(.bluishGrey),
        .font(.openSans(style: .semiBold(size: 12.0)))]).append(
          attrs: " \(prescription?.numberOfPumps ?? 0)".attributed.add([
            .color(.gunmetal),
            .font(.openSans(style: .semiBold(size: 12.0)))]))
      if let frequency = prescription?.frequency?.map({ $0.uppercased() }) {
        let attrFrequency = NSMutableAttributedString()
        frequency.enumerated().forEach { (indx,  dTime) in
          if indx > 0 {
            attrFrequency.append(" | ".attributed.add([
              .color(.gunmetal),
              .font(.openSans(style: .semiBold(size: 12.0))),
              .baseline(offset: 4.0)]))
          }
          if dTime == "DAY" {
            attrFrequency.append(UIImage.icSun.resizeImage(newSize: CGSize(width: 18.0, height: 18.0)).attributed.append(
              attrs: "  \(dTime)".attributed.add([
                .color(.gunmetal),
                .font(.openSans(style: .semiBold(size: 12.0))),
                .baseline(offset: 4.0)])))
          } else if dTime == "NIGHT" {
            attrFrequency.append(UIImage.icMoon.resizeImage(newSize: CGSize(width: 19.0, height: 19.0)).attributed.append(
              attrs: "  \(dTime)".attributed.add([
                .color(.gunmetal),
                .font(.openSans(style: .semiBold(size: 12.0))),
                .baseline(offset: 4.0)])))
          }
        }
        dayLabel.isHidden = false
        dayLabel.attributedText = attrFrequency
      } else {
        dayLabel.isHidden = true
      }
      if let _frequency = prescription?.afterNumberOfDays {
        frequencyLabel.isHidden = false
        let frequency: String
        if _frequency > 1 {
          frequency = "USE AFTER \(_frequency) DAYS"
        } else {
          frequency = "USE DAILY"
        }
        frequencyLabel.attributedText = frequency.attributed.add([
          .color(.bluishGrey),
          .font(.openSans(style: .semiBold(size: 12.0)))])
      } else {
        frequencyLabel.isHidden = true
      }
    }
  }
  
  public var position: Position = .middle {
    didSet {
      topLineView.backgroundColor = position == .top ? .clear: UIColor(hex: 0xdae2eb)
      bottomLineView.backgroundColor = position == .bottom ? .clear: UIColor(hex: 0xdae2eb)
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    cardView.addShadow(appearance: .default)
  }
}

// MARK: - CellProtocol
extension MyProductPrescriptionTCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 143.0)
  }
}
