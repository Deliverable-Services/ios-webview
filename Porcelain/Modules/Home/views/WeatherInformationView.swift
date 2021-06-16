//
//  WeatherInformationView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 24/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import SwiftyJSON

public struct WeatherInformationData {
  public var country: String?
  public var temperature: String?
  public var speedKMh: String?
  public var uvLevel: Int?
  public var humidPercent: String?
  
  init(data: JSON) {
    country = data.country.string
    temperature = String(format: "%d", data.temperature.string?.toNumber().intValue ?? 0)
    speedKMh = String(format: "%d", data["windSpeed"].string?.toNumber().intValue ?? 0)
    uvLevel = 0
    humidPercent = String(format: "%d", data.humidity.string?.toNumber().intValue ?? 0)
  }
}

private struct ErrorIndicatorAppearance: ErrorIndicatorAppearanceProtocol {
  var font: UIFont = .openSans(style: .regular(size: 13.0))
  var color: UIColor = .bluishGrey
  var position: ErrorIndicatorPosition = .bottomLeft(offset: .zero)
}

public protocol WeatherInformationViewModelProtocol {
  var weatherInformationData: WeatherInformationData? { get }
  
  func reloadWeather(latitude: Double, longitude: Double)
}

public final class WeatherInformationView: UIView, ActivityIndicatorProtocol, EmptyNotificationActionIndicatorProtocol {
  public var emptyNotificationActionView: EmptyNotificationActionView?
  
  public var activityIndicatorView: UIActivityIndicatorView? {
    didSet {
      activityIndicatorView?.color = .white
      activityIndicatorView?.backgroundColor  = .clear
    }
  }
  
  @IBOutlet private weak var view: UIView! {
    didSet {
      view.isHidden = true
    }
  }
  @IBOutlet private weak var temperatureLabel: UILabel!
  @IBOutlet private weak var speedLabel: UILabel!
  @IBOutlet private weak var uvLevelLabel: UILabel! {
    didSet {
      uvLevelLabel.isHidden = true
    }
  }
  @IBOutlet private weak var humidityLabel: UILabel!
  
  public var emptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let emptyNotificationActionData = emptyNotificationActionData  {
        view.isHidden = true
        showEmptyNotificationActionOnView(self, type: .horizontal(data: emptyNotificationActionData))
      } else {
        view.isHidden = viewModel == nil
        hideEmptyNotificationAction()
      }
    }
  }
  
  private var temperature: String? {
    didSet {
      temperatureLabel.attributedText = "\(temperature ?? "0")".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 13.0)))]).append(
        attrs: "°C".attributed.add([.color(.white), .font(.openSans(style: .light(size: 13.0)))]))
    }
  }
  
  private var sppedKMh: String? {
    didSet {
      speedLabel.attributedText = "\(sppedKMh ?? "0")".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 13.0)))]).append(
        attrs: " km/h".attributed.add([.color(.white), .font(.openSans(style: .light(size: 13.0)))]))
    }
  }
  
  private var uvLevel: Int? {
    didSet {
      uvLevelLabel.attributedText = "UV".attributed.add([.color(.white), .font(.openSans(style: .light(size: 13.0)))]).append(
        attrs: " Lvl \(uvLevel ?? 0)".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 13.0)))]))
    }
  }
  
  private var humidPercent: String? {
    didSet {
      humidityLabel.attributedText = "\(humidPercent ?? "0")".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 13.0)))]).append(
        attrs: " %".attributed.add([.color(.white), .font(.openSans(style: .light(size: 13.0)))]))
    }
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    loadNib(WeatherInformationView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
  }
  
  public var isLoading: Bool = false {
    didSet {
      if isLoading {
        showActivityOnView(self)
      } else {
        hideActivity()
      }
    }
  }
  
  public var viewModel: WeatherInformationViewModelProtocol? {
    didSet {
      if let data = viewModel?.weatherInformationData {
        temperature = data.temperature
        sppedKMh = data.speedKMh
        uvLevel = data.uvLevel
        humidPercent = data.humidPercent
        view.isHidden = false
      } else {
        view.isHidden = true
      }
    }
  }
  
  public func emptyNotificationActionTapped(data: EmptyNotificationActionData) {
    guard let url = URL(string: UIApplicationOpenSettingsURLString) else { return }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }
}
