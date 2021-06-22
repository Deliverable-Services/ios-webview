//
//  Protocols.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 09/06/2018.
//  Copyright © 2018 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

public protocol ReuseIdentifier {
  static var identifier: String { get }
}

extension ReuseIdentifier {
  public static var identifier: String {
    return String(describing: Self.self)
  }
}

extension UIViewController: ReuseIdentifier {
}

extension UIView: ReuseIdentifier {
}

public protocol OpenURLProtocol {
  var openURL: URL? { get }
}

extension String: OpenURLProtocol {
  public var openURL: URL? {
    return  URL(string: self)
  }
}

extension URL: OpenURLProtocol {
  public var openURL: URL? {
    return self
  }
}

public protocol ApplicationProtocol {
}

extension UIApplication: ApplicationProtocol {
}

extension ApplicationProtocol where Self: UIApplication {
  public func rootViewController() -> UIViewController? {
    return UIApplication.shared.keyWindow?.rootViewController?.presentedViewController ?? UIApplication.shared.keyWindow?.rootViewController
  }
  
  public func topViewController(_ viewController: UIViewController? = UIApplication.shared.rootViewController()) -> UIViewController? {
    if let navigationController = viewController as? UINavigationController {
      return topViewController(navigationController.visibleViewController)
    }
    if let tabBarController = viewController as? UITabBarController {
      if let selectedViewController = tabBarController.selectedViewController {
        return topViewController(selectedViewController)
      }
    }
    if let presentedViewController = viewController?.presentedViewController {
      return topViewController(presentedViewController)
    }
    return viewController
  }
  
  public func inAppSafariOpen(url: OpenURLProtocol) {
    guard let openURL = url.openURL, let topViewController = topViewController() else { return }
    let sfSafariViewController = SFSafariViewController(url: openURL)
    topViewController.present(sfSafariViewController.self, animated: true, completion: nil)
  }
  
  public func hasTopNotch() -> Bool {
    if #available(iOS 11.0,  *) {
      return (UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0) > 24.0
    }
    return false
  }
  
  public func call(phone: String) {
    guard let url = URL(string: "tel://\(phone)") else { return }
    open(url, options: [:], completionHandler: nil)
  }
}

public protocol StoryProtocol {
}

extension UIStoryboard: StoryProtocol {
}

extension StoryProtocol where Self: UIStoryboard {
  public func getController<T: UIViewController & ControllerProtocol>(_ controller: T.Type) -> T {
    return instantiateViewController(withIdentifier: controller.identifier) as! T
  }
}

public protocol ControllerProtocol: class {
  static var segueIdentifier: String { get }
  func setupUI()
  func setupController()
  func setupObservers()
}

extension ControllerProtocol where Self: UIViewController {
  ///calls setupUI setupController setupObservers
  public func setup() {
    setupUI()
    setupObservers()
    setupController()
  }

  public func getChildController<T: ControllerProtocol>(_ cClass: T.Type) -> T? {
    return children.filter({ $0.isKind(of: cClass) }).first as? T
  }

  public func getChildControllers<T: ControllerProtocol>(_ cClass: T.Type) -> [T]? {
    return children.filter({ $0.isKind(of: cClass) }) as? [T]
  }
}

/// Allows access to Navigation helper methods
public protocol NavigationProtocol {
  var barButtonColor: UIColor? { get }
}

extension NavigationProtocol where Self: UIViewController {
  /// Generates left navigation button with image and overriding  color
  public func generateLeftNavigationButton(image: UIImage, color: UIColor? = nil, selector: Selector) {
    let newBarButtonColor = color ?? barButtonColor
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: image.maskWithColor(newBarButtonColor), style: .plain, target: self, action: selector)
    navigationItem.rightBarButtonItem?.tintColor = newBarButtonColor
  }
  
  /// Generate left navigtions buttons with overriding color
  public func generateLeftNavigationButtons(_ buttons: [UIBarButtonItem], color: UIColor? = nil) {
    let newBarButtonColor = color ?? barButtonColor
    buttons.forEach { (barItem) in
      barItem.image = barItem.image?.maskWithColor(newBarButtonColor)
      barItem.tintColor = newBarButtonColor
    }
    navigationItem.leftBarButtonItems = buttons
  }

  /// Generate right navigation button with image and overriding color
  public func generateRightNavigationButton(image: UIImage, color: UIColor? = nil, selector: Selector) {
    let newBarButtonColor = color ?? barButtonColor
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: image.maskWithColor(newBarButtonColor), style: .plain, target: self, action: selector)
    navigationItem.rightBarButtonItem?.tintColor = newBarButtonColor
  }

  /// Generate right navigtions buttons with overriding color
  public func generateRightNavigationButtons(_ buttons: [UIBarButtonItem], color: UIColor? = nil) {
    let newBarButtonColor = color ?? barButtonColor
    buttons.forEach { (barItem) in
      barItem.image = barItem.image?.maskWithColor(newBarButtonColor)
      barItem.tintColor = newBarButtonColor
    }
    navigationItem.rightBarButtonItems = buttons
  }
  
  /// Generate right navigation padding
  public func generateRightNavigationPadding(width: CGFloat) {
    let barItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    barItem.width = width
    navigationItem.rightBarButtonItems = [barItem]
  }

  /// Hides navigation bar separator
  public func hideBarSeparator() {
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
  }

  /// Shows navigation bar separator
  public func showBarSeparator() {
    navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    navigationController?.navigationBar.shadowImage = nil
  }
}

///  Allows access to tableview helper methods
public protocol TableViewProtocol {
}

/// Explicitly gives tableview helper methods access to UITableView
extension UITableView: TableViewProtocol {
  public enum ResizeDimension {
    case header
    case cell
    case footer
  }
}

extension TableViewProtocol where Self: UITableView {
  ///Register nib must conform to CellProtocol to use
  public func registerWithNib<T: UITableViewCell & CellProtocol>(_ cell: T.Type) {
    register(cell.nib, forCellReuseIdentifier: cell.identifier)
  }

  ///Register class must conform to CellProtocol to use
  public func registerWithClass<T: UITableViewCell & CellProtocol>(_ cell: T.Type) {
    register(cell.self, forCellReuseIdentifier: cell.identifier)
  }

  ///Dequeue reusable cell must conform to CellProtocol to use
  public func dequeueReusableCell<T: UITableViewCell & CellProtocol>(_ cell: T.Type, atIndexPath indexPath: IndexPath) -> T {
    return dequeueReusableCell(withIdentifier: cell.identifier, for: indexPath) as! T
  }

  ///Set default dimensions  to header, cell and/or footer; default is cell
  public func setAutomaticDimension(_ dimensions: [ResizeDimension] = [.cell]) {
    dimensions.forEach { (dimension) in
      switch dimension {
      case .header:
        sectionHeaderHeight = UITableView.automaticDimension
        estimatedSectionHeaderHeight = 48.0
      case .cell:
        estimatedRowHeight = 48.0
        rowHeight = UITableView.automaticDimension
      case .footer:
        sectionFooterHeight = UITableView.automaticDimension
        estimatedSectionFooterHeight = 48.0
      }
    }
  }

  ///Update tableview without  animation
  public func updateWithoutAnimation() {
    UIView.performWithoutAnimation {
      beginUpdates()
      endUpdates()
    }
  }

  public func updateWithPreserveOffset() {
    let offset = contentOffset
    updateWithoutAnimation()
    contentOffset = offset
  }
  
  public func reloadVisibleCells(excludes: [IndexPath]? = nil) {
    guard let indexPathsForVisibleRows = indexPathsForVisibleRows else { return }
    reloadRows(at: indexPathsForVisibleRows.filter({ !(excludes?.contains($0) ?? false) }), with: .automatic)
  }
}

/// Allows access to collectionview helper methods
public protocol CollectionViewProtocol {
}

extension UICollectionView: CollectionViewProtocol {
}

extension CollectionViewProtocol where Self: UICollectionView {
  ///Register nib must conform to CellProtocol to use
  public func registerWithNib<T: UICollectionViewCell & CellProtocol>(_ cell: T.Type) {
    register(cell.nib, forCellWithReuseIdentifier: cell.identifier)
  }

  ///Register class must conform to CellProtocol to use
  public func registerWithClass<T: UICollectionViewCell & CellProtocol>(_ cell: T.Type) {
    register(cell.self, forCellWithReuseIdentifier: cell.identifier)
  }

  ///Dequeue reusable cell must conform to CellProtocol to use
  public func dequeueReusableCell<T: UICollectionViewCell & CellProtocol>(_ cell: T.Type, atIndexPath indexPath: IndexPath) -> T {
    return dequeueReusableCell(withReuseIdentifier: cell.identifier, for: indexPath) as! T
  }

  ///Register reusable suppelementary header view nib must conform to CellProtocol to use
  public func registerSupplementaryHeaderViewWithNib<T: UICollectionReusableView & CellProtocol>(_ cell: T.Type) {
    register(cell.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cell.identifier)
  }

  ///Register reusable suppelementary header view class must conform to CellProtocol to use
  public func registerSupplementaryHeaderViewWithClass<T: UICollectionReusableView & CellProtocol>(_ cell: T.Type) {
    register(cell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cell.identifier)
  }

  ///Dequeue reusable suppelementary header view must conform to CellProtocol to use
  public func dequeueReusableSupplementaryHeaderView<T: UICollectionReusableView & CellProtocol>(_ cell: T.Type, atIndexPath indexPath: IndexPath) -> T {
    return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: cell.identifier, for: indexPath) as! T
  }

  /// set automatic dimension to collectionviewcell
  public func setAutomaticDimension() {
    if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
      if #available(iOS 10.0, *) {
        flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
      } else {
        flowLayout.estimatedItemSize = CGSize(width: 1.0, height: 1.0)
      }
    }
  }
  
  public var visibleIndexPaths: [IndexPath] {
    return visibleCells.compactMap({ indexPath(for: $0) })
  }
}

/// Allows access to necessary data for cells
public protocol CellProtocol {
  static var defaultSize: CGSize { get }
}

extension CellProtocol where Self: UITableViewCell {
  public static var nib: UINib {
    return UINib(nibName: identifier, bundle: Bundle(for: Self.self))
  }
  
  public static var defaultSize: CGSize {
    return .zero
  }
}

extension CellProtocol where Self: UICollectionViewCell {
  public static var nib: UINib {
    return UINib(nibName: identifier, bundle: Bundle(for: Self.self))
  }
  
  public static var defaultSize: CGSize {
    return .zero
  }
}

extension CellProtocol where Self: UICollectionReusableView {
  public static var nib: UINib {
    return UINib(nibName: identifier, bundle: Bundle(for: Self.self))
  }
  
  public static var defaultSize: CGSize {
    return .zero
  }
}

/// Allows access to view helper methods
public protocol ViewProtocol {
}

/// Explicitly gives view helper methods access to UIView
extension UIView: ViewProtocol {
}

extension ViewProtocol where Self: UIView {
  public static func getView<T: UIView>(_ view: T.Type) -> T {
    return Bundle(for: type(of: self.init())).loadNibNamed(identifier, owner: nil, options: nil)?.first as! T
  }
  
  /// Load nib
  public func loadNib<T: UIView>(_ owner: T.Type) {
    Bundle(for: type(of: self)).loadNibNamed(owner.identifier, owner: self, options: nil)
  }
  
  /// Get content size
  func getContentSize(maxWidth: CGFloat, maxHeight: CGFloat = .greatestFiniteMagnitude) -> CGSize {
    return self.sizeThatFits(CGSize(width: maxWidth, height: maxHeight))
  }
  
  /// get content height
  public func getContentHeight(_ maxWidth: CGFloat, maxHeight: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
    return self.sizeThatFits(CGSize(width: maxWidth, height: maxHeight)).height
  }
  
  /// Get content width
  public func getContentWidth(_ maxWidth: CGFloat = .greatestFiniteMagnitude, maxHeight: CGFloat) -> CGFloat {
    return self.sizeThatFits(CGSize(width: maxWidth, height: maxHeight)).width
  }
}

/// Allows access to constraint helper methods
public protocol ConstraintProtocol {
}

extension UIView: ConstraintProtocol {
}

extension ConstraintProtocol where Self: UIView {
  /// Add bound sizing mask
  public func addContainerBoundsResizingMask(_ container: UIView? = nil) {
    guard let superView = container ?? self.superview else { return }
    autoresizingMask = [.flexibleHeight, .flexibleWidth]
    frame = superView.bounds
  }
  
  public func addWidthConstraint(_ width: CGFloat) {
    NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width).isActive = true
  }
  
  public func addHeightConstraint(_ height: CGFloat) {
    NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height).isActive = true
  }
  
  /// Add side constraint
  public func addSideConstraintsWithContainer(_ container: UIView? = nil) {
    guard let superView = container ?? self.superview else { return }
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.leadingAnchor.constraint(equalTo: superView.leadingAnchor),
      self.trailingAnchor.constraint(equalTo: superView.trailingAnchor),
      self.topAnchor.constraint(equalTo: superView.topAnchor),
      self.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
      ])
  }
}

public protocol Designable {
  var cornerRadius: CGFloat { get }
  var borderWidth: CGFloat { get }
  var borderColor: UIColor { get }
  func updateLayer()
}

extension Designable {
  public func updateLayer() {
  }
}

extension Designable where Self: UIView {
  public func updateLayer() {
    layer.cornerRadius = cornerRadius
    layer.borderWidth = borderWidth
    layer.borderColor = borderColor.cgColor
    layer.masksToBounds = cornerRadius > 0.0
  }
}

public protocol DashBorderable: class {
  var dashBorderLayer: CAShapeLayer! { get set }
}

public struct DashBorderAppearance {
  public var color: UIColor = .black
  public var cornerRadius: CGFloat = 0.0
  public var width: CGFloat = 1.0
  public var dashPattern: [NSNumber]?
  
  public init() {
  }
}

extension DashBorderable where Self: UIView {
  private var dashBorderName: String {
    return "meme-milos-:D"
  }
  
  public func addDashBorder(appearance: DashBorderAppearance) {
    removeDashBorder()
    dashBorderLayer = CAShapeLayer()
    dashBorderLayer.name = dashBorderName
    dashBorderLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: appearance.cornerRadius).cgPath
    dashBorderLayer.fillColor = nil
    dashBorderLayer.strokeColor = appearance.color.cgColor
    dashBorderLayer.lineWidth = appearance.width
    dashBorderLayer.lineDashPattern = appearance.dashPattern
    dashBorderLayer.lineCap = .round
    dashBorderLayer.lineJoin = .round
    layer.addSublayer(dashBorderLayer)
  }
  
  public func removeDashBorder() {
    removeLayer(name: dashBorderName)
  }
  
  private func removeLayer(name: String) {
    for layer in layer.sublayers ?? [] {
      if let layerName = layer.name, layerName == name {
        layer.removeFromSuperlayer()
      }
    }
  }
}

public protocol Shadowable: class {
  var shadowLayer: CAShapeLayer! { get set }
}

public struct ShadowAppearance {
  public var fillColor: UIColor = .white
  public var shadowColor: UIColor = .black
  public var shadowOffset: CGSize = CGSize(width: 0.0, height: 5.0)
  public var shadowOpacity: Float = 0.3
  public var shadowRadius: CGFloat = 5.0
  public var cornerRadius: CGFloat = 7.0
  
  public init() {
  }
}

extension Shadowable where Self: UIView {
  private var shadowLayerName: String {
    return "sinister-shadow-games"
  }
  /// creates shadow; makes layer.masksToBounds = false and should be called on
  /// • draw(:rect) - fixed size view
  /// • layoutSubview - dynamic size view
  public func addShadow(color: UIColor = .black, fillColor: UIColor = .white, opacity: CFloat = 0.1, cornerRadius: CGFloat = 7.0) {
    removeShadow()
    shadowLayer = CAShapeLayer()
    shadowLayer.name = shadowLayerName
    shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    shadowLayer.fillColor = fillColor.cgColor
    shadowLayer.shadowColor = color.cgColor
    shadowLayer.shadowPath = shadowLayer.path
    shadowLayer.shadowOffset = CGSize(width: 0.0, height: 0.3)
    shadowLayer.shadowOpacity = opacity
    shadowLayer.shadowRadius = 3.0
    layer.insertSublayer(shadowLayer, at: 0)
    layer.masksToBounds = false
  }
  
  /// creates shadow; makes layer.masksToBounds = false and should be called on
  /// • draw(:rect) - fixed size view
  /// • layoutSubview - dynamic size view
  public func addShadow(appearance: ShadowAppearance) {
    removeShadow()
    shadowLayer = CAShapeLayer()
    shadowLayer.name = shadowLayerName
    shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: appearance.cornerRadius).cgPath
    shadowLayer.fillColor = appearance.fillColor.cgColor
    shadowLayer.shadowColor = appearance.shadowColor.cgColor
    shadowLayer.shadowPath = shadowLayer.path
    shadowLayer.shadowOffset = appearance.shadowOffset
    shadowLayer.shadowOpacity = appearance.shadowOpacity
    shadowLayer.shadowRadius = appearance.shadowRadius
    layer.insertSublayer(shadowLayer, at: 0)
    layer.masksToBounds = false
  }

  /// remove shadow
  public func removeShadow() {
    removeLayer(name: shadowLayerName)
  }

  private func removeLayer(name: String) {
    for layer in layer.sublayers ?? [] {
      if let layerName = layer.name, layerName == name {
        layer.removeFromSuperlayer()
      }
    }
  }
}

public protocol LabelProtocol {
}

extension UILabel: LabelProtocol {
}

extension LabelProtocol where Self: UILabel {
  /// get content text height
  func getContentTextHeight(_ maxWidth: CGFloat, maxHeight: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
    return self.getContentHeight(maxWidth, maxHeight: maxHeight)
  }

  /// get content text width
  func getContentTextWidth(_  maxHeight: CGFloat, maxWidth: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
    return self.getContentWidth(maxWidth, maxHeight: maxHeight)
  }
}

extension Sequence where Iterator.Element: Equatable {
  public func unique() -> [Iterator.Element] {
    var buffer: [Iterator.Element] = []
    
    for element in self {
      guard !buffer.contains(element) else { continue }
      
      buffer.append(element)
    }
    return buffer
  }
}

public protocol DateProtocol {
}

extension Date: DateProtocol {
}

extension DateProtocol where Self == Date {
  public func getDateComponents() -> DateComponents {
    return Calendar.current.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: self)
  }

  public func isGreaterThan(_ date: Date) -> Bool {
    return self.compare(date) == .orderedDescending
  }

  public func isLessThan(_ date: Date) -> Bool {
    return self.compare(date) == .orderedAscending
  }

  public func isEqualTo(_ date: Date) -> Bool {
    return self.compare(date) == .orderedSame
  }

  public func toString(WithFormat withFormat: String = "yyyy-MM-dd'T'HH:mm:ssZZZ") -> String {//TODO: set default date format
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = withFormat
    return dateFormater.string(from: self)
  }
  
  public func startOfWeek() -> Date {
      let gregorian = Calendar(identifier: .gregorian)
      guard let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        else { fatalError() }
    return gregorian.date(byAdding: .day, value: 1, to: sunday)!
  }
  
  public func endOfWeek() -> Date {
    let start = startOfWeek()
    return start.dateByAdding(days: 6)
  }

  public func startOfMonth() -> Date {
    return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
  }

  public func endOfMonth() -> Date {
    return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
  }

  public func startOfTheDay() -> Date {
    return Calendar.current.startOfDay(for: self)
  }

  public func dateByAdding(years: Int) -> Date {
    return Calendar.current.date(byAdding: .year, value: years, to: self)!
  }

  public func dateByAdding(months: Int) -> Date {
    return Calendar.current.date(byAdding: .month, value: months, to: self)!
  }

  public func dateByAdding(weeks: Int) -> Date {
    return Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self)!
  }

  public func dateByAdding(days: Int) -> Date {
    return Calendar.current.date(byAdding: .day, value: days, to: self)!
  }

  public func dateByAdding(hours: Int) -> Date {
    return Calendar.current.date(byAdding: .hour, value: hours, to: self)!
  }

  public func dateByAdding(minutes: Int) -> Date {
    return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
  }

  public func dateByAdding(seconds: Int) -> Date {
    return Calendar.current.date(byAdding: .second, value: seconds, to: self)!
  }

  public func dateDifferenceFrom(_ date: Date, toDate: Date) -> DateComponents {
    return Calendar.current.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: date, to: toDate)
  }

  public func yearsFrom(_ date: Date) -> Int {
    return dateDifferenceFrom(date, toDate: self).year ?? 0
  }

  public func monthsFrom(_ date: Date ) -> Int {
    return dateDifferenceFrom(date, toDate: self).month ?? 0
  }

  public func weeksFrom(_ date: Date) -> Int {
    return dateDifferenceFrom(date, toDate: self).weekOfYear ?? 0
  }

  public func daysFrom(_ date: Date) -> Int {
    return dateDifferenceFrom(date, toDate: self).day ?? 0
  }

  public func hoursFrom(_ date: Date) -> Int {
    return dateDifferenceFrom(date, toDate: self).hour ?? 0
  }

  public func minutesFrom(_ date: Date) -> Int {
    return dateDifferenceFrom(date, toDate: self).minute ?? 0
  }

  public func secondsFrom(_ date: Date) -> Int {
    return dateDifferenceFrom(date, toDate: self).second ?? 0
  }
}

public protocol StringProtocol {
}

extension String: StringProtocol {
}

extension StringProtocol where Self == String {
  public func toDate(format: String = "yyyy-MM-dd'T'HH:mm:ssZZZ") -> Date? {
    let dateFormater = DateFormatter()
    dateFormater.dateFormat = format
    return dateFormater.date(from: self)
  }

  public func formatPrice(showDecimalPoints: Bool = true) -> String {
    let price = Double(self) ?? 0
    if price.truncatingRemainder(dividingBy: 1) == 0 && !showDecimalPoints {
      return String(format: "%.0f", price.roundTo2f())
    }
    return String(format: "%.2f", price.roundTo2f())
  }
  
  public func capitalizingFirstLetter() -> String {
    return self.prefix(1).capitalized + self.dropFirst()
  }
  
  public mutating func capitalizeFirstLetter() {
    self = self.capitalizingFirstLetter()
  }
  
  public func capitalizingPerWord() -> String {
    return self.components(separatedBy: " ").map({ $0.capitalizingFirstLetter() }).joined(separator: " ")
  }
  
  public mutating func capitalizedPerWord() {
    self = self.capitalizingPerWord()
  }

  /// generate number from string
  public func toNumber() -> NSNumber {
    return NumberFormatter().number(from: self) ?? NSNumber(value: 0)
  }

  public func clean() -> String {
    return self.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  public func cleanHTMLTags() -> String {
    return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
  }

  public func aggressiveClean() -> String {
    return self.components(separatedBy: " ").map({ $0.clean() }).joined(separator: " ")
  }
  
  /// convert sw range from nsrange
  public func range(from nsRange: NSRange) -> Range<String.Index>? {
    guard
      let from16 = self.utf16.index(self.utf16.startIndex, offsetBy: nsRange.location, limitedBy: self.utf16.endIndex),
      let to16 = self.utf16.index(self.utf16.startIndex, offsetBy: nsRange.location + nsRange.length, limitedBy: self.utf16.endIndex),
      let from = from16.samePosition(in: self),
      let to = to16.samePosition(in: self)
      else { return nil }
    return from ..< to
  }

  public func compareInsensitiveEqual(string: Self?) -> Bool {
    guard let string = string else { return false }
    return self.caseInsensitiveCompare(string) == .orderedSame
  }
  
  public var emptyToNil: String? {
    guard !self.isEmpty else { return nil }
    return self
  }
  
  public func findMatches(regex: String) throws -> [NSTextCheckingResult] {
    do {
      let regex = try NSRegularExpression(pattern: regex)
      let fullRange = NSRange(self.startIndex..., in: self)
      let results = regex.matches(in: self, range: fullRange)
      return results
    } catch {
      throw error
    }
  }
}

public protocol DoubleProtocol {
}

extension Double: DoubleProtocol {
}

extension DoubleProtocol where Self == Double {
  /// round upto 2 decimal places
  public func roundTo2f() -> Double { return Double(Darwin.round(100 * self)/100)}

  /// converts to string
  public var toString: String { return concatenate(self) }
}

public protocol ImageProtocol {

}

extension UIImage: ImageProtocol {
}

extension ImageProtocol {
  public static func makeFromView(_ view: UIView) -> UIImage? {
    if #available(iOS 10.0, *) {
      let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
      return renderer.image { rendererContext in
        view.layer.render(in: rendererContext.cgContext)
      }
    } else {
      UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
      defer { UIGraphicsEndImageContext() }
      guard let currentContext = UIGraphicsGetCurrentContext() else {
        return nil
      }
      view.layer.render(in: currentContext)
      return UIGraphicsGetImageFromCurrentImageContext()
    }
  }
}

@objc
public protocol KeyboardHandlerProtocol {
  @objc
  func keyboardWillHide(_ notification: Notification)
  @objc
  func keyboardWillShow(_ notification: Notification)
}

extension KeyboardHandlerProtocol {
  public func observeKeyboard() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
  }
  
  public func evaluateKeyboardFrameFromNotification(_ notification: Notification) -> CGRect {
    guard let userInfo = notification.userInfo else { return .zero }
    guard let keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return .zero }
    return keyboardFrame
  }
}

@objc
public protocol ApplicationDelegateCallbackProtocol {
  @objc
  func applicationWillResignActive(_ notification: Notification)
  @objc
  func applicationDidEnterBackground(_ notification: Notification)
  @objc
  func applicationWillEnterForeground(_ notification: Notification)
  @objc
  func applicationDidBecomeActive(_ notification: Notification)
  @objc
  func applicationWillTerminate(_ notification: Notification)
}

extension ApplicationDelegateCallbackProtocol {
  public func observeApplicationCallback() {
    NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate(_:)), name: UIApplication.willTerminateNotification, object: nil)
  }
}

@objc
public protocol RefreshHandlerProtocol {
  var refreshControl: UIRefreshControl? { get set }
  var refreshScrollView: UIScrollView? { get set }
  
  @objc
  func refreshControlDidRefresh(_ refreshControl: UIRefreshControl)
}

extension RefreshHandlerProtocol {
  public func observeRefresh(scrollView: UIScrollView) {
    guard refreshControl == nil else { return }
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refreshControlDidRefresh(_:)), for: .valueChanged)
    self.refreshControl = refreshControl
    scrollView.alwaysBounceVertical = true
    scrollView.addSubview(self.refreshControl!)
    refreshScrollView = scrollView
  }
  
  public func unobserveRefresh() {
    self.refreshControl?.removeFromSuperview()
    self.refreshControl = nil
    self.refreshScrollView = nil
  }
  
  public func startRefreshing() {
    guard let refreshControl = refreshControl, !refreshControl.isRefreshing else { return }
    guard let refreshScrollView = refreshScrollView else { return }
    refreshScrollView.setContentOffset(CGPoint(
      x: refreshScrollView.contentOffset.x,
      y: min(refreshScrollView.contentOffset.y, -60.0)), animated: true)
    refreshControl.beginRefreshing()
  }
  
  public func endRefreshing() {
    guard let refreshControl = refreshControl else { return }
    guard refreshControl.isRefreshing else { return }
    refreshControl.endRefreshing()
  }
}

@objc
public protocol TapToDismissProtocol {
  @objc
  func handleTapToDismiss(_ tapGesture: UITapGestureRecognizer)
}

extension TapToDismissProtocol {
  public func observeTapToDismiss(view: UIView) {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapToDismiss(_:)))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
  }
}

@objc
public protocol PanToDismissProtocol {
  @objc
  func handlePanToDismiss(_ panGesture: UIPanGestureRecognizer)
}

extension PanToDismissProtocol {
  public func observePanToDismiss(view: UIView) {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanToDismiss(_:)))
    view.addGestureRecognizer(panGesture)
  }
  
  public func evaluatePanToDismiss(panGesture: UIPanGestureRecognizer, dimissCompletion: @escaping VoidCompletion) {
    guard let view = panGesture.view else { return }
    let translation = panGesture.translation(in: view)
    
    if panGesture.state == .began {
      view.transform = .init(translationX: 0.0, y: 0.0)
    } else if panGesture.state == .changed {
      view.transform = .init(translationX: translation.x, y: translation.y)
    } else if panGesture.state == .ended {
      let velocity = panGesture.velocity(in: view)
      let absVelocityX = abs(velocity.x)
      let absVelocityY = abs(velocity.y)
      if absVelocityX >= 1500 || absVelocityY >= 1500 {
        var translationX: CGFloat = 0
        if translation.x < 0 {
          translationX = -(abs(translation.x) + min(absVelocityX, 1000.0))
        } else {
          translationX = abs(translation.x) +  min(absVelocityX, 1000.0)
        }
        var translationY: CGFloat = 0
        if translation.y < 0 {
          translationY = -(abs(translation.y) +  min(absVelocityY, 1000.0))
        } else {
          translationY = abs(translation.y) +  min(absVelocityY, 1000.0)
        }
        UIView.animate(withDuration: 0.3, animations: {
          view.transform = .init(translationX: translationX, y: translationY)
        }, completion: { (_) in
          dimissCompletion()
        })
      } else {
        UIView.animate(withDuration: 0.3) {
          view.transform = .init(translationX: 0.0, y: 0.0)
        }
      }
    }
  }
}

public protocol ActivityIndicatorProtocol: class {
  var activityIndicatorView: UIActivityIndicatorView? { get set }
}

extension ActivityIndicatorProtocol {
  public func showActivityOnView(_ view: UIView) {
    if activityIndicatorView == nil {
      let activityIndicatorView = UIActivityIndicatorView(style: .white)
      activityIndicatorView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
      activityIndicatorView.hidesWhenStopped = true
      self.activityIndicatorView = activityIndicatorView
      view.addSubview(self.activityIndicatorView!)
      self.activityIndicatorView?.addContainerBoundsResizingMask(view)
    }
    activityIndicatorView?.startAnimating()
  }
  
  public func hideActivity() {
    activityIndicatorView?.stopAnimating()
  }
}

public enum ErrorIndicatorPosition {
  case topLeft(offset: CGSize)
  case bottomLeft(offset: CGSize)
}

public protocol ErrorIndicatorAppearanceProtocol {
  var font: UIFont { get }
  var color: UIColor { get }
  var position: ErrorIndicatorPosition { get }
}

public protocol ErrorIndicatorViewProtocol {
  var errorAppearance: ErrorIndicatorAppearanceProtocol { get }
  var errorContainerView: UIView { get }
  var errorDescription: String? { get }
}

extension ErrorIndicatorViewProtocol {
  public func showErrorIndicator() {
    if let errorLabel = errorContainerView.viewWithTag(35505) as? UILabel {
      errorLabel.isHidden = false
      errorLabel.font = errorAppearance.font
      errorLabel.textColor = errorAppearance.color
      errorLabel.text = errorDescription
      errorContainerView.clipsToBounds = false
    } else {
      let errorLabel = UILabel(frame: .zero)
      errorLabel.tag = 35505
      errorLabel.font = errorAppearance.font
      errorLabel.textColor = errorAppearance.color
      errorLabel.text = errorDescription
      errorContainerView.clipsToBounds = false
      errorContainerView.addSubview(errorLabel)
      let offsetHeight = errorLabel.getContentHeight(errorContainerView.bounds.width)
      errorLabel.translatesAutoresizingMaskIntoConstraints = false
      switch errorAppearance.position {
      case .topLeft(let offset):
        NSLayoutConstraint(
          item: errorLabel,
          attribute: .leading,
          relatedBy: .equal,
          toItem: errorContainerView,
          attribute: .leading,
          multiplier: 1.0,
          constant: offset.width).isActive = true
        NSLayoutConstraint(
          item: errorLabel,
          attribute: .top,
          relatedBy: .equal,
          toItem: errorContainerView,
          attribute: .top,
          multiplier: 1.0,
          constant: -(offsetHeight + offset.height)).isActive = true
      case .bottomLeft(let offset):
        NSLayoutConstraint(
          item: errorLabel,
          attribute: .leading,
          relatedBy: .equal,
          toItem: errorContainerView,
          attribute: .leading,
          multiplier: 1.0,
          constant: offset.width).isActive = true
        NSLayoutConstraint(
          item: errorLabel,
          attribute: .bottom,
          relatedBy: .equal,
          toItem: errorContainerView,
          attribute: .bottom,
          multiplier: 1.0,
          constant: offsetHeight + offset.height).isActive = true
      }
    }
  }
  
  public func hideErrorIndicator() {
    guard let errorLabel = errorContainerView.viewWithTag(35505) as? UILabel else { return }
    errorLabel.isHidden = true
  }
}

public protocol BadgeAppearanceProtoocol  {
  var font: UIFont { get }
  var textColor: UIColor { get }
  var backgroundColor: UIColor { get }
}

extension BadgeAppearanceProtoocol {
  public var font: UIFont {
    return .systemFont(ofSize: 10.0)
  }
  public var textColor: UIColor {
    return .white
  }
  public var backgroundColor: UIColor {
    return .red
  }
}

/// Allows access to create badge
public protocol BadgeableProtocol {
  var badgeAppearance: BadgeAppearanceProtoocol { get }
  var badgeContainer: UIView? { get }
  
  func setBadge(_ badge: String?)
}

private final class BadgeLabel: UILabel {
  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets(top: 0, left: 2.0, bottom: 0, right: 2.0)
    super.drawText(in: rect.inset(by: insets))
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    layer.cornerRadius = bounds.width/2
    layer.masksToBounds = true
  }
  
  override var intrinsicContentSize: CGSize {
    var size = super.intrinsicContentSize
    size.width += 4.0
    size.height += 4.0
    return size
  }
}

extension BadgeableProtocol {
  public func setBadge(_ badge: String?) {
    renderBadge(badge)
  }
  
  public func renderBadge(_ badge: String?) {
    guard let badgeContainer = badgeContainer else { return }
    badgeContainer.clipsToBounds = false
    if let badgeLabel = badgeContainer.viewWithTag(44835) as? BadgeLabel {
      badgeLabel.isHidden = badge == nil
      badgeLabel.font = badgeAppearance.font
      badgeLabel.textColor = badgeAppearance.textColor
      badgeLabel.backgroundColor = badgeAppearance.backgroundColor
      badgeLabel.textAlignment = .center
      badgeLabel.text = badge
      badgeContainer.bringSubviewToFront(badgeLabel)
    } else {
      let badgeLabel = BadgeLabel(frame: .zero)
      badgeLabel.tag = 44835
      badgeLabel.isHidden = badge == nil
      badgeLabel.font = badgeAppearance.font
      badgeLabel.textColor = badgeAppearance.textColor
      badgeLabel.backgroundColor = badgeAppearance.backgroundColor
      badgeLabel.textAlignment = .center
      badgeLabel.text = badge
      badgeContainer.addSubview(badgeLabel)
      badgeLabel.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint(
        item: badgeLabel,
        attribute: .height,
        relatedBy: .equal,
        toItem: badgeLabel,
        attribute: .width,
        multiplier: 1.0, constant: 1.0).isActive = true
      NSLayoutConstraint(
        item: badgeLabel,
        attribute: .trailing,
        relatedBy: .equal,
        toItem: badgeContainer,
        attribute: .trailing,
        multiplier: 1.0,
        constant: 0.0).isActive = true
      NSLayoutConstraint(
        item: badgeLabel,
        attribute: .top,
        relatedBy: .equal,
        toItem: badgeContainer,
        attribute: .top,
        multiplier: 1.0,
        constant: 0.0).isActive = true
      badgeContainer.bringSubviewToFront(badgeLabel)
    }
  }
}
