//
//  MyTreatmentsViewController.swift
//  Porcelain
//
//  Created by Justine Rangel on 14/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import UPCarouselFlowLayout
import R4pidKit

private struct Constant {
  static let barTitle = "MY TREATMENTS".localized()
}

public class MyTreatmentsViewController: UIViewController {
  @IBOutlet fileprivate weak var myTreatmentsPreviewView: MyTreatmentsSegmentedView!
  @IBOutlet fileprivate weak var myTreatmentsCollectionView: UICollectionView!
  
  fileprivate var viewModel: MyTreatmentsViewModelProtocol!
  
  public func configure(viewModel: MyTreatmentsViewModelProtocol) {
    viewModel.attachView(self)
    self.viewModel = viewModel
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    //Testing start
    var treatments: [MyTreatmentsItemViewModel] = []
    treatments.append(MyTreatmentsItemViewModel(title: "Quintessential Facial",
                                            imageURL: nil,
                                            description: "\"The quick brown fox jumps over the lazy dog\" is an English-language pangram—a sentence that contains all of the letters of the alphabet. It is commonly used for touch-typing practice, testing typewriters and computer keyboards, displaying examples of fonts, and other applications involving text where the use of all letters in the alphabet is desired. Owing to its brevity and coherence, it has become widely known.",
                                            frequencyDescription: "\"The quick brown fox jumps over the lazy dog\" is an English-language pangram—a sentence that contains all of the letters of the alphabet. It is commonly used for touch-typing practice, testing typewriters and computer keyboards, displaying examples of fonts, and other applications involving text where the use of all letters in the alphabet is desired. Owing to its brevity and coherence, it has become widely known.",
                                            tipsDescription: "\"The quick brown fox jumps over the lazy dog\" is an English-language pangram—a sentence that contains all of the letters of the alphabet. It is commonly used for touch-typing practice, testing typewriters and computer keyboards, displaying examples of fonts, and other applications involving text where the use of all letters in the alphabet is desired. Owing to its brevity and coherence, it has become widely known."))
    treatments.append(MyTreatmentsItemViewModel(title: "Quintessential Facial 2",
                                            imageURL: nil,
                                            description: "\"The quick brown fox jumps over the lazy dog\" is an English-language pangram—a sentence that contains all of the letters of the alphabet. It is commonly used for touch-typing practice, testing typewriters and computer keyboards, displaying examples of fonts, and other applications involving text where the use of all letters in the alphabet is desired. Owing to its brevity and coherence, it has become widely known.",
                                            frequencyDescription: "The quick brown fox jumps over the lazy dog",
                                            tipsDescription: "\"The quick brown fox jumps over the lazy dog\" is an English-language pangram—a sentence that contains all of the letters of the alphabet. It is commonly used for touch-typing practice, testing typewriters and computer keyboards, displaying examples of fonts, and other applications involving text where the use of all letters in the alphabet is desired. Owing to its brevity and coherence, it has become widely known."))
    treatments.append(MyTreatmentsItemViewModel(title: "Quintessential Facial 3",
                                            imageURL: nil,
                                            description: "The quick brown fox jumps over the lazy dog",
                                            frequencyDescription: "The quick brown fox jumps over the lazy dog",
                                            tipsDescription: "The quick brown fox jumps over the lazy dog"))
    treatments = treatments + treatments + treatments
    let viewModel = MyTreatmentsViewModel(treatments: treatments)
    configure(viewModel: viewModel)
    myTreatmentsPreviewView.configure(viewModel: viewModel)
    //Testing end
    setup()
  }
  
  public override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    myTreatmentsCollectionView.collectionViewLayout.invalidateLayout()
  }
}

extension MyTreatmentsViewController: ControllerProtocol, NavigationProtocol {
  public static var segueIdentifier: String {
    return "showMyTreatments"
  }
  
  public func setupUI() {
    title = Constant.barTitle
    view.backgroundColor = UIColor.Porcelain.whiteFour
  }
  
  public func setupController() {
    generateLeftNavigationButton(image: #imageLiteral(resourceName: "dashboard-icon"), selector: #selector(dismissViewController))
    if let flowLayout = myTreatmentsCollectionView.collectionViewLayout as? UPCarouselFlowLayout {
      flowLayout.spacingMode = .overlap(visibleOffset: 100.0)
    }
    myTreatmentsCollectionView.dataSource = self
    myTreatmentsCollectionView.delegate = self

    performSegue(withIdentifier: MyEmptyTreatmentsViewController.segueIdentifier, sender: nil)
  }
  
  public func setupObservers() {
  }
}

// MARK: - MyTreatmentsView
extension MyTreatmentsViewController: MyTreatmentsView {
  public func scrollToIndex(_ index: Int) {
    guard !myTreatmentsCollectionView.isDragging else { return }
    myTreatmentsCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
    AppSocketManager.shared.treatmentSelect(atIndex: index)
  }
}

// MARK: - UICollectionViewDataSource
extension MyTreatmentsViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.treatments.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let myTreatmentsItemCell = collectionView.dequeueReusableCell(MyTreatmentsItemCell.self, atIndexPath: indexPath)
    myTreatmentsItemCell.configure(viewModel: viewModel.treatments[indexPath.row])
    return myTreatmentsItemCell
  }
}

// MARK: - UICollectionViewDataSource
extension MyTreatmentsViewController: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyTreatmentsViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: max(300.0, collectionView.bounds.width - (34.0 * 2)), height: collectionView.bounds.height - 66.0)
  }
}

extension MyTreatmentsViewController {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard scrollView.isDragging else { return }
    let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
    let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    let selectedItemIndex = myTreatmentsCollectionView.indexPathForItem(at: visiblePoint)?.row
    if viewModel.selectedItemIndex != selectedItemIndex {
      viewModel.selectedItemIndex = selectedItemIndex
      myTreatmentsPreviewView.updateSelectedIndex()
    }
  }
}

public protocol MyTreatmentsSegmentedViewModelProtocol {
  var selectedItemIndex: Int? { get set }
  var previewImagesURL: [String?] { get }
}

public class MyTreatmentsSegmentedView: UIView, Shadowable {
  public var shadowLayer: CAShapeLayer!
  
  @IBOutlet fileprivate weak var previewCollectionView: UICollectionView!
  
  fileprivate var viewModel: MyTreatmentsSegmentedViewModelProtocol!
  
  public func configure(viewModel: MyTreatmentsSegmentedViewModelProtocol) {
    self.viewModel = viewModel
    previewCollectionView.reloadData()
    DispatchQueue.main.async {
      self.updateSelectedIndex()
    }
  }
  
  public override func layoutSubviews() {
    super.layoutSubviews()
    
    addShadow()
  }
  
  public func updateSelectedIndex() {
    guard let selectedItemIndex = viewModel.selectedItemIndex else { return }
    previewCollectionView.selectItem(at: IndexPath(row: selectedItemIndex, section: 0), animated: true, scrollPosition: .centeredHorizontally)
  }
  
  public override func awakeFromNib() {
    super.awakeFromNib()
    
    previewCollectionView.dataSource = self
    previewCollectionView.delegate = self
  }
}

// MARK: - UICollectionViewDataSource
extension MyTreatmentsSegmentedView: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.previewImagesURL.count
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let myTreatmentsSegmentedPreviewCell = collectionView.dequeueReusableCell(MyTreatmentsSegmentedPreviewCell.self, atIndexPath: indexPath)
    myTreatmentsSegmentedPreviewCell.imageURL = viewModel.previewImagesURL[indexPath.row]
    return myTreatmentsSegmentedPreviewCell
  }
}

// MARK: - UICollectionViewDataSource
extension MyTreatmentsSegmentedView: UICollectionViewDelegate {
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    viewModel.selectedItemIndex = indexPath.row
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MyTreatmentsSegmentedView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return MyTreatmentsSegmentedPreviewCell.defaultSize
  }
}

public class MyTreatmentsSegmentedPreviewCell: UICollectionViewCell {
  @IBOutlet private weak var previewImageVIew: UIImageView!
  public var imageURL: String? {
    didSet {
      guard let imageURL = imageURL else {
        previewImageVIew.image = #imageLiteral(resourceName: "sample-porcelein")
        return
      }
      previewImageVIew.image = UIImage(data: try! Data(contentsOf: URL(string: imageURL)!))
    }
  }
  
  public override var isSelected: Bool {
    didSet {
      backgroundColor = isSelected ? UIColor.Porcelain.blueGrey: .white
    }
  }
}

extension MyTreatmentsSegmentedPreviewCell: CellProtocol {
  public static var defaultSize: CGSize {
    return CGSize(width: 48.0, height: 48.0)
  }
}
