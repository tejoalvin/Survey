//
//  ResultViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 09/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit
import RealmSwift
import MessageUI

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var surveyNameLabel: UILabel!
    @IBOutlet weak var timeSurveyStarted: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var isFromResultTable : Bool!
    var surveyFinished : SurveyAnswered!
    
    let config = Realm.Configuration(
        schemaVersion: 1
    )
	var commentTextFields = [UITextField]()
	var saveButton : UIBarButtonItem!
	@IBOutlet weak var mainQLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
        tableView.delegate = self
        tableView.dataSource = self
        
        if isFromResultTable == false {
            let homeButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(self.homeButtonAction(_:)))
            navigationItem.setLeftBarButton(homeButton, animated: true)
            navigationItem.title = "Result"
        } else {
            let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.backButtonAction(_:)))
            navigationItem.setLeftBarButton(backButton, animated: true)
            navigationItem.title = surveyFinished.surveyName + " Result"
        }
        
        saveButton = UIBarButtonItem(title: "Save Comments", style:.plain, target: self, action: #selector(self.saveButtonAction(_:)))
        navigationItem.setRightBarButton(saveButton, animated: true)
		
		saveButton.isEnabled = false
		
        patientNameLabel.text = surveyFinished.patient!.patientsName
        surveyNameLabel.text = surveyFinished.surveyName
		
		mainQLabel.text = surveyFinished.question
		
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        
        timeSurveyStarted.text = dateFormatter.string(from: surveyFinished.dateStarted as Date)
        // Do any additional setup after loading the view.
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapToRemoveKeyboard(_:)))
		view.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    func homeButtonAction(_ sender:UIBarButtonItem){
        if presentingViewController is UINavigationController {
			self.performSegue(withIdentifier: "unwindToMain", sender: self)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
	
	@IBAction func exportTherapistReport(_ sender: UIButton) {
		let mailString = createCSVDataTherapist()
		
		// Converting it to NSData.
		let data = mailString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
		
		// Unwrapping the optional.
		if let content = data {
			print("NSData: \(content)")
		}
		
		let emailController = MFMailComposeViewController()
		emailController.mailComposeDelegate = self
		let subject = "Survey Report " + surveyFinished.patient!.patientsName + "-" + surveyFinished.surveyName + "-"
			+ timeSurveyStarted.text!
		emailController.setSubject(subject)
		emailController.setMessageBody("", isHTML: false)
		
		// Attaching the .CSV file to the email.
		let fileName = surveyFinished.patient!.patientsName + "-" + surveyFinished.surveyName + "-" + timeSurveyStarted.text! + ".csv"
		emailController.addAttachmentData(data!, mimeType: "text/csv", fileName: fileName)
		
		if MFMailComposeViewController.canSendMail() {
			self.present(emailController, animated: true, completion: nil)
		}

	}
	

	@IBAction func exportCSV(_ sender: UIButton) {

		let mailString = createCSVData()
		
        // Converting it to NSData.
        let data = mailString.data(using: String.Encoding.utf8.rawValue, allowLossyConversion: false)
		
        // Unwrapping the optional.
        if let content = data {
            print("NSData: \(content)")
        }
		
        let emailController = MFMailComposeViewController()
        emailController.mailComposeDelegate = self
		let subject = "Survey Report " + surveyFinished.patient!.patientsName + "-" + surveyFinished.surveyName + "-"
			+ timeSurveyStarted.text!
        emailController.setSubject(subject)
        emailController.setMessageBody("", isHTML: false)
        
        // Attaching the .CSV file to the email.
		let fileName = surveyFinished.patient!.patientsName + "-" + surveyFinished.surveyName + "-" + timeSurveyStarted.text! + ".csv"
        emailController.addAttachmentData(data!, mimeType: "text/csv", fileName: fileName)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(emailController, animated: true, completion: nil)
        }
    }

    
    func createCSVData() -> NSMutableString {
        let text = NSMutableString()
        text.append("Name," + surveyFinished.patient!.patientsName + "\n")
        text.append("Survey Name," + surveyFinished.surveyName + "\n")
        text.append("Time Started," + timeSurveyStarted.text! + "\n")
        text.append("\n\n")
        text.append("No.,Technology Name," + mainQLabel.text! + ",Confidence level (of 5),Comments\n")
		
		let qTotal = surveyFinished.devices.count
		
		for index in 0..<qTotal {
			let deviceName = surveyFinished.devices[index].value
			var mainQAnswer : String
			var confidentQAnswer : String
			var answerComments = ""
			
			if index > surveyFinished.mainAnswer.count-1{
				mainQAnswer = "N/A"
			} else {
				let mainAnswer = surveyFinished.mainAnswer[index]
				
				if mainAnswer.answer == true {
					mainQAnswer = "Yes"
				} else {
					mainQAnswer = "No"
				}
				
				answerComments = mainAnswer.comments
			}
			
			
			if index > surveyFinished.confidenceAnswer.count-1{
				confidentQAnswer = "N/A"
			} else {
				let confidenceAnswer = surveyFinished.confidenceAnswer[index]
				confidentQAnswer = String(confidenceAnswer.answer)
			}

			var stringAppend = String(index+1) + "," + deviceName + ","
			stringAppend = stringAppend + mainQAnswer + "," + confidentQAnswer + "," + answerComments + "\n"
            text.append(stringAppend)
        }
		
        return text
    }
	
	func createCSVDataTherapist() -> NSMutableString{
		let text = NSMutableString()
		text.append("Name," + surveyFinished.patient!.patientsName + "\n")
		text.append("Survey Name," + surveyFinished.surveyName + "\n")
		text.append("Time Started," + timeSurveyStarted.text! + "\n")
		text.append("\n\n")
		
		var device : String = ""
		var main : String = ""
		var confidence : String = ""
		
		for index in 0..<surveyFinished.devices.count {
			let deviceName = surveyFinished.devices[index].value
			var mainQAnswer : String
			var confidentQAnswer : String
			
			if index > surveyFinished.mainAnswer.count-1{
				mainQAnswer = "-"
			} else {
				let mainAnswer = surveyFinished.mainAnswer[index]
				
				if mainAnswer.answer == true {
					mainQAnswer = "Y"
				} else {
					mainQAnswer = "N"
				}
			}
			
			if index > surveyFinished.confidenceAnswer.count-1{
				confidentQAnswer = "-"
			} else {
				let confidenceAnswer = surveyFinished.confidenceAnswer[index]
				confidentQAnswer = String(confidenceAnswer.answer)
			}

			device = device + deviceName + ","
			main = main + mainQAnswer + ","
			confidence = confidence + confidentQAnswer + ","
		}
		
		text.append(device + "\n")
		text.append(main + "\n")
		text.append(confidence + "\n")
		
		return text
	}
	
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    func backButtonAction(_ sender:UIBarButtonItem){
        print("backButton pressed")
        
        self.performSegue(withIdentifier: "unwindToSurveyDone", sender: self)
    }
    
    func saveButtonAction(_ sender:UIBarButtonItem){
        print("save comments")
        
        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        
        for index in 0..<surveyFinished.mainAnswer.count{
            let a = tableView.visibleCells[index] as! ResultTableViewCell
            let comment = a.commentTextField.text
            
            if comment != ""{
                try! realm.write{
                    let mainToBeAdded = surveyFinished.mainAnswer[index]
                    realm.create(SurveyMainResult.self, value: ["id":mainToBeAdded.id, "comments":comment!], update: true)
                }
            }
        }
        saveButton.isEnabled = false
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return surveyFinished.devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "resultCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ResultTableViewCell
        
//        let eachSurvey = surveyFinished.deviceName
        cell.questionNumber.text = String((indexPath as NSIndexPath).row + 1)
        cell.deviceName.text = surveyFinished.devices[(indexPath as NSIndexPath).row].value
		
		cell.commentTextField.delegate = self
		commentTextFields += [cell.commentTextField]
        cell.commentTextField.isEnabled = false
        
        if (indexPath as NSIndexPath).row > surveyFinished.mainAnswer.count-1{
            cell.mainQuestionAnswer.text = "N/A"
        } else {
            let mainAnswer = surveyFinished.mainAnswer[(indexPath as NSIndexPath).row]
            
            if mainAnswer.answer == true {
                cell.mainQuestionAnswer.text = "Yes"
            } else {
                cell.mainQuestionAnswer.text = "No"
            }
            
            cell.commentTextField.isEnabled = true
            cell.commentTextField.text = mainAnswer.comments
        }
        
       
        if (indexPath as NSIndexPath).row > surveyFinished.confidenceAnswer.count-1{
             cell.confidentQuestionAnswer.text = "N/A"
        } else {
            let confidenceAnswer = surveyFinished.confidenceAnswer[indexPath.row].answer
			
			if confidenceAnswer == 0 {
				cell.confidentQuestionAnswer.text = "N/A"
			} else {
				cell.confidentQuestionAnswer.text = String(confidenceAnswer)

			}
		}
       
        return cell
    }
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		textChecker()
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textChecker()
		for text in commentTextFields {
			text.resignFirstResponder()
		}
		return true
	}
	
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		textChecker()
		for text in commentTextFields{
			text.resignFirstResponder()
		}
		return true
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		saveButton.isEnabled = false
	}
	
	func tapToRemoveKeyboard(_ gesture: UITapGestureRecognizer){
		textChecker()
		for text in commentTextFields {
			text.resignFirstResponder()
		}
	}
	
	func textChecker(){
		saveButton.isEnabled = false
		for text in commentTextFields {
			if text.text != "" {
				saveButton.isEnabled = true
			}
		}
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
