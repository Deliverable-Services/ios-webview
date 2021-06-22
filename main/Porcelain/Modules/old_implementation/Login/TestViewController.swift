//
//  TestViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 18/05/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit

class TestViewController: UIViewController {
  @IBAction func showCalendarButtonClicked(_ sender: Any) {
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
}

//extension TestViewController: WWCalendarTimeSelectorProtocol {
//  func showCalendar() {
//    let selector = WWCalendarTimeSelector.instantiate()
//    selector.delegate = self
//    /*
//     Any other options are to be set before presenting selector!
//     */
//    presentViewController(selector, animated: true, completion: nil)
//  }
//  
//  func WWCalendarTimeSelectorDone(selector: WWCalendarTimeSelector, date: NSDate) {
//    print(date)
//  }
//}
