//
//  ProductPrescriptionViewController+TableView.swift
//  Porcelain Therapist
//
//  Created by Patricia Marie Cesar on 11/12/2018.
//  Copyright © 2018 Augmatics Pte. Ltd. All rights reserved.
//

import Foundation
import UIKit

extension ProductPrescriptionViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (arrayOfCellData?.count ?? 0 > 0) ? arrayOfCellData!.count : 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard (arrayOfCellData?.count ?? 0) > 0 else {
      let cell = tableView.dequeueReusableCell(withIdentifier: DefaultEmptyCell.identifier) as! DefaultEmptyCell
      cell.configure(text: "No product prescription".localized())
      return cell
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: ProductPrescriptionCell.identifier) as? ProductPrescriptionCell
    if let data = arrayOfCellData?[indexPath.row] {
      cell?.configure(ProductPrescriptionModel(productPrescription: data.productPrescription))
    }

    return cell!
  }
}
