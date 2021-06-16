//
//  CreditCardViewModel.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 08/08/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import R4pidKit

public protocol CreditCardView: class {
  func reload()
  func showLoading()
  func hideLoading()
  func showError(message: String?)
}

public protocol CreditCardViewModelProtocol {
  var cardsRecipe: CoreDataRecipe { get }
  var emptyNotificationActionData: EmptyNotificationActionData? { get }
  
  func attachView(_ view: CreditCardView)
  func initialize()
  func setCardPrimary(_ card: Card)
  func deleteCard(_ card: Card)
}

public final class CreditCardViewModel: CreditCardViewModelProtocol {
  private weak var view: CreditCardView?
  public var cardsRecipe: CoreDataRecipe {
    var recipe = CoreDataRecipe()
    recipe.sorts = [.dateCreated(isAscending: false)]
    recipe.predicate = CoreDataRecipe.Predicate.compoundAnd(predicates: [
      .isEqual(key: "customer.id", value: AppUserDefaults.customerID)]).rawValue
    return recipe
  }
  public var emptyNotificationActionData: EmptyNotificationActionData?
}

extension CreditCardViewModel {
  public func attachView(_ view: CreditCardView) {
    self.view = view
  }
  
  public func initialize() {
    view?.reload()
    view?.showLoading()
    PPAPIService.User.getStripCards().call { (response) in
      switch response {
      case .success(let result):
        CoreDataUtil.performBackgroundTask({ (moc) in
          guard let customerID = AppUserDefaults.customerID else { return }
          guard let customer = Customer.getUser(id: customerID, type: .customer, inMOC: moc) else { return }
          Card.parseCardsFromData(result.data, customer: customer, inMOC: moc)
        }, completion: { (_) in
          if result.data.isEmpty {
            self.emptyNotificationActionData = EmptyNotificationActionData(
              title: "You haven't added any cards yet.",
              subtitle: nil,
              action: nil)
          } else {
            self.emptyNotificationActionData = nil
          }
          self.view?.hideLoading()
          self.view?.reload()
        })
      case .failure(let error):
        self.emptyNotificationActionData = EmptyNotificationActionData(
          title: error.localizedDescription,
          subtitle: nil,
          action: nil)
        self.view?.hideLoading()
      }
    }
  }
  
  public func setCardPrimary(_ card: Card) {
    guard let customerID = AppUserDefaults.customerID else { return }
    guard let cardID = card.id else { return }
    CoreDataUtil.performBackgroundTask({ (moc) in
      let cards = Card.getCards(customerID: customerID, inMOC: moc)
      cards.forEach { (card) in
        card.isDefault = card.id == cardID
      }
    }, completion: { (_) in
    })
    PPAPIService.User.markStripeCardAsDefault(cardID: cardID).call { (_) in
    }
  }
  
  public func deleteCard(_ card: Card) {
    guard let customerID = AppUserDefaults.customerID else { return }
    guard let cardID = card.id else { return }
    CoreDataUtil.performBackgroundTask({ (moc) in
      guard let card = Card.getCard(id: cardID, customerID: customerID, inMOC: moc) else { return }
      card.delete()
    }, completion: { (_) in
    })
    PPAPIService.User.deleteStripCard(cardID: cardID).call { (_) in
    }
  }
}
