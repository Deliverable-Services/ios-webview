//
//  SAGraphStatsView.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 12/13/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import SwiftyJSON

public final class SAGraphStatsView: UIView {
  @IBOutlet private weak var view: UIView!
  @IBOutlet private weak var gradientLevelView: DesignableView! {
    didSet {
      gradientLevelView.cornerRadius = 4.0
    }
  }
  @IBOutlet private weak var levelStack: UIStackView!
  @IBOutlet private weak var graphView: UIView!
  @IBOutlet private weak var noticeLabel: UILabel! {
    didSet {
      noticeLabel.font = .openSans(style: .regular(size: 13.0))
      noticeLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var durationStack: UIStackView!
  
  public var type: SAStatViewByType = .monthly {
    didSet {
      updateDuration()
    }
  }
  public var periods: JSON? {
    didSet {
      updatePeriods()
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
  
  public override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    gradientLevelView.insertGradient(colors: [.greenishTeal, .butterscotch, .lightishRed], locations: [0.0, 0.5, 1.0])
    updatePeriods()
  }
  
  private func commonInit() {
    loadNib(SAGraphStatsView.self)
    addSubview(view)
    view.addSideConstraintsWithContainer()
    
    setup()
  }
  
  private func setup() {
    levelStack.removeAllArrangedSubviews()
    let levels: [String] = ["0", "10", "20", "30", "40", "50", "60", "70", "80", "90", "100"]
    levels.forEach { (level) in
      let levelLabel = UILabel()
      levelLabel.font = .openSans(style: .regular(size: 10.0))
      levelLabel.textAlignment = .right
      levelLabel.textColor = .gunmetal
      levelLabel.text = level
      levelLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
      levelLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
      levelLabel.setContentCompressionResistancePriority(.required, for: .vertical)
      levelStack.addArrangedSubview(levelLabel)
    }
  }
  
  private func updateDuration() {
    durationStack.removeAllArrangedSubviews()
    let durations: [String]
    switch type {
    case .monthly:
      durations = ["0", "4", "8", "12", "16", "20", "24", "28"]
    case .yearly:
      durations = ["JAN", "FEB", "MAR", "APR", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    }
    durations.enumerated().forEach { (indx, duration) in
      let durationLabel = UILabel()
      durationLabel.font = .openSans(style: .semiBold(size: 10))
      durationLabel.textAlignment = .left
      durationLabel.textColor = .gunmetal
      durationLabel.text = duration
      durationLabel.tag = indx + 1
      durationLabel.setContentCompressionResistancePriority(.required, for: .vertical)
      durationStack.addArrangedSubview(durationLabel)
    }
  }
  
  private func updatePeriods() {
    let graphSize = graphView.bounds.size
    let dotSize = CGSize(width: 8.0, height: 8.0)
    graphView.layer.sublayers?.removeAll()
    let verticalLineLayer = CAShapeLayer()
    verticalLineLayer.lineWidth = 1.0
    verticalLineLayer.strokeColor = UIColor.whiteThree.cgColor
    let verticalLinePath = CGMutablePath()
    verticalLinePath.addLines(between: [CGPoint.zero, CGPoint(x: 0.0, y: graphSize.height)])
    verticalLineLayer.path = verticalLinePath
    graphView.layer.addSublayer(verticalLineLayer)
    let horizontalLayer = CAShapeLayer()
    horizontalLayer.lineWidth = 1.0
    horizontalLayer.strokeColor = UIColor.whiteThree.cgColor
    let horizontalLinePath = CGMutablePath()
    horizontalLinePath.addLines(between: [CGPoint(x: 0.0, y: graphSize.height), CGPoint(x: graphSize.width, y: graphSize.height)])
    horizontalLayer.path = horizontalLinePath
    graphView.layer.addSublayer(horizontalLayer)
    if let periods = periods {
      noticeLabel.isHidden = true
      switch type {
      case .monthly:
        var prevPoint: CGPoint?
        periods.forEach { (dict) in
          let width = graphSize.width/32.0
          let dayInt = dict.0.toNumber().intValue
          let value = dict.1.intValue
          let y = graphSize.height/100 * CGFloat(value)
          let x = (width * CGFloat(dayInt))
          let targetPoint = CGPoint(x: x, y: y)
          let dotPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: targetPoint.x - 4, y: targetPoint.y - 4.0), size: dotSize))
          let dotLayer = CAShapeLayer()
          dotLayer.path = dotPath.cgPath
          dotLayer.strokeColor = UIColor.greyblue.cgColor
          dotLayer.fillColor = UIColor.greyblue.cgColor
          graphView.layer.addSublayer(dotLayer)
          if let prevPoint = prevPoint {
            let linePointLayer = CAShapeLayer()
            linePointLayer.lineWidth = 1.0
            linePointLayer.strokeColor = UIColor.greyblue.cgColor
            let linePointPath = CGMutablePath()
            linePointPath.addLines(between: [prevPoint, targetPoint])
            linePointLayer.path = linePointPath
            graphView.layer.addSublayer(linePointLayer)
          }
          prevPoint = targetPoint
        }
      case .yearly:
        var prevPoint: CGPoint?
        periods.forEach { (dict) in
          let yearInt = dict.0.toNumber().intValue
          let value = dict.1.intValue
          let y = graphSize.height/100 * CGFloat(value)
          let x = graphSize.width/12.0 * CGFloat(yearInt - 1)
          let targetPoint = CGPoint(x: x, y: y)
          let dotPath = UIBezierPath(ovalIn: CGRect(origin: CGPoint(x: targetPoint.x - 4.0, y: targetPoint.y - 4.0), size: dotSize))
          let dotLayer = CAShapeLayer()
          dotLayer.path = dotPath.cgPath
          dotLayer.strokeColor = UIColor.greyblue.cgColor
          dotLayer.fillColor = UIColor.greyblue.cgColor
          graphView.layer.addSublayer(dotLayer)
          if let prevPoint = prevPoint {
            let linePointLayer = CAShapeLayer()
            linePointLayer.lineWidth = 1.0
            linePointLayer.strokeColor = UIColor.greyblue.cgColor
            let linePointPath = CGMutablePath()
            linePointPath.addLines(between: [prevPoint, targetPoint])
            linePointLayer.path = linePointPath
            graphView.layer.addSublayer(linePointLayer)
          }
          prevPoint = targetPoint
        }
      }
    } else {
      noticeLabel.isHidden = false
    }
  }
}
