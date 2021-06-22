//
//  BookAnAppointmentViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 22/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct DropDownData: DropDownDataProtocol {
  var title: String?
  var subtitle: String?
}

public final class BookAnAppointmentViewController: UIViewController {
  @IBOutlet private weak var navTitleView: BAANavTitleView!
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var treatmentInputView: BAAInputView! {
    didSet {
      treatmentInputView.type = .fieldSelection(activeTitle: "Treatment", inactiveTitle: "Select a Treatment")
    }
  }
  @IBOutlet private weak var addonsInputView: BAAInputView! {
    didSet {
      addonsInputView.type = .multiSelection(activeTitle: "Add-On(s)", inactiveTitle: "Add-On(s)")
    }
  }
  @IBOutlet private weak var preferredTherapistsInputView: BAAInputView! {
    didSet {
      preferredTherapistsInputView.type = .multiSelection(activeTitle: "Preferred Therapist(s)", inactiveTitle: "Preferred Therapist(s)")
    }
  }
  @IBOutlet private weak var notesInputView: BAAInputView! {
    didSet {
      notesInputView.type = .textView(activeTitle: "Notes", inactiveTitle: "Add note")
    }
  }
  @IBOutlet private weak var calendarView: BAACalendarView!
  @IBOutlet private weak var timeSlotsView: BAATimeSlotsView!
  @IBOutlet private weak var requestNowButton: DesignableButton! {
    didSet {
      requestNowButton.cornerRadius = 7.0
    }
  }
  
  private var isRequestNowEnabled: Bool = false {
    didSet {
      var appearance = DialogButtonAttributedTitleAppearance()
      appearance.color = isRequestNowEnabled ? .white: .bluishGrey
      requestNowButton.backgroundColor = isRequestNowEnabled ? .greyblue: .whiteThree
      requestNowButton.setAttributedTitle("REQUEST NOW".attributed.add(.appearance(appearance)), for: .normal)
    }
  }
  
  private var requestData: BAATimeSlotsResultData? {
    didSet {
      isRequestNowEnabled = requestData != nil
    }
  }
  
  fileprivate var didDismiss: VoidCompletion?
  fileprivate var didRequest: VoidCompletion?
  
  private var centers: [Center] = []
  private var addons: [Service] = []
  private var therapists: [Therapist] = []
  
  fileprivate lazy var viewModel: BookAnAppointmentViewModelProtocol = BookAnAppointmentViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    hideBarSeparator()
    isRequestNowEnabled = false
    viewModel.reload()
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if !AppUserDefaults.oneTimeBookAppointmentWalkthrough && AppConfiguration.enableWalkthrough {
      calendarView.isHidden = false
      appDelegate.showBaseWalkthrough(type: .booking(
        branchView: navTitleView,
        treatmentView: treatmentInputView,
        addonsView: addonsInputView,
        therapistView: preferredTherapistsInputView,
        noteView: notesInputView,
        calendarView: calendarView,
        requestView: requestNowButton), delegate: self)
    }
  }
  
  private func updateSlotDatesView() {
    guard let centerID = self.viewModel.selectedCenter?.id else { return }
    guard let treatmentID = self.viewModel.selectedTreatment?.id else { return }
    calendarView.evaluateSlotDates(data: SlotDatesData(
      centerID: centerID,
      treatmentID: treatmentID,
      addonIDs: viewModel.selectedAddons?.compactMap({ $0.id }),
      therapistIDs: viewModel.selectedTherapists?.compactMap({ $0.id })))
  }
  
  private func updateTimeSlotsView() {
    timeSlotsView.cancel()
    guard let centerID = self.viewModel.selectedCenter?.id else {
      self.timeSlotsView.errorMessage = "Please select a branch."
      return
    }
    guard let treatmentID = self.viewModel.selectedTreatment?.id else {
      self.timeSlotsView.errorMessage = "Please select a treatment."
      return
    }
    guard let date = calendarView.selectedDate else {
      self.timeSlotsView.errorMessage = "Please select a date."
      return
    }
    timeSlotsView.evaluateRequest(BAATimeSlotsRequestData(
      centerID: centerID,
      treatmentID: treatmentID,
      addOnIDs: viewModel.selectedAddons?.compactMap({ $0.id }),
      therapistIDs: viewModel.selectedTherapists?.compactMap({ $0.id }),
      date: date))
  }
  
  public override func popOrDismissViewController() {
    super.popOrDismissViewController()
    didDismiss?()
  }
  
  @IBAction private func centerTapped(_ sender: Any) {
    view.endEditing(true)
    let handler = DropDownHandler()
    handler.headerTitle = "SELECT BRANCH"
    handler.width = 300.0
    handler.type = .singleSelection(appearance: DropDownAppearance())
    handler.didSelectIndex = { [weak self] (indx) in
      guard let `self` = self else { return }
      self.viewModel.selectedCenter = self.centers[indx]
      self.viewModel.selectedTreatment = nil
      self.viewModel.selectedAddons = nil
      self.viewModel.selectedTherapists = nil
      self.viewModel.reload()
      self.updateTimeSlotsView()
      self.updateSlotDatesView()
    }
    handler.preSelectedIndex = centers.enumerated().first(where: { $0.element.id == viewModel.selectedCenter?.id })?.offset
    handler.willShow = { [weak self] in
      guard let `self` = self else { return }
      self.navTitleView.isSelected = true
    }
    handler.willHide = { [weak self] in
      guard let `self` = self else { return }
      self.navTitleView.isSelected = false
    }
    handler.asyncCompletion = { (_, dropDownView) in
      dropDownView.showLoading()
      PPAPIService.Center.getCenters().call { (response) in
        switch response {
        case .success(let result):
          CoreDataUtil.performBackgroundTask({ (moc) in
            Center.parseCentersFromData(result.data, inMOC: moc)
          }, completion: { (_) in
            dropDownView.hideLoading()
            self.centers = CoreDataUtil.list(
              Center.self,
              sorts: [.custom(key: "name", isAscending: true)])
            dropDownView.contents = self.centers.map({ DropDownData(title: $0.name, subtitle: $0.address1 ) })
            dropDownView.reload()
          })
        case .failure(let error):
          dropDownView.hideLoading()
          dropDownView.errorDescription = error.localizedDescription
        }
      }
    }
    PresenterViewController.show(
      presentVC: DropDownViewController.load(handler: handler),
      settings: [
        .tapToDismiss,
        .anchor(view: navigationController!.navigationBar, position: .bottomCenter(offset: .zero))],
      onVC: self)
  }
  
  @IBAction private func requestNowTapped(_ sender: Any) {
    viewModel.notes = notesInputView.text
    guard let requestData = requestData else { return }
    viewModel.requestAppointment(data: requestData)
  }
}

extension BookAnAppointmentViewController {
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let selectTreatmentViewController = segue.destination as? BAASelectTreatmentViewController {
      let handler = BAASelectTreatmentHandler()
      handler.selectedCenter = viewModel.selectedCenter
      handler.didSelectTreatment = { [weak self] (service) in
        guard let `self` = self else { return }
        self.viewModel.selectedTreatment = service
        self.viewModel.selectedAddons = nil
        self.viewModel.selectedTherapists = nil
        self.viewModel.reload()
        self.updateTimeSlotsView()
        self.updateSlotDatesView()
      }
      selectTreatmentViewController.handler = handler
    }
  }
}

// MARK: - NavigationProtocol
extension BookAnAppointmentViewController: NavigationProtocol {
}

// MARK: - BaseWalkthroughDelegate
extension BookAnAppointmentViewController: BaseWalkthroughDelegate {
  public func baseWalkthroughDidStart(baseWalkthroughViewController: BaseWalkthroughViewController) {
  }
  
  public func baseWalkthroughDidChangeStep(baseWalkthroughViewController: BaseWalkthroughViewController, step: BaseWalkthroughStep) {
    if step == .addNote, UIScreen.main.bounds.width <= 320.0 {
      scrollView.setContentOffset(CGPoint(x: 0.0, y: 60.0), animated: false)
    } else if step == .selectDateTime,
      let calendarFrame = calendarView.superview?.convert(calendarView.frame, to: nil),
      let navBarFrame = navigationController?.navigationBar.superview?.convert(navigationController!.navigationBar.frame, to: nil) {
      if UIScreen.main.bounds.width <= 320.0 {
        scrollView.setContentOffset(CGPoint(x: 0.0, y: calendarFrame.origin.y - (navBarFrame.origin.y + navBarFrame.height) + 60.0), animated: false)
      } else {
        scrollView.setContentOffset(CGPoint(x: 0.0, y: calendarFrame.origin.y - (navBarFrame.origin.y + navBarFrame.height)), animated: false)
      }
    }
  }
  
  public func baseWalkthroughDidFinish(baseWalkthroughViewController: BaseWalkthroughViewController) {
    scrollView.setContentOffset(.zero, animated: false)
    calendarView.isHidden = viewModel.selectedTreatment == nil
  }
}

// MARK: - ControllerProtocol
extension BookAnAppointmentViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    return "showSelectTreatment"
  }
  
  public func setupUI() {
    view.backgroundColor = .whiteFive
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popOrDismissViewController))
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.icLeftArrow.maskWithColor(.clear), style: .plain, target: nil, action: nil)
    viewModel.attachView(self)
    viewModel.initialize()
    updateTimeSlotsView()
  }
  
  public func setupObservers() {
    observeKeyboard()
    treatmentInputView.didSelect = { [weak self] in
      guard let `self` = self else { return }
      guard self.viewModel.selectedCenter != nil else {
        self.showError(message: "Branch must be loaded to continue, please try reloading the screen.")
        self.timeSlotsView.errorMessage = "Branch must be loaded to continue, please try reloading the screen."
        return
      }
      self.view.endEditing(true)
      self.performSegue(withIdentifier: BAASelectTreatmentViewController.segueIdentifier, sender: nil)
    }
    setupAddonsHandler()
    setupPreferredTherapistsHandler()
    calendarView.didSelectDate = { [weak self] (date) in
      guard let `self` = self else { return }
      self.updateTimeSlotsView()
    }
    timeSlotsView.didSelectTimeSlot = { [weak self] (timeSlot) in
      guard let `self` = self else { return }
      self.requestData = timeSlot
    }
  }
}

extension BookAnAppointmentViewController {
  private func setupAddonsHandler() {
    addonsInputView.didUpdateContents = { [weak self] in
      guard let `self` = self else { return }
      self.viewModel.selectedAddons = self.addons.filter { (addon) -> Bool in
        return self.addonsInputView.multiSelectionContents?.contains(where: { $0.id == addon.id }) ?? false
      }
      self.viewModel.reload()
      self.updateTimeSlotsView()
      self.updateSlotDatesView()
    }
    addonsInputView.didSelect = { [weak self] in
      guard let `self` = self else { return }
      guard let centerID = self.viewModel.selectedCenter?.id else {
        self.showError(message: "Please select a branch first.")
        self.timeSlotsView.errorMessage = "Please select a branch first."
        return
      }
      guard let treatmentID = self.viewModel.selectedTreatment?.id else {
        self.showError(message: "Please select a treatment first.")
        self.timeSlotsView.errorMessage = "Please select a treatment first."
        return
      }
      self.view.endEditing(true)
      var apperance: PresenterAppearance = .default
      apperance.shadowAppearance = nil
      let handler = BAADropdownHandler()
      handler.title = "Select your Add-On(s)"
      handler.defaultTitle = "None"
      handler.didSelectRows = { [weak self] (rows) in
        guard let `self` = self else { return }
        self.viewModel.selectedAddons = self.addons.enumerated().filter({ rows.contains($0.offset) }).map({ $0.element })
        self.viewModel.selectedTherapists = nil
        self.viewModel.reload()
        self.updateTimeSlotsView()
        self.updateSlotDatesView()
      }
      handler.didSelectNoPreference = { [weak self] in
        guard let `self` = self else { return }
        self.viewModel.selectedAddons = nil
        self.viewModel.reload()
        self.updateTimeSlotsView()
        self.updateSlotDatesView()
      }
      handler.asyncCompletion = { [weak self] (dropdownView) in
        guard let `self` = self else { return }
        dropdownView.showLoading()
        PPAPIService.Center.getAddons(centerID: centerID, serviceID: treatmentID).call { (response) in
          switch response {
          case .success(let result):
            CoreDataUtil.performBackgroundTask({ (moc) in
              Service.parseCenterServicesFromData(result.data, centerID: centerID, type: .addon, inMOC: moc)
            }, completion: { (_) in
              dropdownView.hideLoading()
              self.addons = CoreDataUtil.list(
                Service.self,
                predicate: .compoundAnd(predicates: [
                  .isEqual(key: "type", value: ServiceType.addon.rawValue),
                  .isEqual(key: "centerID", value: centerID)]),
                sorts: [.custom(key: "name", isAscending: true)])
              dropdownView.contents = self.addons.compactMap({ $0.name })
              dropdownView.reload()
              dropdownView.selectedRows = self.addons.enumerated().filter { (_, service) -> Bool in
                return self.viewModel.selectedAddons?.contains(where: { $0.id == service.id }) ?? false
                }.map({ $0.offset })
            })
          case .failure(let error):
            dropdownView.hideLoading()
            dropdownView.showError(message: error.localizedDescription)
          }
        }
      }
      PresenterViewController.show(
        presentVC: BAADropdownViewController.load(handler: handler),
        settings: [
          .tapToDismiss,
          .appearance(apperance)],
        onVC: self)
    }
  }
  
  private func setupPreferredTherapistsHandler() {
    preferredTherapistsInputView.didUpdateContents = { [weak self] in
      guard let `self` = self else { return }
      self.viewModel.selectedTherapists = self.therapists.filter { (therapist) -> Bool in
        return self.preferredTherapistsInputView.multiSelectionContents?.contains(where: { $0.id == therapist.id }) ?? false
      }
      self.viewModel.reload()
      self.updateTimeSlotsView()
      self.updateSlotDatesView()
    }
    preferredTherapistsInputView.didSelect = { [weak self] in
      guard let `self` = self else { return }
      guard let centerID = self.viewModel.selectedCenter?.id else {
        self.showError(message: "Please select a branch first.")
        self.timeSlotsView.errorMessage = "Please select a branch first."
        return
      }
      guard let treatmentID = self.viewModel.selectedTreatment?.id else {
        self.showError(message: "Please select a treatment first.")
        self.timeSlotsView.errorMessage = "Please select a treatment first."
        return
      }
      self.view.endEditing(true)
      var apperance: PresenterAppearance = .default
      apperance.shadowAppearance = nil
      let handler = BAADropdownHandler()
      handler.title = "Select Therapist(s)"
      handler.defaultTitle = "No Preference"
      handler.didSelectRows = { [weak self] (rows) in
        guard let `self` = self else { return }
        self.viewModel.selectedTherapists = self.therapists.enumerated().filter({ rows.contains($0.offset) }).map({ $0.element })
        self.viewModel.reload()
        self.updateTimeSlotsView()
        self.updateSlotDatesView()
      }
      handler.didSelectNoPreference = { [weak self] in
        guard let `self` = self else { return }
        self.viewModel.selectedTherapists = nil
        self.viewModel.reload()
        self.updateTimeSlotsView()
        self.updateSlotDatesView()
      }
      handler.asyncCompletion = { [weak self] (dropdownView) in
        guard let `self` = self else { return }
        dropdownView.showLoading()
        PPAPIService.Center.getTherapists(centerID: centerID, serviceID: treatmentID, addonIDs: self.viewModel.selectedAddons?.compactMap({ $0.id })).call { (response) in
          switch response {
          case .success(let result):
            var therapistIDs: [String] = []
            CoreDataUtil.performBackgroundTask({ (moc) in
              guard let therapistArray = result.data.array else { return }
              therapistIDs = therapistArray.compactMap({ $0.employeeID.string })
              let therapists = CoreDataUtil.list(
                Therapist.self,
                predicate: .compoundAnd(predicates: [
                  .isEqual(key: "type", value: UserType.therapist.rawValue),
                  .isEqualIn(key: "id", values: therapistIDs)]),
                inMOC: moc)
              therapistArray.forEach { (data) in
                let therapist = Therapist.parseUserFromData(data, users: therapists, type: .therapist, inMOC: moc)
                therapist?.displayName = data.name.string
              }
            }, completion: { (_) in
              dropdownView.hideLoading()
              self.therapists = CoreDataUtil.list(
                Therapist.self,
                predicate: .compoundAnd(predicates: [
                  .isEqual(key: "type", value: UserType.therapist.rawValue),
                  .isEqualIn(key: "id", values: therapistIDs)]),
                sorts: [.custom(key: "displayName", isAscending: true)])
              dropdownView.contents = self.therapists.compactMap({ $0.displayName ?? $0.shortName })
              dropdownView.reload()
              dropdownView.selectedRows = self.therapists.enumerated().filter { (_, therapist) -> Bool in
                return self.viewModel.selectedTherapists?.contains(where: { $0.id == therapist.id }) ?? false
                }.map({ $0.offset })
            })
          case .failure(let error):
            dropdownView.hideLoading()
            dropdownView.showError(message: error.localizedDescription)
          }
        }
      }
      PresenterViewController.show(
        presentVC: BAADropdownViewController.load(handler: handler),
        settings: [
          .tapToDismiss,
          .appearance(apperance)],
        onVC: self)
    }
  }
}

// MARK: - BookAnAppointmentView
extension BookAnAppointmentViewController: BookAnAppointmentView {
  public func reload() {
    if centers.isEmpty {
      centers = CoreDataUtil.list(
        Center.self,
        sorts: [.custom(key: "name", isAscending: true)])
    }
    navTitleView.selectedCenter = viewModel.selectedCenter
    treatmentInputView.text = viewModel.selectedTreatment?.name
    if let selectedAddons = viewModel.selectedAddons, !selectedAddons.isEmpty {
      addonsInputView.text = nil
      addonsInputView.multiSelectionContents = selectedAddons.map({ BAAMultiSelectionData(title: $0.name, id: $0.id)})
    } else   {
      addonsInputView.text = "None"
      addonsInputView.multiSelectionContents = nil
    }
    if let selectedTherapists = viewModel.selectedTherapists, !selectedTherapists.isEmpty {
      preferredTherapistsInputView.text = nil
      preferredTherapistsInputView.multiSelectionContents = selectedTherapists.map({ BAAMultiSelectionData(title: $0.displayName ?? $0.shortName, id: $0.id)})
    } else {
      preferredTherapistsInputView.text = "No Preference"
      preferredTherapistsInputView.multiSelectionContents = nil
    }
    calendarView.isHidden = viewModel.selectedTreatment == nil
  }
  
  public func showLoading() {
    appDelegate.showLoading()
  }
  
  public func hideLoading() {
    appDelegate.hideLoading()
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
  
  public func showSuccess(message: String?) {
    let dialogHandler = DialogHandler()
    dialogHandler.message = message ?? "You have successfully requested an appointment."
    dialogHandler.actions = [.confirm(title: "GOT IT!")]
    dialogHandler.actionCompletion = { [weak self] (_, dialogView) in
      guard let `self` = self else { return }
      dialogView.dismiss()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.popOrDismissViewController()
        self.didRequest?()
      }
    }
    DialogViewController.load(handler: dialogHandler).show(in: self)
  }
}

// MARK: - KeyboardHandlerProtocol
extension BookAnAppointmentViewController: KeyboardHandlerProtocol {
  public func keyboardWillHide(_ notification: Notification) {
    scrollView.contentInset = .zero
  }
  
  public func keyboardWillShow(_ notification: Notification) {
    let height = evaluateKeyboardFrameFromNotification(notification).height - (tabBarController?.tabBar.bounds.height ?? 0)
    scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: height, right: 0.0)
  }
}

public protocol BookAnAppointmentPresenterProtocol {
  func bookAnAppointmentDidDismiss()
  func bookAnAppointmentDidRequest()
}

extension BookAnAppointmentPresenterProtocol where Self: ControllerProtocol & UIViewController {
  @discardableResult
  public func showBookAnAppointment(rebookData: RebookData? = nil, animated: Bool = true) -> BookAnAppointmentViewController {
    let bookAnAppointmentViewController = UIStoryboard.get(.bookAnAppointment).getController(BookAnAppointmentViewController.self)
    bookAnAppointmentViewController.viewModel.rebookData = rebookData
    bookAnAppointmentViewController.didDismiss = { [weak self] in
      guard let `self` = self else { return }
      self.bookAnAppointmentDidDismiss()
    }
    bookAnAppointmentViewController.didRequest = { [weak self] in
      guard let `self` = self else { return }
      self.bookAnAppointmentDidRequest()
    }
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(bookAnAppointmentViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: bookAnAppointmentViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
    return bookAnAppointmentViewController
  }
}
