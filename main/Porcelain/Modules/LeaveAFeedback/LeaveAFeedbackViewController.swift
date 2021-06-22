//
//  LeaveAFeedbackViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 31/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import Cosmos
import DTPhotoViewerController

private struct FeedbackAttributedDetailsAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 0.22
  }
  var alignment: NSTextAlignment? {
    return nil
  }
  var lineBreakMode: NSLineBreakMode? {
    return nil
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

public final class LeaveAFeedbackViewController: UIViewController, RefreshHandlerProtocol {
  public var refreshControl: UIRefreshControl?
  
  public var refreshScrollView: UIScrollView?
  
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .idealSans(style: .book(size: 18.0))
      titleLabel.textColor = .gunmetal
      titleLabel.text = "Rate your experience"
    }
  }
  @IBOutlet private weak var rateView: CosmosView! {
    didSet {
      var settings = CosmosSettings()
      settings.starSize = 36.0
      settings.starMargin = 16.0
      settings.filledImage = .icFullStar
      settings.emptyImage = .icEmptyStar
      rateView.settings = settings
    }
  }
  @IBOutlet private weak var toRateStack: UIStackView!
  @IBOutlet private weak var feedbackContainerView: DesignableView! {
    didSet {
      feedbackContainerView.cornerRadius = 7.0
      feedbackContainerView.borderWidth = 1.0
      feedbackContainerView.borderColor = .whiteThree
      feedbackContainerView.backgroundColor = .white
    }
  }
  @IBOutlet private weak var feedbackLabel: UILabel! {
    didSet {
      feedbackLabel.font = .openSans(style: .semiBold(size: 13.0))
      feedbackLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var feedbackDetailsLabel: UILabel!
  @IBOutlet private weak var feedbackAttachmentsCollectionView: AttachmentsCollectionView! {
    didSet {
      feedbackAttachmentsCollectionView.config = AttachmentsCollectionConfig(
        isInteractive: false,
        spacing: 8.0,
        rowSize: 6)
    }
  }
  
  private var viewModel: LeaveAFeedbackViewModelProtocol!
  
  public func configure(viewModel: LeaveAFeedbackViewModelProtocol) {
    self.viewModel = viewModel
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    generateLeftNavigationButton(image: isPushed ? .icLeftArrow: .icClose, selector: #selector(popOrDismissViewController))
    viewModel.initialize()
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    viewModel.initialize()
  }
}

// MARK: - NavigationProtocol
extension LeaveAFeedbackViewController: NavigationProtocol {
}

// MARK: - LeaveAFeedbackFormPresenterProtocol
extension LeaveAFeedbackViewController: LeaveAFeedbackFormPresenterProtocol {
}

// MARK: - ControllerProtocol
extension LeaveAFeedbackViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("LeaveAFeedbackViewController not set")
  }
  
  public func setupUI() {
    view.backgroundColor = .whiteFive
  }
  
  public func setupController() {
    viewModel.attachView(self)
  }
  
  public func setupObservers() {
    observeRefresh(scrollView: scrollView)
    rateView.didFinishTouchingCosmos = { [weak self] (rating) in
      guard let `self` = self else { return }
      var feedback = self.viewModel.feedback
      if let pastRating = feedback.rating {
        if pastRating > 3 {//tellus more
          if pastRating >= rating {
            feedback.images = nil
          }
        } else {//report an issue
          if pastRating <= rating {
            feedback.images = nil
          }
        }
      }
      feedback.rating = rating
      if rating > 3 {
        self.showLeaveAFeedbackForm(type: .tellUsMore(dataType: self.viewModel.type), feedback: feedback)
      } else {
        self.showLeaveAFeedbackForm(type: .reportAnIssue(dataType: self.viewModel.type), feedback: feedback)
      }
    }
    feedbackAttachmentsCollectionView.attachmentDidTapped = { [weak self] (refView, image) in
      guard let `self` = self else { return }
      let photoViewerViewController = DTPhotoViewerController(referencedView: refView, image: image)
      self.present(photoViewerViewController, animated: true) {
      }
    }
  }
}

// MARK: - LeaveAFeedbackView
extension LeaveAFeedbackViewController: LeaveAFeedbackView {
  public func reload() {
    if viewModel.feedback.id != nil && viewModel.feedback.rating != nil {
      rateView.isUserInteractionEnabled = false
      navigationItem.title = "FEEDBACK"
      titleLabel.isHidden = true
      rateView.rating = viewModel.feedback.rating ?? 0.0
      feedbackContainerView.isHidden = false
      feedbackLabel.text = viewModel.feedback.feedback
      feedbackDetailsLabel.attributedText = viewModel.feedback.feedbackDetails?.attributed
        .add(.appearance(FeedbackAttributedDetailsAppearance()))
      if let attachments = viewModel.feedback.images?.map({ AttachmentData(image: nil, imageURL: $0) }), !attachments.isEmpty {
        feedbackAttachmentsCollectionView.isHidden = false
        feedbackAttachmentsCollectionView.attachments = attachments
      } else  {
        feedbackAttachmentsCollectionView.isHidden = true
      }
    } else {
      if viewModel.feedback.id == "default" {
        rateView.isUserInteractionEnabled = false
        navigationItem.title = ""
      } else {
        rateView.isUserInteractionEnabled = true
        navigationItem.title = viewModel.type.title
      }
      titleLabel.isHidden = false
      rateView.rating = 0.0
      feedbackContainerView.isHidden = true
    }
    switch viewModel.type {
    case .appointment(let appointment):
      toRateStack.removeAllArrangedSubviews()
      toRateStack.addArrangedSubview(FeedbackAppointmentView(appointment: appointment))
    case .purchase(let purchase):
      toRateStack.removeAllArrangedSubviews()
      toRateStack.addArrangedSubview(FeedbackPurchaseView(purchase: purchase))
    }
  }
  
  public func showLoading() {
    rateView.isUserInteractionEnabled = false
    startRefreshing()
  }
  
  public func hideLoading() {
    rateView.isUserInteractionEnabled = true
    endRefreshing()
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
}

public protocol LeaveAFeedbackPresenterProtocol {
}

extension LeaveAFeedbackPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showLeaveAFeedback(type: FeedbackDataType, animated: Bool = true) {
    let leaveAFeedbackViewController = UIStoryboard.get(.feedback).getController(LeaveAFeedbackViewController.self)
    leaveAFeedbackViewController.configure(viewModel: LeaveAFeedbackViewModel(type: type))
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(leaveAFeedbackViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: leaveAFeedbackViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
  }
}
