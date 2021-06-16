//
//  SkinAnalysisViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 12/12/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public struct SAConstants {
  public enum ConcernIntensity {
    case maintenance(level: Int)
    case moderate(level: Int)
    case intensive(level: Int)
    
    public init?(level: Int) {
      switch level {
      case 0...3:
        self = .maintenance(level: level)
      case 4...7:
        self = .moderate(level: level)
      case 8...10:
        self = .intensive(level: level)
      default:
        return nil
      }
    }
    
    public var title: String {
      switch self {
      case .maintenance:
        return "Maintenance"
      case .moderate:
        return "Moderate"
      case .intensive:
        return "Intensive"
      }
    }
    
    public var color: UIColor {
      return SAConstants.colors[level]
    }
    
    public var level: Int {
      switch self {
       case .maintenance(let level):
         return level
       case .moderate(let level):
         return level
       case .intensive(let level):
         return level
       }
    }
  }
  
  public static let colors: [UIColor] = [
    UIColor(hex: 0x27C856),
    UIColor(hex: 0x4FC347),
    UIColor(hex: 0x77BE37),
    UIColor(hex: 0xCBB313),
    UIColor(hex: 0xC4B416),
    UIColor(hex: 0xFFAD00),
    UIColor(hex: 0xFF9A0F),
    UIColor(hex: 0xFF8820),
    UIColor(hex: 0xFF7630),
    UIColor(hex: 0xFF653E),
    UIColor(hex: 0xFF534D)]
}

private struct AttributedDescriptionTextAppearance: AttributedStringAppearanceProtocol {
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

public final class SkinAnalysisViewController: UIViewController, RefreshHandlerProtocol {
  public var refreshControl: UIRefreshControl?
  
  public var refreshScrollView: UIScrollView?
  
  @IBOutlet private weak var scrollView: UIScrollView! {
    didSet {
      scrollView.contentInset = UIEdgeInsets(top: 16.0, left: 0.0, bottom: 24.0, right: 0.0)
    }
  }
  @IBOutlet private weak var skinTypeContainerStack: UIStackView!
  @IBOutlet private weak var skinTypeTitleLabel: UILabel! {
    didSet {
      skinTypeTitleLabel.font = .openSans(style: .regular(size: 12.0))
      skinTypeTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var skinType1Button: SkinQuizAnswerButton! {
    didSet {
      skinType1Button.tag = 10
      skinType1Button.isQuizDone = true
    }
  }
  @IBOutlet private weak var skinType2Button: SkinQuizAnswerButton! {
    didSet {
      skinType2Button.tag = 11
      skinType2Button.isQuizDone = true
    }
  }
  @IBOutlet private weak var skinTypeQuizContainerView: DesignableView! {
    didSet {
      skinTypeQuizContainerView.cornerRadius = 7.0
      skinTypeQuizContainerView.backgroundColor = .whiteFive
    }
  }
  @IBOutlet private weak var skinTypeQuizDetailsLabel: UILabel! {
    didSet {
      skinTypeQuizDetailsLabel.attributedText = """
        Oops! It seems like we don’t know
        you well enough..
        """.attributed.add(.appearance(AttributedDescriptionTextAppearance()))
    }
  }
  @IBOutlet private weak var startSkinQuizButton: DesignableButton! {
    didSet {
      startSkinQuizButton.cornerRadius = 24.0
      startSkinQuizButton.backgroundColor = .lightNavy
      startSkinQuizButton.setAttributedTitle(
        "START SKIN QUIZ".attributed.add([.color(.white), .font(.idealSans(style: .book(size: 14.0)))]),
        for: .normal)
    }
  }
  @IBOutlet private weak var faceImageView: LoadingImageView! {
    didSet {
      faceImageView.cornerRadius = 94.0
    }
  }
  @IBOutlet private weak var foreheadPointView: DesignableView! {
    didSet {
      foreheadPointView.cornerRadius = 6.0
      foreheadPointView.borderWidth = 2.0
      foreheadPointView.borderColor = .white
      foreheadPointView.backgroundColor = .greyblue
    }
  }
  @IBOutlet private weak var tzonePointView: DesignableView! {
    didSet {
      tzonePointView.cornerRadius = 6.0
      tzonePointView.borderWidth = 2.0
      tzonePointView.borderColor = .white
      tzonePointView.backgroundColor = .greyblue
    }
  }
  @IBOutlet private weak var eyesPointView: DesignableView! {
    didSet {
      eyesPointView.cornerRadius = 6.0
      eyesPointView.borderWidth = 2.0
      eyesPointView.borderColor = .white
      eyesPointView.backgroundColor = .greyblue
    }
  }
  @IBOutlet private weak var leftCheekPointView: DesignableView! {
    didSet {
      leftCheekPointView.cornerRadius = 6.0
      leftCheekPointView.borderWidth = 2.0
      leftCheekPointView.borderColor = .white
      leftCheekPointView.backgroundColor = .greyblue
    }
  }
  @IBOutlet private weak var rightCheekPointView: DesignableView! {
    didSet {
      rightCheekPointView.cornerRadius = 6.0
      rightCheekPointView.borderWidth = 2.0
      rightCheekPointView.borderColor = .white
      rightCheekPointView.backgroundColor = .greyblue
    }
  }
  @IBOutlet private weak var chinPointView: DesignableView! {
    didSet {
      chinPointView.cornerRadius = 6.0
      chinPointView.borderWidth = 2.0
      chinPointView.borderColor = .white
      chinPointView.backgroundColor = .greyblue
    }
  }
  @IBOutlet private weak var neckPointView: DesignableView! {
    didSet {
      neckPointView.cornerRadius = 6.0
      neckPointView.borderWidth = 2.0
      neckPointView.borderColor = .white
      neckPointView.backgroundColor = .greyblue
    }
  }
  @IBOutlet private weak var backPointView: DesignableView! {
    didSet {
      backPointView.cornerRadius = 6.0
      backPointView.borderWidth = 2.0
      backPointView.borderColor = .white
      backPointView.backgroundColor = .greyblue
    }
  }
  @IBOutlet private weak var filterButton: DesignableButton! {
    didSet {
      filterButton.cornerRadius = 7.0
      filterButton.borderColor = .whiteThree
      filterButton.borderWidth = 1.0
      filterButton.setAttributedTitle(
        "FILTER".attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 12.0)))]),
        for: .normal)
    }
  }
  @IBOutlet private weak var skinAnalysisContainerStack: UIStackView!
  @IBOutlet private weak var congestionLevelLabel: UILabel! {
    didSet {
      congestionLevelLabel.font = .openSans(style: .regular(size: 12.0))
      congestionLevelLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var hydrationLevelLabel: UILabel! {
    didSet {
      hydrationLevelLabel.font = .openSans(style: .regular(size: 12.0))
      hydrationLevelLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var areasStack: UIStackView!
  @IBOutlet private weak var skinAnalysisContainerView: DesignableView! {
    didSet {
      skinAnalysisContainerView.cornerRadius = 7.0
      skinAnalysisContainerView.backgroundColor = .whiteFive
    }
  }
  @IBOutlet private weak var skinAnalysisDetailsLabel: UILabel! {
    didSet {
      skinAnalysisDetailsLabel.attributedText = """
        Uh oh! Please drop by for a Skin Analysis session to get your own personalised analysis.
        """.attributed.add(.appearance(AttributedDescriptionTextAppearance())).add(.font(.openSans(style: .semiBold(size: 14.0))), text: "Skin Analysis")
    }
  }
  @IBOutlet private weak var skinAnalysisBookNowButton: DesignableButton! {
    didSet {
      skinAnalysisBookNowButton.cornerRadius = 24.0
      skinAnalysisBookNowButton.backgroundColor = .lightNavy
      skinAnalysisBookNowButton.setAttributedTitle(
        "BOOK NOW".attributed.add([.color(.white), .font(.idealSans(style: .book(size: 14.0)))]),
        for: .normal)
    }
  }
  @IBOutlet private weak var statsTitleLabel: UILabel! {
    didSet {
      statsTitleLabel.font = .idealSans(style: .book(size: 14.0))
      statsTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var changeViewButton: DesignableButton! {
    didSet {
      changeViewButton.cornerRadius = 7.0
      changeViewButton.borderColor = .whiteThree
      changeViewButton.borderWidth = 1.0
      changeViewButton.setAttributedTitle(
        "CHANGE VIEW".attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 12.0)))]),
        for: .normal)
    }
  }
  @IBOutlet private weak var graphView: SAGraphStatsView!
  
  private var isFilterEnabled: Bool = true {
    didSet {
      if isFilterEnabled {
        filterButton.setAttributedTitle(
          "FILTER".attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 12.0)))]),
          for: .normal)
      } else {
        filterButton.setAttributedTitle(
          "FILTER".attributed.add([.color(.bluishGrey), .font(.openSans(style: .regular(size: 12.0)))]),
          for: .normal)
      }
    }
  }
  @IBOutlet private weak var graphTitleLabel: UILabel! {
    didSet {
      graphTitleLabel.font = .openSans(style: .semiBold(size: 10.0))
      graphTitleLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var intensiveLabel: UILabel! {
    didSet {
      intensiveLabel.font = .openSans(style: .regular(size: 10.0))
      intensiveLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var moderateLabel: UILabel! {
    didSet {
      moderateLabel.font = .openSans(style: .regular(size: 10.0))
      moderateLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var maintenanceLabel: UILabel! {
    didSet {
      maintenanceLabel.font = .openSans(style: .regular(size: 10.0))
      maintenanceLabel.textColor = .bluishGrey
    }
  }
  
  private var isChangeViewEnabled: Bool = true {
    didSet {
      if isChangeViewEnabled {
        changeViewButton.setAttributedTitle(
          "CHANGE VIEW".attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 12.0)))]),
          for: .normal)
      } else {
        changeViewButton.setAttributedTitle(
          "CHANGE VIEW".attributed.add([.color(.bluishGrey), .font(.openSans(style: .regular(size: 12.0)))]),
          for: .normal)
      }
    }
  }
  
  private lazy var viewModel: SkinAnalysisViewModelProtocol = SkinAnalysisViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    viewModel.initialize()
  }
  
  private func reloadSkinType() {
    if let skinTypes = viewModel.skinTypes, !skinTypes.isEmpty {
      skinTypeContainerStack.isHidden = false
      skinTypeQuizContainerView.isHidden = true
      skinType1Button.isHidden = true
      skinType2Button.isHidden = true
      skinTypes.enumerated().forEach { (indx, skinType) in
        guard let skinTypeButton = skinTypeContainerStack.viewWithTag(indx + 10) as? SkinQuizAnswerButton else { return }
        skinTypeButton.title = skinType.title
        skinTypeButton.image = skinType.image
        skinTypeButton.isHidden = false
      }
    } else {
      skinTypeContainerStack.isHidden = true
      skinTypeQuizContainerView.isHidden = false
    }
  }
  
  private func resetFacePoints() {
    foreheadPointView.isHidden = true
    tzonePointView.isHidden = true
    eyesPointView.isHidden = true
    leftCheekPointView.isHidden = true
    rightCheekPointView.isHidden = true
    chinPointView.isHidden = true
    neckPointView.isHidden = true
    backPointView.isHidden = true
  }
  
  private func reloadSkinAnalysis() {
    resetFacePoints()
    if let areas = viewModel.skinAnalysis?.areas {
      isFilterEnabled = true
      congestionLevelLabel.attributedText = "Congestion level  ".attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 12.0)))]).append(
        attrs: "\(viewModel.skinAnalysis?.congestionLevel ?? 0)".attributed.add([.color(.gunmetal), .font(.openSans(style: .semiBold(size: 12.0)))]))
      hydrationLevelLabel.attributedText = "Hydration level  ".attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 12.0)))]).append(
        attrs: "\(viewModel.skinAnalysis?.hydrationLevel ?? 0)%".attributed.add([.color(.gunmetal), .font(.openSans(style: .semiBold(size: 12.0)))]))
      faceImageView.image = .imgSkinAnalysisFaceEnabled
      skinAnalysisContainerStack.isHidden = false
      skinAnalysisContainerView.isHidden = true
      areasStack.removeAllArrangedSubviews()
      areasStack.isHidden = areas.isEmpty
      var areaHorizontalStack: UIStackView? //row
      areas.sorted(by: { $0.0 < $1.0 }).enumerated().forEach { (indx, dict) in
        if indx%2 == 0 {
          areaHorizontalStack = UIStackView()
          areaHorizontalStack!.axis = .horizontal
          areaHorizontalStack!.alignment = .top
          areaHorizontalStack!.distribution = .fillEqually
          areaHorizontalStack!.spacing = 8.0
          areasStack.addArrangedSubview(areaHorizontalStack!)
        }
        let areaName = dict.0
        let areaStack = UIStackView()
        areaStack.axis = .vertical
        areaStack.alignment = .leading
        areaStack.spacing = 8.0
        let areaLabel = UILabel()
        areaLabel.font = .idealSans(style: .book(size: 14.0))
        areaLabel.textColor = .greyblue
        areaLabel.numberOfLines = 0
        var areaNames = areaName.components(separatedBy: "|").map({ $0.lowercased() })
        if let filters = viewModel.filter.emptyToNil?.components(separatedBy: ",").map({ $0.lowercased() }) {
          areaNames = areaNames.filter { (areaName) -> Bool in
            return filters.contains(areaName)
          }
        }
        areaLabel.text = areaNames.joined(separator: ", ").uppercased()
        if areaNames.contains("forehead") {
          foreheadPointView.isHidden = false
        }
        if areaNames.contains("t-zone") {
          tzonePointView.isHidden = false
        }
        if areaNames.contains("eyes") {
          eyesPointView.isHidden = false
        }
        if areaNames.contains("left cheek") {
          leftCheekPointView.isHidden = false
        }
        if areaNames.contains("right cheek") {
          rightCheekPointView.isHidden = false
        }
        if areaNames.contains("chin") {
          chinPointView.isHidden = false
        }
        if areaNames.contains("neck") {
          neckPointView.isHidden = false
        }
        if areaNames.contains("back") {
          backPointView.isHidden = false
        }
        areaStack.addArrangedSubview(areaLabel)
        dict.1.array?.forEach { (concern) in
          let verticalStack = UIStackView()
          verticalStack.axis = .vertical
          verticalStack.spacing = 4.0
          verticalStack.alignment = .leading
          verticalStack.distribution = .fill
          let concernLabel = UILabel()
          concernLabel.font = .openSans(style: .semiBold(size: 12.0))
          concernLabel.textColor = .gunmetal
          concernLabel.text = concern.concern.string
          verticalStack.addArrangedSubview(concernLabel)
          let intensityView = DesignableButton()
          intensityView.cornerRadius = 12.0
          intensityView.backgroundColor = SAConstants.colors[concern.intensityLevel.intValue]
          intensityView.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 12.0, bottom: 0.0, right: 12.0)
          intensityView.addHeightConstraint(24.0)
          intensityView.setAttributedTitle(
            SAConstants.ConcernIntensity(level: concern.intensityLevel.intValue)?.title.uppercased().attributed.add([.color(.white), .font(.openSans(style: .semiBold(size: 10.0)))]),
            for: .normal)
          verticalStack.addArrangedSubview(intensityView)
          areaStack.addArrangedSubview(verticalStack)
        }
        areaHorizontalStack?.addArrangedSubview(areaStack)
      }
    } else {
      isFilterEnabled = false
      faceImageView.image = .imgSkinAnalysisFaceDisabled
      skinAnalysisContainerStack.isHidden = true
      skinAnalysisContainerView.isHidden = false
    }
  }
  
  private func reloadSkinAnalysisGraph() {
    if let stats = viewModel.skinAnalysisStats?.filterBy?.uppercased().components(separatedBy: ",") {
      if stats.count > 2 {
        let preStats = Array(stats.prefix(stats.count - 1))
        if let postStat = stats.last {
          statsTitleLabel.text = [preStats.joined(separator: ", "), postStat].joined(separator: " & ")
        } else {
          statsTitleLabel.text = preStats.joined(separator: ", ")
        }
      } else {
        statsTitleLabel.text = stats.joined(separator: " & ")
      }
    } else {
      statsTitleLabel.text = nil
    }
    graphView.type = viewModel.viewBy
    graphView.periods = viewModel.skinAnalysisStats?.periods
    switch viewModel.viewBy {
    case .monthly:
      graphTitleLabel.text = "\(viewModel.skinAnalysisStats?.month?.uppercased() ?? "") (MONTHLY VIEW)"
    case .yearly:
      graphTitleLabel.text = "\(viewModel.skinAnalysisStats?.year ?? "") (YEARLY VIEW)"
    }
  }
  
  @IBAction private func startSkinQuizTapped(_ sender: Any) {
    showSkinQuiz()
  }
  
  @IBAction private func filterTapped(_ sender: Any) {
    guard isFilterEnabled else { return }
    showSAFilter(type: .filter)
  }
  
  @IBAction private func bookNowTapped(_ sender: Any) {
    showBookAnAppointment()
  }
  
  @IBAction private func changeViewTapped(_ sender: Any) {
    guard isChangeViewEnabled else { return }
    showSAFilter(type: .changeView)
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    viewModel.initialize()
  }
}

// MARK: - NavigationProtocol
extension SkinAnalysisViewController: NavigationProtocol {
}

// MARK: - SkinQuizPresenterProtocol
extension SkinAnalysisViewController: SkinQuizPresenterProtocol {
}

// MARK: - BookAnAppointmentPresenterProtocol
extension SkinAnalysisViewController: BookAnAppointmentPresenterProtocol {
  public func bookAnAppointmentDidDismiss() {
  }
  
  public func bookAnAppointmentDidRequest() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.showMyAppointments()
    }
  }
}

// MARK: - MyAppointmentsPresenterProtocol
extension SkinAnalysisViewController: MyAppointmentsPresenterProtocol {
}

// MARK: - SAFilterPresenterProtocol
extension SkinAnalysisViewController: SAFilterPresenterProtocol {
  public func saFilterDidApply(type: SAFilterViewController.SAFilterType, value: String) {
    switch type {
    case .filter:
      if value == "All" {
        viewModel.filter = ""
      } else {
        viewModel.filter = value
      }
    case .changeView:
      viewModel.viewBy = SAStatViewByType(rawValue: value) ?? .monthly
    }
  }
  
  public func saFilterSelectedValue(type: SAFilterViewController.SAFilterType) -> String {
    switch type {
    case .filter:
      return viewModel.filter
    case .changeView:
      return viewModel.viewBy.rawValue
    }
  }
}

// MARK: MARK - ControllerProtocol
extension SkinAnalysisViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("SkinAnalysisViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popViewController))
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    observeRefresh(scrollView: scrollView)
  }
}

// MARK: - SkinAnalysisView
extension SkinAnalysisViewController: SkinAnalysisView {
  public func reload() {
    reloadSkinType()
    reloadSkinAnalysis()
    reloadSkinAnalysisGraph()
  }
  
  public func showLoading() {
  }
  
  public func hideLoading() {
    endRefreshing()
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
}

public protocol SkinAnalysisPresenterProtocol {
}

extension SkinAnalysisPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showSkinAnalysis(animated: Bool = true) {
    let skinAnalysisViewController = UIStoryboard.get(.projectPorcelain).getController(SkinAnalysisViewController.self)
    navigationController?.pushViewController(skinAnalysisViewController, animated: animated)
  }
}
