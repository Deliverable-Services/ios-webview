//
//  AppSocketManager.swift
//
//  Created by Patricia Cesar
//  Copyright © 2018 Patricia Cesar. All rights reserved.
//

import Foundation
import SocketIO
import R4pidKit

enum SocketEventListenerName: String {
  case clientJoin = "client-join"
}

// MARK: Emit events
enum SocketEventName: String {
  case join = "join"
  case clientLeave = "client-leave"
  case productSelect = "product-select"
  case teaOrder = "tea-order"
  case teaSelect = "tea-select"
  case treatmentSelect = "treatment-select"
  case viewTreatment = "view-treatment"
}

public final class AppSocketManager {
  public static let shared = AppSocketManager()
  private lazy var socketManager: SocketManager = {
    var urlComponents = URLComponents()
    urlComponents.scheme = AppSocketConstant.Request.scheme
    urlComponents.host = AppSocketConstant.Request.host
    urlComponents.port = AppSocketConstant.Request.port
    let socketManager = SocketManager(socketURL: urlComponents.url!, config: [.log(true), .compress])
    socketManager.reconnects = false
    return socketManager
  }()
  private lazy var socketClient: SocketIOClient = socketManager.defaultSocket
  private var roomConnectTimer: Timer?

  public var eventListenerBlock: ((SocketAnyEvent) -> ())?
  public var isEnabled: Bool = true
  public var isActive: Bool {
    return socketClient.status.active
  }
  
  public var room: String? {
    get {
      return R4pidDefaults.mirrorRoom
    }
    set {
      R4pidDefaults.mirrorRoom = newValue
    }
  }
  
  public var customerID: String? {
    return AppUserDefaults.customerID
  }
  
  private init() {
    socketClient.on(clientEvent: .connect) {data, ack in
      guard self.socketClient.status == .connected else { return }
      print("\n----------> DEBUG: Socket connected\n\n")
      NotificationCenter.default.post(name: .appSocketDidConnect, object: nil)
    }
    socketClient.on(clientEvent: .reconnect) { (data, ack) in
      print("\n----------> DEBUG: Socket reconnect\n\n")
    }
    socketClient.on(clientEvent: .reconnectAttempt) { (data, ack) in
      print("\n---> DEBUG: Socket attempting to reconnect\n\n")
    }
    socketClient.on(clientEvent: .error) { (data, ack) in
      print("\n---> DEBUG: Socket error\n\n")
      NotificationCenter.default.post(name: .appSocketDidEncounterError, object: (data as? [String])?.first)
    }
    socketClient.on(clientEvent: .disconnect) { (data, ack) in
      print("\n---> DEBUG: Socket disconnected\n\n")
      NotificationCenter.default.post(name: .appSocketDidDisconnect, object: nil)
    }
    socketClient.onAny { [weak self] (anyEvent) in
      guard let `self` = self else { return }
      guard let event = SocketEventListenerName(rawValue: anyEvent.event) else { return }
      switch event {
      case .clientJoin:
        self.roomConnectTimer?.invalidate()
        self.roomConnectTimer = nil
        NotificationCenter.default.post(name: .appSocketDidJoinRoom, object: nil)
      }
    }
  }
  
  private func emit(_ event: SocketEventName, data: [String: Any]) {
    socketClient.emit(event.rawValue, data)
  }
}

extension AppSocketManager {
  public func connect() {
    NotificationCenter.default.post(name: .appSocketWillConnect, object: nil)
    socketClient.connect()
  }
  
  public func disconnect() {
    room = nil
    socketClient.disconnect()
  }

  public func joinRoom() {
    guard let room = room, socketClient.status == .connected else { return }
    NotificationCenter.default.post(name: .appSocketWillJoinRoom, object: nil)
    emit(.join,
         data: [AppSocketConstant.Key.room: room,
             AppSocketConstant.Key.userID: customerID ?? "",
             AppSocketConstant.Key.type: "mobile"])
    
    roomConnectTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] (_) in
      guard let `self` = self else { return }
      appDelegate.hideLoading()
      appDelegate.showAlert(title: "Oops!", message: "Room cannot be reached.")
      self.disconnect()
    }
  }
  
  public func productSelect(atIndex index: Int) {
    guard let room = room, socketClient.status == .connected else { return }
    emit(
      .productSelect,
      data: [AppSocketConstant.Key.room: room,
             AppSocketConstant.Key.index: index])
  }

  public func teaSelect(atIndex index: Int) {
    guard let room = room, socketClient.status == .connected else { return }
    emit(
      .teaSelect,
      data: [AppSocketConstant.Key.room: room,
             AppSocketConstant.Key.index: index])
  }

  
  public func treatmentSelect(atIndex index: Int) {
    guard let room = room, socketClient.status == .connected else { return }
    emit(
      .treatmentSelect,
      data: [AppSocketConstant.Key.room: room,
             AppSocketConstant.Key.index: index])
  }

  public func viewTreatment(data: [String: Any]) {
    guard let room = room, socketClient.status == .connected else { return }
    emit(
      .viewTreatment,
      data: [AppSocketConstant.Key.room: room,
             AppSocketConstant.Key.data: data.jsonString])
  }

  public func teaOrder(atIndex index: Int) {
    guard let room = room, socketClient.status == .connected else { return }
    emit(
      .teaOrder,
      data: [AppSocketConstant.Key.room: room,
             AppSocketConstant.Key.index: index])
  }

  public func exitSmartMirror() {
    guard let room = room, socketClient.status == .connected else { return }
    socketClient.emit(SocketEventName.clientLeave.rawValue, room)
    disconnect()
  }
}

@objc
public protocol AppSocketManagerObserverProtocol {
  @objc func appSocketWillConnect()
  @objc func appSocketDidConnect()
  @objc func appSocketDidDisconnect()
  @objc func appSocketWillJoinRoom()
  @objc func appSocketDidJoinRoom()
  @objc func appSocketDidEncounterError(_ notification: Notification)
}

extension AppSocketManagerObserverProtocol {
  public func observeAppSocketManager() {
    NotificationCenter.default.addObserver(self, selector: #selector(appSocketWillConnect), name: .appSocketWillConnect, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(appSocketDidConnect), name: .appSocketDidConnect, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(appSocketDidDisconnect), name: .appSocketDidDisconnect, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(appSocketWillJoinRoom), name: .appSocketWillJoinRoom, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(appSocketDidJoinRoom), name: .appSocketDidJoinRoom, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(appSocketDidEncounterError(_:)), name: .appSocketDidEncounterError, object: nil)
  }
}

extension Notification.Name {
  fileprivate static let appSocketWillConnect = Notification.Name("appSocketWillConnect")
  fileprivate static let appSocketDidConnect = Notification.Name("appSocketDidConnect")
  fileprivate static let appSocketDidDisconnect = Notification.Name("appSocketDidDisconnect")
  fileprivate static let appSocketWillJoinRoom = Notification.Name("appSocketWillJoinRoom")
  fileprivate static let appSocketDidJoinRoom = Notification.Name("appSocketDidJoinRoom")
  fileprivate static let appSocketDidEncounterError = Notification.Name("appSocketDidEncounterError")
}

extension R4pidDefaultskey {
  fileprivate static let mirrorRoom = R4pidDefaultskey(value: "8605A8C45CF1F647E91C4729DF5D9274893918BF")
}

extension R4pidDefaults {
  fileprivate static var mirrorRoom: String? {
    get {
      return R4pidDefaults.shared[.mirrorRoom]?.string
    }
    set {
      R4pidDefaults.shared[.mirrorRoom] = .init(value: newValue)
    }
  }
}

extension Dictionary {
  var jsonString: String {
    let invalidJson = "Not a valid JSON"
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
      return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
    } catch {
      return invalidJson
    }
  }
  
  func printJson() {
    print(jsonString)
  }
}
