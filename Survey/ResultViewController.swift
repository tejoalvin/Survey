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
            let homeButton = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: #selector(self.homeButtonAction(_:)))
            navigationItem.setLeftBarButtonItem(homeButton, animated: true)
            navigationItem.title = "Result"
        } else {
            let backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(self.backButtonAction(_:)))
            navigationItem.setLeftBarButtonItem(backButton, animated: true)
            navigationItem.title = surveyFinished.surveyName + " Result"
        }
        
        saveButton = UIBarButtonItem(title: "Save Comments", style:.Plain, target: self, action: #selector(self.saveButtonAction(_:)))
        navigationItem.setRightBarButtonItem(saveButton, animated: true)
		
		saveButton.enabled = false
		
        patientNameLabel.text = surveyFinished.patient!.patientsName
        surveyNameLabel.text = surveyFinished.surveyName
		
		mainQLabel.text = surveyFinished.question
		
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        
        timeSurveyStarted.text = dateFormatter.stringFromDate(surveyFinished.dateStarted)
        // Do any additional setup after loading the view.
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapToRemoveKeyboard(_:)))
		view.addGestureRecognizer(tapGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    func homeButtonAction(sender:UIBarButtonItem){
        if presentingViewController is UINavigationController {
			self.performSegueWithIdentifier("unwindToMain", sender: self)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
	
	@IBAction func exportTherapistReport(sender: UIButton) {
		let mailString = createCSVDataTherapist()
		
		// Converting it to NSData.
		let data = mailString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
		
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
			self.presentViewController(emailController, animated: true, completion: nil)
		}

	}
	

	@IBAction func exportCSV(sender: UIButton) {

		let mailString = createCSVData()
		
        // Converting it to NSData.
        let data = mailString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
		
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
            self.presentViewController(emailController, animated: true, completion: nil)
        }
    }

    
    func createCSVData() -> NSMutableString {
        let text = NSMutableString()
        text.appendString("Name," + surveyFinished.patient!.patientsName + "\n")
        text.appendString("Survey Name," + surveyFinished.surveyName + "\n")
        text.appendString("Time Started," + timeSurveyStarted.text! + "\n")
        text.appendString("\n\n")
        text.appendString("No.,Technology Name," + mainQLabel.text! + ",Confidence level (of 5),Comments\n")
		
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

			let stringAppend = String(index+1) + "," + deviceName + "," + mainQAnswer + "," + confidentQAnswer + "," + answerComments + "\n"
            text.appendString(stringAppend)
        }
		
        return text
    }
	
	func createCSVDataTherapist() -> NSMutableString{
		let text = NSMutableString()
		text.appendString("Name," + surveyFinished.patient!.patientsName + "\n")
		text.appendString("Survey Name," + surveyFinished.surveyName + "\n")
		text.appendString("Time Started," + timeSurveyStarted.text! + "\n")
		text.appendString("\n\n")
		
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
		
		text.appendString(device + "\n")
		text.appendString(main + "\n")
		text.appendString(confidence + "\n")
		
		return text
	}
	
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func backButtonAction(sender:UIBarButtonItem){
        print("backButton pressed")
        
        self.performSegueWithIdentifier("unwindToSurveyDone", sender: self)
    }
    
    func saveButtonAction(sender:UIBarButtonItem){
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
        saveButton.enabled = false
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return surveyFinished.devices.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "resultCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! ResultTableViewCell
        
//        let eachSurvey = surveyFinished.deviceName
        cell.questionNumber.text = String(indexPath.row + 1)
        cell.deviceName.text = surveyFinished.devices[indexPath.row].value
		
		cell.commentTextField.delegate = self
		commentTextFields += [cell.commentTextField]
        cell.commentTextField.enabled = false
        
        if indexPath.row > surveyFinished.mainAnswer.count-1{
            cell.mainQuestionAnswer.text = "N/A"
        } else {
            let mainAnswer = surveyFinished.mainAnswer[indexPath.row]
            
            if mainAnswer.answer == true {
                cell.mainQuestionAnswer.text = "Yes"
            } else {
                cell.mainQuestionAnswer.text = "No"
            }
            
            cell.commentTextField.enabled = true
            cell.commentTextField.text = mainAnswer.comments
        }
        
       
        if indexPath.row > surveyFinished.confidenceAnswer.count-1{
             cell.confidentQuestionAnswer.text = "N/A"
        } else {
            let confidenceAnswer = surveyFinished.confidenceAnswer[indexPath.row]
			if confidenceAnswer == 0 {
				cell.confidentQuestionAnswer.text = "N/A"
			} else {
				cell.confidentQuestionAnswer.text = String(confidenceAnswer.answer)

			}
		}
       
        return cell
    }
	
	func textFieldDidEndEditing(textField: UITextField) {
		textChecker()
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textChecker()
		for text in commentTextFields {
			text.resignFirstResponder()
		}
		return true
	}
	
	func textFieldShouldEndEditing(textField: UITextField) -> Bool {
		textChecker()
		for text in commentTextFields{
			text.resignFirstResponder()
		}
		return true
	}
	
	func textFieldDidBeginEditing(textField: UITextField) {
		saveButton.enabled = false
	}
	
	func tapToRemoveKeyboard(gesture: UITapGestureRecognizer){
		textChecker()
		for text in commentTextFields {
			text.resignFirstResponder()
		}
	}
	
	func textChecker(){
		saveButton.enabled = false
		for text in commentTextFields {
			if text.text != "" {
				saveButton.enabled = true
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
