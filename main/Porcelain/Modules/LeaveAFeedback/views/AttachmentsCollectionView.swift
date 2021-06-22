//
//  AttachmentsCollectionView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 31/07/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public struct AttachmentData {
  public var image: UIImage?
  public var imageURL: String?
}

private struct Constant {
  static let maxAttachmentSize: Int = 6
}

public struct AttachmentsCollectionConfig {
  public var isInteractive: Bool = true //can edit
  public var spacing: CGFloat = 8.0
  public var rowSize: Int = 3
}

public final class AttachmentsCollectionView: ResizingContentCollectionView, ActivityIndicatorProtocol {
  public var activityIndicatorView: UIActivityIndicatorView? {
    didSet {
      activityIndicatorView?.color = .lightNavy
      activityIndicatorView?.backgroundColor = .clear
    }
  }
  
  public var attachments: [AttachmentData] {
    get {
      return Array(internalAttachments.prefix(Constant.maxAttachmentSize))
    } set {
      internalAttachments = Array(newValue.prefix(Constant.maxAttachmentSize))
    }
  }
  
  public var images: [UIImage] {
    return visibleCells.compactMap({ $0 as? ImageAttachmentCCell }).compactMap({ $0.image })
  }
  
  private var internalAttachments: [AttachmentData] = [] {
    didSet {
      reloadData()
    }
  }
  
  private var cellSize: CGSize = CGSize(width: 72.0, height: 72.0) {
    didSet {
      reloadData()
    }
  }
  
  public var config: AttachmentsCollectionConfig = AttachmentsCollectionConfig()
  
  public var isLoading: Bool = false {
    didSet {
      if isLoading {
        showActivityOnView(self)
      } else {
        hideActivity()
      }
    }
  }
  
  public var addAttachmentDidTapped: VoidCompletion?
  public var attachmentDidTapped: ((UIView?, UIImage?) -> Void)?
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    registerWithNib(ImageUploadCCell.self)
    registerWithNib(ImageAttachmentCCell.self)
    if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
      layout.minimumLineSpacing = config.spacing
      layout.minimumLineSpacing = config.spacing
      if config.isInteractive {
        layout.itemSize = CGSize(width: 72.0, height: 72.0)
      } else {
        layout.itemSize = CGSize(width: 40.0, height: 40.0)
      }
    }
    dataSource = self
    delegate = self
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    let rowSizeFloat = CGFloat(config.rowSize)
    let size = max(48.0, (bounds.width - (config.spacing * (rowSizeFloat-1.0)))/(rowSizeFloat * 1.05))
    guard cellSize.width != size else { return }
    cellSize = CGSize(width: size, height: size)
  }
}

// MARK: - UICollectionViewDataSource
extension AttachmentsCollectionView: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if internalAttachments.count < Constant.maxAttachmentSize, config.isInteractive {
      return 1 + internalAttachments.count
    } else {
      return internalAttachments.count
    }
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if indexPath.row == 0, internalAttachments.count < Constant.maxAttachmentSize, config.isInteractive {
      let imageUploadCCell = collectionView.dequeueReusableCell(ImageUploadCCell.self, atIndexPath: indexPath)
      if internalAttachments.isEmpty {
        imageUploadCCell.type = .uploadTitle("Upload\nPhoto")
      } else {
        imageUploadCCell.type = .upload(current: internalAttachments.count, total: Constant.maxAttachmentSize)
      }
      return imageUploadCCell
    } else {
      let imageAttachmentCCell = collectionView.dequeueReusableCell(ImageAttachmentCCell.self, atIndexPath: indexPath)
      imageAttachmentCCell.isInteractive = config.isInteractive
      if internalAttachments.count < Constant.maxAttachmentSize, config.isInteractive {
        imageAttachmentCCell.data = internalAttachments[indexPath.row - 1]
      } else {
        imageAttachmentCCell.data = internalAttachments[indexPath.row]
      }
      imageAttachmentCCell.deleteDidTapped = { [weak self] in
        guard let `self` = self else { return }
        if self.internalAttachments.count < Constant.maxAttachmentSize, self.config.isInteractive {
          self.internalAttachments.remove(at: indexPath.row - 1)
        } else {
          self.internalAttachments.remove(at: indexPath.row)
        }
      }
      return imageAttachmentCCell
    }
  }
}

// MARK: - UICollectionViewDelegate
extension AttachmentsCollectionView: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.cellForItem(at: indexPath)?.addBounceAnimate()
    
    if internalAttachments.count < Constant.maxAttachmentSize, config.isInteractive {
      if indexPath.row == 0 {
        addAttachmentDidTapped?()
      } else {
        if let referenceView = (collectionView.cellForItem(at: indexPath) as? ImageAttachmentCCell)?.referenceView {
          attachmentDidTapped?(referenceView, referenceView.image)
        }
      }
    } else {
      if let referenceView = (collectionView.cellForItem(at: indexPath) as? ImageAttachmentCCell)?.referenceView {
        attachmentDidTapped?(referenceView, referenceView.image)
      }
    }
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension AttachmentsCollectionView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return cellSize
  }
}
