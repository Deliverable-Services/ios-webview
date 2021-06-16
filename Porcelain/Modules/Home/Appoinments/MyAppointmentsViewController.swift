//
//  MyAppointmentsViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 08/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import CoreData

private struct Constant {
  static let packageColors: [UIColor] = [
    .init(hex: 0xa8e6ce),
    .init(hex: 0xf8b195),
    .init(hex: 0xf67280),
    .init(hex: 0xdcedc2),
    .init(hex: 0xc06c84)]
}

public final class MyAppointmentsViewController: UIViewController, RefreshHandlerProtocol {
  public var refreshControl: UIRefreshControl? {
    didSet {
      refreshControl?.tintColor = .lightNavy
    }
  }
  
  public var refreshScrollView: UIScrollView?
  
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var bookAnAppointmentButton: DesignableButton! {
    didSet {
      bookAnAppointmentButton.setAttributedTitle(
        UIImage.icCalendarClock.maskWithColor(.white).attributed.append(
          attrs: " BOOK AN APPOINTMENT".attributed.add([
            .color(.white),
            .font(.idealSans(style: .light(size: 15.0))),
            .baseline(offset: 5.0)])),
        for: .normal)
      var appearance = ShadowAppearance.default
      appearance.fillColor = .greyblue
      bookAnAppointmentButton.shadowAppearance = appearance
    }
  }
  @IBOutlet private weak var upcomingAppointmentsLabel: UILabel! {
    didSet {
      upcomingAppointmentsLabel.font = .idealSans(style: .book(size: 16.0))
      upcomingAppointmentsLabel.textColor = .gunmetal
      upcomingAppointmentsLabel.text = "UPCOMING"
    }
  }
  @IBOutlet private weak var upcomingApptEmptyNotificationView: EmptyNotificationView!
  @IBOutlet private weak var upcomingAppointmentsCollectionView: UICollectionView! {
    didSet {
      upcomingAppointmentsCollectionView.registerWithNib(MyAppointmentsCell.self)
      upcomingAppointmentsCollectionView.dataSource = self
      upcomingAppointmentsCollectionView.delegate = self
    }
  }
  @IBOutlet private weak var pendingAppointmentsLabel: UILabel! {
    didSet {
      pendingAppointmentsLabel.font = .idealSans(style: .book(size: 16.0))
      pendingAppointmentsLabel.textColor = .gunmetal
      pendingAppointmentsLabel.text = "PENDING"
    }
  }
  @IBOutlet private weak var pendingAppointmentsSubtitleLabel: UILabel! {
    didSet {
      pendingAppointmentsSubtitleLabel.font = .openSans(style: .regular(size: 12.0))
      pendingAppointmentsSubtitleLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var pendingApptEmptyNotificationView: EmptyNotificationView!
  @IBOutlet private weak var pendingAppointmentsCollectionView: UICollectionView! {
    didSet {
      pendingAppointmentsCollectionView.registerWithNib(MyAppointmentsCell.self)
      pendingAppointmentsCollectionView.dataSource = self
      pendingAppointmentsCollectionView.delegate = self
    }
  }
  @IBOutlet private weak var sessionsLeftLabel: UILabel! {
    didSet {
      sessionsLeftLabel.font = .idealSans(style: .book(size: 16.0))
      sessionsLeftLabel.textColor = .gunmetal
      sessionsLeftLabel.text = "PACKAGES"
    }
  }
  @IBOutlet private weak var segmentedControl: DesignableSegmentedControl!
  @IBOutlet private weak var packageEmptyNotificationView: EmptyNotificationView!
  @IBOutlet private weak var packageTableView: ResizingContentTableView! {
    didSet {
      packageTableView.registerWithNib(PackageCell.self)
      packageTableView.setAutomaticDimension()
      packageTableView.dataSource = self
      packageTableView.delegate = self
    }
  }
  @IBOutlet private weak var pastAppointmentsButton: UIButton! {
    didSet {
//      let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePastAppointmentsButtonPan(_:)))
//      pastAppointmentsButton.addGestureRecognizer(panGesture)
//      pastAppointmentsButton.transform = .init(translationX: AppUserDefaults.pastAppointmentTranslationX ?? 0.0, y:  AppUserDefaults.pastAppointmentTranslationY ?? 0.0)
    }
  }
  
  private var estimatedaPackageHeightDict: [String: CGFloat] = [:]
  private var upcomingHasError: Bool = false
  private var pendingHasError: Bool = false
  private lazy var upcomingFRCHandler = FetchResultsControllerHandler<Appointment>(type: .collectionView(upcomingAppointmentsCollectionView))
  private lazy var pendingFRCHandler = FetchResultsControllerHandler<Appointment>(type: .collectionView(pendingAppointmentsCollectionView))
  
  private lazy var viewModel: MyAppointmentsViewModelProtocol = MyAppointmentsViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
     viewModel.initialize()
  }
  
  @objc
  private func handlePastAppointmentsButtonPan(_ panGesture: UIPanGestureRecognizer) {
    guard let view = panGesture.view else { return }
    let translation = panGesture.translation(in: view)
    if panGesture.state == .began {
      view.transform = .init(translationX: AppUserDefaults.pastAppointmentTranslationX ?? 0.0, y: AppUserDefaults.pastAppointmentTranslationY ?? 0.0)
    } else if panGesture.state == .changed {
      view.transform = .init(translationX: (AppUserDefaults.pastAppointmentTranslationX ?? 0.0) + translation.x, y: (AppUserDefaults.pastAppointmentTranslationY ?? 0.0) + translation.y)
    } else if panGesture.state == .ended {
      AppUserDefaults.pastAppointmentTranslationX = (AppUserDefaults.pastAppointmentTranslationX ?? 0.0) + translation.x
      AppUserDefaults.pastAppointmentTranslationY = (AppUserDefaults.pastAppointmentTranslationY ?? 0.0) + translation.y
    }
  }
  
  @IBAction private func bookAnAppointmentTapped(_ sender: Any) {
    appDelegate.mainView.validateSession(loginCompletion: {
      self.showBookAnAppointment()
    }, validCompletion: {
      self.showBookAnAppointment()
    })
  }
  
  @IBAction private func packageSegmentValueChanged(_ sender: DesignableSegmentedControl) {
    viewModel.isGrouped = !NSNumber(value: sender.selectedSegmentIndex).boolValue
    packageTableView.allowsMultipleSelection = viewModel.isGrouped
    packageTableView.reloadData()
  }
  
  @IBAction private func pastAppointmentsTapped(_ sender: Any) {
    appDelegate.mainView.validateSession(loginCompletion: {
      self.showPastAppointments { [weak self] (rebook) in
        guard let `self` = self else { return }
        self.showBookAnAppointment(rebookData: rebook)
      }
    }) {
      self.showPastAppointments { [weak self] (rebook) in
        guard let `self` = self else { return }
        self.showBookAnAppointment(rebookData: rebook)
      }
    }
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    viewModel.initialize()
  }
}

// MARK: - NavigationProtocol
extension MyAppointmentsViewController: NavigationProtocol {
}

// MARK: - ApplicationDelegateCallbackProtocol
extension MyAppointmentsViewController: ApplicationDelegateCallbackProtocol {
  public func applicationWillResignActive(_ notification: Notification) {
    
  }
  
  public func applicationDidEnterBackground(_ notification: Notification) {
    
  }
  
  public func applicationWillEnterForeground(_ notification: Notification) {
    
  }
  
  public func applicationDidBecomeActive(_ notification: Notification) {
    viewModel.initialize()
  }
  
  public func applicationWillTerminate(_ notification: Notification) {
    
  }
}

// MARK: - BookAnAppointmentPresenterProtocol
extension MyAppointmentsViewController: BookAnAppointmentPresenterProtocol {
  public func bookAnAppointmentDidDismiss() {
  }
  
  public func bookAnAppointmentDidRequest() {
  }
}

// MARK: - PastAppointmentsPresenterProtocol
extension MyAppointmentsViewController: PastAppointmentsPresenterProtocol {
}

// MARK: - ControllerProtocol
extension MyAppointmentsViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("MyAppointmentsViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popViewController))
    viewModel.attachView(self)
  }
  
  public func setupObservers() {
    observeRefresh(scrollView: scrollView)
    observeApplicationCallback()
    upcomingApptEmptyNotificationView.tapped = { [weak self] in
      guard let `self`  = self else { return }
      self.viewModel.reloadUpcomingAppointments()
    }
    pendingApptEmptyNotificationView.tapped = { [weak self] in
      guard let `self`  = self else { return }
      self.viewModel.reloadPendingAppointments()
    }
    packageEmptyNotificationView.tapped = { [weak self] in
      guard let `self`  = self else { return }
      self.viewModel.reloadSessionPackages()
    }
    upcomingFRCHandler.delegate = self
    pendingFRCHandler.delegate = self
  }
}

// MARK: - MyAppointmentsView
extension MyAppointmentsViewController: MyAppointmentsView {
  public func reload() {
    upcomingFRCHandler.reload(recipe: viewModel.upcomingAppointmentsRecipe)
    pendingFRCHandler.reload(recipe: viewModel.pendingAppointmentsRecipe)
  }
  
  public func showLoading(section: MyAppointmentsSection) {
    switch section {
    case .upcomingAppointments:
      upcomingApptEmptyNotificationView.isLoading = true
      if upcomingFRCHandler.numberOfObjectsInSection(0) == 0 || upcomingHasError {
        upcomingApptEmptyNotificationView.isHidden = false
        upcomingAppointmentsCollectionView.isHidden = true
      } else  {
        upcomingApptEmptyNotificationView.isHidden = true
        upcomingAppointmentsCollectionView.isHidden = false
      }
    case .pendingAppointments:
      pendingApptEmptyNotificationView.isLoading = true
      pendingAppointmentsCollectionView.isHidden = true
      if pendingFRCHandler.numberOfObjectsInSection(0) == 0 || pendingHasError {
        pendingApptEmptyNotificationView.isHidden = false
        pendingAppointmentsCollectionView.isHidden = true
      } else {
        pendingApptEmptyNotificationView.isHidden = true
        pendingAppointmentsCollectionView.isHidden = false
      }
    case .sessionPackages:
      packageEmptyNotificationView.isLoading = true
      packageTableView.reloadData()
      if viewModel.packages?.isEmpty ?? true {
        packageEmptyNotificationView.isHidden = false
      } else {
        packageEmptyNotificationView.isHidden = true
      }
    case .view:
      appDelegate.showLoading()
    }
  }
  
  public func hideLoading(section: MyAppointmentsSection) {
    endRefreshing()
    switch section {
    case .upcomingAppointments:
      upcomingApptEmptyNotificationView.isLoading = false
      if upcomingFRCHandler.numberOfObjectsInSection(0) == 0 {
        upcomingApptEmptyNotificationView.isHidden = false
        upcomingAppointmentsCollectionView.isHidden = true
      } else {
        upcomingApptEmptyNotificationView.isHidden = true
        upcomingAppointmentsCollectionView.isHidden = false
      }
    case .pendingAppointments:
      pendingApptEmptyNotificationView.isLoading = false
      if pendingFRCHandler.numberOfObjectsInSection(0) == 0 {
        pendingApptEmptyNotificationView.isHidden = false
        pendingAppointmentsCollectionView.isHidden = true
      } else {
        pendingApptEmptyNotificationView.isHidden = true
        pendingAppointmentsCollectionView.isHidden = false
      }
    case .sessionPackages:
      packageEmptyNotificationView.isLoading = false
      packageTableView.reloadData()
      if viewModel.packages?.isEmpty ?? true {
        packageEmptyNotificationView.isHidden = false
      } else {
        packageEmptyNotificationView.isHidden = true
      }
    case .view:
      appDelegate.hideLoading()
    }
  }
  
  public func showMessage(section: MyAppointmentsSection, message: String?) {
    switch section {
    case .upcomingAppointments:
      upcomingHasError = false
      upcomingApptEmptyNotificationView.message = message
    case .pendingAppointments:
      pendingHasError = false
      pendingApptEmptyNotificationView.message = message
    case .sessionPackages:
      packageEmptyNotificationView.message = message
    case .view:
      showAlert(title: nil, message: message)
    }
  }
  
  public func showError(section: MyAppointmentsSection, message: String?) {
    switch section {
    case .upcomingAppointments:
      upcomingHasError = true
      upcomingApptEmptyNotificationView.isHidden = false
      upcomingApptEmptyNotificationView.message = message
      upcomingAppointmentsCollectionView.isHidden = true
    case .pendingAppointments:
      pendingHasError = true
      pendingApptEmptyNotificationView.isHidden = false
      pendingApptEmptyNotificationView.message = message
      pendingAppointmentsCollectionView.isHidden = true
    case .sessionPackages:
      packageEmptyNotificationView.isHidden = false
      packageEmptyNotificationView.message = message
      packageTableView.reloadData()
    case .view:
      showAlert(title: "Oops!", message: message)
    }
  }
}

// MARK: - UICollectionViewDataSource
extension MyAppointmentsViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == upcomingAppointmentsCollectionView {
      return upcomingFRCHandler.numberOfObjectsInSection(section)
    } else if collectionView == pendingAppointmentsCollectionView {
      return pendingFRCHandler.numberOfObjectsInSection(section)
    } else {
      return 0
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let myAppointmentsCell = collectionView.dequeueReusableCell(MyAppointmentsCell.self, atIndexPath: indexPath)
    if collectionView == upcomingAppointmentsCollectionView {
      myAppointmentsCell.appointment = upcomingFRCHandler.object(at: indexPath)
    } else if collectionView == pendingAppointmentsCollectionView {
      myAppointmentsCell.appointment = pendingFRCHandler.object(at: indexPath)
    } else {
      fatalError("This should not be possible")
    }
    return myAppointmentsCell
  }
}

// MARK: - UICollectionViewDelegate
extension MyAppointmentsViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == upcomingAppointmentsCollectionView {
      AppointmentPopupViewController.load(withAppointment: upcomingFRCHandler.object(at: indexPath)).show(in: self)
    } else if collectionView == pendingAppointmentsCollectionView {
      AppointmentPopupViewController.load(withAppointment: pendingFRCHandler.object(at: indexPath)).show(in: self)
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyAppointmentsViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return MyAppointmentsCell.defaultSize
  }
}

// MARK: - FetchResultsControllerHandlerDelegate
extension MyAppointmentsViewController: FetchResultsControllerHandlerDelegate {
  public func fetchResultsWillUpdateContent(hander: Any) {
  }
  
  public func fetchResultsDidUpdateContent(handler: Any) {
    if upcomingFRCHandler == handler as? FetchResultsControllerHandler {
      if upcomingFRCHandler.numberOfObjectsInSection(0) == 0 {
        upcomingApptEmptyNotificationView.isHidden = false
        upcomingAppointmentsCollectionView.isHidden = true
        upcomingApptEmptyNotificationView.message = "No advanced booking yet."
      } else {
        upcomingApptEmptyNotificationView.isHidden = true
        upcomingAppointmentsCollectionView.isHidden = false
      }
    } else if pendingFRCHandler == handler as? FetchResultsControllerHandler {
      pendingApptEmptyNotificationView.isLoading = false
      if pendingFRCHandler.numberOfObjectsInSection(0) == 0 {
        pendingApptEmptyNotificationView.isHidden = false
        pendingAppointmentsCollectionView.isHidden = true
        pendingApptEmptyNotificationView.message = "No pending approval requests."
      } else {
        pendingApptEmptyNotificationView.isHidden = true
        pendingAppointmentsCollectionView.isHidden = false
      }
    }
  }
}

// MARK: - UITableViewDataSource
extension MyAppointmentsViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.packages?.count ?? 0
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let packageCell = tableView.dequeueReusableCell(PackageCell.self, atIndexPath: indexPath)
    packageCell.isGrouped = viewModel.isGrouped
    packageCell.color = Constant.packageColors[indexPath.row%5]
    packageCell.data = viewModel.packages?[indexPath.row]
    packageCell.isSelected = tableView.indexPathsForSelectedRows?.contains(indexPath) ?? false
    return packageCell
  }
}

// MARK: - UITableViewDelegate
extension MyAppointmentsViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    tableView.beginUpdates()
    tableView.endUpdates()
    estimatedaPackageHeightDict[concatenate(indexPath.row)] = cell.contentView.bounds.height
  }
  
  public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    guard let cell = tableView.cellForRow(at: indexPath) else { return }
    tableView.beginUpdates()
    tableView.endUpdates()
    estimatedaPackageHeightDict[concatenate(indexPath.row)] = cell.contentView.bounds.height
  }
  
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return estimatedaPackageHeightDict[concatenate(indexPath.row)] ?? PackageCell.defaultSize.height
  }
  
  public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    estimatedaPackageHeightDict[concatenate(indexPath.row)] = cell.contentView.bounds.height
  }
}

extension MyAppointmentsViewController {
  public func initialize() {
    viewModel.initialize()
  }
}

public protocol MyAppointmentsPresenterProtocol {
}

extension MyAppointmentsPresenterProtocol where Self: ControllerProtocol & UIViewController {
  @discardableResult
  public func showMyAppointments(animated: Bool = true) -> MyAppointmentsViewController {
    let myAppointmentsViewController = UIStoryboard.get(.appointment).getController(MyAppointmentsViewController.self)
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(myAppointmentsViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: myAppointmentsViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
    return myAppointmentsViewController
  }
}

extension R4pidDefaultskey {
  fileprivate static let pastAppointmentTranslationX = R4pidDefaultskey(value: "33FE419C80741BUKP2CG9BGX7PKO71849ED3\(AppUserDefaults.customerID ?? "")")
  fileprivate static let pastAppointmentTranslationY = R4pidDefaultskey(value: "E419C80741BUK49EDCG93P23FBGX7PKO7183\(AppUserDefaults.customerID ?? "")")
}

extension AppUserDefaults {
  fileprivate static var pastAppointmentTranslationX: CGFloat? {
    get {
      return R4pidDefaults.shared[.pastAppointmentTranslationX]?.number as? CGFloat
    }
    set {
      R4pidDefaults.shared[.pastAppointmentTranslationX] = .init(value: newValue)
    }
  }
  
  fileprivate static var pastAppointmentTranslationY: CGFloat? {
    get {
      return R4pidDefaults.shared[.pastAppointmentTranslationY]?.number as? CGFloat
    }
    set {
      R4pidDefaults.shared[.pastAppointmentTranslationY] = .init(value: newValue)
    }
  }
}
