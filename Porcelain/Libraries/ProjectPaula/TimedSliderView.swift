//
//  TimedSliderView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 24/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public protocol TimedSliderDataProtocol {
  var title: String? { get }
  var message: String? { get }
  var attributedString: NSAttributedString? { get }
  var readMoreData: Any? { get }
}

public struct TimedSliderData: TimedSliderDataProtocol {
  public var title: String?
  public var message: String?
  public var attributedString: NSAttributedString?
  public var readMoreData: Any?
}

public protocol TimedSliderViewModelProtocol {
  var timedSliderScrollTiming: TimeInterval? { get }
  var timedSliderContents: [TimedSliderDataProtocol] { get }
}

public final class TimedSliderView: UIView, ActivityIndicatorProtocol {
  public var activityIndicatorView: UIActivityIndicatorView? {
    didSet {
      activityIndicatorView?.color = .white
      activityIndicatorView?.backgroundColor = .clear
    }
  }
  
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var collectionView: UICollectionView! {
    didSet {
      collectionView.isPagingEnabled = true
      collectionView.registerWithNib(TimedSliderItemCell.self)
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  @IBOutlet private weak var pageControl: UIPageControl!
  private var scrollTimer: Timer?
  
  public var isLoading: Bool = false {
    didSet {
      if isLoading {
        showActivityOnView(self)
      } else {
        hideActivity()
      }
    }
  }
  
  public var didSelectContent: ((TimedSliderDataProtocol) -> Void)?
  public var didSelectRow: IntCompletion?
  
  public var viewModel: TimedSliderViewModelProtocol? {
    didSet {
      scrollTimer?.invalidate()
      contents = viewModel?.timedSliderContents
      scrollToPage(pageControl.currentPage, animated: false)
      guard let scrollTiming = viewModel?.timedSliderScrollTiming else { return }
      pageControl.tag = 0
      scrollTimer = Timer.scheduledTimer(withTimeInterval: scrollTiming, repeats: true) { [weak self] (_) in
        guard let `self` = self else { return }
        if self.pageControl.currentPage + 1 >= self.pageControl.numberOfPages {
          self.pageControl.currentPage = 0
        } else {
          self.pageControl.currentPage += 1
        }
        self.scrollToPage(self.pageControl.currentPage, animated: true)
      }
    }
  }
  
  private var contents: [TimedSliderDataProtocol]? {
    didSet {
      pageControl.numberOfPages = contents?.count ?? 0
      collectionView.reloadData()
    }
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    loadNib(TimedSliderView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
  }
  
  private func scrollToPage(_ page: Int, animated: Bool) {
    guard collectionView.numberOfItems(inSection: 0) > page else { return }
    if viewModel?.timedSliderScrollTiming != nil {
      pageControl.tag = 1 //disable change on page control when scrolling
    }
    collectionView.selectItem(
      at: IndexPath(item: page, section: 0),
      animated: animated,
      scrollPosition: .centeredHorizontally)
  }
  
  @IBAction private func valueChange(_ sender: Any) {
    scrollToPage(pageControl.currentPage, animated: true)
  }
}

// MARK: - UICollectionViewDataSource
extension TimedSliderView: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return contents?.count ?? 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let timedSliderItemCell = collectionView.dequeueReusableCell(TimedSliderItemCell.self, atIndexPath: indexPath)
    timedSliderItemCell.data = contents?[indexPath.row]
    return timedSliderItemCell
  }
}

// MARK: - UICollectionViewDelegate
extension TimedSliderView: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    didSelectRow?(indexPath.row)
    guard let content = contents?[indexPath.row] else { return }
    didSelectContent?(content)
  }
  
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard pageControl.tag == 0 else { return }
    var pageFloat = scrollView.contentOffset.x/collectionView.bounds.width
    pageFloat.round(.toNearestOrAwayFromZero)
    let page = Int(pageFloat)
    guard pageControl.currentPage != page else { return }
    pageControl.currentPage = page
  }
  
  public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    pageControl.tag = 0 //enable change on page control when scrolling
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TimedSliderView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.bounds.size
  }
}

private struct TimedSliderAttributedMessageAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double?
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat? {
    return 18.0
  }
  var font: UIFont? {
    return .openSans(style: .regular(size: 12.0))
  }
  var color: UIColor? {
    return .whiteTwo
  }
}

public final class TimedSliderItemCell: UICollectionViewCell {
  @IBOutlet private weak var contentLabel: UILabel!
  
  public var readMoreDidTapped: ((TimedSliderDataProtocol) -> ())?
  
  public var data: TimedSliderDataProtocol? {
    didSet {
      if let attributedString = data?.attributedString {
        let newAttributedString = NSMutableAttributedString(attributedString: attributedString)
        attributedString.enumerateAttribute(.paragraphStyle, in: NSRange(location: 0, length: attributedString.length), options: .longestEffectiveRangeNotRequired) { (paragraphStyle, range, _) in
          guard let paragraphStyle = paragraphStyle as? NSMutableParagraphStyle else { return }
          paragraphStyle.lineBreakMode = .byTruncatingTail
          newAttributedString.add(.paragraphStyle(paragraphStyle), range: range)
        }
        contentLabel.attributedText = newAttributedString
      } else {
        contentLabel.attributedText = nil
      }
    }
  }
}

// MARK: - CellProtocol
extension TimedSliderItemCell: CellProtocol {
}
