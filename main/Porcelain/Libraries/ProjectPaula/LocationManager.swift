//
//  LocationManager.swift
//  Porcelain
//
//  Created by Justine Angelo Rangel on 2/18/20.
//  Copyright © 2020 R4pid Inc. All rights reserved.
//

import Foundation
import CoreLocation

public enum LocationManagerDelegate {
  case didUpdateLocation
  case didFailWithError(error: Error)
  case didChangeAuthStatus(status: CLAuthorizationStatus)
}

public typealias LocationManagerCompletion = (LocationManagerDelegate) -> Void

public struct LocationManagerHander {
  let completion: LocationManagerCompletion
}

public final class LocationManager: NSObject {
  public static let shared = LocationManager()
  
  private var handlers: [LocationManagerHander] = []
  public var continouslyUpdating = false
  public var coordinate = CLLocationCoordinate2D()
  public var locationAuthStatus: CLAuthorizationStatus {
    return CLLocationManager.authorizationStatus()
  }
  
  private lazy var locationManager: CLLocationManager = {
    let locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestAlwaysAuthorization()
    return  locationManager
  }()
  
  private override init() {
    super.init()
  }
  
  public func startUpdatingLocation() {
    if CLLocationManager.significantLocationChangeMonitoringAvailable() {
      locationManager.startMonitoringSignificantLocationChanges()
    } else if CLLocationManager.locationServicesEnabled() {
      locationManager.startUpdatingLocation()
    }
  }
  
  public func addHandler(_ handler: LocationManagerHander) {
    handlers.append(handler)
    switch LocationManager.shared.locationAuthStatus {
    case .denied, .restricted, .notDetermined:
      handler.completion(.didChangeAuthStatus(status: LocationManager.shared.locationAuthStatus))
    default:
      handler.completion(.didUpdateLocation)
    }
  }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
  public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }
    coordinate = location.coordinate
    if continouslyUpdating {
      manager.stopUpdatingLocation()
    }
    handlers.forEach { (handler) in
      handler.completion(.didUpdateLocation)
    }
  }
  
  public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    handlers.forEach { (handler) in
      handler.completion(.didFailWithError(error: error))
    }
  }
  
  public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    handlers.forEach { (handler) in
      handler.completion(.didChangeAuthStatus(status: status))
    }
  }
}
