//
//  MyTreatmentPlanViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 02/10/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class MyTreatmentPlanViewController: UIViewController, RefreshHandlerProtocol {
  public var refreshControl: UIRefreshControl? {
    didSet {
      refreshControl?.tintColor = .lightNavy
    }
  }
  public var refreshScrollView: UIScrollView?
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var bookAnAppointmentButton: ProjectPorcelainHeaderButton! {
    didSet {
      bookAnAppointmentButton.fillColor = .greyblue
      bookAnAppointmentButton.image = UIImage.icBookAnAppointment
      bookAnAppointmentButton.title = "BOOK AN APPOINTMENT"
    }
  }
  @IBOutlet private weak var myAppointmentsButton: ProjectPorcelainHeaderButton! {
    didSet {
      myAppointmentsButton.fillColor = .lightNavy
      myAppointmentsButton.image = UIImage.icMyAppointments
      myAppointmentsButton.title = "MY APPOINTMENTS"
    }
  }
  @IBOutlet private weak var upcomingAppointmentsLabel: UILabel! {
    didSet {
      upcomingAppointmentsLabel.font = .idealSans(style: .book(size: 16.0))
      upcomingAppointmentsLabel.textColor = .gunmetal
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
  @IBOutlet private weak var treatmentPlanLabel: UILabel! {
    didSet {
      treatmentPlanLabel.font = .idealSans(style: .book(size: 16.0))
      treatmentPlanLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var treatmentPlanEmptyNotifActionView: EmptyNotificationActionView!
  @IBOutlet private weak var treatmentPlanTableView: ResizingContentTableView! {
    didSet {
      treatmentPlanTableView.setAutomaticDimension()
      treatmentPlanTableView.registerWithNib(MyTreatmentPlanTCell.self)
      treatmentPlanTableView.dataSource = self
      treatmentPlanTableView.delegate = self
    }
  }
  
  private lazy var upcomingFRCHandler = FetchResultsControllerHandler<Appointment>(type: .collectionView(upcomingAppointmentsCollectionView))
  private lazy var treatmentPlanFRCHandler = FetchResultsControllerHandler<TreatmentPlanItem>(type: .tableView(treatmentPlanTableView))
  
  private var upcomingHasError: Bool = false
  
  public var treatmentPlanEmptyNotificationActionData: EmptyNotificationActionData? {
    didSet {
      if let treatmentPlanEmptyNotificationActionData = treatmentPlanEmptyNotificationActionData  {
        treatmentPlanEmptyNotifActionView.isHidden = false
        treatmentPlanEmptyNotifActionView.type = .centered(data: treatmentPlanEmptyNotificationActionData)
      } else {
        treatmentPlanEmptyNotifActionView.isHidden = true
      }
    }
  }
  
  private lazy var viewModel: MyTreatmentPlanViewModelProtocol = MyTreatmentPlanViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  private func openAppointment(id: String) {
    guard let customerID = AppUserDefaults.customerID else { return }
    appDelegate.showLoading()
    PPAPIService.Appointment.getAppointment(appointmentID: id).call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customer = User.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          let appointments = Appointment.getAppointments(appointmentIDs: [id], customerID: customerID, inMOC: moc)
          Appointment.parseAppointmentFromData(result.data, customer: customer, appointments: appointments, inMOC: moc)
        }, completion: { (_) in
          appDelegate.hideLoading()
          guard let appointment = Appointment.getAppointment(id: id, customerID: customerID) else {
            self.showAlert(title: "Oops!", message: "Error parsing appointment.")
            return
          }
          if let state = AppointmentState(rawValue: appointment.state ?? "") {
            switch state {
            case .cancelled:
              self.showAlert(title: "Oops!", message: "Appointment has been cancelled already.")
              self.viewModel.initialize()
            case .rejected:
              self.showAlert(title: "Oops!", message: "Appointment has been rejected already.")
              self.viewModel.initialize()
            case .confirmed, .reserved, .requested:
              AppointmentPopupViewController.load(withAppointment: appointment).show(in: self)
            default:
              self.showAlert(title: "Oops!", message: "Appointment has invalid state.")
              self.viewModel.initialize()
            }
          } else {
            self.showAlert(title: "Oops!", message: "Appointment state is not found.")
            self.viewModel.initialize()
          }
        })
      case .failure(let error):
        appDelegate.hideLoading()
        self.showAlert(title: "Oops!", message: error.localizedDescription)
      }
    }
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    viewModel.initialize()
  }
  
  @IBAction private func bookAnAppointmentTapped(_ sender: Any) {
    appDelegate.mainView.validateSession(loginCompletion: {
      self.showBookAnAppointment()
    }, validCompletion: {
      self.showBookAnAppointment()
    })
  }
  
  @IBAction private func myAppointmentsTapped(_ sender: Any) {
    appDelegate.mainView.validateSession(loginCompletion: {
      self.showMyAppointments()
    }, validCompletion: {
      self.showMyAppointments()
    })
  }
}

// MARK: - NavigationProtocol
extension MyTreatmentPlanViewController: NavigationProtocol {
}

// MARK: - BookAnAppointmentPresenterProtocol
extension MyTreatmentPlanViewController: BookAnAppointmentPresenterProtocol {
  public func bookAnAppointmentDidDismiss() {
  }
  
  public func bookAnAppointmentDidRequest() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.showMyAppointments()
    }
  }
}

// MARK: - MyAppointmentsPresenterProtocol
extension MyTreatmentPlanViewController: MyAppointmentsPresenterProtocol {
}

// MARK: - ControllerProtocol
extension MyTreatmentPlanViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("MyTreatmentPlanViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popOrDismissViewController))
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    observeRefresh(scrollView: scrollView)
    upcomingApptEmptyNotificationView.tapped = { [weak self] in
      guard let `self`  = self else { return }
      self.viewModel.reloadUpcomingAppointments()
    }
    treatmentPlanEmptyNotifActionView.actionDidTapped = { [weak self] (action) in
      guard let `self` = self else { return }
      self.viewModel.reloadMyTreatmentPlan()
    }
    upcomingFRCHandler.delegate = self
  }
}

// MARK: - MyTreatmentPlanView
extension MyTreatmentPlanViewController: MyTreatmentPlanView {
  public func reload() {
    treatmentPlanLabel.text = ["My Treatment Plan", viewModel.treatmentPlan?.treatmentPhase].compactMap({ $0 }).joined(separator: ": ")
    upcomingFRCHandler.reload(recipe: viewModel.upcomingAppointmentsRecipe)
    treatmentPlanFRCHandler.reload(recipe: viewModel.treatmentPlanRecipe)
  }
  
  public func showLoading(section: MyTreatmentPlanSection) {
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
    case .treatmentPlan:
      treatmentPlanEmptyNotifActionView.isLoading = true
      if treatmentPlanFRCHandler.numberOfObjectsInSection(0) == 0 {
        treatmentPlanEmptyNotifActionView.isHidden = false
        treatmentPlanTableView.isHidden = true
      } else {
        treatmentPlanEmptyNotifActionView.isHidden = true
        treatmentPlanTableView.isHidden = false
      }
    case .view:
      appDelegate.showLoading()
    }
  }
  
  public func hideLoading(section: MyTreatmentPlanSection) {
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
    case .treatmentPlan:
      treatmentPlanEmptyNotifActionView.isLoading = false
       if treatmentPlanFRCHandler.numberOfObjectsInSection(0) == 0 {
         treatmentPlanEmptyNotifActionView.isHidden = false
         treatmentPlanTableView.isHidden = true
       } else {
         treatmentPlanEmptyNotifActionView.isHidden = true
         treatmentPlanTableView.isHidden = false
       }
    case .view:
      appDelegate.hideLoading()
    }
  }
  
  public func showMessage(section: MyTreatmentPlanSection, message: String?) {
    switch section {
    case .upcomingAppointments:
      upcomingHasError = false
      upcomingApptEmptyNotificationView.message = message
    case .treatmentPlan:
      treatmentPlanLabel.text = ["My Treatment Plan", viewModel.treatmentPlan?.treatmentPhase].compactMap({ $0 }).joined(separator: ": ")
      if treatmentPlanFRCHandler.numberOfObjectsInSection(0) == 0 {
        treatmentPlanEmptyNotificationActionData = EmptyNotificationActionData(
          title: "Uh oh! No recommendations yet.",
          subtitle: """
Approach any of our skin experts for a
personalised treatment plan to balance, treat
and prevent all your skin woes.
""",
          action: nil)
      } else {
        treatmentPlanEmptyNotificationActionData = nil
      }
    case .view:
      showAlert(title: nil, message: message)
    }
  }
  
  public func showError(section: MyTreatmentPlanSection, message: String?) {
    switch section {
    case .upcomingAppointments:
      upcomingHasError = true
      upcomingApptEmptyNotificationView.isHidden = false
      upcomingApptEmptyNotificationView.message = message
      upcomingAppointmentsCollectionView.isHidden = true
    case .treatmentPlan:
      treatmentPlanEmptyNotificationActionData = EmptyNotificationActionData(
      title: nil,
      subtitle: message,
      action: "RELOAD")
      treatmentPlanTableView.isHidden = true
    case .view:
      showAlert(title: "Oops!", message: message)
    }
  }
}

// MARK: - UITableViewDataSource
extension MyTreatmentPlanViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return treatmentPlanFRCHandler.numberOfObjectsInSection(section)
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let myTreatmentPlanTCell = tableView.dequeueReusableCell(MyTreatmentPlanTCell.self, atIndexPath: indexPath)
    myTreatmentPlanTCell.treatmentPlanItem = treatmentPlanFRCHandler.object(at: indexPath)
    if indexPath.row == 0 {
      myTreatmentPlanTCell.position = .top
    } else if (indexPath.row + 1) == treatmentPlanFRCHandler.numberOfObjectsInSection(indexPath.section) {
      myTreatmentPlanTCell.position = .bottom
    } else {
      myTreatmentPlanTCell.position = .middle
    }
    myTreatmentPlanTCell.bookDidTapped = { [weak self] (type) in
      guard let `self` = self else { return }
      switch type {
      case .openAppointment(let id):
        self.openAppointment(id: id)
      case .bookNow(let rebookData):
        self.showBookAnAppointment(rebookData: rebookData)
      }
    }
    return myTreatmentPlanTCell
  }
}

// MARK: - UITableViewDelegate
extension MyTreatmentPlanViewController: UITableViewDelegate {
  
}

// MARK: - UICollectionViewDataSource
extension MyTreatmentPlanViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return upcomingFRCHandler.numberOfObjectsInSection(section)
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let myAppointmentsCell = collectionView.dequeueReusableCell(MyAppointmentsCell.self, atIndexPath: indexPath)
    myAppointmentsCell.appointment = upcomingFRCHandler.object(at: indexPath)
    return myAppointmentsCell
  }
}

// MARK: - UICollectionViewDelegate
extension MyTreatmentPlanViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    AppointmentPopupViewController.load(withAppointment: upcomingFRCHandler.object(at: indexPath)).show(in: self)
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyTreatmentPlanViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return MyAppointmentsCell.defaultSize
  }
}

// MARK: - FetchResultsControllerHandlerDelegate
extension MyTreatmentPlanViewController: FetchResultsControllerHandlerDelegate {
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
    } else if treatmentPlanFRCHandler == handler as? FetchResultsControllerHandler {
      if treatmentPlanFRCHandler.numberOfObjectsInSection(0) == 0 {
        treatmentPlanEmptyNotificationActionData = EmptyNotificationActionData(
          title: "Uh oh! No recommendations yet.",
          subtitle: """
        Approach any of our skin experts for a
        personalised treatment plan to balance, treat
        and prevent all your skin woes.
        """,
          action: nil)
        treatmentPlanTableView.isHidden = true
      } else {
        treatmentPlanEmptyNotificationActionData = nil
        treatmentPlanTableView.isHidden = false
      }
    }
  }
}

public protocol MyTreatmentPlanPresenterProtocol {
}

extension MyTreatmentPlanPresenterProtocol where Self: ControllerProtocol & UIViewController {
  @discardableResult
  public func showMyTreatmentPlan(animated: Bool = true) -> MyTreatmentPlanViewController {
    let myTreatmentPlanViewController = UIStoryboard.get(.projectPorcelain).getController(MyTreatmentPlanViewController.self)
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(myTreatmentPlanViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: myTreatmentPlanViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
    return myTreatmentPlanViewController
  }
}
