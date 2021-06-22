//
//  Extensions.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 15/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
  public static var notch: CGFloat {
    return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
  }
  
  public static var hasNotch: Bool {
    return notch > 0
  }
}

extension UIStoryboard {
  public static func get(_ name: StoryboardName, bundle: Bundle? = nil) -> UIStoryboard {
    return UIStoryboard(name: name, bundle: bundle)
  }
}

extension String {
  public static var ymdhmsDateFormat: String {
    return "yyyy-MM-dd HH:mm:ss"
  }
  public static var ymdDateFormat: String {
    return "yyyy-MM-dd"
  }
}

extension CGRect {
  public func isVisibleOn(scrollView: UIScrollView) -> Bool {
    return intersects(CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size))
  }
}

extension UIColor {
  public convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
    let newRed = CGFloat(red)/255.0
    let newGreen = CGFloat(green)/255.0
    let newBlue = CGFloat(blue)/255.0
    
    self.init(red: newRed, green: newGreen, blue: newBlue, alpha: alpha)
  }
  
  public convenience init(hex: Int, alpha: CGFloat = 1.0) {
    self.init(red: (hex >> 16) & 0xff, green: (hex >> 8) & 0xff, blue: hex & 0xff, alpha: alpha)
  }
  
  public func toImage(withSize size: CGSize = CGSize(width: 1.0, height: 1.0)) -> UIImage {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    setFill()
    UIRectFill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
  }
}

extension UIFont {
  public func fontForTextStyle(_ style: TextStyle) -> UIFont {
    return UIFontMetrics(forTextStyle: style).scaledFont(for: self)
  }
  
  public convenience init?(name: String, textStyle: TextStyle) {
    self.init(name: name, size: UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle).pointSize)
  }
}

extension NSNumber {
  public func cleanNumber(minDigits: Int = 0, maxDigits: Int = 2) -> String? {
    let formatter = NumberFormatter()
    formatter.minimumFractionDigits = minDigits
    formatter.maximumFractionDigits = maxDigits
    formatter.numberStyle = .decimal
    return formatter.string(from: self)
  }
}

extension UIImage {
  public func maskWithColor(_ color: UIColor?) -> UIImage {
    guard let color = color else  { return self }
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    if let context = UIGraphicsGetCurrentContext() {
      let rect = CGRect(origin: .zero, size: size)
      
      color.setFill()
      self.draw(in: rect)
      
      context.setBlendMode(.sourceIn)
      context.fill(rect)
    }
    let resultImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
    UIGraphicsEndImageContext()
    return resultImage
  }
  
  public func resizeImage(newSize: CGSize) -> UIImage {
    guard self.size != newSize else { return self }
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
    self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
    UIGraphicsEndImageContext()
    return newImage
  }
  
  public func resizeImage(height: CGFloat) -> UIImage {
    guard self.size.height != height else { return self }
    var imageSize = self.size
    imageSize.width = height * imageSize.width / imageSize.height
    imageSize.height = height
    UIGraphicsBeginImageContextWithOptions(imageSize, false, 0.0);
    self.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
    UIGraphicsEndImageContext()
    return newImage
  }
  
  public var data: Data? {
    return pngData() ?? jpegData(compressionQuality: 1.0)
  }
}

extension UIView {
  public func addGradinent(colors: [UIColor], locations: [Double]) {
    let gradient = CAGradientLayer()
    gradient.frame = bounds
    gradient.colors = colors.map({ $0.cgColor })
    gradient.locations = locations.map({ NSNumber(value: $0) })
    layer.mask = gradient
  }
  
  
  public func insertGradient(colors: [UIColor], locations: [Double]) {
    let gradient = CAGradientLayer()
    gradient.frame = bounds
    gradient.colors = colors.map({ $0.cgColor })
    gradient.locations = locations.map({ NSNumber(value: $0) })
    layer.insertSublayer(gradient, at: 0)
  }
}

extension UIStackView {
  @discardableResult
  public func removeAllArrangedSubviews() -> [UIView] {
    let removedSubviews = arrangedSubviews.reduce([]) { (removedSubviews, subview) -> [UIView] in
      self.removeArrangedSubview(subview)
      NSLayoutConstraint.deactivate(subview.constraints)
      subview.removeFromSuperview()
      return removedSubviews + [subview]
    }
    return removedSubviews
  }
}

extension UIScrollView {
  /// scroll to top
  public func scrollToTop(_ animated: Bool = false) {
    if contentInset.top > 0 {
      setContentOffset(CGPoint(x: 0.0, y: -contentInset.top), animated: animated)
    } else {
      setContentOffset(.zero, animated: animated)
    }
  }
  
  /// scroll to bottom
  public func scrollToBottom(_ animated: Bool = false) {
    let y = contentSize.height - bounds.size.height
    if y > 0 {
      setContentOffset(CGPoint(x: 0, y: y), animated: animated)
    }
  }
}

extension UITextField {
  public func generateLeftView(_ view: UIView, padding: CGFloat = 0.0) {
    let containerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: max(44.0, view.frame.size.width + (2 * padding)), height: 44.0)))
    containerView.addSubview(view)
    view.addContainerBoundsResizingMask()
    leftView = containerView
    leftViewMode = .always
    sizeToFit()
  }
  
  public func generateRightView(_ view: UIView, padding: CGFloat = 0.0) {
    let containerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: max(44.0, view.frame.size.width + (2 * padding)), height: 44.0)))
    containerView.addSubview(view)
    view.addContainerBoundsResizingMask()
    leftView = containerView
    rightView = containerView
    rightViewMode = .always
    sizeToFit()
  }
  
  public func generateLeftImage(_ image: UIImage, padding: CGFloat = 8.0) {
    let imageView = UIImageView(image: image)
    imageView.contentMode = .center
    imageView.sizeToFit()
    let tap = UITapGestureRecognizer(target: self, action: #selector(forceBecomeFirstResponder(_:)))
    imageView.addGestureRecognizer(tap)
    imageView.isUserInteractionEnabled = true
    generateLeftView(imageView)
  }
  
  public func generateRightImage(_ image: UIImage, padding: CGFloat = 8.0) {
    let imageView = UIImageView(image: image)
    imageView.contentMode = .center
    imageView.sizeToFit()
    let tap = UITapGestureRecognizer(target: self, action: #selector(forceBecomeFirstResponder(_:)))
    imageView.addGestureRecognizer(tap)
    imageView.isUserInteractionEnabled = true
    generateRightView(imageView)
  }
  
  @objc private func forceBecomeFirstResponder(_ sender: UIGestureRecognizer) {
    becomeFirstResponder()
  }
}
