//
//  BAAResizingCollectionView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 22/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class BAAResizingCollectionView: UICollectionView, ResizingContentSizePrototol {
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
    guard let resizingCollectionView = object as? BAAResizingCollectionView, resizingCollectionView == self, isKeyPathValid(keyPath: keyPath) else { return }
    guard resizingCollectionView.contentSize != resizingContentSize else { return }
    resizingContentSize = resizingCollectionView.contentSize
    invalidateIntrinsicContentSize()
  }
  
  deinit {
    unObserveContentSize()
  }
  
  public override var intrinsicContentSize: CGSize {
    return CGSize(width: bounds.width, height: resizingContentSize.height)
  }
}
