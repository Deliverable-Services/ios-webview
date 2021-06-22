//
//  DateCalendarView.swift
//  Porcelain
//
//  Created by Jean on 6/27/18.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import SwiftyAttributes

enum DateCalendarViewStyle: String {
  case light, dark
}

class DateCalendarView: UIView {
  static var identifier = String(describing: DateCalendarView.self)
  static var dateFormat = "dd MMM"
  static var weekdayFormat = "EEE"
  @IBOutlet var dateLbl: UILabel!
  @IBOutlet var dayLbl: UILabel!
  
  func configure(date: Date, style: DateCalendarViewStyle = .dark) {
    dateLbl.attributedText = date.toString(WithFormat: DateCalendarView.dateFormat)
      .uppercased()
      .withAttributes(style == .dark ? darkDateAtt() : lightDateAtt())
    
    dayLbl.attributedText = date.toString(WithFormat: DateCalendarView.weekdayFormat)
      .uppercased()
      .withAttributes(style == .dark ? darkDayAtt() : lightDayAtt())
    backgroundColor = (style == .dark) ? UIColor.Porcelain.lightMetallicBlue : UIColor.Porcelain.white
  }
  
  private func darkDayAtt() -> [Attribute] {
    return [
      Attribute.font(UIFont.Porcelain.openSans(24, weight: .semiBold)),
      Attribute.textColor(UIColor.Porcelain.whiteTwo),
      Attribute.kern(0.5)
    ]
  }
  
  private func darkDateAtt() -> [Attribute] {
    return [
      Attribute.font(UIFont.Porcelain.openSans(13, weight: .semiBold)),
      Attribute.textColor(UIColor.Porcelain.whiteTwo),
      Attribute.kern(0.5)
    ]
  }
  
  private func lightDayAtt() -> [Attribute] {
    return [
      Attribute.font(UIFont.Porcelain.openSans(24, weight: .semiBold)),
      Attribute.textColor(UIColor.Porcelain.greyishBrown),
      Attribute.kern(0.5)
    ]
  }
  
  private func lightDateAtt() -> [Attribute] {
    return [
      Attribute.font(UIFont.Porcelain.openSans(13, weight: .semiBold)),
      Attribute.textColor(UIColor.Porcelain.greyishBrown),
      Attribute.kern(0.5)
    ]
  }
}
