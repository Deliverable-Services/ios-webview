//
//  SelectCountryViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 04/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import SwiftyJSON
import Kingfisher

public struct CountryData {
  fileprivate static var countries: String?
  
  var name: String
  var demonym: String
  var alpha2Code: String?
  var phoneCode: String?
  var flagImageURL: String?
  var rawData: JSON
  
  init?(data: JSON) {
    guard let name = data["name"].string, let demonym = data["demonym"].string else  { return nil }
    self.rawData = data
    self.name = name
    self.demonym = demonym
    alpha2Code = data["alpha2Code"].string
    phoneCode = data["callingCodes"].array?.first?.string
    if let alpha2Code = alpha2Code {
      flagImageURL = "https://img.geonames.org/flags/x/\(alpha2Code.lowercased()).gif"
    } else {
      flagImageURL = nil
    }
  }
}

extension CountryData {
  @discardableResult
  fileprivate static func generateCountriesFromJSON(_ json: JSON? = nil) -> [CountryData] {
    if let json = json, !json.isEmpty {
      countries = json.rawString()
    }
    if let countries = countries  {
      return JSON(parseJSON: countries).arrayValue.compactMap({ CountryData(data: $0) })
    } else  {
      return []
    }
  }
}

public enum SelectCountryQuery {
  case name(value: String?)
  case phoneCode(value: String?)
  case alpha2Code(value: String?)
  
  public var countryData: CountryData? {
    let countries = CountryData.generateCountriesFromJSON()
    switch self {
    case .name(let value):
      return countries.first(where: { $0.name == value })
    case .phoneCode(let value):
      return countries.first(where: { $0.phoneCode == value })
    case .alpha2Code(let value):
      return countries.first(where: { $0.alpha2Code == value })
    }
  }
}

public typealias SelectCountryCompletion = (CountryData) -> Void

public final class SelectCountryHandler {
  public var didSelectCountry: SelectCountryCompletion?
}

public struct SelectCountryService {
  public static func getCountry(query: SelectCountryQuery, completion: @escaping SelectCountryCompletion) {
    if let country = query.countryData {
      completion(country)
    } else {
      CountriesAPIService.getAllCountries().jsonCall { (response) in
        switch response {
        case .success(let result):
          CountryData.generateCountriesFromJSON(result.raw)
          if let country = query.countryData {
            completion(country)
          }
        case .failure(let error):
          r4pidLog(error.localizedDescription)
        }
      }
    }
  }
  
  public static func getDefaultCountry(completion: @escaping SelectCountryCompletion) {
    if let country = SelectCountryQuery.alpha2Code(value: NSLocale.current.regionCode).countryData {
      completion(country)
    } else {
      CountriesAPIService.getAllCountries().jsonCall { (response) in
        switch response {
        case .success(let result):
          CountryData.generateCountriesFromJSON(result.raw)
          if let country = SelectCountryQuery.alpha2Code(value: NSLocale.current.regionCode).countryData {
            completion(country)
          }
        case .failure(let error):
          r4pidLog(error.localizedDescription)
        }
      }
    }
  }
}

public final class SelectCountryViewController: UITableViewController {
  private var countryDictionary: [String: [CountryData]] = [:]
  private var countrySectionTitles: [String] = []
  
  private let searchController = UISearchController(searchResultsController: nil)
  
  private var handler: SelectCountryHandler!
  
  private var filter: String? {
    didSet {
      generateTableRecord()
    }
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  private func generateTableRecord(json: JSON? = nil) {
    countryDictionary.removeAll()
    countrySectionTitles.removeAll()
    var countries = CountryData.generateCountriesFromJSON(json)
    if let filter = filter, !filter.isEmpty {
      countries = countries.filter { (countryData) -> Bool in
        if countryData.name.range(of: filter, options: .caseInsensitive) != nil ||
          countryData.demonym.range(of: filter, options: .caseInsensitive) != nil ||
          countryData.alpha2Code?.range(of: filter, options: .caseInsensitive) != nil ||
          countryData.phoneCode?.range(of: filter, options: .caseInsensitive) != nil {
          return true
        } else {
          return false
        }
      }
    }
    
    for country in countries {
      let countrykey = String(country.name.prefix(1))
      if var countryValues = countryDictionary[countrykey] {
        countryValues.append(country)
        countryDictionary[countrykey] = countryValues
      } else {
        countryDictionary[countrykey] = [country]
      }
    }
    
    countrySectionTitles = [String](countryDictionary.keys).sorted(by: { $0 < $1})
    tableView.reloadData()
  }
}

// MARK: - NavigationProtocol
extension SelectCountryViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension SelectCountryViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    return ""
  }
  
  public func setupUI() {
    title = "SELECT COUNTRY"
    view.backgroundColor = .whiteTwo
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: UIImage.icClose.maskWithColor(.lightNavy), selector: #selector(dismissViewController))
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.placeholder = "Search Country"
    searchController.searchBar.tintColor = .gunmetal
    navigationItem.searchController = searchController
    tableView.rowHeight = SelectCountryCell.defaultSize.height
    tableView.sectionIndexColor  = .greyblue
    tableView.sectionIndexBackgroundColor = .clear
    tableView.separatorColor = .whiteThree
    generateTableRecord()
    CountriesAPIService.getAllCountries().jsonCall { (response) in
      switch response {
      case .success(let result):
        self.generateTableRecord(json: result.raw)
      case .failure(let error):
        r4pidLog(error.localizedDescription)
      }
    }
  }
  
  public func setupObservers() {
  }
}

extension SelectCountryViewController {
  public override func numberOfSections(in tableView: UITableView) -> Int {
    return countrySectionTitles.count
  }
  
  public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return countryDictionary[countrySectionTitles[section]]?.count ?? 0
  }
  
  public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let selectCountryCell = tableView.dequeueReusableCell(SelectCountryCell.self, atIndexPath: indexPath)
    selectCountryCell.country = countryDictionary[countrySectionTitles[indexPath.section]]?[indexPath.row]
    return selectCountryCell
  }
  
  public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerLabel = MarginLabel(frame: .zero)
    headerLabel.edgeInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
    headerLabel.backgroundColor = .whiteTwo
    headerLabel.attributedText = countrySectionTitles[section].attributed.add([
      .color(.bluishGrey),
      .font(.openSans(style: .regular(size: 13.0)))])
    return headerLabel
  }
  
  public override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return countrySectionTitles
  }
  
  public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let country = countryDictionary[countrySectionTitles[indexPath.section]]?[indexPath.row] {
      handler.didSelectCountry?(country)
    }
    searchController.isActive = false
    dismissViewController()
  }
}

// MARK: - UISearchResultsUpdating
extension SelectCountryViewController: UISearchResultsUpdating {
  public func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filter = searchBar.text
  }
}

extension SelectCountryViewController {
  @discardableResult
  public static func load(handler: SelectCountryHandler, in vc: UIViewController) -> SelectCountryViewController {
    let selectCountryVC = UIStoryboard.get(.authentication).getController(SelectCountryViewController.self)
    selectCountryVC.handler = handler
    let navigationController = NavigationController(rootViewController: selectCountryVC)
    if #available(iOS 13.0, *) {
      navigationController.isModalInPresentation = true
    }
    vc.present(navigationController, animated: true) {
    }
    return selectCountryVC
  }
}

public final class SelectCountryCell: UITableViewCell {
  public var country: CountryData? {
    didSet {
      if let flagImageURL = country?.flagImageURL, let url = URL(string: flagImageURL) {
        imageView?.kf.indicatorType = .activity
        imageView?.kf.setImage(
          with: ImageResource(downloadURL: url),
          options: [.processor(DownsamplingImageProcessor(size: CGSize(width: 24.0, height: 16.0)))]) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success:
              self.layoutSubviews()
            case .failure(let error):
              osLogComposeError(error.localizedDescription, log: .ui)
            }
        }
      } else {
        imageView?.image = nil
      }
      textLabel?.attributedText = country?.name.attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 14.0)))])
      if let phoneCode = country?.phoneCode, !phoneCode.isEmpty {
        detailTextLabel?.attributedText = "+\(phoneCode)".attributed.add([.color(.gunmetal), .font(.openSans(style: .regular(size: 14.0)))])
      } else {
        detailTextLabel?.attributedText = nil
      }
    }
  }
  
  public override func prepareForReuse() {
    super.prepareForReuse()
    
    imageView?.kf.cancelDownloadTask()
    imageView?.image = nil
  }
}

extension SelectCountryCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 0.0, height: 48.0)
  }
}
