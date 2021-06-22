//
//  SmartMirrorViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 01/10/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

private struct AttributedTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 1.0
  }
  var alignment: NSTextAlignment? {
    return .center
  }
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? {
    return 18.0
  }
  var font: UIFont? {
    return .idealSans(style: .book(size: 13.0))
  }
  var color: UIColor? {
    return .lightNavy
  }
}

private struct AttributedExitTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? {
    return 1.0
  }
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat?
  var font: UIFont? {
    return .openSans(style: .regular(size: 13.0))
  }
  var color: UIColor? {
    return .gunmetal
  }
}

public final class SmartMirrorViewController: UIViewController {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.attributedText = "YOU ARE CONNECTED TO\nA SMART MIRROR".attributed.add(.appearance(AttributedTitleAppearance()))
    }
  }
  @IBOutlet private weak var exitButton: UIButton! {
    didSet {
      exitButton.setAttributedTitle(
        "EXIT SMART MIRROR".attributed.add(.appearance(AttributedExitTitleAppearance())),
        for: .normal)
    }
  }
  
  private var innerNavigationController: NavigationController? {
    return getChildController(NavigationController.self)
  }
  private var teaSelectionViewController: TeaSelectionViewController? {
    return innerNavigationController?.getChildController(TeaSelectionViewController.self)
  }
  private var smTreatmentsViewController: SMTreatmentsViewController? {
    return innerNavigationController?.getChildController(SMTreatmentsViewController.self)
  }
  
  private lazy var viewModel: SmartMirrorViewModelProtocol = SmartMirrorViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
    AppSocketManager.shared.exitSmartMirror()
  }
  
  @IBAction private func exitTapped(_ sender: Any) {
    if let smTreatmentsViewController = smTreatmentsViewController {
      if !smTreatmentsViewController.hasTreatments {
        AppSocketManager.shared.isEnabled = false
        popOrDismissViewController()
        AppSocketManager.shared.exitSmartMirror()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          guard let topViewController = UIApplication.shared.topViewController() else {
            AppSocketManager.shared.isEnabled = true
            return
          }
          let dialogHandler = DialogHandler()
          dialogHandler.message = """
          It seems like you have not
          booked your next appointment!
          Would you like to book now?
    """
          dialogHandler.actions = [.cancel(title: "LATER"), .confirm(title: "BOOK NOW")]
          dialogHandler.actionCompletion = { (action, actionView) in
            actionView.dismiss()
            if action.title == "BOOK NOW" {
              appDelegate.mainView.goToTab(.home)?.getChildController(HomeViewController.self)?.showMyAppointments(animated: false).showBookAnAppointment()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              AppSocketManager.shared.isEnabled = true
            }
          }
          DialogViewController.load(handler: dialogHandler).show(in: topViewController)
        }
      } else if let selectedAppointmentID = smTreatmentsViewController.selectedAppointmentID {
        AppSocketManager.shared.isEnabled = false
        AppSocketManager.shared.exitSmartMirror()
        popOrDismissViewController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          guard let topViewController = UIApplication.shared.topViewController() else {
             AppSocketManager.shared.isEnabled = true
             return
           }
          SMRateExpViewController.load(appointmentID: selectedAppointmentID, ratingCompletion: { (appointmentID, rating) in
            guard let customerID = AppUserDefaults.customerID, let appointment = Appointment.getAppointment(id: appointmentID, customerID: customerID) else {
              DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                AppSocketManager.shared.isEnabled = true
              }
              return
            }
            appDelegate.showLoading()
            PPAPIService.User.getMyAppointmentFeedback(appointmentID: appointmentID).call { (response) in
              switch response {
              case .success(let result):
                appDelegate.hideLoading()
                if let feedback = FeedbackData(data: result.data) {
                  if rating > 3 {
                    appDelegate.mainView.goToTab(.scanQR)?.getChildController(ScanQRViewController.self)?.showLeaveAFeedbackForm(
                      type: .tellUsMore(dataType: .appointment(appointment)),
                      feedback: feedback)
                  } else {
                    appDelegate.mainView.goToTab(.scanQR)?.getChildController(ScanQRViewController.self)?.showLeaveAFeedbackForm(
                      type: .reportAnIssue(dataType: .appointment(appointment)),
                      feedback: feedback)
                  }
                } else {
                  var feedback = FeedbackData()
                  feedback.id = nil
                  if rating > 3 {
                    appDelegate.mainView.goToTab(.scanQR)?.getChildController(ScanQRViewController.self)?.showLeaveAFeedbackForm(
                       type: .tellUsMore(dataType: .appointment(appointment)),
                       feedback: feedback)
                  } else {
                    appDelegate.mainView.goToTab(.scanQR)?.getChildController(ScanQRViewController.self)?.showLeaveAFeedbackForm(
                       type: .reportAnIssue(dataType: .appointment(appointment)),
                       feedback: feedback)
                  }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                  AppSocketManager.shared.isEnabled = true
                }
              case .failure(let error):
                appDelegate.hideLoading()
                appDelegate.showAlert(title: "Oops!", message: error.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                  AppSocketManager.shared.isEnabled = true
                }
              }
            }
          }, dismissCompletion: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
              AppSocketManager.shared.isEnabled = true
            }
          }).show(in: topViewController)
        }
      } else {
        AppSocketManager.shared.exitSmartMirror()
        popOrDismissViewController()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
          AppSocketManager.shared.isEnabled = true
        }
      }
    } else {
      AppSocketManager.shared.exitSmartMirror()
      popOrDismissViewController()
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        AppSocketManager.shared.isEnabled = true
      }
    }
  }
}

// MARK: - NavigationProtocol
extension SmartMirrorViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension SmartMirrorViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("SmartMirrorViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    innerNavigationController?.delegate = self
  }
}

// MARK: - SmartMirrorView
extension SmartMirrorViewController: SmartMirrorView {
  public func reload() {
  }
  
  public func showLoading() {
  }
  
  public func hideLoading() {
  }
  
  public func showError(message: String?) {
  }
}

// MARK: - UINavigationControllerDelegate
extension SmartMirrorViewController: UINavigationControllerDelegate {
  public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
    if let teaSelectionViewController = viewController as? TeaSelectionViewController {
      teaSelectionViewController.delegate = self
    }
    if let smTreatmentsViewController = viewController as? SMTreatmentsViewController {
      smTreatmentsViewController.delegate = self
    }
  }
}
 
// MARK: - TeaSelectionDelegate
extension SmartMirrorViewController: TeaSelectionDelegate {
  public func teaSelectionDidSelectTea(_ tea: TeaItemData, index: Int) {
    AppSocketManager.shared.teaSelect(atIndex: index)
  }
  
  public func teaSelectionDidOrderTea(_ tea: TeaItemData, index: Int) {
    AppSocketManager.shared.teaOrder(atIndex: index)
    guard let customerID = AppUserDefaults.customerID else { return }
    PPAPIService.Mirror.orderTea(customerID: customerID, teaID: tea.id).call { (_) in
    }
  }
}

// MARK: - SMTreatmentsDelegate
extension SmartMirrorViewController: SMTreatmentsDelegate {
  public func smTreatmentsViewTreatment(_ treatment: SMTreatmentData, beautyTips: BeautyTipsData?) {
    let promotions = beautyTips?.tips.compactMap({ ["title": $0.title ?? "", "description": $0.description ?? ""] }) ?? []
    let data: [String: Any] = [
      "treatment": [
        "name": treatment.name ?? "",
        "benefits": treatment.benefits ?? [],
        "afterCare": treatment.afterCare ?? []],
      "promotions": promotions]
    AppSocketManager.shared.viewTreatment(data: data)
  }
}

public protocol SmartMirrorPresenterProtocol {
  
}

extension SmartMirrorPresenterProtocol where Self: ControllerProtocol & UIViewController {
  @discardableResult
  public func showSmartMirror(animated: Bool = true) -> SmartMirrorViewController {
    let smartMirrorViewController = UIStoryboard.get(.scanQR).getController(SmartMirrorViewController.self)
    present(NavigationController(rootViewController: smartMirrorViewController), animated: animated) {
    }
    return smartMirrorViewController
  }
}
