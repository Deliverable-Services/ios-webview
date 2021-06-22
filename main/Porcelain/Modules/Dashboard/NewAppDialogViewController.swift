//
//  NewAppDialogViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/19/20.
//  Copyright © 2020 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

public final class NewAppDialogViewController: UIViewController {
  @IBOutlet private weak var containerView: DesignableView! {
    didSet {
      containerView.cornerRadius = 7.0
    }
  }
  @IBOutlet private weak var contentLabel: UILabel! {
    didSet {
      let attributedContent = NSMutableAttributedString(attributedString: NSAttributedString(
        content: "We’ve got a spanking new app ready for you.\n",
        font: UIFont.Porcelain.openSans(16.0, weight: .regular),
        foregroundColor: UIColor.Porcelain.metallicBlue,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 26.0,
          characterSpacing: 0.5,
          alignment: .center)))
      attributedContent.append(NSAttributedString(
        content: "Easier & faster. Download it now!",
        font: UIFont.Porcelain.openSans(16.0, weight: .regular),
        foregroundColor: UIColor(red: 132, green: 171, blue: 172),
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 26.0,
          characterSpacing: 0.5,
          alignment: .center)))
      contentLabel.attributedText = attributedContent
    }
  }
  @IBOutlet private weak var laterButton: DesignableButton! {
    didSet {
      laterButton.cornerRadius = 0
      laterButton.borderWidth = 1.0
      laterButton.borderColor = UIColor.Porcelain.metallicBlue
      laterButton.setAttributedTitle(NSAttributedString(
        content: "LATER",
        font: UIFont.Porcelain.idealSans(14.0, weight: .book),
        foregroundColor: UIColor.Porcelain.metallicBlue,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 0.0,
          characterSpacing: 1.0)), for: .normal)
    }
  }
  @IBOutlet private weak var downloadButton: DesignableButton! {
    didSet {
      downloadButton.cornerRadius = 0
      downloadButton.backgroundColor = UIColor.Porcelain.metallicBlue
      downloadButton.setAttributedTitle(NSAttributedString(
        content: "PROCEED",
        font: UIFont.Porcelain.idealSans(14.0, weight: .book),
        foregroundColor: .white,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 0.0,
          characterSpacing: 1.0)), for: .normal)
    }
  }
  
  
  @IBAction private func laterTapped(_ sender: Any) {
    dismissViewController()
  }
  
  @IBAction private func downloadTapped(_ sender: Any) {
    if let url = URL(string: "itms-apps://itunes.apple.com/app/apple-store/id1492655022?mt=8") {
      UIApplication.shared.open(url, options: [:]) { (_) in
      }
    }
    dismissViewController()
  }
}

// MARK: - ControllerConfigurable
extension NewAppDialogViewController: ControllerConfigurable {
  public static var segueIdentifier: String {
    fatalError("NewAppDialogViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
  }
  
  public func setupObservers() {
  }
}

extension NewAppDialogViewController {
  @discardableResult
  public static func show(in vc: UIViewController? = nil) -> NewAppDialogViewController {
    let newAppDialogViewController = UIStoryboard.get(.dashboard).getController(NewAppDialogViewController.self)
    let parent = vc ?? UIApplication.shared.getRootViewController()
    parent?.present(newAppDialogViewController, animated: true)
    return newAppDialogViewController
  }
}
