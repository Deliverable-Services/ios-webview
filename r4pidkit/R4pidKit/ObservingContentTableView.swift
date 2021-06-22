//
//  ObservingContentTableView.swift
//  R4pidKit
//
//  Created by Justine Angelo Rangel on 3/11/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit

public final class ObservingContentTableView: UITableView, ResizingContentSizePrototol  {
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
    guard let observingContentTableView = object as? ObservingContentTableView, observingContentTableView == self, isKeyPathValid(keyPath: keyPath) else { return }
    guard observingContentTableView.contentSize != resizingContentSize else { return }
    resizingContentSize = observingContentTableView.contentSize
  }
  
  deinit {
    unObserveContentSize()
  }
}
