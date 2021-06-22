//
//  SkinQuizViewController.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 11/21/19.
//  Copyright © 2019 R4pid Inc. All rights reserved.
//

import Foundation
import UIKit
import R4pidKit
import WebKit

public final class SkinQuizViewController: UIViewController {
  @IBOutlet private weak var collectionView: UICollectionView! {
    didSet {
      collectionView.registerWithNib(SkinQuizQuestionCCell.self)
      collectionView.allowsSelection = false
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }
  @IBOutlet private weak var previousButton: UIButton! {
    didSet {
      previousButton.setAttributedTitle(
        UIImage.icChevronLeft.maskWithColor(.lightNavy).attributed.add(.baseline(offset: -2.0)).append(attrs: "  PREVIOUS".attributed.add([
          .color(.lightNavy),
          .font(.openSans(style: .semiBold(size: 12.0)))])),
        for: .normal)
      previousButton.setAttributedTitle(
        UIImage.icChevronLeft.maskWithColor(.bluishGrey).attributed.add(.baseline(offset: -2.0)).append(attrs: "  PREVIOUS".attributed.add([
          .color(.bluishGrey),
          .font(.openSans(style: .regular(size: 12.0)))])),
        for: .disabled)
    }
  }
  @IBOutlet private weak var pageLabel: UILabel! {
    didSet {
      pageLabel.font = .openSans(style: .semiBold(size: 10.0))
      pageLabel.textColor = .bluishGrey
    }
  }
  @IBOutlet private weak var pageControl: UIPageControl! {
    didSet {
      pageControl.pageIndicatorTintColor = .whiteThree
      pageControl.currentPageIndicatorTintColor = .lightNavy
      pageControl.numberOfPages = 4
    }
  }
  @IBOutlet private weak var nextButton: UIButton! {
    didSet {
      nextButton.setAttributedTitle("NEXT  ".attributed.add([
        .color(.lightNavy),
        .font(.openSans(style: .semiBold(size: 12.0)))]).append(
          attrs: UIImage.icChevronRight.maskWithColor(.lightNavy).attributed.add(.baseline(offset: -2.0))),
        for: .normal)
    }
  }
  @IBOutlet private weak var resultsContainerView: UIView!
  
  private var skinQuizResultsViewController: SkinQuizResultViewController? {
    return getChildController(SkinQuizResultViewController.self)
  }
  
  private var skinQuizResultViewController: SkinQuizResultViewController? {
    return getChildController(SkinQuizResultViewController.self)
  }
  
  fileprivate var firstLoadQuestionID: String? {
    didSet {
      viewModel.firstLoadQuestionID = firstLoadQuestionID
    }
  }
  private lazy var viewModel: SkinQuizViewModelProtocol = SkinQuizViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    guard let questions = viewModel.skinQuiz?.questions else { return }
    guard let indx = questions.enumerated().first(where: { $0.element.id == firstLoadQuestionID })?.offset else { return }
    DispatchQueue.main.async {
      self.collectionView.scrollToItem(at: IndexPath(item: indx, section: 0), at: .centeredHorizontally, animated: false)
    }
  }
  
  private func showResults(animated: Bool = true) {
    if animated {
      UIView.animate(withDuration: 0.3) {
        self.resultsContainerView.alpha = 1.0
        self.resultsContainerView.transform = .init(translationX: 0.0, y: 0.0)
      }
    } else {
      resultsContainerView.alpha = 0.0
      resultsContainerView.transform = .init(translationX: 0.0, y: 0.0)
    }
  }
  
  private func hideResults(animated: Bool = true) {
    if animated {
      UIView.animate(withDuration: 0.3) {
        self.resultsContainerView.alpha = 0.0
        self.resultsContainerView.transform = .init(translationX: 0.0, y: self.resultsContainerView.bounds.height)
      }
    } else {
      resultsContainerView.alpha = 0.0
      resultsContainerView.transform = .init(translationX: 0.0, y: resultsContainerView.bounds.height)
    }
  }
  
  @IBAction private func navigationTapped(_ sender: UIButton) {
    if sender == previousButton {
      viewModel.prevTapped()
    } else if sender == nextButton {
      viewModel.nextTapped()
    }
  }
}

// MARK: - NavigationProtocol
extension SkinQuizViewController: NavigationProtocol {
}

// MARK: - ControllerProtocol
extension SkinQuizViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("SkinQuizViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: .icLeftArrow, selector: #selector(popViewController))
    viewModel.attachView(self)
    viewModel.initialize()
  }
  
  public func setupObservers() {
    skinQuizResultViewController?.delegate = self
  }
}

// MARK: - SkinQuizView
extension SkinQuizViewController: SkinQuizView {
  public func reload() {
    pageControl.numberOfPages = viewModel.numberOfPages
    updateNavigation()
    collectionView.reloadData()
    if viewModel.isSkinQuizDone {
      showResults()
    } else {
      hideResults(animated: false)
    }
  }
  
  public func updateNavigation() {
    previousButton.isEnabled = viewModel.isPrevEnabled
    pageLabel.text = "\(viewModel.currentPage + 1) of \(viewModel.numberOfPages)"
    pageControl.currentPage = viewModel.currentPage
    if viewModel.displayPage >= viewModel.numberOfPages {
      if viewModel.isNextEnabled {
        nextButton.setAttributedTitle("SUBMIT  ".attributed.add([
          .color(.lightNavy),
          .font(.openSans(style: .semiBold(size: 12.0)))]).append(
            attrs: UIImage.icChevronRight.maskWithColor(.lightNavy).attributed.add(.baseline(offset: -2.0))),
          for: .normal)
      } else {
        nextButton.setAttributedTitle("SUBMIT  ".attributed.add([
          .color(.bluishGrey),
          .font(.openSans(style: .semiBold(size: 12.0)))]).append(
            attrs: UIImage.icChevronRight.maskWithColor(.bluishGrey).attributed.add(.baseline(offset: -2.0))),
          for: .normal)
      }
    } else {
      if viewModel.isNextEnabled {
        nextButton.setAttributedTitle("NEXT  ".attributed.add([
          .color(.lightNavy),
          .font(.openSans(style: .semiBold(size: 12.0)))]).append(
            attrs: UIImage.icChevronRight.maskWithColor(.lightNavy).attributed.add(.baseline(offset: -2.0))),
          for: .normal)
      } else {
        nextButton.setAttributedTitle("NEXT  ".attributed.add([
          .color(.bluishGrey),
          .font(.openSans(style: .semiBold(size: 12.0)))]).append(
            attrs: UIImage.icChevronRight.maskWithColor(.bluishGrey).attributed.add(.baseline(offset: -2.0))),
          for: .normal)
      }
    }
    collectionView.isScrollEnabled = viewModel.isNextEnabled
  }
  
  public func navigateToQuestion() {
    collectionView.scrollToItem(at: IndexPath(item: viewModel.currentPage, section: 0), at: .centeredHorizontally, animated: true)
  }
  
  public func showLoading() {
  }
  
  public func hideLoading() {
  }
  
  public func showError(message: String?) {
    showAlert(title: "Oops!", message: message)
  }
  
  public func showQuizResults() {
    showResults()
    skinQuizResultsViewController?.loadQuizResultIfNeeded()
  }
}

// MARK: - UICollectionViewDataSource
extension SkinQuizViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.skinQuiz?.questions?.count ?? 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let skinQuizQuestionCCell = collectionView.dequeueReusableCell(SkinQuizQuestionCCell.self, atIndexPath: indexPath)
    skinQuizQuestionCCell.modelDelegate = viewModel
    skinQuizQuestionCCell.skinQuizQuestion = viewModel.skinQuiz?.questions?[indexPath.row]
    return skinQuizQuestionCCell
  }
}

// MARK: - UICollectionViewDelegate
extension SkinQuizViewController: UICollectionViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    var pageFloat = scrollView.contentOffset.x/collectionView.bounds.width
    pageFloat.round(.toNearestOrAwayFromZero)
    let page = Int(pageFloat)
    guard pageControl.currentPage != page else { return }
    viewModel.currentPage = page
    updateNavigation()
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SkinQuizViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.bounds.size
  }
}

// MARK: - SkinQuizResultViewControllerDelegate
extension SkinQuizViewController: SkinQuizResultViewControllerDelegate {
  public func skinQuizResultRetakeDidTapped() {
    let dialogHandler = DialogHandler()
    dialogHandler.title = "Are you sure you want to retake quiz?"
    dialogHandler.message = "This will overwrite  your existing results."
    dialogHandler.actions = [.cancel(title: "Cancel"), .confirm(title: "Proceed")]
    dialogHandler.actionCompletion = { [weak self] (action, dialogView) in
      dialogView.dismiss()
      guard let `self` = self else { return }
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        if action.title == "Proceed" {
          self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
          self.viewModel.retakeTapped()
          self.hideResults()
        }
      }
    }
    DialogViewController.load(handler: dialogHandler).show(in: self)
  }
}

public protocol SkinQuizPresenterProtocol {
}

extension SkinQuizPresenterProtocol where Self: ControllerProtocol & UIViewController {
  public func showSkinQuiz(withQuestionID questionID: String? = nil, animated: Bool = true) {
    let skinQuizViewController = UIStoryboard.get(.projectPorcelain).getController(SkinQuizViewController.self)
    skinQuizViewController.firstLoadQuestionID = questionID
    navigationController?.pushViewController(skinQuizViewController, animated: animated)
  }
}
