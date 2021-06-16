//
//  ScannerViewController.swift
//
//  Created by Patricia Cesar on 09/03/2018.
//  Copyright © 2018 Patricia Cesar. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerViewController: UIViewController {
  @IBOutlet weak var qrScopeImageView: UIImageView!
  
  var metaDataOutputBlock: ((String?) -> (Void))?
  var willDisappear: (() -> (Void))?
  var willAppear: (() -> (Void))?
  
  private var captureSession = AVCaptureSession()
  private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
  private lazy var qrCodeFrameView: DesignableView = {
    let qrCodeFrameView = DesignableView(frame: .zero)
    qrCodeFrameView.borderColor = UIColor.Porcelain.blueGrey
    qrCodeFrameView.borderWidth = 3.0
    qrCodeFrameView.cornerRadius = 0.0
    view.addSubview(qrCodeFrameView)
    view.bringSubview(toFront: qrCodeFrameView)
    return qrCodeFrameView
  }()
  private var captureMetadataOutput = AVCaptureMetadataOutput()
  
  func startCapture() {
    captureSession.startRunning()
  }
  
  func endCapture() {
    qrCodeFrameView.frame = .zero
    captureSession.stopRunning()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    intializeVideoCapture()
    
    NotificationCenter.default.addObserver(
    forName: .AVCaptureInputPortFormatDescriptionDidChange,
    object: nil,
    queue: .main) { [weak self] (notification) in
      guard let `self` = self else { return }
      guard let visibleRect = self.videoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: self.qrScopeImageView.frame) else { return }
      self.captureMetadataOutput.rectOfInterest = visibleRect
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    willAppear?()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    willDisappear?()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  private func intializeVideoCapture() {
    // Get the back-facing camera for capturing videos
    let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
      deviceTypes: [
        .builtInDualCamera,
        .builtInWideAngleCamera],
      mediaType: .video,
      position: .unspecified)
    
    guard let captureDevice = deviceDiscoverySession.devices.first else {
      print("Failed to get the camera device")
      return
    }

    do {
      // Get an instance of the AVCaptureDeviceInput class using the previous device object.
      let input = try AVCaptureDeviceInput(device: captureDevice)
      
      // Set the input device on the capture session.
      captureSession.addInput(input)
      
      // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
      captureSession.addOutput(captureMetadataOutput)
      
      // Set delegate and use the default dispatch queue to execute the call back
      captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
      captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
    } catch {
      // If any error occurs, simply print it out and don't continue any more.
      print(error)
    }
  }
  
  private func addVideoPreviewLayer() {
    // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
    videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    videoPreviewLayer?.videoGravity = .resizeAspectFill
    videoPreviewLayer?.frame = view.bounds
    view.layer.addSublayer(videoPreviewLayer!)
    view.bringSubview(toFront: qrScopeImageView)
  }
  
  override func didMove(toParentViewController parent: UIViewController?) {
    DispatchQueue.main.async {
      self.addVideoPreviewLayer()
    }
  }
}

// MARK: - ControllerConfigurable
extension ScannerViewController: ControllerConfigurable {
  static var segueIdentifier: String {
    fatalError("segueIdentifier not set")
  }
  
  func setupUI() {
  }
  
  func setupController() {
  }
  
  func setupObservers() {
  }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    // Check if the metadataObjects array is not nil and it contains at least one object.
    guard let metaDataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
      qrCodeFrameView.frame = CGRect.zero
      metaDataOutputBlock?(nil)
      return
    }
    if metaDataObj.type == AVMetadataObject.ObjectType.qr {
      // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
      let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metaDataObj)
      qrCodeFrameView.frame = barCodeObject?.bounds ?? .zero
      metaDataOutputBlock?(metaDataObj.stringValue)
    } else {
      qrCodeFrameView.frame = .zero
      metaDataOutputBlock?(nil)
    }
  }
}
