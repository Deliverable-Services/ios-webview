//
//  ResizingContentTableView.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 13/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit

open class ResizingContentTableView: UITableView, ResizingContentSizePrototol {
  private var resizingContentSize: CGSize = .zero {
    didSet {
      observeContentSizeUpdates?(resizingContentSize)
    }
  }

  public var observeContentSizeUpdates: ResizingSizeCompletion?

  open override func awakeFromNib() {
    super.awakeFromNib()

    alwaysBounceVertical = false
    observeContentSize()
  }

  open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    guard let resizingContentTableView = object as? ResizingContentTableView, resizingContentTableView == self, isKeyPathValid(keyPath: keyPath) else { return }
    guard resizingContentTableView.contentSize != resizingContentSize else { return }
    resizingContentSize = resizingContentTableView.contentSize
    invalidateIntrinsicContentSize()
  }

  deinit {
    unObserveContentSize()
  }

  open override var intrinsicContentSize: CGSize {
    return CGSize(width: bounds.width, height: resizingContentSize.height)
  }
}
