//
//  MyProductsViewController.swift
//  Porcelain
//
//  Created by Justine Rangel on 14/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import CenteredCollectionView
import KRProgressHUD

private struct Constants {
  static let barTitle = "MY PRODUCTS".localized()
}

public final class MyProductsViewController: UIViewController {
  @IBOutlet private weak var emptyView: UIView!
  @IBOutlet private weak var myProductsCollectionView: CenteredCustomCollectionView!
  @IBOutlet private weak var smartMirrorCustomLabel: UILabel!
  @IBOutlet private weak var smartMirrorButtonContainer: UIView!
  @IBOutlet private weak var smartMirrorButton: UIButton!
  
  public var isFromSmartMirror: Bool = false
  
  public var exitSmartMirrorDidTapped: VoidCompletion?
  
  private lazy var viewModel: MyProductsViewModelProtocol = MyProductsViewModel()
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  @objc
  public func reloadData() {
    viewModel.initializeContent()
  }
  
  @IBAction
  private func exitSmartMirrorTapped(_ sender: Any) {
    dismissViewController()
    exitSmartMirrorDidTapped?()
  }
}

extension MyProductsViewController: ControllerConfigurable, NavigationConfigurable {
  public static var segueIdentifier: String {
    return "showMyProducts"
  }
  
  public func setupUI() {
    title = Constants.barTitle
    view.backgroundColor = UIColor.Porcelain.mainBackground
    smartMirrorButtonContainer.isHidden = !isFromSmartMirror
    if isFromSmartMirror {
      smartMirrorButton.setAttributedTitle(NSAttributedString(
        content: "EXIT SMART MIRROR",
        font: UIFont.Porcelain.openSans(13.0, weight: .regular),
        foregroundColor: UIColor.Porcelain.greyishBrown,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 13.0,
          characterSpacing: 1.0)), for: .normal)
      smartMirrorCustomLabel.attributedText = NSAttributedString(
        content: "You haven’t purchased\nany product".localized(),
        font: UIFont.Porcelain.openSans(20.0, weight: .semiBold),
        foregroundColor: UIColor.Porcelain.warmGrey,
        paragraphStyle: ParagraphStyle.makeCustomStyle(
          lineHeight: 30.0,
          characterSpacing: 0.5, alignment: .center,
          lineBreakMode: .byWordWrapping))
    }
    smartMirrorCustomLabel.isHidden = true
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: isFromSmartMirror ? #imageLiteral(resourceName: "back-icon"): #imageLiteral(resourceName: "dashboard-icon"), selector: #selector(dismissViewController))
    generateRightNavigationButton(image: #imageLiteral(resourceName: "prodPres"), selector: #selector(MyProductsViewController.goToProductPrescriptionScreen))
    myProductsCollectionView.sidePadding = 39.0
    myProductsCollectionView.itemSpacing = 16.0
    myProductsCollectionView.dataSource = self
    myProductsCollectionView.delegate = self
    getChildController(MyEmptyProductsViewController.self)?.configure(viewModel: viewModel)
    viewModel.attachView(self)
    viewModel.initializeContent()
  }
  
  public func setupObservers() {
    AppNotificationCenter.default.addObserver(self, selector: #selector(reloadData), name: .didSync, object: nil)
  }
  
  @objc func goToProductPrescriptionScreen() {
    self.performSegue(withIdentifier: StoryboardIdentifier.toProductPrescription.rawValue, sender: nil)
  }
}

// MARK: - MyProductsView
extension MyProductsViewController: MyProductsView {
  public func reload() {
    viewModel.generateProducts()
    if viewModel.products.isEmpty {
      if isFromSmartMirror {
        myProductsCollectionView.isHidden = true
        smartMirrorCustomLabel.isHidden = false
      } else {
        title = nil
        myProductsCollectionView.isHidden = false
        smartMirrorCustomLabel.isHidden = true
        emptyView.isHidden = false
        setBarTranslucent()
        hideBarSeparator()
      }
    } else {
      title = Constants.barTitle
      myProductsCollectionView.isHidden = false
      smartMirrorCustomLabel.isHidden = true
      emptyView.isHidden = true
      setNavigationTheme(.white, showSeparator: true)
      showBarSeparator()
      myProductsCollectionView.reloadData()
    }
  }
  
  public func showLoading() {
    KRProgressHUD.showHUD()
  }
  
  public func hideLoading() {
    KRProgressHUD.hideHUD()
  }
  
  public func scrollToIndex(_ index: Int) {
    guard !myProductsCollectionView.isDragging else { return }
    myProductsCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
  }
  
  public func goToProducts() {
    guard let navigationController = UIApplication.shared.getTabbarController()?.goToTab(.shop) as? NavigationController else { return }
    navigationController.getChildController(PorcelainViewController.self)?.goToProducts()
    dismiss(animated: true)
  }
}

// MARK: - UICollectionViewDataSource
extension MyProductsViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.products.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let myProductsItemCell = collectionView.dequeueReusableCell(MyProductsItemCell.self, atIndexPath: indexPath)
    myProductsItemCell.configure(viewModel: viewModel.products[indexPath.row])
    myProductsItemCell.addAReviewDidTapped = { [weak self] (productID) in
      guard let `self` = self else { return }
      self.performSegue(withIdentifier: MakeReviewViewController.segueIdentifier, sender: productID)
    }
    return myProductsItemCell
  }
}

// MARK: - UICollectionViewDataSource
extension MyProductsViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyProductsViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(
      width: collectionView.bounds.width - (myProductsCollectionView.sidePadding * 2),
      height: collectionView.bounds.height - 48.0)
  }
}


private enum StoryboardIdentifier: String {
  case toProductPrescription = "MyProductsToProductPrescription"
  case toMakeReview = "showMakeReview"
}

// MARK: - Segues

extension MyProductsViewController {
  override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = StoryboardIdentifier(rawValue: segue.identifier ?? "") else {
      return
    }
    var destinationVC: UIViewController? = segue.destination
    if let navigationVC = segue.destination as? UINavigationController {
      destinationVC = navigationVC.childViewControllers.first
    }
    
    switch identifier {
    case .toProductPrescription: break
    case .toMakeReview:
      if let myProductsViewController = segue.destination as? MakeReviewViewController {
          myProductsViewController.productID = sender as? String
      }
    }
   
  }
}


// MARK: - UIScrollViewDelegate
extension MyProductsViewController {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard scrollView.isDragging else { return }
    let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
    let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    let selectedItemIndex = myProductsCollectionView.indexPathForItem(at: visiblePoint)?.row
    if viewModel.selectedItemIndex != selectedItemIndex {
      viewModel.selectedItemIndex = selectedItemIndex
      if let index = selectedItemIndex, AppUserDefaults.mirrorRoom != nil {
        AppSocketManager.shared.productSelect(atIndex: index)
      }
    }
  }
}
