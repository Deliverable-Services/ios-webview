//
//  HomeViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 24/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import SafariServices

private struct BannerPromptAttributedTextApperance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double?
  var alignment: NSTextAlignment? = .left
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat?
  var font: UIFont?
  var color: UIColor?
}

public final class HomeViewController: UIViewController, RefreshHandlerProtocol {
  public var refreshControl: UIRefreshControl? {
    didSet {
      refreshControl?.tintColor = .lightNavy
    }
  }
  
  public var refreshScrollView: UIScrollView?
  
  @IBOutlet private weak var locationImageView: UIImageView! {
    didSet {
      locationImageView.image = nil
    }
  }
  @IBOutlet private weak var locationLabel: UILabel! {
    didSet {
      locationLabel.font = .openSans(style: .regular(size: 16.0))
      locationLabel.textColor = .lightNavy
      locationLabel.text = nil
    }
  }
  @IBOutlet private weak var scrollView: UIScrollView! {
    didSet {
      scrollView.alwaysBounceVertical = true
    }
  }
  @IBOutlet private weak var weatherContainerView: DesignableView!
  @IBOutlet private weak var weatherInformationView: WeatherInformationView!
  @IBOutlet private weak var timedSliderView: TimedSliderView!
  @IBOutlet private weak var productsButton: HomeCircleButton!
  @IBOutlet private weak var treatmentsButton: HomeCircleButton!
  @IBOutlet private weak var myAppointmentsButton: HomeCircleButton!
  @IBOutlet private weak var articleSegmentStack: UIStackView!
  @IBOutlet private weak var newsButton: ArticleSegmentButton! {
    didSet {
      newsButton.setAttributedTitle(
        "News".attributed.add([.color(.gunmetal), .font(.idealSans(style: .book(size: 14.0)))]),
        for: .normal)
      newsButton.setAttributedTitle(
        "News".attributed.add([.color(.white), .font(.idealSans(style: .book(size: 14.0)))]),
        for: .selected)
    }
  }
  @IBOutlet private weak var prologueButton: ArticleSegmentButton! {
    didSet {
      prologueButton.setAttributedTitle(
        "Prologue".attributed.add([.color(.gunmetal), .font(.idealSans(style: .book(size: 14.0)))]),
        for: .normal)
      prologueButton.setAttributedTitle(
        "Prologue".attributed.add([.color(.white), .font(.idealSans(style: .book(size: 14.0)))]),
        for: .selected)
    }
  }
  @IBOutlet private weak var promotionsButton: ArticleSegmentButton! {
    didSet {
      promotionsButton.setAttributedTitle(
        "Promotions".attributed.add([.color(.gunmetal), .font(.idealSans(style: .book(size: 14.0)))]),
        for: .normal)
      promotionsButton.setAttributedTitle(
        "Promotions".attributed.add([.color(.white), .font(.idealSans(style: .book(size: 14.0)))]),
        for: .selected)
    }
  }
  @IBOutlet private weak var articleSliderContainerView: UIView!
  @IBOutlet private weak var newsArticleSliderView: ArticleSliderView!
  @IBOutlet private weak var prologueArticleSliderView: ArticleSliderView!
  @IBOutlet private weak var promotionsArticleSliderView: ArticleSliderView!
  
  private lazy var chatBarButton = BadgeableBarButtonItem(image: .icChat, style: .plain, target: self, action: #selector(chatTapped(_:)))
  private lazy var notificationsBarButton = BadgeableBarButtonItem(image: .icNotifications, style: .plain, target: self, action: #selector(notificationsTapped(_:)))
  
  private let viewModel: HomeViewModelProtocol = HomeViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if viewModel.articleSection == .promotions {
      updateArticleSection()
    }
    if !AppUserDefaults.isLoggedIn {
      notificationsBarButton.setBadge(nil)
    }
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if appDelegate.hasPendingMainWalkthrough {
      appDelegate.showBaseWalkthrough(type: .main(chatBarButton: chatBarButton, notificationsBarButton: notificationsBarButton))
    }
  }

  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    var shadowAppearance: ShadowAppearance = .default
    shadowAppearance.cornerRadius = 0.0
    weatherContainerView.addShadow(appearance: shadowAppearance)
    updateArticleSection()
  }
  
  private func validateWeatherInfoIssue() {
    switch LocationManager.shared.locationAuthStatus {
    case .denied, .restricted, .notDetermined:
      locationImageView.image = nil
      locationLabel.text = nil
      weatherInformationView.emptyNotificationActionData = EmptyNotificationActionData(
        title: "Your location cannot be detected.",
        titleNumberOfLines: 1,
        subtitle: "Allow access to see weather forecast.",
        subtitleNumberOfLines: 1,
        action: "OPEN SETTINGS")
    default:
      weatherInformationView.emptyNotificationActionData = nil
      if let country = viewModel.weatherInformationData?.country {
        locationImageView.image = UIImage.icLocationPin.maskWithColor(.lightNavy)
        locationLabel.text = country
      } else {
        locationImageView.image = nil
        locationLabel.text = nil
      }
    }
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
  
  @IBAction private func productsTapped(_ sender: Any) {
    appDelegate.mainView.goToTab(.shop)
    appDelegate.mainView.selectedNavC?.getChildController(ShopViewController.self)?.showSection(.products)
  }
  
  @IBAction private func treatmentsTapped(_ sender: Any) {
    appDelegate.mainView.goToTab(.shop)
    appDelegate.mainView.selectedNavC?.getChildController(ShopViewController.self)?.showSection(.treatments)
  }
  
  @IBAction private func myAppointmentsTapped(_ sender: Any) {
    appDelegate.mainView.validateSession(loginCompletion: {
      self.showMyAppointments()
    }) {
      self.showMyAppointments()
    }
  }
  
  @IBAction private func newsTapped(_ sender: Any) {
    viewModel.setArticleSection(.news)
  }
  
  @IBAction private func prologueTapped(_ sender: Any) {
    viewModel.setArticleSection(.prolouge)
  }
  
  @IBAction private func promotionsTapped(_ sender: Any) {
    viewModel.setArticleSection(.promotions)
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    viewModel.initialize()
    LocationManager.shared.startUpdatingLocation()
  }
}

// MARK: - NavigationProtocol
extension HomeViewController: NavigationProtocol {
}

// MARK: - NotificationsPresenterProtocol
extension HomeViewController: NotificationsPresenterProtocol {
}

// MARK: - MyAppointmentsPresenterProtocol
extension HomeViewController: MyAppointmentsPresenterProtocol {
}

// MARK: - ControllerProtocol
extension HomeViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("HomeViewController segueIdentifier not set")
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
    newsArticleSliderView.didSelectArticle = { (article) in
      UIApplication.shared.inAppSafariOpen(url: article.source ?? "")
    }
    prologueArticleSliderView.didSelectArticle = { (article) in
      UIApplication.shared.inAppSafariOpen(url: article.source ?? "")
    }
    promotionsArticleSliderView.didSelectArticle = { (article) in
      UIApplication.shared.inAppSafariOpen(url: article.source ?? "")
    } 
    promotionsArticleSliderView.emptyNotificationActionDidTapped = { [weak self] in
      guard let `self` = self else { return }
      appDelegate.mainView.validateSession(loginCompletion: {
        self.updateArticleSection()
      }) {
        self.updateArticleSection()
      }
    }
  }
}

// MARK: - HomeView
extension HomeViewController: HomeView {
  public func reload() {
  }
  
  public func updateArticleSection() {
    switch viewModel.articleSection {
    case .news:
      selectArticleSegmentButton(newsButton)
      selectArticleSliderView(newsArticleSliderView)
      newsArticleSliderView.data = viewModel.newsArticleData
    case .prolouge:
      selectArticleSegmentButton(prologueButton)
      selectArticleSliderView(prologueArticleSliderView)
      prologueArticleSliderView.data = viewModel.prologueArticleData
    case .promotions:
      selectArticleSegmentButton(promotionsButton)
      selectArticleSliderView(promotionsArticleSliderView)
      if AppUserDefaults.isLoggedIn {
        promotionsArticleSliderView.data = viewModel.promotionsArticleData
        promotionsArticleSliderView.emptyNotificationActionData = nil
      } else {
        promotionsArticleSliderView.data = nil
        promotionsArticleSliderView.emptyNotificationActionData = EmptyNotificationActionData(
          title: "To continue and view our latest promos",
          subtitle: nil,
          action: "LOGIN")
      }
    }
  }
  
  public func showLoading(section: HomeSection) {
    switch section {
    case .weather:
      locationImageView.image = nil
      locationLabel.text = "Loading..."
      weatherInformationView.viewModel = nil
      weatherInformationView.isLoading =  true
    case .banner:
      timedSliderView.viewModel = nil
      timedSliderView.isLoading = true
    case .articles:
      newsArticleSliderView.isLoading = true
      prologueArticleSliderView.isLoading = true
      promotionsArticleSliderView.isLoading = true
    }
  }
  
  public func hideLoading(section: HomeSection) {
    endRefreshing()
    switch section {
    case .weather:
      if let country = viewModel.weatherInformationData?.country {
        locationImageView.image = UIImage.icLocationPin.maskWithColor(.lightNavy)
        locationLabel.text = country
      } else {
        locationImageView.image = nil
        locationLabel.text = nil
      }
      weatherInformationView.viewModel = viewModel
      weatherInformationView.isLoading = false
    case .banner:
      timedSliderView.viewModel = viewModel
      timedSliderView.isLoading = false
    case .articles:
      newsArticleSliderView.isLoading = false
      prologueArticleSliderView.isLoading = false
      promotionsArticleSliderView.isLoading = false
    }
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
  
  public func updateNotificationBadge() {
    notificationsBarButton.setBadge(viewModel.notificationBadge)
  }
}

extension HomeViewController {
  private func selectArticleSegmentButton(_ articleButton: ArticleSegmentButton) {
    articleSegmentStack.subviews.forEach { (view) in
      guard let articleSegmentButton = view as? ArticleSegmentButton else { return }
      articleSegmentButton.isSelected = articleSegmentButton == articleButton
    }
  }
  
  private func selectArticleSliderView(_ articleView: ArticleSliderView) {
    articleSliderContainerView.subviews.forEach { (view) in
      guard let articleSliderView = view as? ArticleSliderView else { return }
      articleSliderView.isHidden = articleSliderView != articleView
    }
  }
}

extension HomeViewController {
  public func initialize() {
    viewModel.initialize()
    LocationManager.shared.startUpdatingLocation()
  }
}

public final class HomeCircleButton: DesignableButton {
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    var appearance = ShadowAppearance.default
    appearance.fillColor = .white
    appearance.cornerRadius = rect.width/2
    addShadow(appearance: appearance)
  }
}

public final class ArticleSegmentButton: DesignableButton {
  public override var isSelected: Bool {
    didSet {
      if isSelected {
        var shadowAppearance: ShadowAppearance = .default
        shadowAppearance.cornerRadius = bounds.width/2.0
        shadowAppearance.fillColor = .lightNavy
        addShadow(appearance: shadowAppearance)
      } else {
        removeShadow()
      }
    }
  }
}
