//
//  PorcelainTests.swift
//  PorcelainTests
//
//  Created by Patricia Marie Cesar on 12/05/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import XCTest
@testable import Porcelain

class PorcelainTests: XCTestCase {
  var networkRequest: PorcelainNetworkRequest {
    let request = PorcelainNetworkRequest()
    return request
  }
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  private struct TestAPIRequest: PorcelainAPIRequest {
    var headers: [String : String]? = ["Content-type": "application/json"]
    var path: RequestPath = "/ca/validateQRCode/salarydeductionQRCode/123"
    var method: String = "GET"
    var parameters: Any?
    var queryParameters: [String: AnyObject]?
    var successCode: Int = 200
    
    func scheme() -> String? { return "http" }
    func host() -> String? { return "54.169.215.171" }
    func port() -> Int? { return nil }
  }
  
  /***************************************************/
  func testGETRequest() {
    let request = TestAPIRequest()
    let exp = expectation(description: "Status code: 200")
    request.startRequest({ (jsonArray) in
      exp.fulfill()
      print(jsonArray!)
    }) { (error, statusCode, data, response, errorMessage) in
      XCTFail(statusCode!.description)
    }
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  /***************************************************/
  func testPOSTRequestWithoutParam() {
    let exp = expectation(description: "")
    
    var request = TestAPIRequest()
    request.path = "/ca/validateQRCode/salarydeductionQRCode/123"
    request.method = "POST"
 
    request.startRequest({ (jsonArray) in
      print(jsonArray!)
      exp.fulfill()
    }) { (error, statusCode, data, response, errorMessage) in
      print(error ?? "")
      XCTFail(statusCode!.description)
    }
    waitForExpectations(timeout: 15, handler: nil)
  }
  
  /***************************************************/
  private struct ESportsTestRequest: PorcelainAPIRequest {
    var headers: [String : String]? = ["Authorization": "Token 9278cadf62902610a21cfecfc60b8eeb2c830e93"]
    var path: String = "/api/account-category"
    var method: String = "POST"
    var parameters: Any?
    var queryParameters: [String: AnyObject]?
    var successCode: Int = 201
    
    func host() -> String? {
      return "13.251.112.122"
    }
  }
  
  func testPOSTRequestWithParam() {
    let exp = expectation(description: "Status code: 200")
    var request = ESportsTestRequest()
    
    var parameters: [String: Any] = [:]
    parameters["category_name"] = "12345"
    request.parameters = parameters
    
    request.startRequest({ (jsonArray) in
      print(jsonArray ?? "")
      exp.fulfill()
    }) { (error, statusCode, data, response, errorMessage) in
      print(error ?? "")
      XCTFail(statusCode!.description)
    }
    waitForExpectations(timeout: 15, handler: nil)
  }
  
  /***************************************************/
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
