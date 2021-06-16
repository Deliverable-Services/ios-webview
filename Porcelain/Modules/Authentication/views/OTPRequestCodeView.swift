//
//  OTPRequestCodeView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 23/05/2019.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit



public enum OTPRequestAction {
  case `default`
  case start
  case failed
}

private struct AttributedTitleAppearance: AttributedStringAppearanceProtocol {
  var characterSpacing: Double? = 0.0
  var alignment: NSTextAlignment?
  var lineBreakMode: NSLineBreakMode?
  var minimumLineHeight: CGFloat?
  var font: UIFont? = .openSans(style: .semiBold(size: 15.0))
  var color: UIColor? = .white
}

public final class OTPRequestCodeView: UIView {
  @IBOutlet private weak var buttonStack: UIStackView!
  @IBOutlet private weak var resendButton: UIButton! {
    didSet {
      var appearance = AttributedTitleAppearance()
      appearance.color = .white
      resendButton.setAttributedTitle("Resend Code".attributed.add(.appearance(appearance)), for: .normal)
      appearance.color = UIColor.whiteThree.withAlphaComponent(0.7)
      resendButton.setAttributedTitle("Resend Code".attributed.add(.appearance(appearance)), for: .disabled)
    }
  }
  @IBOutlet private weak var subtitle: UILabel!
  
  public var resendDidTapped: VoidCompletion?
  
  private var timerCountDown: Int = 0
  private var timer: Timer?
  
  private var action: OTPRequestAction?
  
  public func setRequestAction(_ action: OTPRequestAction) {
    self.action = action
    switch action {
    case .default:
      isHidden = true
    case .start:
      isHidden = false
      subtitle.isHidden = false
      startCountDown(60)
    case .failed:
      isHidden = false
      subtitle.isHidden = true
      timer?.invalidate()
    }
  }
  
  
  private func startCountDown(_ count: Int) {
    timer?.invalidate()
    timerCountDown = count
    setCountDownTime(timerCountDown)
    resendButton.isEnabled = false
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] (timer) in
      guard let `self` = self else { return }
      self.timerCountDown -= 1
      self.setCountDownTime(self.timerCountDown)
      if self.timerCountDown <= 0 {
        self.timer?.invalidate()
        self.resendButton.isEnabled = true
        self.setRequestAction(.failed)
      }
    }
  }
  
  private func setCountDownTime(_ time: Int) {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.minute, .second]
    formatter.unitsStyle = .positional
    formatter.zeroFormattingBehavior = .pad
    guard let time = formatter.string(from: TimeInterval(time)) else { return }
    subtitle.text = "Request new code in \(time)"
  }
  
  @IBAction private func resendTapped(_ sender: Any) {
    resendDidTapped?()
  }
  
  public override var intrinsicContentSize: CGSize {
    return CGSize(width: bounds.width, height: buttonStack.bounds.height + 16.0)
  }
}
