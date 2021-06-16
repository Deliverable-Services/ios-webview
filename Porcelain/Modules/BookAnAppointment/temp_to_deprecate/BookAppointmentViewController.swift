//
//  BookAppointmentViewController.swift
//  Porcelain
//
//  Created by Justine Rangel on 11/10/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import KRProgressHUD
import R4pidKit

public final class BookAppointmentViewController: UIViewController {
  @IBOutlet private weak var navigationTitleView: BANavigationTitleView!
  @IBOutlet private weak var navigationExtensionView: BANavigationExtensionView!
  @IBOutlet private weak var tableView: UITableView!
  
  public var rebookData: ReBookAppointmentData? {
    didSet {
      viewModel.rebookData = rebookData
    }
  }
  
  private var cachedBACalendarCell: BookAppointmentCalendarCell?
  private var cachedBAScheduleCell: BookAppointmentScheduleCell?
  
  
  private var walkThroughViewController: BAWalkthroughViewController?
  
  public var didTriggerSuccess: VoidCompletion?
  
  private lazy var viewModel: BookAppointmentViewModelProtocol = BookAppointmentViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setNavigationTheme(.white)
    hideBarSeparator()
  }
  
  @objc
  private func keyboardWillShow(_ notification: NSNotification) {
    let userInfo: NSDictionary = notification.userInfo! as NSDictionary
    guard let keyboardRect = (userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey) as AnyObject).cgRectValue else { return }
    let keyboardFrame = self.view.convert(keyboardRect, from: nil)
    tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardFrame.height, 0.0)
  }
  
  @objc
  private func keyboardWillHide(_ notification: NSNotification) {
    tableView.contentInset = .zero
  }
  
  private func updateNavigationTitleViewIfNeeded() {
    guard navigationTitleView.data == nil else { return }
    guard let firstLocation = viewModel.locations.first else { return }
    viewModel.locationData = BookAppointmentData(
      id: firstLocation.id!,
      name: firstLocation.locationName ?? firstLocation.address!)
    navigationTitleView.data = BANavigationTitleData(
      title: firstLocation.name!,
      subtitle: firstLocation.locationName ?? firstLocation.address!)
    navigationExtensionView.title = firstLocation.locationName ?? firstLocation.address!
  }
  
  @objc
  private func datePickerValueChanged(_ sender: UIDatePicker) {
  }
}

// MARK: - ControllerProtocol/NavigationProtocol
extension BookAppointmentViewController: ControllerProtocol, NavigationProtocol {
  public static var segueIdentifier: String {
    return "showBookAppointment"
  }
  
  public func setupUI() {
    view.backgroundColor = UIColor.Porcelain.mainBackground
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: #imageLiteral(resourceName: "dashboard-icon"), selector: #selector(dismissViewController))
    tableView.registerWithNib(BookAppointmentTextFieldCell.self)
    tableView.registerWithNib(BookAppointmentMultiSelectionCell.self)
    tableView.registerWithNib(BookAppointmentNotesCell.self)
    tableView.registerWithNib(BookAppointmentCalendarCell.self)
    tableView.registerWithNib(BookAppointmentScheduleCell.self)
    tableView.registerWithNib(BookAppointmentRequestActionCell.self)
    tableView.setAutomaticDimension()
    tableView.dataSource = self
    tableView.delegate = self
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    navigationTitleView.titleDidTapped = { [weak self] in
      guard let `self` = self else { return }
      let locations = self.viewModel.locations
      let contents = locations.map({ PopOverBranchItemData(
        title: $0.name!,
        subtitle: $0.locationName ?? $0.address!) })
      PopOverListViewController.showList(
        title: "SELECT BRANCH",
        contents: contents,
        selectedRow: locations.index(where: { $0.id == self.viewModel.locationData?.id }),
        sourceView: self.navigationExtensionView) { row in
          let location = locations[row]
          self.viewModel.locationData = BookAppointmentData(
            id: location.id,
            name: location.name)
          self.navigationTitleView.data = BANavigationTitleData(
            title: location.name!,
            subtitle: location.locationName ?? location.address!)
          self.navigationExtensionView.title = location.locationName ?? location.address!
          self.viewModel.loadAvailableSlots()
      }
    }
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
  }
}

// MARK: - BookAppointmentView
extension BookAppointmentViewController: BookAppointmentView {
  public func reload() {
    updateNavigationTitleViewIfNeeded()
    viewModel.generateSections()
    tableView.reloadData()
    if !viewModel.isBookAppointmentWalkthroughDone && walkThroughViewController == nil {
      walkThroughViewController = BAWalkthroughViewController.initializeWalkthrough(on: self, didShow: {
      }) {
        self.viewModel.isBookAppointmentWalkthroughDone = true
        self.viewModel.defaultSettings()
        self.reload()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          self.tableView.scrollToTop(true)
          self.viewModel.triggerRebookingIfNeeded()
        }
      }
      walkThroughViewController?.scrollToCalendarScheduleWithImage = { [weak self] in
        guard let `self` = self else { return nil }
        self.tableView.setContentOffset(CGPoint(x: 0, y: 203.0), animated: true)
        return self.cachedBACalendarCell?.calendarImage
      }
      walkThroughViewController?.scrollToTimeScheduleWithImage = { [weak self] scrollDiff in
        guard let `self` = self else { return nil }
        self.tableView.setContentOffset(CGPoint(x: 0, y: 420.0 + scrollDiff), animated: true)
        return self.cachedBAScheduleCell?.scheduleImage
      }
      walkThroughViewController?.scrollToScheduleTherapistWithImage = { [weak self] scrollDiff in
        guard let `self` = self else { return nil }
        self.tableView.setContentOffset(CGPoint(x: 0, y: 668.0 + scrollDiff), animated: true)
        return self.cachedBAScheduleCell?.therapistsImage
      }
      walkThroughViewController?.navigationTitleData = navigationTitleView.data
    }
  }
  
  public func forceUpdateNavigationTitle(name: String, subtitle: String) {
    navigationTitleView.data = BANavigationTitleData(
      title: name,
      subtitle: subtitle)
    navigationExtensionView.title = subtitle
  }
  
  public func showLoading() {
    KRProgressHUD.showHUD()
  }
  
  public func hideLoading() {
    KRProgressHUD.hideHUD()
  }
  
  public func selectTreatmentsByLocation() {
    performSegue(withIdentifier: SelectTreatmentViewController.segueIdentifier, sender: nil)
  }
  
  public func selectAddonsByLocation() {
    let addOns = viewModel.addOns
    let addOnIDs = viewModel.addOnsData.map({ $0.id! })
    let selectedValues: [PickerValueProtocol] = addOns.filter({ addOnIDs.contains($0.id!) }).map({ PickerPopOverValue(mainValue: $0.name!) })
    let list: [PickerValueProtocol] = addOns.map({ PickerPopOverValue(mainValue: $0.name!) }) + [PickerOtherValue(mainValue: "No Preference")]
    PickerViewController.loadPickerWithType(.popOver, list: list, title: "Select your add-on".localized(), selectionType: .multiple, selectedValues: selectedValues, dimissOnBackgroundTap: true) { (isContent, rows) in
      if isContent {
        let newAddOns = rows.map({ addOns[$0] })
        self.viewModel.addOnsData = newAddOns.map({ BookAppointmentData(id: $0.id, name: $0.name) })
        self.viewModel.addOnsNoPreference = false
      } else {
        self.viewModel.addOnsData.removeAll()
        self.viewModel.addOnsNoPreference = true
      }
      self.reload()
      }.show(in: self)
  }
  
  public func selectTherapistsByTreatment() {
    let therapists = viewModel.therapists
    let therapistIDs = viewModel.therapistsData.map({ $0.id! })
    let selectedValues: [PickerValueProtocol] = therapists.filter({ therapistIDs.contains($0.id!) }).map({ PickerPopOverValue(mainValue: $0.name!) })
    let list: [PickerValueProtocol] = therapists.map({ PickerPopOverValue(mainValue: $0.name!) }) + [PickerOtherValue(mainValue: "No Preference")]
    PickerViewController.loadPickerWithType(.popOver, list: list, title: "Select Therapist(s)".localized(), selectionType: .multiple, selectedValues: selectedValues, dimissOnBackgroundTap: true) { (isContent, rows) in
      if isContent {
        let newTherapists = rows.map({ therapists[$0] })
        self.viewModel.therapistsData = newTherapists.map({ BookAppointmentData(id: $0.id, name: $0.name) })
        self.viewModel.therapistsNoPreference = false
      } else {
        self.viewModel.therapistsData.removeAll()
        self.viewModel.therapistsNoPreference = true
      }
      self.reload()
      self.viewModel.loadAvailableSlots()
      }.show(in: self)
  }
  
  public func showError(message: String?) {
    guard let message = message else { return }
    AlertViewController.loadAlertWithContent(message, actions: ["OK".localized()]).show(in: self)
  }
  
  public func showSuccess(message: String?) {
    let message = message ?? "We have received your appointment request. We’ll send an email confirmation shortly!"
    AlertViewController.loadAlertWithContent(message, actions: ["OK".localized()], completion: { (_) in
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        self.dismissViewController()
        self.didTriggerSuccess?()
      }
    }).show(in: self)
  }
}

// MARK: - Segue
extension BookAppointmentViewController {
  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let selectTreatmentViewController = segue.destination as? SelectTreatmentViewController {
      selectTreatmentViewController.configure(viewModel: viewModel.selectTreatmentViewModel!)
      selectTreatmentViewController.didSelectTreatment = { [weak self] treatment in
        guard let `self` = self else { return }
        self.viewModel.treatmentData = BookAppointmentData(
          id: treatment.id,
          name: treatment.title)
        self.viewModel.therapistsData.removeAll()
        self.viewModel.therapistsNoPreference = true
        self.reload()
        self.viewModel.loadAvailableSlots()
      }
    }
  }
}

// MARK: - UITableViewDataSource
extension BookAppointmentViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.shownSections.count
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch viewModel.shownSections[indexPath.row] {
    case .treatment:
      let bookAppointmentTextFieldCell = tableView.dequeueReusableCell(BookAppointmentTextFieldCell.self, atIndexPath: indexPath)
      bookAppointmentTextFieldCell.data = BookAppointmentTextFieldData(
        title: "Treatment",
        content: viewModel.treatmentData?.name ?? "",
        placeholder: "Select a Treatment",
        icon: #imageLiteral(resourceName: "arrow-right-icon").withRenderingMode(.alwaysTemplate))
      bookAppointmentTextFieldCell.didBeginEditing = { [weak self] in
        guard let `self` = self else { return }
        self.viewModel.loadAndSelectTreatmentsByLocation(locationID: self.viewModel.locationData?.id, completion: nil)
      }
      return bookAppointmentTextFieldCell
    case .addOns:
      let bookAppointmentMultiSelectionCell = tableView.dequeueReusableCell(BookAppointmentMultiSelectionCell.self, atIndexPath: indexPath)
      bookAppointmentMultiSelectionCell.data = BookAppointmentMultiSelectionData(
        title: "Add-On(s)",
        content: viewModel.addOnsNoPreference ? "No Preference": nil,
        contents: viewModel.addOnsData.map({ $0.name! }),
        placeholder: "Add-On(s)",
        icon: #imageLiteral(resourceName: "plus-icon").withRenderingMode(.alwaysTemplate))
      bookAppointmentMultiSelectionCell.didBeginEditing = { [weak self] in
        guard let `self` = self else { return }
        self.viewModel.loadAndSelectAddOnsByLocation(locationID: self.viewModel.locationData?.id)
      }
      bookAppointmentMultiSelectionCell.didDeleteAtIndex = { [weak self] indx in
        guard let `self` = self else { return }
        self.viewModel.addOnsData.remove(at: indx)
        self.viewModel.addOnsNoPreference = self.viewModel.addOnsData.isEmpty
        self.reload()
        self.viewModel.loadAvailableSlots()
      }
      return bookAppointmentMultiSelectionCell
    case .therapists:
      let bookAppointmentMultiSelectionCell = tableView.dequeueReusableCell(BookAppointmentMultiSelectionCell.self, atIndexPath: indexPath)
      bookAppointmentMultiSelectionCell.data = BookAppointmentMultiSelectionData(
        title: "Therapist(s)",
        content: viewModel.therapistsNoPreference ? "No Preference": nil,
        contents: viewModel.therapistsData.map({ $0.name! }),
        placeholder: "Select a Therapist(s)",
        icon: #imageLiteral(resourceName: "plus-icon").withRenderingMode(.alwaysTemplate))
      bookAppointmentMultiSelectionCell.didBeginEditing = { [weak self] in
        guard let `self` = self else { return }
        self.viewModel.loadAndSelectTherapistsByTreatment(treatmentID: self.viewModel.treatmentData?.id)
      }
      bookAppointmentMultiSelectionCell.didDeleteAtIndex = { [weak self] indx in
        guard let `self` = self else { return }
        self.viewModel.therapistsData.remove(at: indx)
        self.viewModel.therapistsNoPreference = self.viewModel.therapistsData.isEmpty
        self.reload()
        self.viewModel.loadAvailableSlots()
      }
      return bookAppointmentMultiSelectionCell
    case .notes:
      let bookAppointmentNotesCell = tableView.dequeueReusableCell(BookAppointmentNotesCell.self, atIndexPath: indexPath)
      bookAppointmentNotesCell.data = BookAppointmentNotesData(
        title: "Notes",
        content: viewModel.notes,
        placeholder: "Add note",
        icon: #imageLiteral(resourceName: "edit-icon").withRenderingMode(.alwaysTemplate))
      bookAppointmentNotesCell.didUpdateText = { [weak self] text in
        guard let `self` = self else { return }
        self.viewModel.notes = text
        self.tableView.updateWithPreserveOffset()
      }
      return bookAppointmentNotesCell
    case .calendar:
      let bookAppointmentCalendarCell = tableView.dequeueReusableCell(BookAppointmentCalendarCell.self, atIndexPath: indexPath)
      bookAppointmentCalendarCell.data = BookAppointmentCalendarData(
        calendarReferenceDate: viewModel.calendarReferenceDate,
        selectedCalendarReferenceDate: viewModel.selectedCalendarReferenceDate)
      bookAppointmentCalendarCell.prevDidTapped = { [weak self] in
        guard let `self` = self else { return }
        self.viewModel.calendarReferenceDate = self.viewModel.calendarReferenceDate.dateByAdding(months: -1)
        self.reload()
      }
      bookAppointmentCalendarCell.nextDidTapped = { [weak self] in
        guard let `self` = self else { return }
        self.viewModel.calendarReferenceDate = self.viewModel.calendarReferenceDate.dateByAdding(months: 1)
        self.reload()
      }
      bookAppointmentCalendarCell.didSelectDate = { [weak self] date in
        guard let `self` = self else { return }
        self.viewModel.selectedCalendarReferenceDate = date
        self.reload()
        self.viewModel.loadAvailableSlots()
      }
      cachedBACalendarCell = bookAppointmentCalendarCell
      return bookAppointmentCalendarCell
    case .schedule:
      let bookAppointmentScheduleCell = tableView.dequeueReusableCell(BookAppointmentScheduleCell.self, atIndexPath: indexPath)
      bookAppointmentScheduleCell.data = BookAppointmentScheduleData(
        selectedCalendarReferenceDate: viewModel.selectedCalendarReferenceDate,
        calendarScheduleDate: viewModel.selectedCalendarScheduleDate,
        selectedScheduleTime: viewModel.selectedScheduleTime,
        selectedScheduleTherapist: viewModel.selectedScheduleTherapist,
        indicatorType: viewModel.scheduleIndicatorType)
      bookAppointmentScheduleCell.didSelectScheduleTime = { [weak self] scheduleTime in
        guard let `self` = self else { return }
        self.viewModel.selectedScheduleTime = scheduleTime
        self.viewModel.selectedScheduleTherapist = nil
        self.reload()
      }
      bookAppointmentScheduleCell.didSelectScheduleTherapist = { [weak self] scheduleTherapist, shouldReload in
        guard let `self` = self else { return }
        self.viewModel.selectedScheduleTherapist = scheduleTherapist
        if shouldReload {
          self.reload()
        }
      }
      cachedBAScheduleCell = bookAppointmentScheduleCell
      return bookAppointmentScheduleCell
    case .request:
      let bookAppointmentRequestActionCell = tableView.dequeueReusableCell(BookAppointmentRequestActionCell.self, atIndexPath: indexPath)
      bookAppointmentRequestActionCell.isEnabled = viewModel.isRequestEnabled
      bookAppointmentRequestActionCell.requestDidTapped = { [weak self] in
        guard let `self` = self else { return }
        self.viewModel.requestAppointment()
      }
      return bookAppointmentRequestActionCell
    }
  }
}

// MARK: - UITableViewDelegate
extension BookAppointmentViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch viewModel.shownSections[indexPath.row] {
    case .treatment:
      viewModel.loadAndSelectTreatmentsByLocation(locationID: viewModel.locationData?.id, completion: nil)
    case .addOns:
      viewModel.loadAndSelectAddOnsByLocation(locationID: viewModel.locationData?.id)
    case .therapists:
      viewModel.loadAndSelectTherapistsByTreatment(treatmentID: viewModel.treatmentData?.id)
    case .notes:
      tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
    default: break
    }
  }
  
  public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    switch viewModel.shownSections[indexPath.row] {
    case .treatment, .addOns, .therapists, .notes:
      return 79.0
    case .calendar:
      return 359.0
    case .schedule:
      return 500.0
    case .request:
      return 96.0
    }
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return .leastNonzeroMagnitude
  }
  
  public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return .leastNonzeroMagnitude
  }
}

extension UIViewController {
  public func showBookAppointment() {
    
  }
}
