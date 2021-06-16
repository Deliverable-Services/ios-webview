//
//  SocialNetworkAuthView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 22/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit

public final class SocialNetworkAuthView: UIView {
  @IBOutlet private weak var topSubtitleLabel: UILabel! {
    didSet {
      topSubtitleLabel.font = .openSans(style: .regular(size: 13.0))
      topSubtitleLabel.textColor = .white
      topSubtitleLabel.text = "Or continue with a social account"
    }
  }
  @IBOutlet private weak var facebookSignInButton: FacebookSignInButton!
  @IBOutlet private weak var googleSignInButton: GoogleSignInButton!
  @IBOutlet private weak var versionLabel: UILabel! {
    didSet {
      versionLabel.font = .openSans(style: .regular(size: 12.0))
      versionLabel.textColor = .gunmetal
      versionLabel.text = "\(AppUserDefaults.isProduction ? "": "Staging ")Version \(AppMainInfo.version ?? "") (\(AppMainInfo.build ?? ""))"
    }
  }
  
  public var facebookSignInDidTapped: VoidCompletion?
  public var googleSignInDidTapped: VoidCompletion?
  
  @IBAction private func facebookSignInTapped(_ sender: Any) {
    facebookSignInDidTapped?()
  }
  
  @IBAction private func googleSignInTapped(_ sender: Any) {
    googleSignInDidTapped?()
  }
}

public final class FacebookSignInButton: DesignableControl {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .semiBold(size: 14.0))
      titleLabel.textColor = .white
    }
  }
  
  public var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    var appearance = ShadowAppearance.default
    appearance.fillColor = .lightNavyBlue
    addShadow(appearance: appearance)
  }
}

public final class GoogleSignInButton: DesignableControl {
  @IBOutlet private weak var titleLabel: UILabel! {
    didSet {
      titleLabel.font = .openSans(style: .semiBold(size: 14.0))
      titleLabel.textColor = .gunmetal
    }
  }
  
  public var title: String? {
    didSet {
      titleLabel.text = title
    }
  }
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    addShadow(appearance: .default)
  }
}

