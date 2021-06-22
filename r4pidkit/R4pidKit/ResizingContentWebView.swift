//
//  ResizingContentWebView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/6/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import WebKit

open class ResizingContentWebView: WKWebView, ResizingContentSizePrototol {
  private var resizingContentSize: CGSize = .zero {
    didSet {
      observeContentSizeUpdates?(resizingContentSize)
    }
  }

  public var observeContentSizeUpdates: ResizingSizeCompletion?

  open override func awakeFromNib() {
    super.awakeFromNib()

    scrollView.alwaysBounceVertical = false
    observeContentSize(target: scrollView)
  }

  open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    guard let scrollView = object as? UIScrollView, scrollView == self.scrollView, isKeyPathValid(keyPath: keyPath) else { return }
    guard scrollView.contentSize != resizingContentSize else { return }
    resizingContentSize = scrollView.contentSize
    invalidateIntrinsicContentSize()
  }

  deinit {
    unObserveContentSize(target: scrollView)
  }

  open override var intrinsicContentSize: CGSize {
    return CGSize(width: bounds.width, height: resizingContentSize.height)
  }
}
