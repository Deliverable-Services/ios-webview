//
//  ProjectPorcelainViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 27/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct StartSkinQuizAttributedTextAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 0.46
  }
  var alignment: NSTextAlignment? {
    return .center
  }
  var lineBreakMode: NSLineBreakMode? {
    return .byWordWrapping
  }
  var minimumLineHeight: CGFloat? {
    return 22.0
  }
  var font: UIFont? {
    return .openSans(style: .regular(size: 13.0))
  }
  var color: UIColor? {
    return .bluishGrey
  }
}

public final class ProjectPorcelainViewController: UIViewController, RefreshHandlerProtocol {
  public var refreshControl: UIRefreshControl? {
    didSet {
      refreshControl?.tintColor = .lightNavy
    }
  }
  
  public var refreshScrollView: UIScrollView?
  
  @IBOutlet private weak var scrollView: UIScrollView! {
    didSet {
      scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 16.0, right: 0.0)
    }
  }
  @IBOutlet private weak var startSkinQuizContainerView: UIView!
  @IBOutlet private weak var startSkinQuizDescriptionLabel: UILabel! {
    didSet {
      startSkinQuizDescriptionLabel.attributedText = """
        Kickstart your skincare journey with us here — take this short quiz so we know your skin better!
        """.attributed.add(.appearance(StartSkinQuizAttributedTextAppearance()))
    }
  }
  @IBOutlet private weak var startSkinQuizButton: DesignableButton! {
    didSet {
      startSkinQuizButton.cornerRadius = 20.0
      startSkinQuizButton.backgroundColor = .lightNavy
      startSkinQuizButton.setAttributedTitle(
        "START SKIN QUIZ".attributed.add([.color(.white), .font(.idealSans(style: .book(size: 13.0)))]),
        for: .normal)
    }
  }
  @IBOutlet private weak var skinQuizContentStack: UIStackView!
  @IBOutlet private weak var skinProfileTitleLabel: UILabel! {
    didSet {
      skinProfileTitleLabel.font = .openSans(style: .regular(size: 12.0))
      skinProfileTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var skinProfileAnswer1Button: SkinQuizAnswerButton!
  @IBOutlet private weak var skinProfileAnswer2Button: SkinQuizAnswerButton!
  @IBOutlet private weak var skinConcernsTitleLabel: UILabel! {
    didSet {
      skinConcernsTitleLabel.font = .openSans(style: .regular(size: 12.0))
      skinConcernsTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var skinConcernAnswer1Button: SkinQuizAnswerButton!
  @IBOutlet private weak var skinConcernAnswer2Button: SkinQuizAnswerButton!
  @IBOutlet private weak var skinQuizIncompleteLabel: UILabel! {
    didSet {
      skinQuizIncompleteLabel.attributedText = """
        Remember to complete the quiz so we can start whizzing you to good skin!
        """.attributed.add(.appearance(StartSkinQuizAttributedTextAppearance()))
    }
  }
  @IBOutlet private weak var skinQuizSeparatorView: UIView! {
    didSet {
      skinQuizSeparatorView.backgroundColor = .whiteThree
    }
  }
  @IBOutlet private weak var skinQuizButton: SkinQuizButton!
  @IBOutlet private weak var skinAnalysisButton: SkinAnalysisButton!
  @IBOutlet private weak var myTreatmentPlanButton: ProjectPorcelainButton! {
    didSet {
      myTreatmentPlanButton.image = .icMyTreatmentPlan
      myTreatmentPlanButton.title = "My Treatment Plan"
      myTreatmentPlanButton.content = "Discover your carefully-curated, bespoke regimen that works specifically for you."
    }
  }
  @IBOutlet private weak var myProductPrescriptionButton: ProjectPorcelainButton! {
    didSet {
      myProductPrescriptionButton.image = .icMyProductPrescription
      myProductPrescriptionButton.title = "My Product Prescription"
      myProductPrescriptionButton.content = "It’s all about the right fit. Find out about the products cherry-picked for your skin."
    }
  }
  @IBOutlet private weak var weatherContainerView: DesignableView!
  @IBOutlet private weak var weatherInformationView: WeatherInformationView!
  @IBOutlet private weak var timedSliderView: TimedSliderView!
  
  private lazy var chatBarButton = BadgeableBarButtonItem(image: .icChat, style: .plain, target: self, action: #selector(chatTapped(_:)))
  private lazy var notificationsBarButton = BadgeableBarButtonItem(image: .icNotifications, style: .plain, target: self, action: #selector(notificationsTapped(_:)))

  private lazy var viewModel: ProjectPorcelainViewModelProtocol = ProjectPorcelainViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    viewModel.reloadSkinQuiz()
    if !AppUserDefaults.isLoggedIn {
      notificationsBarButton.setBadge(nil)
    }
  }
  
  private func validateWeatherInfoIssue() {
    switch LocationManager.shared.locationAuthStatus {
    case .denied, .restricted, .notDetermined:
      weatherInformationView.emptyNotificationActionData = EmptyNotificationActionData(
        title: "Your location cannot be detected.",
        titleNumberOfLines: 1,
        subtitle: "Allow access to see weather forecast.",
        subtitleNumberOfLines: 1,
        action: "OPEN SETTINGS")
    default:
      weatherInformationView.emptyNotificationActionData = nil
    }
  }
  
  private func updateSkinQuizUI(isLoading: Bool = false) {
    let skinProfileAnswers = viewModel.skinQuizSkinProfileAnswers
    let skinConcernsAnswers = viewModel.skinQuizSkinConcernsAnswers
    skinProfileAnswer1Button.isQuizDone = viewModel.isSkinQuizDone
    skinProfileAnswer2Button.isQuizDone = viewModel.isSkinQuizDone
    skinConcernAnswer1Button.isQuizDone = viewModel.isSkinQuizDone
    skinConcernAnswer2Button.isQuizDone = viewModel.isSkinQuizDone
    if !skinProfileAnswers.isEmpty || !skinConcernsAnswers.isEmpty {
      startSkinQuizContainerView.isHidden = true
      skinQuizContentStack.isHidden = false
      if skinProfileAnswers.count > 1 {
        skinProfileAnswer1Button.image = skinProfileAnswers[0].image
        skinProfileAnswer1Button.title = skinProfileAnswers[0].title
        skinProfileAnswer2Button.image = skinProfileAnswers[1].image
        skinProfileAnswer2Button.title = skinProfileAnswers[1].title
      } else {
        skinProfileAnswer1Button.image = skinProfileAnswers.first?.image
        skinProfileAnswer1Button.title = skinProfileAnswers.first?.title
        skinProfileAnswer2Button.image = nil
        skinProfileAnswer2Button.title = nil
      }
      if skinConcernsAnswers.count > 1 {
        skinConcernAnswer1Button.image = skinConcernsAnswers[0].image
        skinConcernAnswer1Button.title = skinConcernsAnswers[0].title
        skinConcernAnswer2Button.image = skinConcernsAnswers[1].image
        skinConcernAnswer2Button.title = skinConcernsAnswers[1].title
      } else {
        skinConcernAnswer1Button.image = skinConcernsAnswers.first?.image
        skinConcernAnswer1Button.title = skinConcernsAnswers.first?.title
        skinConcernAnswer2Button.image = nil
        skinConcernAnswer2Button.title = nil
      }
//      if skinProfileAnswers.count >= 2 && skinConcernsAnswers.count >= 2 {
//        skinQuizIncompleteLabel.isHidden = true
//      } else {
        skinQuizIncompleteLabel.isHidden = viewModel.isSkinQuizDone
//      }
    } else {
      startSkinQuizContainerView.isHidden = false
      skinQuizContentStack.isHidden = true
      skinQuizIncompleteLabel.isHidden = true
      skinQuizSeparatorView.isHidden = true
    }
    skinQuizButton.isComplete = viewModel.isSkinQuizDone
  }
  
  private func showSkinQuizIfNeeded(_ sender: DesignableControl) {
    if viewModel.isSkinQuizDone {
     self.showSkinQuiz()
    } else {
      if sender == skinProfileAnswer1Button || sender == skinProfileAnswer2Button {
        self.showSkinQuiz(withQuestionID: "1")
      } else if sender == skinConcernAnswer1Button || sender == skinConcernAnswer2Button {
        if viewModel.skinQuizAnswers.filter({ $0.questionID == "1" }).isEmpty {
          showSkinQuiz(withQuestionID: "1")
        } else if viewModel.skinQuizAnswers.filter({ $0.questionID == "2" }).isEmpty {
          showSkinQuiz(withQuestionID: "2")
        } else {
          showSkinQuiz(withQuestionID: "3")
        }
      } else {
        showSkinQuiz()
      }
    }
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    viewModel.initialize()
    LocationManager.shared.startUpdatingLocation()
  }
  
  @objc
  private func notificationsTapped(_ sender: Any) {
    appDelegate.mainView.validateSession(loginCompletion: {
      self.showNotifications()
    }) {
      self.showNotifications()
    }
  }
  
  @objc
  private func chatTapped(_ sender: Any) {
    appDelegate.mainView.validateSession(loginCompletion: {
       appDelegate.freshChatShowConversations(in: self)
    }) {
       appDelegate.freshChatShowConversations(in: self)
    }
  }
  
  @IBAction private func skinQuizTapped(_ sender: DesignableControl) {
    appDelegate.mainView.validateSession(loginCompletion: {
      self.showSkinQuizIfNeeded(sender)
    }) {
      self.showSkinQuizIfNeeded(sender)
    }
  }
  
  @IBAction private func skinAnalysisTapped(_ sender: DesignableControl) {
    appDelegate.mainView.validateSession(loginCompletion: {
      self.showSkinAnalysis()
    }, validCompletion: {
      self.showSkinAnalysis()
    })
  }
  
  @IBAction private func myTreatmentPlanTapped(_ sender: Any) {
    appDelegate.mainView.validateSession(loginCompletion: {
      self.showMyTreatmentPlan()
    }, validCompletion: {
      self.showMyTreatmentPlan()
    })
  }
  
  @IBAction private func myProductPrescriptionTapped(_ sender: Any) {
    appDelegate.mainView.validateSession(loginCompletion: {
      self.showMyProductPrescriptions()
    }, validCompletion: {
      self.showMyProductPrescriptions()
    })
  }
}

// MARK: - NavigationProtocol
extension ProjectPorcelainViewController: NavigationProtocol {
}

// MARK: - NotificationsPresenterProtocol
extension ProjectPorcelainViewController: NotificationsPresenterProtocol {
}

// MARK: - SkinQuizViewModelProtocol
extension ProjectPorcelainViewController: SkinQuizPresenterProtocol {
}

// MARK: - SkinAnalysisPresenterProtocol
extension ProjectPorcelainViewController: SkinAnalysisPresenterProtocol {
}

// MARK: - MyTreatmentPlanPresenterProtocol
extension ProjectPorcelainViewController: MyTreatmentPlanPresenterProtocol {
}

// MARK: - MyProductPrescriptionPresenter
extension ProjectPorcelainViewController: MyProductPrescriptionPresenter {
}

// MARK: - ControllerProtocol
extension ProjectPorcelainViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("ProjectPorcelainViewController segueIdentifier")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    generateRightNavigationButtons([chatBarButton, notificationsBarButton])
    viewModel.attachView(self)
    viewModel.initialize()
    LocationManager.shared.startUpdatingLocation()
  }
  
  public func setupObservers() {
    observeRefresh(scrollView: scrollView)
    LocationManager.shared.addHandler(LocationManagerHander(completion: { (delegate) in
      switch delegate {
      case .didUpdateLocation:
        self.viewModel.reloadWeather(latitude: LocationManager.shared.coordinate.latitude, longitude: LocationManager.shared.coordinate.longitude)
      case .didFailWithError:
        self.validateWeatherInfoIssue()
      case .didChangeAuthStatus:
        self.validateWeatherInfoIssue()
      }
    }))
    NotificationCenter.default.addObserver(forName: .didReceiveNotification, object: nil, queue: .main) { (_) in
      self.viewModel.reloadNotifications()//handle notification badge
    }
    timedSliderView.didSelectRow = { [weak self] (row) in
      guard let `self` = self else { return }
      guard let bannerDatas = self.viewModel.timedSliderContents as? [BannerData] else { return }
      let dialogHandler = DialogHandler()
      dialogHandler.attributedMessage = bannerDatas[row].dialogAttrString
      dialogHandler.actions = [.confirm(title: "GOT IT!")]
      DialogViewController.load(handler: dialogHandler).show(in: self)
    }
  }
}

// MARK: - ProjectPorcelainView
extension ProjectPorcelainViewController: ProjectPorcelainView {
  public func reload() {
  }
  
  public func showLoading(section: ProjectPorcelainSection) {
    switch section {
    case .weather:
      weatherInformationView.viewModel = nil
      weatherInformationView.isLoading =  true
    case .banner:
      timedSliderView.viewModel = nil
      timedSliderView.isLoading = true
    case .skinQuiz:
      updateSkinQuizUI(isLoading: true)
    }
  }
  
  public func hideLoading(section: ProjectPorcelainSection) {
    endRefreshing()
    switch section {
    case .weather:
      weatherInformationView.viewModel = viewModel
      weatherInformationView.isLoading = false
    case .banner:
      timedSliderView.viewModel = viewModel
      timedSliderView.isLoading = false
    case .skinQuiz:
      updateSkinQuizUI(isLoading: false)
    }
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
  
  public func updateNotificationBadge() {
    notificationsBarButton.setBadge(viewModel.notificationBadge)
  }
}

public final class SkinQuizAnswerButton: DesignableControl {
  @IBOutlet private weak var emptyView: DesignableView! {
    didSet {
      emptyView.backgroundColor = .whiteFive
    }
  }
  @IBOutlet private weak var imageView: LoadingImageView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 12.0))
      titleLabel.textColor = .gunmetal
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    emptyView.cornerRadius = emptyView.bounds.width/2.0
    imageView.cornerRadius = imageView.bounds.width/2.0
  }
  
  public var isQuizDone: Bool = false {
    didSet {
      imageView.isHidden = image == nil
      emptyView.isHidden = image != nil || isQuizDone
    }
  }
  
  public var image: String? {
    didSet {
      imageView.isHidden = image == nil
      emptyView.isHidden = image != nil || isQuizDone
      imageView.url = image
    }
  }
  
  public var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
}

public final class SkinQuizButton: DesignableControl {
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var noticeLabel: UILabel! {
    didSet {
      noticeLabel.font = .idealSans(style: .book(size: 10.0))
      noticeLabel.textColor = .coral
      noticeLabel.text = "Incomplete"
    }
  }
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .light(size: 12.0))
      titleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var completeImageView: UIImageView!
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    addShadow(appearance: .default)
  }
  
  public var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
  public var isComplete: Bool = false {
    didSet {
      noticeLabel.isHidden = isComplete
      completeImageView.image = isComplete ? UIImage.icComplete: UIImage.icIncomplete
    }
  }
}

public final class SkinAnalysisButton: DesignableControl {
  @IBOutlet private weak var imageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .light(size: 12.0))
      titleLabel.textColor = .gunmetal
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    addShadow(appearance: .default)
  }
  
  public var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
}
