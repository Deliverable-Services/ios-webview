//
//  ContactUsViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 19/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import PhoneNumberKit

public final class ContactUsViewController: UIViewController {
  @IBOutlet private weak var scrollView: UIScrollView!
  @IBOutlet private weak var phoneLabel: UILabel! {
    didSet {
      phoneLabel.font = .openSans(style: .semiBold(size: 13.0))
      phoneLabel.textColor = .gunmetal
      phoneLabel.text = nil
    }
  }
  @IBOutlet private weak var callButton: UIButton!
  @IBOutlet private weak var whatsappButton: UIButton!
  @IBOutlet private weak var selectBranchTitleLabel: UILabel! {
    didSet {
      var appearance = FormSaveButtonAttributedTitleAppearance()
      appearance.color = .gunmetal
      selectBranchTitleLabel.attributedText = "SELECT BRANCH".attributed.add(.appearance(appearance))
    }
  }
  @IBOutlet private weak var branchTableView: DesignableCentersTableView! {
    didSet {
      branchTableView.cornerRadius = 7.0
      branchTableView.borderColor = .whiteThree
      branchTableView.borderWidth = 1.0
      branchTableView.alwaysBounceVertical = false
      branchTableView.separatorColor = .whiteThree
      branchTableView.separatorInset = .zero
      branchTableView.setAutomaticDimension()
      branchTableView.registerWithNib(ContactUsTCell.self)
      branchTableView.dataSource = self
      branchTableView.delegate = self
    }
  }
  @IBOutlet private weak var emailLabel: UILabel! {
    didSet {
      emailLabel.font = .openSans(style: .semiBold(size: 13.0))
      emailLabel.textColor = .gunmetal
      emailLabel.text = AppConstant.supportEmail
    }
  }
  @IBOutlet private weak var eStoreLabel: UILabel! {
    didSet {
      eStoreLabel.font = .openSans(style: .semiBold(size: 13.0))
      eStoreLabel.textColor = .gunmetal
      eStoreLabel.text = AppConstant.estoreURL
    }
  }
  
  private var selectedCenter: Center? {
    didSet {
      var phoneVal = AppConstant.generalCallPhone
      if let phone = selectedCenter?.contact?.number, !phone.isEmpty {
        let phoneCode = selectedCenter?.contact?.countryCode ?? "65"
        if let phoneNumber = try? PhoneNumberKit().parse([phoneCode, phone].joined()) {
          phoneVal = "+\(phoneNumber.countryCode) " + "\(phoneNumber.nationalNumber)".formatMobile()
        }
      }
      phoneLabel.text = phoneVal
    }
  }
  
  private lazy var frcHandler = FetchResultsControllerHandler<Branch>(type: .tableView(branchTableView))
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    reload()
  }
  
  private func reload() {
    var recipe = CoreDataRecipe()
    recipe.sorts = [.custom(key: "name", isAscending: true)]
    frcHandler.reload(recipe: recipe)
    guard frcHandler.numberOfObjectsInSection(0) > 0 else { return }
    let indexPath = IndexPath(row: 0, section: 0)
    branchTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
    selectedCenter = frcHandler.object(at: indexPath)
  }
  
  @IBAction private func callTapped(_ sender: Any) {
    let callPhone: String
    if let phone = selectedCenter?.contact?.number {
      let phoneCode = selectedCenter?.contact?.countryCode ?? "65"
      let phoneNumber = try? PhoneNumberKit().parse([phoneCode, phone].joined())
      callPhone = (phoneNumber?.numberString ?? AppConstant.generalCallPhone).prependPlusIfNeeded()
    } else {
      callPhone = AppConstant.generalCallPhone
    }
    UIApplication.shared.call(phone: callPhone.replacingOccurrences(of: " ", with: "").prependPlusIfNeeded())
  }
  
  @IBAction private func whatsappTapped(_ sender: Any) {
    let whatsAppPhone = selectedCenter?.whatsapp?.prependPlusIfNeeded() ?? AppConstant.whatsappPhone
    do {
      let phoneNumber = try PhoneNumberKit().parse(whatsAppPhone)
      guard let url = URL(string: AppConstant.whatsapp(phone: phoneNumber.numberString.prependPlusIfNeeded()).replacingOccurrences(of: " ", with: "")) else { return }
      UIApplication.shared.open(url, options: [:]) { (_) in
      }
    } catch {
      showAlert(title: nil, message: error.localizedDescription)
    }
  }
  
  @IBAction private func mailTapped(_ sender: Any) {
    openMailSender(toEmails: [AppConstant.supportEmail])
  }
  
  @IBAction private func siteTapped(_ sender: Any) {
    guard let url = URL(string: AppConstant.estoreURL) else { return }
    UIApplication.shared.open(url, options: [:]) { (_) in
    }
  }
}

// MARK: - NavigationProtocol
extension ContactUsViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension ContactUsViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    return "showContactUs"
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popOrDismissViewController))
    PPAPIService.Center.getCenters().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          Center.parseCentersFromData(result.data, inMOC: moc)
        }, completion: { (_) in
          self.reload()
        })
      case .failure(let error):
        self.showAlert(title: "Oops!", message: error.localizedDescription)
      }
    }
  }
  
  public func setupObservers() {
  }
}

// MARK: - UITableViewDataSource
extension ContactUsViewController: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return frcHandler.numberOfObjectsInSection(section)
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let contactUsTCell = tableView.dequeueReusableCell(ContactUsTCell.self, atIndexPath: indexPath)
    contactUsTCell.branch = frcHandler.object(at: indexPath)
    return contactUsTCell
  }
}

// MARK: - UITableViewDelegate
extension ContactUsViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedCenter = frcHandler.object(at: indexPath)
  }
}

public protocol ContactUsPresenterProtocol {
}

extension ContactUsPresenterProtocol where Self: ControllerProtocol & UIViewController {
  @discardableResult
  public func showContactUs(animated: Bool = true) -> ContactUsViewController {
    let contactUsViewController = UIStoryboard.get(.settings).getController(ContactUsViewController.self)
    if let navigationController = navigationController as? NavigationController {
      navigationController.pushViewController(contactUsViewController, animated: animated)
    } else {
      let navigationController = NavigationController(rootViewController: contactUsViewController)
      if #available(iOS 13.0, *) {
        navigationController.isModalInPresentation = true
      }
      present(navigationController, animated: animated) {
      }
    }
    return contactUsViewController
  }
}

public final class DesignableCentersTableView: ResizingContentTableView, Designable {
  public var cornerRadius: CGFloat = 0.0
  public var borderWidth: CGFloat = 0.0
  public var borderColor: UIColor = .clear
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    updateLayer()
  }
}
