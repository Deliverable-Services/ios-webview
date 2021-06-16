//
//  ScanQRViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 27/05/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import UIKit
import R4pidKit
import AVFoundation
import SwiftyJSON

public final class ScanQRViewController: UIViewController {
  private lazy var captureSession = AVCaptureSession()
  private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
  private lazy var metaDataOutput = AVCaptureMetadataOutput()
  private lazy var qrCodeFrameView: DesignableView = {
    let qrCodeFrameView = DesignableView()
    qrCodeFrameView.borderColor = .greyblue
    qrCodeFrameView.borderWidth = 3.0
    view.addSubview(qrCodeFrameView)
    qrCodeFrameView.isHidden = true
    return qrCodeFrameView
  }()
  private var captureSessionEnabled: Bool = false
  private var scanLock: Bool = false
  private var isLoading: Bool = false
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  public override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  
    initCaptureDeviceIfNeeded()
    startRunningIfPossible()
  }
  
  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    stopRunningIfPossible()
  }
  
  private func startRunningIfPossible() {
    guard captureSessionEnabled else { return }
    guard !captureSession.isRunning else { return }
    captureSession.startRunning()
  }
  
  private func stopRunningIfPossible() {
    guard captureSessionEnabled else { return }
    guard captureSession.isRunning else { return }
    captureSession.stopRunning()
  }
  
  private func initCaptureDeviceIfNeeded() {
    guard !captureSessionEnabled else { return }
    guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
      r4pidLog("Error getting capture device.")
      return
    }
    do {
      let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
      guard captureSession.canAddInput(videoInput) else {
        r4pidLog("Error adding video input on capture session.")
        return
      }
      captureSession.addInput(videoInput)
      guard captureSession.canAddOutput(metaDataOutput) else {
        r4pidLog("Error adding meta output on capture session.")
        return
      }
      captureSession.addOutput(metaDataOutput)
      metaDataOutput.setMetadataObjectsDelegate(self, queue: .main)
      metaDataOutput.metadataObjectTypes = [.qr]
      previewLayer.frame = view.layer.bounds
      previewLayer.videoGravity = .resizeAspectFill
      view.layer.addSublayer(previewLayer)
      captureSessionEnabled = true
    } catch {
      r4pidLog(error.localizedDescription)
    }
  }
}

// MARK: - NavigationProtocol
extension ScanQRViewController: NavigationProtocol {
}

// MARK: - SmartMirrorPresenterProtocol
extension ScanQRViewController: SmartMirrorPresenterProtocol {
}

// MARK: - LeaveAFeedbackPresenterProtocol
extension ScanQRViewController: LeaveAFeedbackPresenterProtocol {
}

// MARK: - LeaveAFeedbackFormPresenterProtocol
extension ScanQRViewController: LeaveAFeedbackFormPresenterProtocol {
}

// MARK: - ControllerProtocol
extension ScanQRViewController: ControllerProtocol {
  public static var segueIdentifier: String {
    fatalError("ScanQRViewController segueIdentifier not set")
  }
  
  public func setupUI() {
  }
  
  public func setupController() {
  }
  
  public func setupObservers() {
    observeAppSocketManager()
  }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScanQRViewController: AVCaptureMetadataOutputObjectsDelegate {
  public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    guard !scanLock else { return }
    guard !isLoading else { return }
    guard AppSocketManager.shared.isEnabled else { return }
    guard !AppSocketManager.shared.isActive else { return }
    guard let metadataObject = metadataObjects.first else { return }
    if let bounds = previewLayer.transformedMetadataObject(for: metadataObject)?.bounds {
      qrCodeFrameView.isHidden = false
      qrCodeFrameView.frame = bounds
    } else {
      qrCodeFrameView.isHidden = true
    }
    guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
    guard let link = readableObject.stringValue, !link.isEmpty else { return }
    AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {
    }
    evaluateLinkForRedirection(link: link)
  }
}

// MARK: - AppSocketManagerObserverProtocol
extension ScanQRViewController: AppSocketManagerObserverProtocol {
  public func appSocketWillConnect() {
    isLoading = true
    appDelegate.showLoading()
  }
  
  public func appSocketDidConnect() {
    isLoading = false
    appDelegate.hideLoading()
    AppSocketManager.shared.joinRoom()
  }
  
  public func appSocketDidDisconnect() {
    isLoading = false
    appDelegate.hideLoading()
    scanLock = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.qrCodeFrameView.isHidden = true
      self.scanLock = false
    }
  }
  
  public func appSocketWillJoinRoom() {
    isLoading = true
    appDelegate.showLoading()
  }
  
  public func appSocketDidJoinRoom() {
    isLoading = false
    appDelegate.hideLoading()
    showSmartMirror()
  }
  
  public func appSocketDidEncounterError(_ notification: Notification) {
    isLoading = false
    appDelegate.hideLoading()
    guard let error = notification.object as? String else { return }
    showAlert(title: "Oops!", message: error)
  }
}

// MARK: - URLRedirectionHandlerProtocol
extension ScanQRViewController: URLRedirectionHandlerProtocol {
  public func redirect(type: URLRedirectionType, url: URL?, link: String?) {
    scanLock = true
    switch type {
    case .feedback(let appointmentID):
      if let customerID = AppUserDefaults.customerID, let appointment = Appointment.getAppointment(id: appointmentID, customerID: customerID) {
        self.showLeaveAFeedback(type: .appointment(appointment))
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.qrCodeFrameView.isHidden = true
        self.scanLock = false
      }
    case .scan(let room):
      AppSocketManager.shared.room = room
      AppSocketManager.shared.connect()
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.qrCodeFrameView.isHidden = true
        self.scanLock = false
      }
    case .invalid(let error):
      let dialogHandler = DialogHandler()
      if let link = link ?? url?.absoluteString {
        dialogHandler.title = nil
        dialogHandler.message = link
      } else {
        dialogHandler.title = "Oops!"
        dialogHandler.message = "Invalid QR code: \(error)"
      }
      dialogHandler.actions = [.confirm(title: "GOT IT!")]
      dialogHandler.actionCompletion = { [weak self] (_, actionView) in
        guard let `self` = self else { return }
        actionView.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
          self.qrCodeFrameView.isHidden = true
          self.scanLock = false
        }
      }
      DialogViewController.load(handler: dialogHandler).show(in: self)
    }
  }
}
