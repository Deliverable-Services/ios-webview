//
//  ResizingContentScrollView.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 28/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit

public typealias ResizingSizeCompletion = (CGSize) -> Void
public typealias ObserveKeyPath = String

extension ObserveKeyPath {
  public static var contentSize: ObserveKeyPath {
    return "contentSize"
  }
}

public protocol ResizingContentSizePrototol {
  var observeContentSizeUpdates: ResizingSizeCompletion? { get }
}

extension ResizingContentSizePrototol where Self: NSObject {
  public func observeContentSize(keyPath:  ObserveKeyPath = .contentSize, target: NSObject? = nil) {
    (target ?? self).addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
  }
  
  public func unObserveContentSize(keyPath:  ObserveKeyPath = .contentSize, target: NSObject? = nil) {
    (target ?? self).removeObserver(self, forKeyPath: keyPath, context: nil)
  }
  
  public func isKeyPathValid(keyPath: String?) -> Bool {
    return keyPath == .contentSize
  }
}

public final class ObservingContentScrollView: UIScrollView, ResizingContentSizePrototol {
  private var resizingContentSize: CGSize = .zero {
    didSet {
      observeContentSizeUpdates?(resizingContentSize)
    }
  }
  
  public var observeContentSizeUpdates: ResizingSizeCompletion?
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    observeContentSize()
  }
  
  public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    guard let observingContentScrollView = object as? ObservingContentScrollView, observingContentScrollView == self, isKeyPathValid(keyPath: keyPath) else { return }
    guard observingContentScrollView.contentSize != resizingContentSize else { return }
    resizingContentSize = observingContentScrollView.contentSize
  }
  
  deinit {
    unObserveContentSize()
  }
}
