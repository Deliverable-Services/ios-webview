//
//  QuestionnaireViewController.swift
//  Porcelain
//
//  Created by Patricia Marie Cesar on 01/06/2018.
//  Copyright © 2018 Patricia Marie Cesar. All rights reserved.
//

import Foundation
import UIKit
import KRProgressHUD

class QuestionnaireViewController: UIViewController {
  var questionnaireTypes: [QuestionTypes] = [.gender, .birthdate, .makeUpFrequency, .facialFrequency, .lastFacialTreatment]
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var dimView: UIView!
  
  let dateFormatter = DateFormatter()
  let locale = NSLocale.current
  var datePicker : UIDatePicker!
  let toolBar = UIToolbar()
  
  var counter  = 1
  
  var selectedDate: String? {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM dd, yyyy"
    let dateString: String = dateFormatter.string(from: self.datePicker.date)
    return dateString
  }
  
  var gender: Gender?
  var makeUpFrequency: MakeUpFrequency?
  var facialFrequency: FacialFrequency?
  var lastFacialTreatment: LastFacialTreatment?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.estimatedRowHeight = 200
    self.tableView.tableFooterView = UIView()
    self.dimView.frame = self.view.frame
    self.view.addSubview(self.dimView)
    self.createDatePicker()
    self.showDatePicker(false)
  }
}

/****************************************************************/

extension QuestionnaireViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return counter
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == self.questionnaireTypes.count {
      let backgroundColor = UIColor.Porcelain.gradientBlue[indexPath.row-1]
      let cell = tableView.dequeueReusableCell(withIdentifier: "NextCell")!
      cell.contentView.backgroundColor = backgroundColor
      let button = cell.viewWithTag(1) as! UIButton
      button.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
      return cell
    } else {
      let backgroundColor = UIColor.Porcelain.gradientBlue[indexPath.row]
      let sectionType = questionnaireTypes[indexPath.row]
      
      switch sectionType {
      case .birthdate:
        let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnairePickerCell.identifier) as! QuestionnairePickerCell
        cell.configure(buttonLabel: self.selectedDate, backgroundColor: backgroundColor)
        cell.pickerButtonClickedBlock = {
          self.showDatePicker(true)
          self.displayNextQuestion(fromRow: indexPath.row)
        }
        return cell
      case .gender:
        let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnaireGenderCell.identifier) as! QuestionnaireGenderCell
        cell.configure(backgroundColor: backgroundColor)
        cell.genderSelectedBlock = { gender in
          self.gender = gender
          self.displayNextQuestion(fromRow: indexPath.row)
        }
        return cell
      case .facialFrequency, .lastFacialTreatment, .makeUpFrequency:
        let cell = tableView.dequeueReusableCell(withIdentifier: QuestionnaireSelectionCell.identifier) as! QuestionnaireSelectionCell
        cell.configure(questionnaireItem: QuestionnaireItem(title: sectionType.questionTitle, selection: sectionType.selectionItems), backgroundColor: backgroundColor)
        cell.itemSelectedBlock = { index in
          if sectionType == .facialFrequency {
            self.facialFrequency = ((sectionType.selectionItems as? [String])?[index]).map { FacialFrequency(rawValue: $0) }!
          } else if sectionType == .lastFacialTreatment {
            self.lastFacialTreatment = ((sectionType.selectionItems as? [String])?[index]).map { LastFacialTreatment(rawValue: $0) }!
          } else if sectionType == .makeUpFrequency {
            self.makeUpFrequency = ((sectionType.selectionItems as? [String])?[index]).map { MakeUpFrequency(rawValue: $0) }!
          }
          self.displayNextQuestion(fromRow: indexPath.row)
        }
        return cell
      }
    }
  }
  
  func displayNextQuestion(fromRow row: Int) {
    if row == self.counter-1 && self.counter < self.questionnaireTypes.count + 1 {
      self.progressView.progress = Float(self.counter)/Float(self.questionnaireTypes.count)
      self.counter += 1
      self.tableView.insertRows(at: [IndexPath(row: self.counter-1, section: 0)], with: .bottom)
      self.tableView.scrollToRow(at: IndexPath(row: self.counter-1, section: 0), at: .top, animated: true)
    }
  }
  
  @objc func nextButtonClicked() {
    let networkRequest = PorcelainNetworkRequest()
    networkRequest.delegate = self
    networkRequest.sendSurveyInfo(self.constructParameters())
  }
  
  private func constructParameters() -> Any? {
    var parameters: [String: Any] = [:]
    parameters[PorcelainAPIConstant.Key.gender] = self.gender?.rawValue.lowercased()
    parameters[PorcelainAPIConstant.Key.birthdate] = self.selectedDate
    parameters[PorcelainAPIConstant.Key.makeUpFrequency] = self.makeUpFrequency?.rawValue.lowercased()
    parameters[PorcelainAPIConstant.Key.facialFrequency] = self.facialFrequency?.paramValue
    parameters[PorcelainAPIConstant.Key.lastFacialTreatment] = self.lastFacialTreatment?.paramValue
    parameters[PorcelainAPIConstant.Key.userID] = AppUserDefaults.userID
    return parameters
  }
  
  @objc func goToDashboard() {
    self.navigate(StoryboardIdentifier.toDashboard.rawValue)
  }
}

/****************************************************************/

extension QuestionnaireViewController: PorcelainNetworkRequestDelegateProtocol {
  func requestWillStart(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction) {
    KRProgressHUD.showHUD()
  }
  
  func requestDidFail(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction,
                      error: Error?, statusCode: Int?, errorMessage: String?) {
    print("Failed: ", error ?? "")
    print(statusCode.debugDescription)
    KRProgressHUD.hideHUD()
    self.goToDashboard()
  }
  
  func requestSuccessful(_ dataSource: PorcelainNetworkRequest, action: PorcelainNetworkRequestAction, result: Any?) {
    KRProgressHUD.hideHUD()
    self.goToDashboard()
  }
}

/****************************************************************/

extension QuestionnaireViewController {
  func createDatePicker() {
    // DatePicker
    let pickerHeight: CGFloat = 200.0
    self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: self.view.frame.size.height - pickerHeight, width: self.view.frame.size.width, height: pickerHeight))
    self.datePicker?.backgroundColor = UIColor.white
    self.datePicker?.datePickerMode = UIDatePickerMode.date
    
    var components = DateComponents()
    components.year = -100
    let minDate = Calendar.current.date(byAdding: components, to: Date())
    components.year = -18
    let maxDate = Calendar.current.date(byAdding: components, to: Date())
    
    self.datePicker.minimumDate = minDate
    self.datePicker.maximumDate = maxDate
    
    // ToolBar
    self.toolBar.barStyle = .default
    self.toolBar.isTranslucent = true
    self.toolBar.sizeToFit()
    let datePickerFrame = self.datePicker.frame
    self.toolBar.frame = CGRect(x: datePickerFrame.origin.x, y: datePickerFrame.origin.y - self.toolBar.frame.size.height, width: self.toolBar.frame.size.width, height: self.toolBar.frame.size.height)
    
    // Cancel and Done buttons in toolbar
    let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(datePickerDoneButtonClick))
    let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(datePickerCancelButtonClick))
    self.toolBar.setItems([cancelButton, spaceButton, doneButton], animated: true)
    self.toolBar.isUserInteractionEnabled = true
    
    self.view.addSubview(self.toolBar)
    self.view.addSubview(self.datePicker)
  }
  
  @objc func datePickerDoneButtonClick() {
    let dateFormatter1 = DateFormatter()
    dateFormatter1.dateStyle = .medium
    dateFormatter1.timeStyle = .none
    self.datePicker.resignFirstResponder()
    datePicker.isHidden = true
    self.toolBar.isHidden = true
    self.showDimView(false)
    
    UIView.animate(withDuration: 0.3) {
      self.tableView.reloadData()
    }
    
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  @objc func datePickerCancelButtonClick() {
    self.datePicker.isHidden = true
    self.toolBar.isHidden = true
    self.showDimView(false)
  }
  
  private func showDatePicker(_ show: Bool) {
    UIView.animate(withDuration: 0.3) {
      self.datePicker.isHidden = !show
      self.toolBar.isHidden = !show
      self.showDimView(show)
    }
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  private func showDimView(_ show: Bool) {
    self.dimView.isHidden = !show
    UIView.animate(withDuration: 0.1, animations: {
      self.dimView.backgroundColor = show ? UIColor.Porcelain.greyishBrown.withAlphaComponent(0.5): .clear
    })
    
    UIView.animate(withDuration: 0.1) {
      self.view.layoutIfNeeded()
    }
  }
}

/****************************************************************/

private enum StoryboardIdentifier: String {
  case toDashboard = "QuestionnaireToDashboard"
}
