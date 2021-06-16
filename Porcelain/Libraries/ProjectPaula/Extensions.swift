//
//  Extensions.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 21/05/2019.
//  Copyright © 2019 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

extension ShadowAppearance {
  public static let `default`: ShadowAppearance = {
    var appearance = ShadowAppearance()
    appearance.cornerRadius = 7.0
    appearance.shadowColor = PorcelainColor(red: 113.0/255.0, green: 168.0/255.0, blue: 187.0/255.0, alpha: 1.0)
    appearance.shadowOpacity = 0.3
    appearance.shadowOffset = CGSize(width: 0.0, height: 3.0)
    appearance.shadowRadius = 5.0
    return appearance
  }()
}

extension DashBorderAppearance {
  public static let `default`: DashBorderAppearance = {
    var appearance = DashBorderAppearance()
    appearance.color = .whiteThree
    appearance.cornerRadius = 0.0
    appearance.width = 2.0
    appearance.dashPattern = [4.0, 4.0]
    return appearance
  }()
}

extension PresenterAppearance {
  public static let `default`: PresenterAppearance = {
    var appearance = PresenterAppearance()
    appearance.cornerRadius = 7.0
    appearance.dimAnchor = true
    appearance.dimColor = UIColor.black.withAlphaComponent(0.8)
    appearance.minPadding = 24.0
    appearance.shadowAppearance = .default
    return appearance
  }()
  
  public static let dropDown: PresenterAppearance = {
    var appearance = PresenterAppearance.default
    appearance.dimColor = .clear
    return appearance
  }()
}

public struct DropDownAppearance: DropDownAppearanceProtocol {
  public var filterAppearance: DropDownTextAppearance = .init(
    characterSpacing: 0.5,
    alignment: nil,
    lineBreakMode: .byTruncatingTail,
    minimumLineHeight: nil,
    font: .openSans(style: .regular(size: 13.0)),
    color: .gunmetal)
  
  public var titleAppearance: DropDownTextAppearance = .init(
    characterSpacing: 0.5,
    alignment: nil,
    lineBreakMode: nil,
    minimumLineHeight: nil,
    font: .openSans(style: .regular(size: 13.0)),
    color: .bluishGrey)
  
  public var titleBackgroundColor: UIColor?  = .white
  
  public var selectedTitleApperance: DropDownTextAppearance = .init(
    characterSpacing: 0.5,
    alignment: nil,
    lineBreakMode: .byTruncatingTail,
    minimumLineHeight: nil,
    font: .openSans(style: .semiBold(size: 13.0)),
    color: .white)
  
  public var selectedTitleBackgroundColor: UIColor? = .greyblue
  
  public var subtitleAppearance: DropDownTextAppearance = .init(
    characterSpacing: 0.5,
    alignment: nil,
    lineBreakMode: .byTruncatingTail,
    minimumLineHeight: nil,
    font: .openSans(style: .regular(size: 13.0)),
    color: .bluishGrey)
  
  public var selectedSubtitleApperance: DropDownTextAppearance = .init(
    characterSpacing: 0.5,
    alignment: nil,
    lineBreakMode: .byTruncatingTail,
    minimumLineHeight: nil,
    font: .openSans(style: .semiBold(size: 13.0)),
    color: .white)
  
  public var noticeApperance: DropDownTextAppearance = .init(
    characterSpacing: 0.5,
    alignment: .center,
    lineBreakMode: nil,
    minimumLineHeight: nil,
    font: .openSans(style: .regular(size: 13.0)),
    color: .bluishGrey)
}

// MARK: - Icon Images
extension UIImage {
  public static var icAddShippingAddress: UIImage {
    return #imageLiteral(resourceName: "ic-add-new-address")
  }
  public static var icAddNewCard: UIImage {
    return #imageLiteral(resourceName: "ic-add-new-card")
  }
  public static var icApplePay: UIImage {
    return #imageLiteral(resourceName: "ic-apple-pay")
  }
  public static var icBigCheck: UIImage {
    return #imageLiteral(resourceName: "ic-big-check")
  }
  public static var icBookAnAppointment: UIImage {
    return #imageLiteral(resourceName: "ic-book-an-appointment")
  }
  public static var icBrowser: UIImage {
    return #imageLiteral(resourceName: "ic-browser")
  }
  public static var icCalendarAdd: UIImage {
    return #imageLiteral(resourceName: "ic-calendar-add")
  }
  public static var icCalendarClock: UIImage {
    return #imageLiteral(resourceName: "ic-calendar-clock")
  }
  public static var icCalendarNew: UIImage {
    return #imageLiteral(resourceName: "ic-calendar-new")
  }
  public static var icCamera: UIImage {
    return #imageLiteral(resourceName: "ic-camera")
  }
  public static var icCart: UIImage {
    return #imageLiteral(resourceName: "ic-cart")
  }
  public static var icChat: UIImage {
    return #imageLiteral(resourceName: "ic-chat")
  }
  public static var icCheck: UIImage {
    return #imageLiteral(resourceName: "ic-check")
  }
  public static var icCheckBoxSelected: UIImage {
    return #imageLiteral(resourceName: "ic-checkbox-selected")
  }
  public static var icCheckBoxUnSelected: UIImage {
    return #imageLiteral(resourceName: "ic-checkbox-unselected")
  }
  public static var icCheckoutRadioSelected: UIImage {
    return #imageLiteral(resourceName: "ic-checkout-radio-selected")
  }
  public static var icCheckoutRadioUnselected: UIImage {
    return #imageLiteral(resourceName: "ic-checkout-radio-unselected")
  }
  public static var icChevronDown: UIImage {
    return #imageLiteral(resourceName: "ic-chevron-down")
  }
  public static var icChevronLeft: UIImage {
    return #imageLiteral(resourceName: "ic-chevron-left")
  }
  public static var icChevronRight: UIImage {
    return #imageLiteral(resourceName: "ic-chevron-right")
  }
  public static var icChevronUp: UIImage {
    return #imageLiteral(resourceName: "ic-chevron-up")
  }
  public static var icCircleCheckSelected: UIImage {
    return #imageLiteral(resourceName: "ic-circle-check-selected")
  }
  public static var icCircleCheckUnselected: UIImage {
    return #imageLiteral(resourceName: "ic-circle-check-unselected")
  }
  public static var icCircleCheck: UIImage {
    return #imageLiteral(resourceName: "ic-circle-check")
  }
  public static var icClose: UIImage {
    return #imageLiteral(resourceName: "ic-close")
  }
  public static var icComplete: UIImage {
    return #imageLiteral(resourceName: "ic-complete")
  }
  public static var icCopy: UIImage {
    return #imageLiteral(resourceName: "ic-copy")
  }
  public static var icDay: UIImage {
    return #imageLiteral(resourceName: "ic-day")
  }
  public static var icDelete: UIImage {
    return #imageLiteral(resourceName: "ic-delete")
  }
  public static var icEdit: UIImage {
    return #imageLiteral(resourceName: "ic-edit")
  }
  public static var icEditAdd: UIImage {
    return #imageLiteral(resourceName: "ic-edit-add")
  }
  public static var icEditCancel: UIImage {
    return #imageLiteral(resourceName: "ic-edit-cancel")
  }
  public static var icEditConfirm: UIImage {
    return #imageLiteral(resourceName: "ic-edit-confirm")
  }
  public static var icEditMinus: UIImage {
    return #imageLiteral(resourceName: "ic-edit-minus")
  }
  public static var isEmail: UIImage {
    return #imageLiteral(resourceName: "ic-email")
  }
  public static var icEmptyStar: UIImage {
    return #imageLiteral(resourceName: "ic-empty-star")
  }
  public static var icFaceGlow: UIImage {
    return #imageLiteral(resourceName: "ic-face-glow")
  }
  public static var icFacebook: UIImage {
    return #imageLiteral(resourceName: "ic-facebook")
  }
  public static var icFullStar: UIImage {
    return #imageLiteral(resourceName: "ic-full-star")
  }
  public static var icGoogle: UIImage {
    return #imageLiteral(resourceName: "ic-google")
  }
  public static var icHumidity: UIImage {
    return #imageLiteral(resourceName: "ic-humidity")
  }
  public static var icIncomplete: UIImage {
    return #imageLiteral(resourceName: "ic-incomplete")
  }
  public static var icInformation: UIImage {
    return #imageLiteral(resourceName: "ic-information")
  }
  public static var icLeftArrow: UIImage {
    return #imageLiteral(resourceName: "ic-left-arrow")
  }
  public static var icLocationPin: UIImage {
    return #imageLiteral(resourceName: "ic-location-pin")
  }
  public static var icMoon: UIImage {
    return #imageLiteral(resourceName: "ic-moon")
  }
  public static var icMyAppointments: UIImage {
    return #imageLiteral(resourceName: "ic-my-appointments")
  }
  public static var icMyProductPrescription: UIImage {
    return #imageLiteral(resourceName: "ic-my-product-prescription")
  }
  public static var icMyProducts: UIImage {
    return #imageLiteral(resourceName: "ic-my-products")
  }
  public static var icMyTreatmentPlan: UIImage {
    return #imageLiteral(resourceName: "ic-my-treatment-plan")
  }
  public static var icNight: UIImage {
    return #imageLiteral(resourceName: "ic-night")
  }
  public static var icNotifications: UIImage {
    return #imageLiteral(resourceName: "ic-notifications")
  }
  public static var icPencil: UIImage {
    return #imageLiteral(resourceName: "ic-pencil")
  }
  public static var icPlus: UIImage {
    return #imageLiteral(resourceName: "ic-plus")
  }
  public static var icPorcelainBulletNew: UIImage {
    return #imageLiteral(resourceName: "ic-porcelain-bullet-new")
  }
  public static var icPorcelainBullet: UIImage {
    return #imageLiteral(resourceName: "ic-porcelain-bullet")
  }
  public static var icQRScope: UIImage {
    return #imageLiteral(resourceName: "ic-qr-scope")
  }
  public static var icQuizAnswerEmpty: UIImage {
    return #imageLiteral(resourceName: "ic-quiz-answer-empty")
  }
  public static var icRadioSelected: UIImage {
    return #imageLiteral(resourceName: "ic-radio-selected")
  }
  public static var icRadioUnselected: UIImage {
    return #imageLiteral(resourceName: "ic-radio-unselected")
  }
  public static var icRaindrops: UIImage {
    return #imageLiteral(resourceName: "ic-raindrops")
  }
  public static var icRemove: UIImage {
    return #imageLiteral(resourceName: "ic-remove")
  }
  public static var icRightArrow: UIImage {
    return #imageLiteral(resourceName: "ic-right-arrow")
  }
  public static var icScan: UIImage {
    return #imageLiteral(resourceName: "ic-scan")
  }
  public static var icSearch: UIImage {
    return #imageLiteral(resourceName: "ic-search")
  }
  public static var icSelectedTea: UIImage {
    return #imageLiteral(resourceName: "ic-selected-tea")
  }
  public static var icSettings: UIImage {
    return #imageLiteral(resourceName: "ic-settings")
  }
  public static var icShare: UIImage {
    return #imageLiteral(resourceName: "ic-share")
  }
  public static var icShopNow: UIImage {
    return #imageLiteral(resourceName: "ic-shop-now")
  }
  public static var icSkinAnalysisCongestionLevel: UIImage {
    return #imageLiteral(resourceName: "ic-skin-analysis-congestion-level")
  }
  public static var icSkinAnalysisHydrationLevel: UIImage {
    return #imageLiteral(resourceName: "ic-skin-analysis-hydration-level")
  }
  public static var icSkinAnalysis: UIImage {
    return #imageLiteral(resourceName: "ic-skin-analysis")
  }
  public static var icSkinJourney: UIImage {
    return #imageLiteral(resourceName: "ic-skin-journey")
  }
  public static var icSkinQuiz: UIImage {
    return #imageLiteral(resourceName: "ic-skin-quiz")
  }
  public static var icSkin: UIImage {
    return #imageLiteral(resourceName: "ic-skin")
  }
  public static var icStepIndicator: UIImage {
    return #imageLiteral(resourceName: "ic-step-indicator")
  }
  public static var icSun: UIImage {
    return #imageLiteral(resourceName: "ic-sun")
  }
  public static var imgAmericanExpressCard: UIImage {
    return #imageLiteral(resourceName: "img-american-express-card")
  }
  public static var imgBackground: UIImage {
    return #imageLiteral(resourceName: "img-background")
  }
  public static var imgLandscapePlaceholder: UIImage {
    return #imageLiteral(resourceName: "img-landscape-placeholder")
  }
  public static var imgMasterCard: UIImage {
    return #imageLiteral(resourceName: "img-master-card")
  }
  public static var imgPhotoPlaceholder: UIImage {
    return #imageLiteral(resourceName: "img-photo-placeholder")
  }
  public static var imgPrescriptionPlaceholder: UIImage {
    return #imageLiteral(resourceName: "img-prescription-placeholder")
  }
  public static var imgPocelainLogo: UIImage {
    return #imageLiteral(resourceName: "img-porcelain-logo")
  }
  public static var imgProfilePlaceholder: UIImage {
    return #imageLiteral(resourceName: "img-profile-placeholder")
  }
  public static var imgSegmentedLine: UIImage {
    return #imageLiteral(resourceName: "img-segmented-line")
  }
  public static var imgShopBanner: UIImage {
    return #imageLiteral(resourceName: "img-shop-banner")
  }
  public static var imgSkinAnalysisFaceDisabled: UIImage {
    return #imageLiteral(resourceName: "img-skin-analysis-face-disabled")
  }
  public static var imgSkinAnalysisFaceEnabled: UIImage {
    return #imageLiteral(resourceName: "img-skin-analysis-face-enabled")
  }
  public static var imgSplashLogo: UIImage {
    return #imageLiteral(resourceName: "img-splash-logo")
  }
  public static var imgTempPotato: UIImage {
    return #imageLiteral(resourceName: "img-temp-potato")
  }
  public static var imgVisaCard: UIImage {
    return #imageLiteral(resourceName: "img-visa-card")
  }
  public static var imgWeatherBG: UIImage {
    return #imageLiteral(resourceName: "img-weather-bg")
  }
}

// MARK: - Tab Images
extension UIImage {
  public static var icTabHome: UIImage {
    return #imageLiteral(resourceName: "ic-tab-home")
  }
  public static var icTabPorcelain: UIImage {
    return #imageLiteral(resourceName: "ic-tab-porcelain-2021").resizeImage(newSize: CGSize(width: 22, height: 22))
  }
  public static var icTabProfile: UIImage {
    return #imageLiteral(resourceName: "ic-tab-profile")
  }
  public static var icTabScanQR: UIImage {
    return #imageLiteral(resourceName: "ic-tab-scan-qr")
  }
  public static var icTabShop: UIImage {
    return #imageLiteral(resourceName: "ic-tab-shop")
  }
}

extension DesignableTextView {
  public enum Theme {
    case `default`
  }
  
  public func setTheme(_ theme: Theme) {
    switch theme {
    case .default:
      typingAttributes = NSAttributedString.createAttributesString([.appearance(AttributedTextViewTextAppearance())])
      tintColor = .gunmetal
      topMargin = 12.0
      leftMargin = 12.0
      rightMargin = 12.0
      bottomMargin = 12.0
    }
  }
}

extension NavigationProtocol {
  public var barButtonColor: UIColor? {
    return .lightNavy
  }
}

extension UIViewController {
  public var isPushed: Bool {
    if let navigationController = navigationController, navigationController.childViewControllers.count > 1 {
      return true
    } else {
      return false
    }
  }
  
  public func popToRootOrDismissViewController() {
    if isPushed {
      DispatchQueue.main.async {
        self.navigationController?.popToRootViewController(animated: true)
      }
    } else {
      DispatchQueue.main.async {
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  @IBAction public func popOrDismissViewController() {
    if isPushed {
      DispatchQueue.main.async {
        self.navigationController?.popViewController(animated: true)
      }
    } else {
      DispatchQueue.main.async {
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  @IBAction public func popViewController() {
    DispatchQueue.main.async {
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  @IBAction public func dismissViewController() {
    DispatchQueue.main.async {
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  public func showAlert(title: String?, message: String?) {
    let dialogHandler = DialogHandler()
    dialogHandler.title = title
    dialogHandler.message = message
    dialogHandler.actions = [.confirm(title: "GOT IT!")]
    DialogViewController.load(handler: dialogHandler).show(in: self)
  }
  
  public func setNavigationTheme(_ theme: NavigationTheme) {
    guard let navigationController = navigationController as? NavigationController else { return }
    navigationController.setTheme(theme)
  }
  
  public func setStatusBarNav(style: UIStatusBarStyle) {
    guard let navigationControler = navigationController as? NavigationController else { return }
    navigationControler.overrideStatusBarStyle(style)
  }
  
  public func resetNavigationController() {
    guard let navigationControler = navigationController as? NavigationController else { return }
    navigationControler.setup()
  }
  
  public func displayAlert(title: String? = nil, message: String? = nil, handler: ((UIAlertAction) -> Void)?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: handler)
    alertController.addAction(cancelAction)
    present(alertController, animated: true, completion: nil)
  }
}

extension String {
  public func formatMobile(spaceIndex: [Int] = [4, 8]) -> String {
    let cleanMobile = components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    var formattedMobile = ""
    cleanMobile.enumerated().forEach { (indx, char) in
      if spaceIndex.contains(indx) {
        formattedMobile.append(" ")
      }
      formattedMobile.append(char)
    }
    return formattedMobile
  }
  
  public func formatNumber(interval: Int, text: String = " ") -> (value: String, intervals: [Int]) {
    let cleanNumbers = components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    var formattedNumber = ""
    var newInterval = interval
    var intervals: [Int] = [newInterval]
    var increment = 0
    cleanNumbers.enumerated().forEach { (indx, num) in
      if indx == newInterval {
        formattedNumber.append(text)
        newInterval += interval
        increment += 1
        intervals.append(newInterval + increment)
      }
      formattedNumber.append(num)
    }
    return (formattedNumber, intervals)
  }
}

extension Double {
  public var getFilled5StarRating: String {
    var stars: [MaterialDesignIcon] = []
    for indx in 1...5 {
      let dDiff = self - Double(indx)
      if dDiff >= 0 {
        stars.append(.star)
      } else if dDiff < 0 && dDiff > -1.0 {
        stars.append(.starHalf)
      }
    }
    return stars.map({ $0.rawValue }).joined(separator: " ")
  }
  
  public var getOutlined5StarRating: String {
    let ceilRating = ceil(self)
    guard ceilRating < 5.0 else { return "" }
    var stars: [MaterialDesignIcon] = []
    let intCeilRating = 5 - Int(ceilRating)
    for _ in 1...intCeilRating {
      stars.append(.starOutline)
    }
    return stars.map({ $0.rawValue }).joined(separator: " ")
  }
}

extension UIStoryboard {
  public enum StoryboardName: String {
    case main = "Main"
    case cart = "Cart"
    case logIn = "LogIn"
    case viewHelpers = "ViewHelpers"
    case scanQR = "ScanQR"
    case myTreatment = "MyTreatment"
    case feedback = "Feedback"
    
    //new
    case bookAnAppointment = "BookAnAppointment"
    case authentication = "Authentication"
    case appointment = "Appointment"
    case webView = "WebView"
    case settings = "Settings"
    case notification = "Notification"
    case makeReview = "MakeReview"
    //main tabs
    case home = "Home"
    case projectPorcelain = "ProjectPorcelain"
    case profile = "Profile"
    case shop = "Shop"
  }
}

// MARK: - UIStoryboard
extension UIStoryboard {
  static func get(_ type: StoryboardName) -> UIStoryboard {
    return UIStoryboard(name: type.rawValue, bundle: nil)
  }
}
