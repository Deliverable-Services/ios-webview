//
//  SelectShippingAddressDataSource.swift
//  Porcelain
//
//  Created by Jean on 05/11/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

protocol ShippingAddressDataSourceProtocol: UITableViewDelegate, UITableViewDataSource {
  var shippingDetails: [ShippingDetails] { get }
  var delegate: ShippingAddressDataSourceDelegate? { get set }

  func populateAddress()
}

extension ShippingAddressDataSource: ShippingAddressDataSourceProtocol {
  func populateAddress() {
    shippingDetails = ShippingAddress.myAddresses(in: CoreDataUtil.mainMOC)
  }
}

extension ShippingAddressDataSource: ShippingAddressCellDelegate {
  func edit(indexPath: IndexPath) {
    guard indexPath.row <= shippingDetails.count else { return }
    delegate?.showUpdate(details: shippingDetails[indexPath.row-1], indexPath: indexPath)
  }

  func delete(indexPath: IndexPath) {
    guard indexPath.row <= shippingDetails.count else { return }
    delegate?.confirmDelete(details: shippingDetails[indexPath.row-1], indexPath: indexPath)
  }

  func setAsDefault(details: ShippingDetails?, indexPath: IndexPath) {
    delegate?.setDefault(details: details)
    guard details != nil else { return }

    let selectedRow = tableView.indexPathForSelectedRow
    if selectedRow != indexPath {
      tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
      tableView(tableView, didSelectRowAt: indexPath)
    }

    guard let sRow = selectedRow else { return }
    tableView.reloadRows(at: [sRow], with: .none)
  }
}

class ShippingAddressDataSource: NSObject {
  var shippingDetails: [ShippingDetails] = []
  var delegate: ShippingAddressDataSourceDelegate?
  private var tableView: UITableView

  init(tableView: UITableView) {
    self.tableView = tableView
    super.init()
  }

  // MARK: - Private methods
  private func goToAddAddress() {
    delegate?.addNewDetails()
  }

  private func initButtonCell(tableView: UITableView) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: ButtonCell.identifier)
      as? ButtonCell else { fatalError() }

    cell.configure( didTap: { self.goToAddAddress() },
      attributedTitle: " ADD NEW ADDRESS".localized()
        .withFont(UIFont.Porcelain.idealSans(14))
        .withTextColor(UIColor.Porcelain.metallicBlue)
        .withKern(0.5),
      bgColor: UIColor.Porcelain.mainBackground,
      borderColor: UIColor.Porcelain.metallicBlue,
      borderWidth: 1.0,
      cornerRadius: 7.0)
    cell.button.setImage(#imageLiteral(resourceName: "add-icon").withRenderingMode(.alwaysTemplate), for: .normal)
    cell.button.tintColor = UIColor.Porcelain.metallicBlue
    cell.button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    cell.contentView.backgroundColor = UIColor.Porcelain.mainBackground
    cell.topMargin.constant = 32
    cell.bottomMargin.constant = 32
    return cell
  }

  // MARK: - TableView delegate datasource
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return shippingDetails.count + 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 0 { return initButtonCell(tableView: tableView) }

    guard let cell = tableView.dequeueReusableCell(withIdentifier: ShippingAddressCell.identifier)
      as? ShippingAddressCell else { fatalError() }
    let details = shippingDetails[indexPath.row - 1]
    cell.configure(details: details, indexPath: indexPath)
    cell.delegate = self

    print("will display cell row \(indexPath.row) with ID \(details.id), selected id: \(delegate?.defaultAddress?.id)")
    if details.id == delegate?.defaultAddress?.id {
      self.tableView(tableView, didSelectRowAt: indexPath)
      self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
      cell.selectNoBlock()
    } else { cell.deselectNoBlock() }

    return cell
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell: ShippingAddressCell = tableView.cellForRow(at: indexPath) as? ShippingAddressCell
      else { return }

    print("did select row \(indexPath.row)")
    let details = shippingDetails[indexPath.row - 1]
    delegate?.setDefault(details: details)
    cell.selectNoBlock()
  }

  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    guard let cell: ShippingAddressCell = tableView.cellForRow(at: indexPath) as? ShippingAddressCell
      else { return }
    cell.deselectNoBlock()
  }
}
