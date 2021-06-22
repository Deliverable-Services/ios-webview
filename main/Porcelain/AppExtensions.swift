//
//  AppExtensions.swift
//
//  Created by Patricia Cesar on 11/11/2017.
//  Copyright © 2017. All rights reserved.
//

import Foundation
import UIKit
import KRProgressHUD
import SwiftyJSON
import CoreData
import CoreImage

public func randomNumber<T : SignedInteger>(inRange range: ClosedRange<T> = 1...6) -> T {
  let length = Int64(range.upperBound - range.lowerBound + 1)
  let value = Int64(arc4random()) % length + Int64(range.lowerBound)
  return T(value)
}

extension Collection {
  func randomItem() -> Self.Iterator.Element {
    let count = distance(from: startIndex, to: endIndex)
    let roll = randomNumber(inRange: 0...count-1)
    return self[index(startIndex, offsetBy: roll)]
  }
}

extension NSObject {
  var className: String {
    return String(describing: type(of: self))
  }
  
  class var className: String {
    return String(describing: self)
  }
}

extension UITableView {
  func addRefreshControl(target: Any?, action: Selector, tintColor: UIColor? = UIColor.Porcelain.warmGrey) {
    let refreshControl = UIRefreshControl()
    refreshControl.tag = 3425
    refreshControl.tintColor = tintColor!
    refreshControl.addTarget(target, action: action, for: .valueChanged)
    //    addSubview(refreshControl)
    self.refreshControl = refreshControl
  }
  
  func endRefreshAnimation() {
    //    if let refreshControl = subviews.first(where: { $0.tag == 3425 }) as? UIRefreshControl,
    if refreshControl?.isRefreshing ?? false {
      refreshControl?.endRefreshing()
    }
  }
}

extension Double {
  /// Rounds the double to decimal places value
  mutating func roundToPlaces(places:Int) -> Double {
    let divisor = pow(10.0, Double(places))
    
    return Double(roundf(Float(self * divisor))) / divisor
  }
}

extension String {
  @discardableResult
  public mutating func replaceString(_ string: String, with: String) -> String {
    self = replacingOccurrences(of: string, with: with)
    return self
  }
  
  func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
    return NSLocalizedString(self, tableName: tableName, bundle: bundle, value: "\(self)", comment: "")
  }

  var pairs: [String] {
    var result: [String] = []
    let characters = Array(self)
    stride(from: 0, to: count, by: 2).forEach {
      result.append(String(characters[$0..<min($0+2, count)]))
    }
    return result
  }

  mutating func insert(separator: String, every n: Int) {
    self = inserting(separator: separator, every: n)
  }
  
  func inserting(separator: String, every n: Int) -> String {
    var result: String = ""
    let characters = Array(self)
    stride(from: 0, to: count, by: n).forEach {
      result += String(characters[$0..<min($0+n, count)])
      if $0+n < count {
        result += separator
      }
    }
    return result
  }

  func isValidEmail() -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: self)
  }
}

extension Encodable {
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}

extension UIColor {
  convenience init(red: Int, green: Int, blue: Int) {
    let newRed = CGFloat(red)/255
    let newGreen = CGFloat(green)/255
    let newBlue = CGFloat(blue)/255
    
    self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
  }
  
  convenience init(hex:Int) {
    self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
  }
}

extension UINavigationController {
  func findFirstInstanceOf(_ type: UIViewController.Type) -> UIViewController? {
    guard let vc = self.viewControllers.first(where: { return $0.isKind(of: type) }) else {
      return nil
    }
    return vc
  }
}

extension UIView {
  func copyView<T: UIView>() -> T {
    return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
  }
  
  func dropShadow(offsetX: CGFloat, offsetY: CGFloat, color: UIColor, opacity: Float, radius: CGFloat, scale: Bool = true) {
    layer.masksToBounds = false
    layer.shadowOffset = CGSize(width: offsetX, height: offsetY)
    layer.shadowColor = color.cgColor
    layer.shadowOpacity = opacity
    layer.shadowRadius = radius
    layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = scale ? UIScreen.main.scale : 1
  }
  
}

extension UIImage {
  static func from(color: UIColor, rect: CGRect) -> UIImage {
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    context!.setFillColor(color.cgColor)
    context!.fill(rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img!
  }
}

extension UITableView {
  func applyGroupedTableViewLayout(_ cell: UITableViewCell, indexPath: IndexPath) {
    let cornerRadius: CGFloat = 5
    cell.backgroundColor = .clear
    
    let layer = CAShapeLayer()
    let pathRef = CGMutablePath()
    let bounds = cell.bounds.insetBy(dx: 20, dy: 0)
    var addLine = false
    
    if indexPath.row == 0 && indexPath.row == self.numberOfRows(inSection: indexPath.section) - 1 {
      pathRef.__addRoundedRect(transform: nil, rect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
    } else if indexPath.row == 0 {
      pathRef.move(to: .init(x: bounds.minX, y: bounds.maxY))
      pathRef.addArc(tangent1End: .init(x: bounds.minX, y: bounds.minY), tangent2End: .init(x: bounds.midX, y: bounds.minY), radius: cornerRadius)
      pathRef.addArc(tangent1End: .init(x: bounds.maxX, y: bounds.minY), tangent2End: .init(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
      pathRef.addLine(to: .init(x: bounds.maxX, y: bounds.maxY))
      addLine = true
    } else if indexPath.row == self.numberOfRows(inSection: indexPath.section) - 1 {
      pathRef.move(to: .init(x: bounds.minX, y: bounds.minY))
      pathRef.addArc(tangent1End: .init(x: bounds.minX, y: bounds.maxY), tangent2End: .init(x: bounds.midX, y: bounds.maxY), radius: cornerRadius)
      pathRef.addArc(tangent1End: .init(x: bounds.maxX, y: bounds.maxY), tangent2End: .init(x: bounds.maxX, y: bounds.midY), radius: cornerRadius)
      pathRef.addLine(to: .init(x: bounds.maxX, y: bounds.minY))
    } else {
      pathRef.addRect(bounds)
      addLine = true
    }
    
    layer.path = pathRef
    layer.fillColor = UIColor(white: 1, alpha: 0.8).cgColor
    
    if (addLine == true) {
      let lineLayer: CALayer = CALayer()
      let lineHeight: CGFloat  = (1 / UIScreen.main.scale)
      lineLayer.frame = CGRect(x:bounds.minX, y:bounds.size.height-lineHeight, width:bounds.size.width, height:lineHeight)
      lineLayer.backgroundColor = self.separatorColor!.cgColor
      layer.addSublayer(lineLayer)
    }
    
    let testView: UIView = UIView(frame:bounds)
    testView.layer.insertSublayer(layer, at: 0)
    testView.backgroundColor = UIColor.clear
    cell.backgroundView = testView
  }
}

extension UIViewController {
  func hideKeyboardWhenTappedAroundView() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
  
  @objc @IBAction func popViewController() {
    DispatchQueue.main.async {
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  @IBAction func dismissViewController() {
    DispatchQueue.main.async {
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  func displayAlert(title: String? = nil, message: String? = nil, handler: ((UIAlertAction) -> Void)?) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: handler)
    
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true, completion: nil)
  }
}

extension UIStoryboard {
  public enum StoryboardName: String {
    case main = "Main"
    case bookAppointment = "BookAppointment"
    case cart = "Cart"
    case logIn = "LogIn"
    case viewHelpers = "ViewHelpers"
    case scanQR = "ScanQR"
    case myTreatment = "MyTreatment"
    case profile = "Profile"
    case feedback = "Feedback"
    case dashboard = "Dashboard"
  }
}

// MARK: - UIStoryboard
extension UIStoryboard {
  static func get(_ type: StoryboardName) -> UIStoryboard {
    return UIStoryboard(name: type.rawValue, bundle: nil)
  }
}

extension KRProgressHUD {
  static func showHUD() {
    DispatchQueue.main.async {
      KRProgressHUD.show()
    }
  }
  
  static func hideHUD() {
    DispatchQueue.main.async {
      KRProgressHUD.dismiss()
    }
  }
}

// MARK: - JSON get helpers
extension JSON {
  public func getMessage() -> String? {
    guard count > 0 else { return nil }
    guard let message = self[0].dictionary?[PorcelainAPIConstant.Key.message]?.string else { return nil }
    return message
  }
  
  public func getData() -> JSON? {
    guard count > 0 else { return nil }
    guard let data = self[0].dictionary?[PorcelainAPIConstant.Key.data] else { return nil }
    return data
  }
}

// MARK: - Coredata
extension NSManagedObject {
  func addObject(value: NSManagedObject, forKey key: String) {
    let items = self.mutableSetValue(forKey: key)
    items.add(value)
  }

  func removeObject(value: NSManagedObject, forKey key: String) {
    let items = self.mutableSetValue(forKey: key)
    items.remove(value)
  }
}

public extension DispatchQueue {
  private static var _onceTracker = [String]()
  
  public class func once(file: String = #file,
                         function: String = #function,
                         line: Int = #line,
                         block: () -> Void) {
    let token = "\(file):\(function):\(line)"
    once(token: token, block: block)
  }
  
  /**
   Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
   only execute the code once even in the presence of multithreaded calls.
   
   - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
   - parameter block: Block to execute once
   */
  public class func once(token: String,
                         block: () -> Void) {
    objc_sync_enter(self)
    defer { objc_sync_exit(self) }
    
    guard !_onceTracker.contains(token) else { return }
    
    _onceTracker.append(token)
    block()
  }
}

extension UIDevice {
  public static let modelName: String = {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
      #if os(iOS)
      switch identifier {
      case "iPod5,1":                                 return "iPod Touch 5"
      case "iPod7,1":                                 return "iPod Touch 6"
      case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
      case "iPhone4,1":                               return "iPhone 4s"
      case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
      case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
      case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
      case "iPhone7,2":                               return "iPhone 6"
      case "iPhone7,1":                               return "iPhone 6 Plus"
      case "iPhone8,1":                               return "iPhone 6s"
      case "iPhone8,2":                               return "iPhone 6s Plus"
      case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
      case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
      case "iPhone8,4":                               return "iPhone SE"
      case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
      case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
      case "iPhone10,3", "iPhone10,6":                return "iPhone X"
      case "iPhone11,2":                              return "iPhone XS"
      case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
      case "iPhone11,8":                              return "iPhone XR"
      case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
      case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
      case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
      case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
      case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
      case "iPad6,11", "iPad6,12":                    return "iPad 5"
      case "iPad7,5", "iPad7,6":                      return "iPad 6"
      case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
      case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
      case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
      case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
      case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
      case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
      case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
      case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
      case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
      case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
      case "AppleTV5,3":                              return "Apple TV"
      case "AppleTV6,2":                              return "Apple TV 4K"
      case "AudioAccessory1,1":                       return "HomePod"
      case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
      default:                                        return identifier
      }
      #elseif os(tvOS)
      switch identifier {
      case "AppleTV5,3": return "Apple TV 4"
      case "AppleTV6,2": return "Apple TV 4K"
      case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
      default: return identifier
      }
      #endif
    }
    
    return mapToDevice(identifier: identifier)
  }()
  
}
