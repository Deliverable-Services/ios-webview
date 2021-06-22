//
//  TreatmentViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 23/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct ButtonTitleAppearance: AttributedStringAppearanceProtocol {
  public var characterSpacing: Double? =  1.08
  public var alignment: NSTextAlignment? = nil
  public var lineBreakMode: NSLineBreakMode? = nil
  public var minimumLineHeight: CGFloat? = nil
  public var font: UIFont? = .idealSans(style: .book(size: 14.0))
  public var color: UIColor? = .white
}

private struct TitleAttributedTitleAppearance: AttributedStringAppearanceProtocol {
  public var characterSpacing: Double? = 0.37
  public var alignment: NSTextAlignment? = nil
  public var lineBreakMode: NSLineBreakMode? = nil
  public var minimumLineHeight: CGFloat? = 24.0
  public var font: UIFont? = .idealSans(style: .light(size: 18.0))
  public var color: UIColor? = .gunmetal
}

private struct ContentAttributedTitleAppearance: AttributedStringAppearanceProtocol {
  public var characterSpacing: Double? = 0.54
  public var alignment: NSTextAlignment? = .left
  public var lineBreakMode: NSLineBreakMode? = .byWordWrapping
  public var minimumLineHeight: CGFloat? = 22.0
  public var font: UIFont? = .openSans(style: .regular(size: 13.0))
  public var color: UIColor? = .bluishGrey
}

public final class TreatmentViewController: UIViewController, TreatmentProtocol, RefreshHandlerProtocol {
  public var refreshControl: UIRefreshControl?
  
  public var refreshScrollView: UIScrollView?
  
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var imageView: LoadingImageView! {
    didSet {
      imageView.placeholderImage = .imgLandscapePlaceholder
      imageView.cornerRadius = 1.0
    }
  }
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var contentLabel: UILabel!
  @IBOutlet private weak var webView: ResizingContentWebView!
  @IBOutlet private weak var durationNoticeLabel: UILabel! {
    didSet {
      durationNoticeLabel.font = .openSans(style: .regular(size: 12.0))
      durationNoticeLabel.textColor = .gunmetal
    }
  }
  @IBOutlet private weak var bookNowButton: DesignableButton! {
    didSet {
      bookNowButton.cornerRadius = 7.0
      bookNowButton.backgroundColor = .lightNavy
      bookNowButton.setAttributedTitle(
        "BOOK NOW!".attributed.add(.appearance(ButtonTitleAppearance())),
        for: .normal)
    }
  }
  @IBOutlet private weak var contactButton: DesignableButton! {
    didSet {
      contactButton.cornerRadius = 7.0
      contactButton.backgroundColor = .greyblue
      contactButton.setAttributedTitle(
        "CONTACT PORCELAIN".attributed.add(.appearance(ButtonTitleAppearance())),
        for: .normal)
    }
  }
  
  public var treatment: Treatment?
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setStatusBarNav(style: .default)
    hideBarSeparator()
  }
  
  private func initialize() {
    navigationItem.title = treatment?.categoryName?.uppercased()
    imageView.url = treatment?.image
    titleLabel.attributedText = treatmentName?.attributed.add(.appearance(TitleAttributedTitleAppearance()))
    contentLabel.attributedText = desc?.attributed.add(.appearance(ContentAttributedTitleAppearance()))
    durationNoticeLabel.text = duration
    webView.isHidden = true
    guard let centerID = treatment?.centerIDs?.first, let serviceID = treatment?.serviceID else { return }
    PPAPIService.Center.getTreatmentHTML(centerID: centerID, serviceID: serviceID).call { (response) in
      switch response {
      case .success(let result):
        if let htmlString = result.data.string {
          self.webView.isHidden = false
          self.webView.loadHTMLString(htmlString, baseURL: nil)
        } else {
          self.webView.isHidden = true
        }
        self.endRefreshing()
      case .failure:
        self.webView.isHidden = true
        self.endRefreshing()
      }
    }
  }
  
  private func showBookNowIfPossible() {
    guard let serviceID = treatment?.serviceID else { return }
    if let centerIDs = centerIDs, !centerIDs.isEmpty {
      let centers = Center.getCenters(centerIDs: centerIDs)
      if let centerID = centerIDs.first, centers.count == 1 {
        showBookAnAppointment(rebookData: RebookData(
          appointment: nil,
          selectedCenter: centers.first,
          selectedTreatment: Service.getService(id: serviceID, type: .treatment, centerID: centerID),
          selectedAddons: nil,
          selectedTherapists: nil,
          notes: nil))
      } else {
        let actionSheetViewController = UIAlertController(title: nil, message: "SELECT BRANCH", preferredStyle: .actionSheet)
        centers.enumerated().forEach { (indx, center) in
          guard let centerID = center.id else { return }
          actionSheetViewController.addAction(UIAlertAction(title: "\(center.name ?? "")", style: .default, handler: {  [weak self] (_) in
            guard let `self` = self else { return }
            self.showBookAnAppointment(rebookData: RebookData(
              appointment: nil,
              selectedCenter: center,
              selectedTreatment: Service.getService(id: serviceID, type: .treatment, centerID: centerID),
              selectedAddons: nil,
              selectedTherapists: nil,
              notes: nil))
          }))
        }
        actionSheetViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        }))
        present(actionSheetViewController, animated: true, completion: nil)
      }
    } else {
      showBookAnAppointment()
    }
  }
  
  public func refreshControlDidRefresh(_ refreshControl: UIRefreshControl) {
    initialize()
  }
  
  @IBAction private func bookNowTapped(_ sender: Any) {
    appDelegate.mainView.validateSession(loginCompletion: {
      self.showBookNowIfPossible()
    }) {
      self.showBookNowIfPossible()
    }
  }
  
  @IBAction private func contactTapped(_ sender: Any) {
    showContactUs()
  }
}

// MARK: - NavigationProtocol
extension TreatmentViewController: NavigationProtocol {
}

// MARK: - BookAnAppointmentPresenterProtocol
extension TreatmentViewController: BookAnAppointmentPresenterProtocol {
  public func bookAnAppointmentDidDismiss() {
    
  }
  
  public func bookAnAppointmentDidRequest() {
    navigationController?.popToRootViewController(animated: false)
    appDelegate.mainView.goToTab(.home)?.getChildController(HomeViewController.self)?.showMyAppointments()
  }
}

// MARK: - ContactUsPresenterProtocol
extension TreatmentViewController: ContactUsPresenterProtocol {
}

// MARK: - TreatmentViewController
extension TreatmentViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("TreatmentViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popViewController))
    initialize()
  }
  
  public func setupObservers() {
    observeRefresh(scrollView: scrollView)
  }
}

public protocol TreatmentPresenterProtocol {
}

extension TreatmentPresenterProtocol where Self: ControllerProtocol & UIViewController {
  @discardableResult
  public func showTreatment(_ treatment: Treatment, animated: Bool = true) -> TreatmentViewController {
    let treatmentViewController = UIStoryboard.get(.shop).getController(TreatmentViewController.self)
    treatmentViewController.treatment = treatment
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(treatmentViewController, animated: animated)
    } else {
      present(NavigationController(rootViewController: treatmentViewController), animated: animated) {
      }
    }
    return treatmentViewController
  }
}
