//
//  AppointmentPopupViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct ContactAttributedTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.5
  var alignment: NSTextAlignment? = .center
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? = 18.0
  var font: UIFont? = .openSans(style: .regular(size: 13.0))
  var color: UIColor? = .white
}

public final class AppointmentPopupViewController: UIViewController, ActivityIndicatorProtocol {
  public var activityIndicatorView: UIActivityIndicatorView?
  
  @IBOutlet private weak var scrollView: ObservingContentScrollView! {
    didSet {
      scrollView.alwaysBounceVertical = false
    }
  }
  @IBOutlet private weak var containerView: DesignableView! {
    didSet {
      containerView.cornerRadius = 7.0
    }
  }
  @IBOutlet private weak var addToCalendarButton: DesignableButton!
  @IBOutlet private weak var addToCalendarHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var dayLabel: UILabel! {
    didSet {
      dayLabel.font = .openSans(style: .semiBold(size: 24.0))
      dayLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var ddMMlabel: UILabel! {
    didSet {
      ddMMlabel.font = .openSans(style: .semiBold(size: 13.0))
      ddMMlabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var serviceNameLabel: UILabel! {
    didSet {
      serviceNameLabel.font = .idealSans(style: .book(size: 13.0))
      serviceNameLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var timeLabel: UILabel! {
    didSet {
      timeLabel.font = .openSans(style: .regular(size: 12.0))
      timeLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var addOnsTitleLabel: UILabel! {
    didSet {
      addOnsTitleLabel.font = .openSans(style: .semiBold(size: 12.0))
      addOnsTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var addOnsLabel: UILabel! {
    didSet {
      addOnsLabel.font = .openSans(style: .regular(size: 12.0))
      addOnsLabel.textColor = .lightNavy
    }
  }
  @IBOutlet private weak var therapistTitleLabel: UILabel! {
    didSet {
      therapistTitleLabel.font = .openSans(style: .semiBold(size: 12.0))
      therapistTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var therapistLabel: UILabel! {
    didSet {
      therapistLabel.font = .openSans(style: .regular(size: 12.0))
      therapistLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var locationTitleLabel: UILabel! {
    didSet {
      locationTitleLabel.font = .openSans(style: .semiBold(size: 12.0))
      locationTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var locationLabel: UILabel! {
    didSet {
      locationLabel.font = .openSans(style: .semiBold(size: 12.0))
      locationLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var notesTitleLabel: UILabel! {
    didSet {
      notesTitleLabel.font = .openSans(style: .semiBold(size: 12.0))
      notesTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var editNotesButton: DesignableButton! {
    didSet {
      editNotesButton.setImage(
        UIImage.icEdit.maskWithColor(.lightNavy),
        for: .normal)
      editNotesButton.setImage(
        UIImage.icCircleCheck.maskWithColor(.greenishTealTwo),
        for: .selected)
    }
  }
  @IBOutlet private weak var notesTextView: DesignableTextView! {
    didSet {
      notesTextView.tintColor = .gunmetal
      notesTextView.typingAttributes = defaultTypingAttributes
      notesTextView.delegate = self
    }
  }
  @IBOutlet private weak var footerView: UIView! {
    didSet {
      footerView.backgroundColor = .greyblue
    }
  }
  @IBOutlet private weak var statusLabel: UILabel! {
    didSet {
      sessionsLabel.font = .openSans(style: .semiBold(size: 13.0))
      sessionsLabel.textColor = .white
      
    }
  }
  @IBOutlet private weak var sessionsLabel: UILabel! {
    didSet {
      sessionsLabel.font = .openSans(style: .semiBold(size: 12.0))
      sessionsLabel.textColor = .white
    }
  }
  @IBOutlet private weak var buttonStack: UIStackView!
  @IBOutlet private weak var contactButton: UIButton!
  @IBOutlet private weak var confirmButton: DesignableButton! {
    didSet {
      confirmButton.backgroundColor = .lightNavy
      confirmButton.cornerRadius = 7.0
      confirmButton.setAttributedTitle(
        "CONFIRM APPOINTMENT".attributed.add(.appearance(DialogButtonAttributedTitleAppearance(color: .white))),
        for: .normal)
    }
  }
  @IBOutlet private weak var cancelButton: DesignableButton! {
    didSet {
      cancelButton.backgroundColor = .white
      cancelButton.cornerRadius = 7.0
      cancelButton.setAttributedTitle(
        "CANCEL APPOINTMENT".attributed.add(.appearance(DialogButtonAttributedTitleAppearance(color: .greyblue))),
        for: .normal)
    }
  }
  
  private lazy var defaultTypingAttributes = NSAttributedString.createAttributesString([.appearance(DefaultTextViewTextAppearance())])
  
  private var isAddedToCalendar: Bool = false {
    didSet {
      if isAddedToCalendar {
        addToCalendarButton.borderWidth = 0.0
        addToCalendarButton.borderColor = .clear
        addToCalendarButton.backgroundColor = .greyblue
        addToCalendarButton.setAttributedTitle(
          MaterialDesignIcon.check.attributed.add([.color(.white), .font(.materialDesign(size: 14.0))]).append(
            attrs: " ADDED TO CALENDAR".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 13.0)))])),
          for: .normal)
        addToCalendarHeightConstraint.constant = 36.0
      } else {
        addToCalendarButton.borderWidth = 1.0
        addToCalendarButton.borderColor = .whiteThree
        addToCalendarButton.backgroundColor = .clear
        addToCalendarButton.setAttributedTitle(
          UIImage.icCalendarAdd.maskWithColor(.lightNavy).attributed.append(
            attrs: " ADD TO CALENDAR".attributed.add([
              .appearance(DialogButtonAttributedTitleAppearance(color: .lightNavy)),
              .baseline(offset: 3.0)])),
          for: .normal)
        addToCalendarHeightConstraint.constant = 48.0
      }
    }
  }
  
  private var isNotesSelected: Bool = false {
    didSet {
      editNotesButton.isSelected = isNotesSelected
      if isNotesSelected {
        notesTextView.isHidden = false
        notesTextView.textColor = .gunmetal
        notesTextView.becomeFirstResponder()
      }  else {
        notesTextView.isHidden = notesTextView.text.isEmpty
        notesTextView.textColor = .bluishGrey
        notesTextView.resignFirstResponder()
      }
    }
  }
  
  private var isCancellable: Bool = false {
    didSet {
      if isCancellable {
        contactButton.isUserInteractionEnabled = false
        contactButton.setAttributedTitle(
          """
Should you wish to cancel your appointment,
you may do so 72 hours before
the actual schedule.
""".attributed.add(.appearance(ContactAttributedTitleAppearance())),
          for: .normal)
      } else {
        let mainAppearance = ContactAttributedTitleAppearance()
        var subAppearance = mainAppearance
        subAppearance.font = .openSans(style: .semiBold(size: 13.0))
        contactButton.isUserInteractionEnabled = true
        contactButton.setAttributedTitle(
          """
NOTE: If you would like to cancel your
appointment
""".attributed.add(.appearance(mainAppearance)).append(
  attrs: " please contact us.".attributed.add(.appearance(subAppearance))),
          for: .normal)
      }
      cancelButton.isHidden = !isCancellable
    }
  }
  
  private var viewModel: AppointmentPopupViewModelProtocol!
  
  public func configure(viewModel: AppointmentPopupViewModelProtocol) {
    self.viewModel = viewModel
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  private func updateAddToCalendarUI() {
    guard let customerID = AppUserDefaults.customerID else { return }
    guard let appointmentID = viewModel.appointment?.id else { return }
    CalendarEventUtil.searchEvent(queries: [customerID, appointmentID]) { (events) in
      if events.isEmpty {
        self.isAddedToCalendar = false
      } else {
        self.isAddedToCalendar = true
      }
    }
  }
  
  @objc
  private func scrollTapped(_ sender: Any) {
    dismissPresenter()
  }
  
  @IBAction private func addToCalenderTapped(_ sender: Any) {
    guard !isAddedToCalendar else { return }
    viewModel.addToCalendar()
  }
  
  @IBAction private func editNotesTapped(_ sender: Any) {
    isNotesSelected = !editNotesButton.isSelected
  }
  
  @IBAction private func contactUsTapped(_ sender: Any) {
    dismissPresenter()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      appDelegate.mainView.goToTab(.profile)?.getChildController(ProfileViewController.self)?.showSettings(animated: false).showContactUs()
    }
  }
  
  @IBAction private func confirmTapped(_ sender: Any) {
    guard let appointmentID = viewModel.appointment?.id else { return }
    let handler = DialogHandler()
    handler.message = "Do you want to confirm your appointment?"
    handler.actions = [.cancel(title: "CANCEL"), .confirm(title: "PROCEED")]
    handler.actionCompletion = { [weak self] (action, dialogView) in
      dialogView.dismiss()
      guard let `self` = self else { return }
      if action.title == "PROCEED" {
        self.dismissPresenter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          AppointmentPopupViewController.confirmAppointment(appointmentID: appointmentID)
        }
      }
    }
    PresenterViewController.show(
      presentVC: DialogViewController.load(handler: handler),
      onVC: self)
  }
  
  @IBAction private func cancelTapped(_ sender: Any) {
    guard let appointmentID = viewModel.appointment?.id else { return }
    let handler = DialogHandler()
    if isAddedToCalendar {
      handler.message = """
      Your appointment will also be
      removed from your calendar
      """
    } else {
      switch self.viewModel.type {
      case .upcoming:
        handler.message = "Do you want to cancel your upcoming appointment?"
      case .pending:
        handler.message = "Do you want to cancel your pending appointment?"
      case .past:
        handler.message = "Do you want to cancel your appointment?"
      }
    }
    handler.actions = [.cancel(title: "CANCEL"), .confirm(title: "PROCEED")]
    handler.actionCompletion = { [weak self] (action, dialogView) in
      dialogView.dismiss()
      guard let `self` = self else { return }
      if action.title == "PROCEED" {
        self.dismissPresenter()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          AppointmentPopupViewController.cancelAppointment(appointmentID: appointmentID)
        }
      }
    }
    PresenterViewController.show(
      presentVC: DialogViewController.load(handler: handler),
      onVC: self)
  }
}

extension AppointmentPopupViewController {
  public static func confirmAppointment(appointmentID: String) {
    guard let customerID = AppUserDefaults.customerID else { return }
    appDelegate.showLoading()
    PPAPIService.User.confirmMyAppointment(appointmentID: appointmentID).call { (response) in
      switch response {
      case .success:
        CoreDataUtil.performBackgroundTask({ (moc) in
          let appointment = Appointment.getAppointment(id: appointmentID, customerID: customerID, inMOC: moc)
          appointment?.state = AppointmentState.confirmed.rawValue
        }, completion: { (_) in
          appDelegate.hideLoading()
          appDelegate.showAlert(title: nil, message: "Your upcoming reserved appointment has been confirmed.")
        })
      case .failure(let error):
        appDelegate.hideLoading()
        appDelegate.showAlert(title: "Oops!", message: error.localizedDescription)
      }
    }
  }
  
  public static func cancelAppointment(appointmentID: String) {
    guard let customerID = AppUserDefaults.customerID else { return }
    appDelegate.showLoading()
    PPAPIService.User.cancelMyAppointment(appointmentID: appointmentID).call { (response) in
      switch response {
      case .success:
        var appointmentState: AppointmentState = .requested
        CoreDataUtil.performBackgroundTask({ (moc) in
          let appointment = Appointment.getAppointment(id: appointmentID, customerID: customerID, inMOC: moc)
          if let apptState = AppointmentState(rawValue: appointment?.state ?? "") {
            appointmentState = apptState
          }
          appointment?.delete()
        }, completion: { (_) in
          CalendarEventUtil.searchEvent(queries: [customerID, appointmentID]) { (events) in
            events.forEach { (event) in
              CalendarEventUtil.deleteEvent(event.eventIdentifier)
            }
          }
          appDelegate.hideLoading()
          switch appointmentState {
          case .reserved, .confirmed:
            appDelegate.showAlert(title: nil, message: "Your upcoming appointment has been cancelled.")
          case .requested:
            appDelegate.showAlert(title: nil, message: "Your pending request for an appointment has been successfully cancelled.")
          default:
            appDelegate.showAlert(title: nil, message: "Successfully cancelled your appointment.")
          }
        })
      case .failure(let error):
        appDelegate.hideLoading()
        appDelegate.showAlert(title: "Oops!", message: error.localizedDescription)
      }
    }
  }
}

// MARK: - ControllerProtocol
extension AppointmentPopupViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    return "showAppointmentPopup"
  }
  
  public func setupUI() {
    isAddedToCalendar = false
    isNotesSelected = false
  }
  
  public func setupController() {
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollTapped(_:)))
    tapRecognizer.cancelsTouchesInView = true
    tapRecognizer.delegate = self
    scrollView.addGestureRecognizer(tapRecognizer)
    scrollView.observeContentSizeUpdates = { [weak self] (_) in
      guard let `self` = self else { return }
      self.reloadPresenter()
    }
  }
}

// MARK: - AppointmentPopupView
extension AppointmentPopupViewController: AppointmentPopupView {
  public func reload() {
    isCancellable = viewModel.isCancellable
    dayLabel.text = viewModel.startDate?.toString(WithFormat: "E").uppercased()
    ddMMlabel.text = viewModel.startDate?.toString(WithFormat: "d MMM").uppercased()
    serviceNameLabel.text = viewModel.treatment?.name
    let times = [viewModel.startDate?.toString(WithFormat: "h:mma"), viewModel.endDate?.toString(WithFormat: "h:mma")].compactMap({ $0 })
    timeLabel.attributedText = MaterialDesignIcon.time.attributed.add([.color(.gunmetal), .font(.materialDesign(size: 12.0))]).append(
      attrs: " \(times.joined(separator: " - "))".attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 12.0)))]))
    let addonsT = viewModel.addons?.map({ $0.name }).compactMap({ $0 })
    addOnsLabel.text = addonsT?.joined(separator: ", ").emptyToNil ?? "-"
    therapistLabel.text = viewModel.therapist?.fullName
    locationLabel.attributedText = MaterialDesignIcon.pin.attributed.add([.color(.lightNavy), .font(.materialDesign(size: 12.0))]).append(
      attrs: " \(viewModel.center?.name ?? "")".attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 12.0)))]))
    notesTextView.textColor = editNotesButton.isSelected ? .gunmetal: .bluishGrey
    notesTextView.text = viewModel.appointmentNote?.note
    notesTextView.isHidden = notesTextView.text.isEmpty
    switch viewModel.appointmentState {
    case .confirmed:
      addToCalendarButton.isHidden = false
      statusLabel.attributedText = MaterialDesignIcon.check.attributed.add([.color(.white), .font(.materialDesign(size: 14.0))]).append(
        attrs: " CONFIRMED".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 13.0)))]))
      footerView.backgroundColor = .greyblue
      updateAddToCalendarUI()
      confirmButton.isHidden = true
      cancelButton.backgroundColor = .greyblue
      cancelButton.setAttributedTitle(
        "CANCEL APPOINTMENT".attributed.add(.appearance(DialogButtonAttributedTitleAppearance(color: .white))),
        for: .normal)
    case .reserved:
      addToCalendarButton.isHidden = false
      statusLabel.attributedText = "RESERVED".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 13.0)))])
      footerView.backgroundColor = .lightNavy
      updateAddToCalendarUI()
      confirmButton.isHidden = !viewModel.isConfirmable
      cancelButton.backgroundColor = .white
      cancelButton.setAttributedTitle(
        "CANCEL APPOINTMENT".attributed.add(.appearance(DialogButtonAttributedTitleAppearance(color: .greyblue))),
        for: .normal)
    case .requested:
      addToCalendarButton.isHidden = true
      statusLabel.attributedText = "PENDING".attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 13.0)))])
      footerView.backgroundColor = .heather
      confirmButton.isHidden = true
      cancelButton.backgroundColor = .greyblue
      cancelButton.setAttributedTitle(
        "CANCEL APPOINTMENT".attributed.add(.appearance(DialogButtonAttributedTitleAppearance(color: .white))),
        for: .normal)
    default: break
    }
    sessionsLabel.text = "Sessions left: \(viewModel.sessionsLeft)"
  }
  
  public func showLoading(section: AppointmentPopupSection) {
    switch section {
    case .calendar:
      addToCalendarButton.isLoading = true
    case .notes:
      editNotesButton.isLoading = true
    case .view:
      showActivityOnView(view)
    }
  }
  
  public func hideLoading(section: AppointmentPopupSection) {
    switch section {
    case .calendar:
      addToCalendarButton.isLoading = false
      updateAddToCalendarUI()
    case .notes:
      editNotesButton.isLoading = false
    case .view:
      hideActivity()
    }
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
}

// MARK: - UIGestureRecognizerDelegate
extension AppointmentPopupViewController: UIGestureRecognizerDelegate {
  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return !containerView.frame.contains(gestureRecognizer.location(in: scrollView))
  }
}

// MARK: - UITextViewDelegate
extension AppointmentPopupViewController: UITextViewDelegate {
  public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    textView.typingAttributes = defaultTypingAttributes
    if isCancellable {
      cancelButton.isHidden = true
    }
    if !isNotesSelected {
      isNotesSelected = true
    }
    return true
  }
  
  public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    if isCancellable {
      cancelButton.isHidden = false
    }
    isNotesSelected = false
    viewModel.saveNote(text: textView.text)
    return true
  }
}

// MARK: - PresentedControllerProtocol
extension AppointmentPopupViewController: PresentedControllerProtocol {
  public var presenterType: PresenterType? {
    if !cancelButton.isHidden || !confirmButton.isHidden {
      return .popover(size: CGSize(width: 327.0, height: UIScreen.main.bounds.height))
    } else {
      return .popover(size: CGSize(width: 327.0, height: scrollView.contentSize.height))
    }
  }
}

extension AppointmentPopupViewController {
  public static func load(withAppointment: Appointment) -> AppointmentPopupViewController {
    let appointmentPopupViewController = UIStoryboard.get(.appointment).getController(AppointmentPopupViewController.self)
    appointmentPopupViewController.configure(viewModel: AppointmentPopupViewModel(appointment: withAppointment))
    return appointmentPopupViewController
  }
  
  public func show(in vc: UIViewController) {
    var appearance = PresenterAppearance.default
    appearance.cornerRadius = 0
    appearance.shadowAppearance = nil
    PresenterViewController.show(
      presentVC: self,
      settings: [
        .panToDismiss,
        .tapToDismiss,
        .appearance(appearance)],
      onVC: vc)
  }
}
