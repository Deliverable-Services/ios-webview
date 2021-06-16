//
//  BAAInputView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 22/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import AlignedCollectionViewFlowLayout

private struct TextViewTitleAppearance: AttributedStringAppearanceProtocol {
  public var characterSpacing: Double? {
    return 0.5
  }
  public var alignment: NSTextAlignment?
  public var lineBreakMode: NSLineBreakMode?
  public var minimumLineHeight: CGFloat? {
    return 20.0
  }
  public var font: UIFont? = .openSans(style: .regular(size: 14.0))
  public var color: UIColor? = .gunmetal
}

public enum BAAInputType {
  case fieldSelection(activeTitle: String, inactiveTitle: String)
  case multiSelection(activeTitle: String, inactiveTitle: String)
  case textView(activeTitle: String, inactiveTitle: String)
  
  public var title: (activeTitle: String, inactiveTitle: String) {
    switch self {
    case .fieldSelection(let activeTitle, let inactiveTitle):
      return (activeTitle: activeTitle, inactiveTitle: inactiveTitle)
    case .multiSelection(let activeTitle, let inactiveTitle):
      return (activeTitle: activeTitle, inactiveTitle: inactiveTitle)
    case .textView(let activeTitle, let inactiveTitle):
      return (activeTitle: activeTitle, inactiveTitle: inactiveTitle)
    }
  }
  
  public var calloutImage: UIImage {
    switch self {
    case .fieldSelection:
      return UIImage.icChevronRight.maskWithColor(.gunmetal)
    case .multiSelection:
      return UIImage.icPlus.maskWithColor(.gunmetal)
    case .textView:
      return UIImage.icPencil.maskWithColor(.gunmetal)
    }
  }
}

public struct BAAMultiSelectionData {
  public var title: String?
  public var id: String?
}

@IBDesignable
public final class BAAInputView: UIView {
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet private weak var multiSelectionCollectionView: BAAResizingCollectionView! {
    didSet {
      if let alignedCollectionViewFlowLayout = multiSelectionCollectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout {
        alignedCollectionViewFlowLayout.horizontalAlignment = .left
        alignedCollectionViewFlowLayout.verticalAlignment = .center
      }
      multiSelectionCollectionView.setAutomaticDimension()
      multiSelectionCollectionView.registerWithNib(BAAMultiSelectionCell.self)
      multiSelectionCollectionView.dataSource = self
      multiSelectionCollectionView.delegate = self
    }
  }
  @IBOutlet private weak var textView: DesignableTextView! {
    didSet {
      textView.tintColor = .bluishGrey
      textView.typingAttributes = defaultTypingAttributes
      textView.delegate = self
    }
  }
  @IBOutlet private weak var calloutButton: UIButton!
  @IBOutlet private weak var separatorView: UIView! {
    didSet {
      separatorView.backgroundColor = .whiteThree
    }
  }
  
  private lazy var defaultTypingAttributes = NSAttributedString.createAttributesString([.appearance(TextViewTitleAppearance())])
  
  private lazy var toolbar: UIToolbar = {
    let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 48.0))
    toolbar.isTranslucent = true
    toolbar.barStyle = .default
    let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let done: UIBarButtonItem = UIBarButtonItem(title: "DONE", style: .done, target: self, action: #selector(doneTapped(_:)))
    toolbar.items = [flexSpace, done]
    toolbar.sizeToFit()
    return toolbar
  }()
  
  public var isWalkthrough: Bool = false {
    didSet {
      textView.textColor = .white
      titleLabel.textColor = .white
      calloutButton.setImage(type.calloutImage.maskWithColor(.white), for: .normal)
      separatorView.backgroundColor = .white
    }
  }
  
  public var didSelect: VoidCompletion?
  public var didUpdateContents: VoidCompletion?
  
  public var type: BAAInputType = .fieldSelection(activeTitle: "", inactiveTitle: "") {
    didSet {
      let text = self.text ?? ""
      if !text.isEmpty {
        setActive(animated: false)
      } else {
        setInactive(animated: false)
      }
      calloutButton.setImage(type.calloutImage, for: .normal)
    }
  }
  
  public var text: String? {
    get {
      return textView.text
    }
    set {
      textView.text = newValue ?? ""
      updateActivityStatus()
    }
  }
  
  public var multiSelectionContents: [BAAMultiSelectionData]? {
    didSet {
      if let multiSelectionContents = multiSelectionContents, !multiSelectionContents.isEmpty {
        textView.isHidden = true
        separatorView.isHidden = true
        multiSelectionCollectionView.isHidden = false
      } else {
        textView.isHidden = false
        separatorView.isHidden = false
        multiSelectionCollectionView.isHidden = true
      }
      updateActivityStatus()
      multiSelectionCollectionView.reloadData()
      multiSelectionCollectionView.collectionViewLayout.invalidateLayout()
    }
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    commonInit()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    commonInit()
  }
  
  private func commonInit() {
    loadNib(BAAInputView.self)
    addSubview(view)
    view.addContainerBoundsResizingMask()
  }
  
  private func updateActivityStatus() {
    let isTextEmpty = textView.text.isEmpty
    let isMultiselectionEmpty =  multiSelectionContents?.isEmpty ?? true
    if !isTextEmpty || !isMultiselectionEmpty {
      setActive(animated: false)
    } else {
      setInactive(animated: false)
    }
  }
  
  public override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    
    commonInit()
    type = .fieldSelection(activeTitle: "Active Title", inactiveTitle: "Inactive Title")
    text = "Value"
  }
  
  @objc
  private func doneTapped(_ sender: Any) {
  }
  
  @IBAction private func calloutTapped(_ sender: Any) {
    didSelect?()
    switch type {
    case .textView:
      textView.becomeFirstResponder()
    default: break
    }
  }
}

extension BAAInputView {
  private func setActive(animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.15, animations: {
        self.titleLabel.transform = .init(translationX: 0.0, y: -24.0)
      }, completion: { (_) in
        self.titleLabel.font = .openSans(style: .semiBold(size: 12.0))
        self.titleLabel.textColor = .gunmetal
        self.titleLabel.text = self.type.title.activeTitle
      })
    } else {
      titleLabel.transform = .init(translationX: 0.0, y: -24.0)
      titleLabel.font = .openSans(style: .semiBold(size: 12.0))
      titleLabel.textColor = .gunmetal
      titleLabel.text = type.title.activeTitle
    }
  }
  
  private func setInactive(animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.15, animations: {
        self.titleLabel.transform = .init(translationX: 0.0, y: 0.0)
      }, completion: { (_) in
        self.titleLabel.font = .openSans(style: .regular(size: 14.0))
        self.titleLabel.textColor = .bluishGrey
        self.titleLabel.text = self.type.title.inactiveTitle
      })
    } else {
      titleLabel.transform = .init(translationX: 0.0, y: 0.0)
      titleLabel.font = .openSans(style: .regular(size: 14.0))
      titleLabel.textColor = .bluishGrey
      titleLabel.text = type.title.inactiveTitle
    }
  }
}

// MARK: - UICollectionViewDataSource
extension BAAInputView: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return multiSelectionContents?.count ?? 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let baaMultiSelectionCell = collectionView.dequeueReusableCell(BAAMultiSelectionCell.self, atIndexPath: indexPath)
    baaMultiSelectionCell.data = multiSelectionContents?[indexPath.row]
    baaMultiSelectionCell.deleteDidTapped = { [weak self] (data) in
      guard let `self` = self else { return }
      guard let indx = self.multiSelectionContents?.enumerated().first(where: { $0.element.id == data.id })?.offset else { return }
      self.multiSelectionContents?.remove(at: indx)
      self.didUpdateContents?()
    }
    return baaMultiSelectionCell
  }
}

// MARK: - UICollectionViewDelegate
extension BAAInputView: UICollectionViewDelegate {
}

// MARK: - UITextFieldDelegate
extension BAAInputView: UITextViewDelegate {
  public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    if tag == 0 {
      didSelect?()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        self.tag = 0
      }
    }
    tag = 1
    switch type {
    case .textView:
      setActive(animated: true)
      return true
    default:
      return false
    }
  }
  
  public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
    switch type {
    case .textView:
      if textView.text.isEmpty {
        setInactive(animated: true)
      }
      return true
    default:
      return false
    }
  }
}
