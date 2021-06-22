//
//  BAATimeSlotsView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 25/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import SwiftyJSON

public struct BAATimeSlotsRequestData {
  public var centerID: String
  public var treatmentID: String
  public var addOnIDs: [String]?
  public var therapistIDs: [String]?
  public var date: Date
}

private struct BAATimeSlotsData {
  public var morningSlots: [BAATimeSlotData]?
  public var afternoonSlots: [BAATimeSlotData]?
  public var eveningSlots: [BAATimeSlotData]?
  
  public init?(data: JSON, treatmentID: String?, addOnIDs: [String]?) {
    guard let centerArray = data.array else { return nil }
    var timeSlots: [String: BAATimeSlotData] = [:]
    centerArray.forEach { (data) in
      let date = data.date.string
      let centerID = data.center.centerID.string
      guard let therapistArray = data.center.therapists.array else { return }
      therapistArray.forEach { (data) in
        var therapist = BAATherapistData(data: data)
        therapist.centerID = centerID
        therapist.treatmentID = treatmentID
        therapist.addOnIDs = addOnIDs
        therapist.date = date
        guard let slotArray = data.slots.array else { return }
        slotArray.forEach { (data) in
          guard let time = data.time.string else { return }
          therapist.time = time
          if var slot = timeSlots[time] {
            slot.therapist?.append(therapist)
            timeSlots[time] = slot
          } else {
            guard var slot = BAATimeSlotData(data: data) else { return }
            slot.date = date
            slot.centerID = centerID
            slot.therapist = [therapist]
            timeSlots[time] = slot
          }
        }
      }
    }
    var morningSlots: [BAATimeSlotData] = []
    var afternoonSlots: [BAATimeSlotData] = []
    var eveningSlots: [BAATimeSlotData] = []
    let slots = timeSlots.values.map({ $0 })
    guard !slots.isEmpty else { return nil }
    slots.unique().sorted(by: { (slot1, slot2) -> Bool in
      let doubleTime1 = slot1.time.replacingOccurrences(of: ":", with: "").toNumber().doubleValue
      let doubleTime2 = slot2.time.replacingOccurrences(of: ":", with: "").toNumber().doubleValue
      return doubleTime1 < doubleTime2
    }).forEach { (slot) in
      if [BAATimeH.am, BAATimeH.mn].contains(slot.amPM) {
        morningSlots.append(slot)
      } else if slot.hour.toNumber().intValue >= 6 && slot.hour.toNumber().intValue < 12 && slot.amPM == .pm {
        eveningSlots.append(slot)
      } else {
        afternoonSlots.append(slot)
      }
    }
    self.morningSlots = morningSlots
    self.afternoonSlots = afternoonSlots
    self.eveningSlots = eveningSlots
  }
}

public struct BAATimeSlotsResultData {
  public var centerID: String?
  public var treatmentID: String?
  public var addOnIDs: [String]?
  public var therapistID: String?
  public var date: String?
  public var time: String?
}
public typealias BAATimeSlotsCompletion = (BAATimeSlotsResultData?) -> Void

public final class BAATimeSlotsView: DesignableView, ActivityIndicatorProtocol {
  public var activityIndicatorView: UIActivityIndicatorView?
  
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var emptyNotificationView: EmptyNotificationView! {
    didSet {
      emptyNotificationView.tapped = { [weak self]  in
        guard let `self` = self else { return }
        guard let requestData = self.requestData else { return }
        self.evaluateRequest(requestData)
      }
    }
  }
  @IBOutlet private weak var contentStack: UIStackView!
  @IBOutlet private weak var headerButton: UIButton! {
    didSet {
      headerButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
      headerButton.setAttributedTitle(
        "AVAILABLE SLOTS".attributed.add([
          .color(.gunmetal), .font(.openSans(style: .semiBold(size: 14.0)))]),
        for: .normal)
    }
  }
  @IBOutlet private weak var separatorView: UIView! {
    didSet {
      separatorView.backgroundColor = .whiteThree
    }
  }
  @IBOutlet private weak var morningTableView: BAAAvailableTimeSlotsTableView! {
    didSet {
      morningTableView.didSelectSlot = { [weak self] (timeSlot) in
        guard let `self` = self else { return }
        self.afternoonTableView.reset()
        self.eveningTableView.reset()
        self.didSelectTimeSlot?(nil)
        self.therapistsTableView.therapists = timeSlot.therapist
      }
    }
  }
  @IBOutlet private weak var afternoonTableView: BAAAvailableTimeSlotsTableView! {
    didSet {
      afternoonTableView.didSelectSlot = { [weak self] (timeSlot) in
        guard let `self` = self else { return }
        self.morningTableView.reset()
        self.eveningTableView.reset()
        self.didSelectTimeSlot?(nil)
        self.therapistsTableView.therapists = timeSlot.therapist
      }
    }
  }
  @IBOutlet private weak var eveningTableView: BAAAvailableTimeSlotsTableView! {
    didSet {
      eveningTableView.didSelectSlot = { [weak self] (timeSlot) in
        guard let `self` = self else { return }
        self.morningTableView.reset()
        self.afternoonTableView.reset()
        self.didSelectTimeSlot?(nil)
        self.therapistsTableView.therapists = timeSlot.therapist
      }
    }
  }
  @IBOutlet private weak var therapistsTableView: BAAAvailableTherapistsTableView! {
    didSet {
      therapistsTableView.didSelectTherapist = { [weak self] (therapist) in
        guard let `self` = self else { return }
        if let requestData = self.requestData {
          self.didSelectTimeSlot?(.init(
            centerID: requestData.centerID,
            treatmentID: requestData.treatmentID,
            addOnIDs: requestData.addOnIDs,
            therapistID: therapist.id,
            date: therapist.date,
            time: therapist.time))
        } else {
          self.didSelectTimeSlot?(nil)
        }
      }
    }
  }
  
  public var errorMessage: String? {
    didSet {
      if let errorMessage = errorMessage {
        emptyNotificationView.isHidden = false
        emptyNotificationView.message = errorMessage
        contentStack.isHidden = true
      } else {
        emptyNotificationView.isHidden = true
        contentStack.isHidden = data == nil
      }
    }
  }
  
  private var isLoading: Bool = false {
    didSet {
      if isLoading {
        showActivityOnView(self)
      } else {
        hideActivity()
      }
    }
  }
  private var availableSlotsRequest: URLSessionDataTask?
  private var requestData: BAATimeSlotsRequestData?
  private var data: BAATimeSlotsData? {
    didSet {
      if data == nil {
        errorMessage = "Oops! Sorry, no schedule available."
        contentStack.isHidden = true
      } else {
        errorMessage = nil
        contentStack.isHidden = false
        if let dateString = requestData?.date.toString(WithFormat: "MMMM d, yyyy").uppercased() {
          headerButton.isHidden = false
          headerButton.setAttributedTitle(
            "AVAILABLE SLOTS FOR \(dateString)".attributed.add([
              .color(.gunmetal), .font(.openSans(style: .semiBold(size: 14.0)))]),
            for: .normal)
        } else {
          headerButton.isHidden = true
        }
        morningTableView.type = .morning(slots: data?.morningSlots)
        afternoonTableView.type = .afternoon(slots: data?.afternoonSlots)
        eveningTableView.type = .evening(slots: data?.eveningSlots)
      }
    }
  }
  
  public func cancel() {
    availableSlotsRequest?.cancel()
    isLoading = false
  }
  
  public func evaluateRequest(_ requestData: BAATimeSlotsRequestData) {
    self.requestData = requestData
    availableSlotsRequest?.cancel()
    didSelectTimeSlot?(nil)
    isLoading = true
    availableSlotsRequest = PPAPIService.Center.getAvailableSlots(
      centerID: requestData.centerID,
      treatmentID: requestData.treatmentID,
      addOnIDs: requestData.addOnIDs,
      therapistIDs: requestData.therapistIDs,
      date: requestData.date).call { [weak self] (response) in
        guard let `self` = self else { return }
        switch response {
        case .success(let result):
          self.therapistsTableView.reset()
          self.data = BAATimeSlotsData(data: result.data, treatmentID: requestData.treatmentID, addOnIDs: requestData.addOnIDs)
          self.isLoading = false
        case .failure(let error):
          guard error.failureCode.rawCode != -1  && error.localizedDescription != "cancelled" else { return }
          self.therapistsTableView.reset()
          self.data = nil
          self.errorMessage = error.localizedDescription
          self.isLoading = false
        }
    }
  }
  
  public var didSelectTimeSlot: BAATimeSlotsCompletion?
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  private func commonInit() {
    loadNib(BAATimeSlotsView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
    layoutIfNeeded()
    cornerRadius = 7.0
    borderWidth = 1.0
    borderColor = .whiteThree
  }
}

public final class BAAAvailableTimeSlotsTableView: ResizingContentTableView {
  public enum `Type` {
    case morning(slots:  [BAATimeSlotData]?)
    case afternoon(slots:  [BAATimeSlotData]?)
    case evening(slots:  [BAATimeSlotData]?)
    
    public var slots: [BAATimeSlotData]? {
      switch self {
      case .morning(let slots):
        return slots
      case .afternoon(let slots):
        return slots
      case .evening(let slots):
        return slots
      }
    }
    
    public var title: String? {
      switch self {
      case .morning:
        return "MORNING"
      case .afternoon:
        return "AFTERNOON"
      case .evening:
        return "EVENING"
      }
    }
  }

  public var type: Type? {
    didSet {
      slots = type?.slots
    }
  }
  
  private var slots: [BAATimeSlotData]? {
    didSet {
      reloadData()
    }
  }
  
  public var selectedSlot: BAATimeSlotData?
  public var didSelectSlot: ((BAATimeSlotData) -> Void)?
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    separatorStyle = .none
    registerWithNib(BAAAvailableTimeSlotsTCell.self)
    dataSource = self
    delegate = self
  }
  
  public func reload() {
    reloadData()
    updateDateSelection()
  }
  
  public func reset() {
    selectedSlot = nil
    reloadData()
  }
  
  public func updateDateSelection() {
    guard let selectedSlot = selectedSlot else { return }
    guard let indx = slots?.firstIndex(where: { $0 == selectedSlot }) else { return }
    selectRow(at: IndexPath(row: indx, section: 0), animated: false, scrollPosition: .none)
  }
}

// MARK: - UITableViewDataSource
extension BAAAvailableTimeSlotsTableView: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return slots?.count ?? 0
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let timeSlotsTCell = tableView.dequeueReusableCell(BAAAvailableTimeSlotsTCell.self, atIndexPath: indexPath)
    timeSlotsTCell.data = slots?[indexPath.row]
    return timeSlotsTCell
  }
}

// MARK: - UITableViewDelegate
extension BAAAvailableTimeSlotsTableView: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let slot = slots?[indexPath.row] else { return }
    selectedSlot = slot
    didSelectSlot?(slot)
  }
  
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let label = UILabel(frame: .zero)
    label.font = .openSans(style: .semiBold(size: 14.0))
    label.textColor = .gunmetal
    label.textAlignment = .center
    label.text = type?.title
    return label
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50.0
  }
}

public enum BAATimeH: String {
  case mn
  case am
  case nn
  case pm
}

public struct BAATimeSlotData: Equatable {
  public var date: String?
  public var time: String
  public var amPM: BAATimeH
  public var hour: String
  public var minutes: String
  public var centerID: String?
  public var therapist: [BAATherapistData]?
  
  init?(data: JSON) {
    guard let time = data.time.string else { return nil }
    let evalTime = time.components(separatedBy: ":")
    guard !evalTime.isEmpty else { return nil }
    self.time = time
    let hourInt = evalTime.first?.toNumber().intValue ?? 0
    let minutesInt = evalTime.last?.toNumber().intValue ?? 0
    if hourInt == 12 {
      hour = evalTime.first ?? "00"
      if minutesInt == 0 {
        amPM = .nn
      } else {
        amPM = .pm
      }
    } else if hourInt > 12 {
      let difference = hourInt - 12
      hour = concatenate(difference < 10 ? "0": "", difference)
      amPM = .pm
    } else if hourInt == 0 && minutesInt == 0 {
      hour = evalTime.first ?? "00"
      amPM = .mn
    } else  {
      hour = evalTime.first ?? "00"
      amPM = .am
    }
    minutes = evalTime.last ?? "00"
  }
  
  public static func == (lhs: BAATimeSlotData, rhs: BAATimeSlotData) -> Bool {
    return lhs.time == rhs.time
  }
}

public final class  BAAAvailableTimeSlotsTCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: DesignableLabel! {
    didSet {
      titleLabel.cornerRadius = 17.0
    }
  }
  
  public var data: BAATimeSlotData? {
    didSet {
      if let data = data {
        titleLabel.text = "\(data.hour):\(data.minutes) \(data.amPM)"
      } else {
        titleLabel.text = nil
      }
    }
  }
  
  public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
  }
  
  public override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    updateSelection(selected)
  }
  
  private func updateSelection(_ isSelected: Bool = false) {
    titleLabel.font = isSelected ? .openSans(style: .semiBold(size: 14.0)): .openSans(style: .regular(size: 14.0))
    titleLabel.textColor = isSelected ? .white: .bluishGrey
    titleLabel.backgroundColor = isSelected ? .lightNavy: .clear
  }
}

// MARK: - CellProtocol
extension BAAAvailableTimeSlotsTCell: CellProtocol {
  public static var defaultSize: CGSize {
    fatalError("BAAAvailableTimeSlotsTCell defaultSize not set")
  }
}

public final class BAAAvailableTherapistsTableView: ResizingContentTableView {
  public var therapists: [BAATherapistData]? {
    didSet {
      selectedTherapist = nil
      if let therapists = therapists, !therapists.isEmpty {
        isHidden = false
        reloadData()
        updateDateSelection()
      } else   {
        isHidden = true
      }
    }
  }
  
  public var selectedTherapist: BAATherapistData?
  public var didSelectTherapist: ((BAATherapistData) -> Void)?
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    separatorStyle = .singleLine
    separatorInset = .zero
    registerWithNib(BAAAvailableTherapistsTCell.self)
    dataSource = self
    delegate = self
  }
  
  public func reset() {
    therapists = nil
  }
  
  public func updateDateSelection() {
    guard let selectedTherapist = selectedTherapist else { return }
    guard let indx = therapists?.firstIndex(where: { $0 == selectedTherapist }) else { return }
    selectRow(at: IndexPath(row: indx, section: 0), animated: false, scrollPosition: .none)
  }
}

// MARK: - UITableViewDataSource
extension BAAAvailableTherapistsTableView: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return therapists?.count ?? 0
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let therapistsTCell = tableView.dequeueReusableCell(BAAAvailableTherapistsTCell.self, atIndexPath: indexPath)
    therapistsTCell.data = therapists?[indexPath.row]
    return therapistsTCell
  }
}

// MARK: - UITableViewDelegate
extension BAAAvailableTherapistsTableView: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let therapist = therapists?[indexPath.row] else { return }
    selectedTherapist = therapist
    didSelectTherapist?(therapist)
  }
  
  public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let button = UIButton()
    button.backgroundColor = .whiteThree
    button.isUserInteractionEnabled = false
    button.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    button.setAttributedTitle(
      "SELECT THERAPIST(S)".attributed.add([
        .color(.gunmetal),
        .font(.openSans(style: .semiBold(size: 12.0)))]),
      for: .normal)
    return button
  }
  
  public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 36.0
  }
}

public struct BAATherapistData: Equatable {
  public var id: String?
  public var name: String?
  public var duration: Int
  public var centerID: String?
  public var treatmentID: String?
  public var addOnIDs: [String]?
  public var date: String?
  public var time: String?
  
  init(data: JSON) {
    id = data.employeeID.string
    name = data.name.string
    duration = data.duration.intValue
  }
  
  public static func == (lhs: BAATherapistData, rhs: BAATherapistData) -> Bool {
    return lhs.id == rhs.id
  }
}

public final class  BAAAvailableTherapistsTCell: UITableViewCell {
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var selectionLabel: UILabel! {
    didSet {
      selectionLabel.attributedText = MaterialDesignIcon.check.attributed.add([
        .color(.lightNavy), .font(.materialDesign(size: 18.0))])
    }
  }
  
  public var data: BAATherapistData? {
    didSet {
      titleLabel.text = data?.name
    }
  }
  
  public override func setHighlighted(_ highlighted: Bool, animated: Bool) {
    super.setHighlighted(highlighted, animated: animated)
  }
  
  public override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    updateSelection(selected)
  }
  
  private func updateSelection(_ isSelected: Bool = false) {
    titleLabel.font = .openSans(style: isSelected ? .semiBold(size: 14.0): .regular(size: 14.0))
    titleLabel.textColor = isSelected ? .lightNavy: .bluishGrey
    selectionLabel.isHidden = !isSelected
  }
}

// MARK: - CellProtocol
extension BAAAvailableTherapistsTCell: CellProtocol {
  public static var defaultSize: CGSize {
    fatalError("BAAAvailableTherapistsTCell defaultSize not set")
  }
}
