//
//  BaseWalkthroughViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 12/10/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

extension StoryboardName {
  public static let walkthrough = "Walkthrough"
}

private struct AttributedContentTextAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.5
  var alignment: NSTextAlignment? = .center
  var lineBreakMode: NSLineBreakMode? = .byWordWrapping
  var minimumLineHeight: CGFloat? = 20.0
  var font: UIFont? = .idealSans(style: .light(size: 14.0))
  var color: UIColor? = .bluishGrey
}

public enum BaseWalkthroughStep: Int {
  case notifications = 0
  case liveChat
  case welcomeToPorcelain
  case scanQR
  case porcelain
  case profile
  case shop
  case selectBranch = 10
  case selectTreatment
  case selectAddons
  case selectTherapist
  case addNote
  case selectDateTime
  case requestNow
  
  public var title: String? {
    switch self {
    case .notifications:
      return "NOTIFICATIONS"
    case .liveChat:
      return "LIVE CHAT"
    case .welcomeToPorcelain:
      return "Welcome to Porcelain!"
    case .scanQR:
      return "Scan QR"
    case .porcelain:
      return "Porcelain"
    case .profile:
      return "Profile"
    case .shop:
      return "Shop"
    case .selectBranch:
      return "Select an Outlet"
    case .selectTreatment:
      return "Select a Treatment"
    case .selectAddons:
      return "Add-ons"
    case .selectTherapist:
      return "Select a Therapist(s)"
    case .addNote:
      return "Drop a note!"
    case .selectDateTime:
      return "When & What Time?"
    case .requestNow:
      return "Request Now!"
    }
  }
  
  public var content: NSAttributedString? {
    switch self {
    case .notifications:
      return "Opting in for notifications will fast-track you to new month bookings. & You’ll be the first to know about the latest news/updates!".attributed.add(.appearance(AttributedContentTextAppearance()))
    case .liveChat:
      return "Need help? Reach out to us with our live support!".attributed.add(.appearance(AttributedContentTextAppearance()))
    case .welcomeToPorcelain:
      var appearance = AttributedContentTextAppearance()
      appearance.alignment = .left
      let attributedString = NSMutableAttributedString()
      if UIScreen.main.bounds.width <= 320.0 {
        attributedString.append(UIImage.icPorcelainBulletNew.attributed.add(.baseline(offset: -2.0)).append(
          attrs: "\tRequest & amend your appointments\n\twith ease".attributed.add([.appearance(appearance), .baseline(offset: 3.0)])))
        attributedString.append(attrs: "\n".attributed.add(.font(.idealSans(style: .light(size: 8.0)))))
        attributedString.append(UIImage.icPorcelainBulletNew.attributed.add(.baseline(offset: -2.0)).append(
          attrs: "\tTrack your purchases and visits\n\twith us\n".attributed.add([.appearance(appearance), .baseline(offset: 3.0)])))
        attributedString.append(attrs: "\n".attributed.add(.font(.idealSans(style: .light(size: 8.0)))))
        attributedString.append(UIImage.icPorcelainBulletNew.attributed.add(.baseline(offset: -2.0)).append(
          attrs: "\tBe the first to know about latest\n\tnews/updates".attributed.add([.appearance(appearance), .baseline(offset: 3.0)])))
        attributedString.append(attrs: "\n".attributed.add(.font(.idealSans(style: .light(size: 8.0)))))
        attributedString.append(UIImage.icPorcelainBulletNew.attributed.add(.baseline(offset: -2.0)).append(
          attrs: "\tShop at our E-store".attributed.add([.appearance(appearance), .baseline(offset: 3.0)])))
      } else {
        attributedString.append(UIImage.icPorcelainBulletNew.attributed.add(.baseline(offset: -2.0)).append(
          attrs: "\tRequest & amend your appointments\n\twith ease".attributed.add([.appearance(appearance), .baseline(offset: 3.0)])))
        attributedString.append(attrs: "\n".attributed.add(.font(.idealSans(style: .light(size: 8.0)))))
        attributedString.append(UIImage.icPorcelainBulletNew.attributed.add(.baseline(offset: -2.0)).append(
          attrs: "\tTrack your purchases and visits with us\n".attributed.add([.appearance(appearance), .baseline(offset: 3.0)])))
        attributedString.append(attrs: "\n".attributed.add(.font(.idealSans(style: .light(size: 8.0)))))
        attributedString.append(UIImage.icPorcelainBulletNew.attributed.add(.baseline(offset: -2.0)).append(
          attrs: "\tBe the first to know about latest\n\tnews/updates".attributed.add([.appearance(appearance), .baseline(offset: 3.0)])))
        attributedString.append(attrs: "\n".attributed.add(.font(.idealSans(style: .light(size: 8.0)))))
        attributedString.append(UIImage.icPorcelainBulletNew.attributed.add(.baseline(offset: -2.0)).append(
          attrs: "\tShop at our E-store".attributed.add([.appearance(appearance), .baseline(offset: 3.0)])))
      }
      return attributedString
    case .scanQR:
      return "Stay connected withing our digital touchpoints around our Porcelain Outlets!".attributed.add(.appearance(AttributedContentTextAppearance()))
    case .porcelain:
      var appearance = AttributedContentTextAppearance()
      appearance.alignment = .left
      let attributedString = NSMutableAttributedString()
      if UIScreen.main.bounds.width <= 320.0 {
        attributedString.append(UIImage.icPorcelainBulletNew.attributed.add(.baseline(offset: -2.0)).append(
          attrs: "\tHere, you’ll kickstart your\n\tskincare journey with us.\n".attributed.add([.appearance(appearance), .baseline(offset: 3.0)])))
        attributedString.append(attrs: "\n".attributed.add(.font(.idealSans(style: .light(size: 8.0)))))
        attributedString.append(UIImage.icPorcelainBulletNew.attributed.add(.baseline(offset: -2.0)).append(
          attrs: "\tSkin quiz, customized\n\ttreatment plan,\n\tproduct prescription.\n".attributed.add([.appearance(appearance), .baseline(offset: 3.0)])))
        attributedString.append(attrs: "\n".attributed.add(.font(.idealSans(style: .light(size: 8.0)))))
        attributedString.append(UIImage.icPorcelainBulletNew.attributed.add(.baseline(offset: -2.0)).append(
          attrs: "\tDiscover your bespoke regimen\n\tthat works specifically for you.".attributed.add([.appearance(appearance), .baseline(offset: 3.0)])))
      } else  {
        attributedString.append(UIImage.icPorcelainBulletNew.attributed.add(.baseline(offset: -2.0)).append(
          attrs: "\tHere, you’ll kickstart your skincare journey\n\twith us.\n".attributed.add([.appearance(appearance), .baseline(offset: 3.0)])))
        attributedString.append(attrs: "\n".attributed.add(.font(.idealSans(style: .light(size: 8.0)))))
        attributedString.append(UIImage.icPorcelainBulletNew.attributed.add(.baseline(offset: -2.0)).append(
          attrs: "\tSkin quiz, customized treatment plan,\n\tproduct prescription.\n".attributed.add([.appearance(appearance), .baseline(offset: 3.0)])))
        attributedString.append(attrs: "\n".attributed.add(.font(.idealSans(style: .light(size: 8.0)))))
        attributedString.append(UIImage.icPorcelainBulletNew.attributed.add(.baseline(offset: -2.0)).append(
          attrs: "\tDiscover your bespoke regimen that works\n\tspecifically for you.".attributed.add([.appearance(appearance), .baseline(offset: 3.0)])))
      }
      return attributedString
    case .profile:
      return "View and update profile details, account settings and view purchase history all in one glance.".attributed.add(.appearance(AttributedContentTextAppearance()))
    case .shop:
      return "Let’s go shopping! Make Porcelain product purchases online with exclusive promotions & more.".attributed.add(.appearance(AttributedContentTextAppearance()))
    case .selectBranch:
      var appearance = AttributedContentTextAppearance()
      appearance.font = .idealSans(style: .book(size: 14.0))
      return "Start off by selecting an outlet of your preference to schedule an appointment.".attributed.add(.appearance(appearance))
    case .selectTreatment:
      var appearance = AttributedContentTextAppearance()
      appearance.font = .idealSans(style: .book(size: 14.0))
      return "Next, Pick your desired treatment".attributed.add(.appearance(appearance))
    case .selectAddons:
      var appearance = AttributedContentTextAppearance()
      appearance.font = .idealSans(style: .book(size: 14.0))
      return """
      Do it in a single session! For example : OxyRevive + Revital Eye Luxx for the best results!
      """.attributed.add(.appearance(appearance))
    case .selectTherapist:
      var appearance = AttributedContentTextAppearance()
      appearance.font = .idealSans(style: .book(size: 14.0))
      return """
      Choose your preferred therapist.
      For equipment treatments, your therapist might change.
      Leave field as No Preference if you love everyone in the team!
      """.attributed.add(.appearance(appearance)).add([.color(.lightNavy)], text: "No Preference")
    case .addNote:
      var appearance = AttributedContentTextAppearance()
      appearance.font = .idealSans(style: .book(size: 14.0))
      return """
      If you’d like us to take note of for your treatment, let us know!
      """.attributed.add(.appearance(appearance))
    case .selectDateTime:
      var appearance = AttributedContentTextAppearance()
      appearance.font = .idealSans(style: .book(size: 14.0))
      return """
      Select your date and time to your preference.
      Note that to maximize the slots for all Porcelain customers, there may be slight changes to the timing
      """.attributed.add(.appearance(appearance))
    case .requestNow:
      var appearance = AttributedContentTextAppearance()
      appearance.font = .idealSans(style: .book(size: 14.0))
      return """
      Appointment will be captured as a request. You will be notified once an appointment is being accepted.
      """.attributed.add(.appearance(appearance))
    }
  }
}

public enum BaseWalkthroughType {
  case main(chatBarButton: BadgeableBarButtonItem, notificationsBarButton: BadgeableBarButtonItem)
  case booking(branchView: BAANavTitleView, treatmentView: UIView, addonsView: UIView, therapistView: UIView, noteView: UIView, calendarView: UIView, requestView: UIView)
}

public protocol BaseWalkthroughDelegate: class {
  func baseWalkthroughDidStart(baseWalkthroughViewController: BaseWalkthroughViewController)
  func baseWalkthroughDidChangeStep(baseWalkthroughViewController: BaseWalkthroughViewController, step: BaseWalkthroughStep)
  func baseWalkthroughDidFinish(baseWalkthroughViewController: BaseWalkthroughViewController)
}

public final class BaseWalkthroughViewController: UIViewController {
  private var currentStep: BaseWalkthroughStep = .notifications {
    didSet {
      delegate?.baseWalkthroughDidChangeStep(baseWalkthroughViewController: self, step: currentStep)
      switch type {
      case .main(let chatBarButton, let notificationsBarButton):
        showWalkthroughPopup()
        switch currentStep {
         case .notifications:
           appDelegate.mainView.goToTab(.home)
           renderBackground(anchorView: notificationsBarButton.value(forKey: "view") as? UIView)
         case .liveChat:
           appDelegate.mainView.goToTab(.home)
           renderBackground(anchorView: chatBarButton.value(forKey: "view") as? UIView)
         case .welcomeToPorcelain:
           appDelegate.mainView.goToTab(.home)
           renderBackground(anchorView: appDelegate.mainView.selectedTabBar?.value(forKey: "view") as? UIView)
         case .scanQR:
           appDelegate.mainView.goToTab(.scanQR)
           renderBackground(anchorView: appDelegate.mainView.selectedTabBar?.value(forKey: "view") as? UIView)
         case .porcelain:
           appDelegate.mainView.goToTab(.porcelain)
           renderBackground(anchorView: appDelegate.mainView.selectedTabBar?.value(forKey: "view") as? UIView)
         case .profile:
           appDelegate.mainView.goToTab(.profile)
           renderBackground(anchorView: appDelegate.mainView.selectedTabBar?.value(forKey: "view") as? UIView)
         case .shop:
           appDelegate.mainView.goToTab(.shop)
           renderBackground (anchorView: appDelegate.mainView.selectedTabBar?.value(forKey: "view") as? UIView)
         default: break
         }
      case .booking(let branchView, let treatmentView, let addonsView, let therapistView, let noteView, let calendarView, let requestView):
        baNavTitleView.selectedCenter = branchView.selectedCenter
        resetBAViews()
        switch currentStep {
        case .selectBranch:
          showWalkthroughPopup(anchor: WalkthroughPopupAnchor(view: branchView, position: .bottomCenter(offset: CGSize(width: 0.0, height: 44.0))))
          renderBackground(anchorView: branchView)
        case .selectTreatment:
          showWalkthroughPopup(anchor: WalkthroughPopupAnchor(view: treatmentView, position: .bottomCenter(offset: CGSize(width: 0.0, height: 44.0))))
          renderBackground(anchorView: treatmentView)
        case .selectAddons:
          showWalkthroughPopup(anchor: WalkthroughPopupAnchor(view: addonsView, position: .bottomCenter(offset: CGSize(width: 0.0, height: 44.0))))
          renderBackground(anchorView: addonsView)
        case .selectTherapist:
          showWalkthroughPopup(anchor: WalkthroughPopupAnchor(view: therapistView, position: .bottomCenter(offset: CGSize(width: 0.0, height: 44.0))))
          renderBackground(anchorView: therapistView)
        case .addNote:
          showWalkthroughPopup(anchor: WalkthroughPopupAnchor(view: noteView, position: .bottomCenter(offset: CGSize(width: 0.0, height: 44.0))))
          renderBackground(anchorView: noteView)
        case .selectDateTime:
          showWalkthroughPopup(anchor: WalkthroughPopupAnchor(view: calendarView, position: .bottomCenter(offset: CGSize(width: 0.0, height: 44.0))))
          renderBackground(anchorView: calendarView)
        case .requestNow:
          showWalkthroughPopup(anchor: WalkthroughPopupAnchor(view: requestView, position: .topCenter(offset: CGSize(width: 0.0, height: 44.0))))
          renderBackground(anchorView: requestView)
        default: break
        }
      case .none:
        break
      }
    }
  }
  
  @IBOutlet private weak var gradientView: UIView!
  @IBOutlet private weak var baNavTitleView: BAANavTitleView! {
    didSet {
      baNavTitleView.isWalkthrough = true
    }
  }
  @IBOutlet private weak var baTreatmentTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var baTreatmentInputView: BAAInputView! {
    didSet {
      baTreatmentInputView.type = .fieldSelection(activeTitle: "Treatment", inactiveTitle: "Select a Treatment")
      baTreatmentInputView.isWalkthrough = true
    }
  }
  @IBOutlet private weak var baAddonsTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var baAddonsInputView: BAAInputView! {
    didSet {
      baAddonsInputView.type = .multiSelection(activeTitle: "Add-On(s)", inactiveTitle: "Add-On(s)")
      baAddonsInputView.text = "None"
      baAddonsInputView.multiSelectionContents = nil
      baAddonsInputView.isWalkthrough = true
    }
  }
  @IBOutlet private weak var baPreferredTherapistsTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var baPreferredTherapistsInputView: BAAInputView! {
    didSet {
      baPreferredTherapistsInputView.type = .multiSelection(activeTitle: "Preferred Therapist(s)", inactiveTitle: "Preferred Therapist(s)")
      baPreferredTherapistsInputView.text = "No Preference"
      baPreferredTherapistsInputView.multiSelectionContents = nil
      baPreferredTherapistsInputView.isWalkthrough = true
    }
  }
  @IBOutlet private weak var baNotesTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var baNotesInputView: BAAInputView! {
    didSet {
      baNotesInputView.type = .textView(activeTitle: "Notes", inactiveTitle: "Add note")
      baNotesInputView.isWalkthrough = true
    }
  }
  @IBOutlet private weak var baRequestTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var baRequestInputView: DesignableButton! {
    didSet {
      baRequestInputView.cornerRadius = 7.0
      var appearance = DialogButtonAttributedTitleAppearance()
      appearance.color = .white
      baRequestInputView.backgroundColor = .greyblue
      baRequestInputView.setAttributedTitle("REQUEST NOW".attributed.add(.appearance(appearance)), for: .normal)
    }
  }
  
  fileprivate var type: BaseWalkthroughType!
  fileprivate weak var delegate: BaseWalkthroughDelegate?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    delegate?.baseWalkthroughDidStart(baseWalkthroughViewController: self)
    switch type {
    case .main:
      currentStep = .notifications
    case .booking:
      currentStep = .selectBranch
    case .none:
      delegate?.baseWalkthroughDidFinish(baseWalkthroughViewController: self)
      dismissViewController()
    }
  }
  
  private func resetBAViews() {
    baNavTitleView.isHidden = true
    baTreatmentInputView.isHidden = true
    baAddonsInputView.isHidden = true
    baPreferredTherapistsInputView.isHidden = true
    baNotesInputView.isHidden = true
    baRequestInputView.isHidden = true
  }
  
  private func renderBackground(anchorView: UIView? = nil) {
    gradientView.layer.sublayers?.removeAll()
    let colors = [UIColor(red: 172, green: 206, blue: 206, alpha: 0.75),UIColor(red: 22, green: 92, blue: 125, alpha: 0.75)]
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = view.bounds
    gradientLayer.colors = colors.map({ $0.cgColor })
    gradientLayer.locations = [0.0, 1.0].map({ NSNumber(value: $0) })
    if let anchorView = anchorView, var windowFrame = anchorView.superview?.convert(anchorView.frame, to: nil) {
      let cornerRadius: CGFloat
      let dashLineStartPoint: CGPoint
      let subEndValue: CGFloat
      switch type {
      case .main:
        switch currentStep {
        case .welcomeToPorcelain, .scanQR, .porcelain, .profile, .shop:
          cornerRadius = 0
          dashLineStartPoint = view.center
          subEndValue = 0
        default:
          let oldSize = windowFrame.size
          let targetSize = CGSize(width: 40.0, height: 40.0)
          var originValue = windowFrame.origin
          originValue.x = originValue.x + (oldSize.width - targetSize.width)/2.0
          originValue.y = originValue.y + (oldSize.height - targetSize.height)/2.0
          windowFrame = CGRect(origin: originValue, size: targetSize)
          cornerRadius = targetSize.height/2.0
          dashLineStartPoint = view.center
          subEndValue = 0
        }
      case .booking:
        cornerRadius = anchorView.layer.cornerRadius
        switch currentStep {
        case .requestNow:
          dashLineStartPoint = CGPoint(x: view.center.x, y: windowFrame.origin.y - (windowFrame.height + 44.0))
          subEndValue = -(windowFrame.height/2.0 + 16.0)
        default:
          dashLineStartPoint = CGPoint(x: view.center.x, y: windowFrame.origin.y + windowFrame.height + 44.0)
          subEndValue = windowFrame.height/2.0 + 16.0
        }
      case .none:
        cornerRadius = 0
        dashLineStartPoint = view.center
        subEndValue = 0
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        //dashed start
        let dashedLayer = CAShapeLayer()
        dashedLayer.lineWidth = 1.5
        dashedLayer.strokeColor = UIColor.white.cgColor
        dashedLayer.lineDashPattern = [8,2]
        
        let dashedPath = CGMutablePath()
        let endPoint = CGPoint(x: windowFrame.origin.x + (windowFrame.width/2.0), y: windowFrame.origin.y + (windowFrame.height/2.0) + subEndValue)
        dashedPath.addLines(between: [dashLineStartPoint, endPoint])
        dashedLayer.path = dashedPath
        gradientLayer.addSublayer(dashedLayer)
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 0.3
        dashedLayer.add(animation, forKey: "MyAnimation")
        //dashed end
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          switch self.currentStep {
          case .selectBranch, .selectTreatment, .selectAddons, .selectTherapist, .addNote, .selectDateTime:
            let dotPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: endPoint.x - 5.0, y: endPoint.y - 10.0), size: CGSize(width: 10.0, height: 10.0)))
            let dotLayer = CAShapeLayer()
            dotLayer.path = dotPath.cgPath
            dotLayer.lineWidth = 1.5
            dotLayer.strokeColor = UIColor.white.cgColor
            dotLayer.fillColor = UIColor.clear.cgColor
            gradientLayer.addSublayer(dotLayer)
          case .requestNow:
            let dotPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: endPoint.x - 5.0, y: endPoint.y), size: CGSize(width: 10.0, height: 10.0)))
            let dotLayer = CAShapeLayer()
            dotLayer.path = dotPath.cgPath
            dotLayer.lineWidth = 1.5
            dotLayer.strokeColor = UIColor.white.cgColor
            dotLayer.fillColor = UIColor.clear.cgColor
            gradientLayer.addSublayer(dotLayer)
          default: break
          }
          switch self.currentStep {
          case .selectBranch:
            self.baNavTitleView.isHidden = false
            self.baNavTitleView.frame = windowFrame
          case .selectTreatment:
            self.baTreatmentInputView.isHidden = false
            self.baTreatmentTopConstraint.constant = windowFrame.origin.y
          case .selectAddons:
            self.baAddonsInputView.isHidden = false
            self.baAddonsTopConstraint.constant = windowFrame.origin.y
          case .selectTherapist:
            self.baPreferredTherapistsInputView.isHidden = false
            self.baPreferredTherapistsTopConstraint.constant = windowFrame.origin.y
          case .addNote:
            self.baNotesInputView.isHidden = false
            self.baNotesTopConstraint.constant = windowFrame.origin.y
          case .requestNow:
            self.baRequestInputView.isHidden = false
            self.baRequestTopConstraint.constant = windowFrame.origin.y
          default:
            let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height), cornerRadius: 0)
            let circlePath = UIBezierPath(roundedRect: CGRect(origin: windowFrame.origin, size: windowFrame.size), cornerRadius: cornerRadius)
            path.append(circlePath)
            path.usesEvenOddFillRule = true
            let fillLayer = CAShapeLayer()
            fillLayer.path = path.cgPath
            fillLayer.fillRule = kCAFillRuleEvenOdd
            gradientLayer.mask = fillLayer
          }
        }
      }
    }
    gradientView.layer.addSublayer(gradientLayer)
  }
}

// MARK: - WalkthroughPopupPresenterProtocol
extension  BaseWalkthroughViewController: WalkthroughPopupPresenterProtocol {
  public func walkthroughPopupTitle() -> String? {
    return currentStep.title
  }
  
  public func walkthroughPopupContent() -> NSAttributedString? {
    return currentStep.content
  }
  
  public func walkthroughPopupSkipTitle() -> String? {
    guard BaseWalkthroughStep(rawValue: currentStep.rawValue + 1) != nil else { return nil }
    return "SKIP"
  }
  
  public func walkthroughPopupNextTitle() -> String? {
    if BaseWalkthroughStep(rawValue: currentStep.rawValue + 1) == nil {
      return "DONE"
    } else {
      return "NEXT"
    }
  }
  
  public func walkthroughPopupSkipDidTapped(walkthroughPopupViewController: WalkthroughPopupViewController) {
    renderBackground()
    switch type {
    case .main:
      AppUserDefaults.oneTimeMainWalkthrough = true
      delegate?.baseWalkthroughDidFinish(baseWalkthroughViewController: self)
      walkthroughPopupViewController.dismissPresenter()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.dismissViewController()
        appDelegate.mainView.goToTab(.home)
      }
    case .booking:
      AppUserDefaults.oneTimeBookAppointmentWalkthrough = true
      delegate?.baseWalkthroughDidFinish(baseWalkthroughViewController: self)
      walkthroughPopupViewController.dismissPresenter()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.dismissViewController()
      }
    case .none: break
    }
  }
  
  public func walkthroughPopupNextDidTapped(walkthroughPopupViewController: WalkthroughPopupViewController) {
    renderBackground()
    walkthroughPopupViewController.dismissPresenter()
    if let newStep = BaseWalkthroughStep(rawValue: currentStep.rawValue + 1) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.currentStep = newStep
      }
    } else {//DONE
      switch type {
      case .main:
        AppUserDefaults.oneTimeMainWalkthrough = true
        delegate?.baseWalkthroughDidFinish(baseWalkthroughViewController: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.dismissViewController()
          appDelegate.mainView.goToTab(.home)
        }
      case .booking:
        AppUserDefaults.oneTimeBookAppointmentWalkthrough = true
        delegate?.baseWalkthroughDidFinish(baseWalkthroughViewController: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          self.dismissViewController()
        }
      case .none: break
      }
    }
  }
}

// MARK: - ControllerProtocol
extension BaseWalkthroughViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("BaseWalkthroughViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    resetBAViews()
    switch type {
    case .main:
      renderBackground()
    case .booking:
      renderBackground()
    case .none:
      break
    }
  }
  
  public func setupObservers() {
  }
}

extension AppDelegate {
  public var hasPendingMainWalkthrough: Bool {
    return !AppUserDefaults.oneTimeMainWalkthrough && AppConfiguration.enableWalkthrough && AppUserDefaults.isLoggedIn
  }
  
  public func showBaseWalkthrough(type: BaseWalkthroughType, delegate: BaseWalkthroughDelegate? = nil) {
    guard let vc = appDelegate.mainView as? UIViewController else { return }
    let baseWalkthroughViewController =  UIStoryboard.get(.walkthrough).getController(BaseWalkthroughViewController.self)
    baseWalkthroughViewController.type = type
    baseWalkthroughViewController.delegate = delegate
    vc.present(baseWalkthroughViewController, animated: true) {
    }
  }
}
