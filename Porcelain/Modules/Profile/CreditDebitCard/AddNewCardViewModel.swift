//
//  AddNewCardViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 05/09/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit
import Stripe

public protocol AddNewCardView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
  func updateButtonInteraction()
  func successAddStripe()
}

public protocol AddNewCardViewModelProtocol {
  var card: STPCardParams { get set }
  var isValid: Bool { get }
  
  func attachView(_ view: AddNewCardView)
  func initialize()
  func reload()
  func validate()
  func addStripeCard()
}

public final class AddNewCardViewModel: AddNewCardViewModelProtocol {
  private weak var view: AddNewCardView?
  
  public var card: STPCardParams = STPCardParams()
  public var isValid: Bool {
    return STPCardValidator.validationState(forCard: card) == .valid
  }
}

extension AddNewCardViewModel {
  public func attachView(_ view: AddNewCardView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
    view?.updateButtonInteraction()
  }
  
  public func reload() {
    view?.reload()
    view?.updateButtonInteraction()
  }
  
  public func validate() {
    view?.updateButtonInteraction()
  }
  
  public func addStripeCard() {
    view?.showLoading()
    STPAPIClient.shared().createToken(withCard: card) { (token, error) in
      if let error = error {
        self.view?.hideLoading()
        self.view?.showError(message: error.localizedDescription)
      } else if let tokenID = token?.tokenId {
        PPAPIService.User.createStripeCard(tokenID: tokenID).call { (response) in
          switch response {
          case .success(let result):
            CoreDataUtil.performBackgroundTask({ (moc) in
              guard let cardID = result.data.id.string else { return }
              guard let customerID = AppUserDefaults.customerID else { return }
              guard let customer = User.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
              let cards = Card.getCards(cardIDs: [cardID], customerID: customerID, inMOC: moc)
              Card.parseCardFromData(result.data, customer: customer, cards: cards, inMOC: moc)
            }, completion: { (_) in
              self.view?.hideLoading()
              self.view?.successAddStripe()
            })
          case .failure(let error):
            self.view?.hideLoading()
            self.view?.showError(message: error.localizedDescription)
          }
        }
      } else {
        self.view?.hideLoading()
        self.view?.showError(message: "Stripe client has not error nor token.")
      }
    }
  }
}
