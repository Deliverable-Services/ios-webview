//
//  ImageAttachmentCCell.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 03/06/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class ImageAttachmentCCell: UICollectionViewCell {
  @IBOutlet private weak var imageView: LoadingImageView! {
    didSet {
      imageView.contentMode = .scaleAspectFill
    }
  }
  @IBOutlet private weak var deleteButton: UIButton! {
    didSet {
      deleteButton.setImage(.icRemove, for: .normal)
    }
  }
  
  public var referenceView: UIImageView? {
    return imageView
  }
  
  public var isInteractive: Bool = true {
    didSet {
      deleteButton.isHidden = !isInteractive
    }
  }
  
  public var image: UIImage? {
    return imageView.image
  }
  
  public var data: AttachmentData? {
    didSet {
      if let image = data?.image {
        imageView.image = image
      } else {
        imageView.url = data?.imageURL
      }
    }
  }
  
  public var deleteDidTapped: VoidCompletion?
  
  @IBAction private func deleteTapped(_ sender: Any) {
    deleteDidTapped?()
  }
}

// MARK: - CellProtocol
extension ImageAttachmentCCell: CellProtocol {
  public static var defaultSize: CGSize {
    fatalError("ImageAttachmentCCell defaultSize not set")
  }
}
