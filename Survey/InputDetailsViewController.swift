//
//  InputDetailsViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 04/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit
import RealmSwift

class InputDetailsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var genderChooser: UISegmentedControl!
    @IBOutlet weak var dobField: UITextField!
    @IBOutlet weak var recentStrokeField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confidenceSurveySetting: UISegmentedControl!
    
    let dateFormat = "dd MMMM yyyy"
    var id = 0
    var survey : SurveyData!
	var isFromNewSurveySelect = false 
    
    let config = Realm.Configuration(
        schemaVersion: 1
    )
	
	var patients = [Patients]()
	var filteredPatients = [Patients]()
	let searchController = UISearchController(searchResultsController: nil)
	
    override func viewDidLoad() {
        super.viewDidLoad()

		Realm.Configuration.defaultConfiguration = config
		let realm = try! Realm()
		
		patients = Array(realm.objects(Patients.self).sorted("patientsName"))
		
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		definesPresentationContext = true
		tableView.tableHeaderView = searchController.searchBar
		
		print(presentingViewController)
		
//		let tapGestures = UITapGestureRecognizer(target: self, action: #selector(self.tapToResignKeyboard(_:)))
//		view.addGestureRecognizer(tapGestures)
		
        print(survey.name)
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
		nameField.delegate = self
		dobField.delegate = self
		recentStrokeField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func filterContent(searchText : String){
		filteredPatients = patients.filter{
			patient in return patient.patientsName.lowercaseString.containsString(searchText.lowercaseString)
		}
		tableView.reloadData()
	}
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation,
        //return the number of rows
		
		if searchController.active && searchController.searchBar.text != "" {
			return filteredPatients.count
		}
		
        return patients.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let identifier = "patients"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! PatientListTableViewCell
        
		var patient : Patients
		
		if searchController.active && searchController.searchBar.text != "" {
			patient = filteredPatients[indexPath.row]
		} else {
			patient = patients[indexPath.row]
		}
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.stringFromDate(patient.dateOfBirth)
		let mostRecentSurvey = patient.surveyDone.sorted("dateStarted", ascending: false)
		dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
		if mostRecentSurvey.count > 0 {
			let lastSurveyDone = dateFormatter.stringFromDate(mostRecentSurvey.first!.dateStarted)
			cell.lastSurveyDone.text = lastSurveyDone
		} else {
			cell.lastSurveyDone.text = "N/A"
		}
		
        cell.nameLabel.text = patient.patientsName
        cell.dobLabel.text = date

        return cell
        
    }
	
//	@IBAction func backButtonAction(sender: UIBarButtonItem) {
//		if presentingViewController is UINavigationController {
//			print("if")
//			performSegueWithIdentifier("unwindToSelectSurvey", sender: self)
//		} else {
//			print("else")
//			performSegueWithIdentifier("backToPreview", sender: self)
//			
//		}
//	}

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        Realm.Configuration.defaultConfiguration = config
//        let realm = try! Realm()
//        
//        let patients = realm.objects(Patients.self).sorted("patientsName")
		
		var patient : Patients
		
		if searchController.active && searchController.searchBar.text != "" {
			patient = filteredPatients[indexPath.row]
		} else {
			patient = patients[indexPath.row]
		}
		
        nameField.text = patient.patientsName
        if patient.isMale {
            genderChooser.selectedSegmentIndex = 0
        } else {
            genderChooser.selectedSegmentIndex = 1
        }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.stringFromDate(patient.dateOfBirth)
        dobField.text = date
        
        id = patient.id
        print(patient.patientsName)
        
        if patient.recentStroke != nil {
            print("not nil")
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = dateFormat
            let stringRecentStroke = dateFormatter.stringFromDate(patient.recentStroke!)
            recentStrokeField.text = stringRecentStroke
        }
        
    }
    
    @IBAction func dobAction(sender: UITextField) {
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 240))
        
        let datePicker  : UIDatePicker = UIDatePicker(frame: CGRectMake(0, 40, self.view.frame.size.width, 180))
        
        datePicker.datePickerMode = UIDatePickerMode.Date
        inputView.addSubview(datePicker) // add date picker to UIView
        
        let doneButton = UIButton(frame: CGRectMake((self.view.frame.size.width/2) - (100/2), 0, 100, 50))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Highlighted)
        doneButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        
        inputView.addSubview(doneButton) // add Button to UIView
        
        doneButton.addTarget(self, action: #selector(InputDetailsViewController.doneButton(_:)), forControlEvents: UIControlEvents.TouchUpInside) // set button click event
        
        sender.inputView = inputView
        datePicker.addTarget(self, action: #selector(self.datePickerValueChangedDOB), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func doneButton(sender:UIButton){
        dobField.resignFirstResponder()
        recentStrokeField.resignFirstResponder()
    }
	
	func textFieldDidEndEditing(textField: UITextField) {
		nameField.resignFirstResponder()
	}

	func textFieldShouldReturn(textField: UITextField) -> Bool {
		nameField.resignFirstResponder()
		return true
	}
	
	func textFieldShouldEndEditing(textField: UITextField) -> Bool {
		nameField.resignFirstResponder()
		return true
	}
	
//	func tapToResignKeyboard(gestures: UITapGestureRecognizer){
//		nameField.resignFirstResponder()
//		dobField.resignFirstResponder()
//		recentStrokeField.resignFirstResponder()
//	}
	
    @IBAction func recentStrokeAction(sender: UITextField) {
        let inputView = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 240))
        
        let datePicker  : UIDatePicker = UIDatePicker(frame: CGRectMake(0, 40, self.view.frame.size.width, 180))
        
        datePicker.datePickerMode = UIDatePickerMode.Date
        inputView.addSubview(datePicker) // add date picker to UIView
        
        let doneButton = UIButton(frame: CGRectMake((self.view.frame.size.width/2) - (100/2), 0, 100, 50))
        doneButton.setTitle("Done", forState: UIControlState.Normal)
        doneButton.setTitle("Done", forState: UIControlState.Highlighted)
        doneButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        doneButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        
        inputView.addSubview(doneButton) // add Button to UIView
        
        doneButton.addTarget(self, action: #selector(InputDetailsViewController.doneButton(_:)), forControlEvents: UIControlEvents.TouchUpInside) // set button click event
        
        sender.inputView = inputView
        
        datePicker.addTarget(self, action: #selector(self.datePickerValueChangedRecentStroke), forControlEvents: UIControlEvents.ValueChanged)
    }
    

    
    func datePickerValueChangedDOB(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
//        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        dobField.text = dateFormatter.stringFromDate(sender.date)
        
    }
    
    func datePickerValueChangedRecentStroke(sender:UIDatePicker) {
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        
//        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        dateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        recentStrokeField.text = dateFormatter.stringFromDate(sender.date)
        
    }
    
    // MARK: - Navigation

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = dateFormat
        let NSDateDOB = dateFormatter.dateFromString(dobField.text!)
        let earlierDate = NSDateDOB?.earlierDate(NSDate())
        
//        let dateComponent = NSCalendar.currentCalendar().components([.Day,.Month,.Year], fromDate: NSDate())
//        let date = NSCalendar.dateFromComponents(dateComponent)
//        dateFormatter.dateFormat = dateFormat
//        let NSDateStroke = dateFormatter.dateFromString(recentStrokeField.text!)
        
//        let order = NSCalendar.currentCalendar().compareDate(NSDateDOB!, toDate: NSDate(), toUnitGranularity: .Day)
        
        
        
        if identifier == "backToPreview"{
            let alert = UIAlertController(title: "You will lose any data you have inputted", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
                UIAlertAction in
                
            })
            
            let ok = UIAlertAction(title: "OK", style: .Default, handler: {
                UIAlertAction in
				if self.isFromNewSurveySelect == true {
					self.performSegueWithIdentifier("unwindToSelectSurvey", sender: nil)
				} else {
					self.performSegueWithIdentifier("backToPreview", sender: nil)
				}
            })
            
            alert.addAction(cancel)
            alert.addAction(ok)
            presentViewController(alert, animated: true, completion: nil)
            
            return true
        } else if identifier == "startSurvey" {
            print(nameField.text)
            print(dobField.text)
            if (nameField.text == "") || (dobField.text == ""){
                let alert = UIAlertController(title: "Name / Date Of Birth is empty", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(ok)
                presentViewController(alert, animated: true, completion: nil)
                return false
            } else if earlierDate?.isEqualToDate(NSDateDOB!) == false {
                //need to check again when time today is with time while date from textfield is 00
                let alert = UIAlertController(title: "Date Of Birth can't be later or same as today date", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(ok)
                presentViewController(alert, animated: true, completion: nil)
                return false
            } else {
                return true
            }
        } else {
            return true
        }
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "startSurvey" {
        
            print("Start survey")
            
            Realm.Configuration.defaultConfiguration = config
            let realm = try! Realm()
            
            let patients = realm.objects(Patients.self).filter("id = \(id)")
            
            let name = nameField.text
            let dob = dobField.text
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = dateFormat
            let NSDateDOB = dateFormatter.dateFromString(dob!)
            print(NSDateDOB)
            
            var genderIsMale = true
            if genderChooser.selectedSegmentIndex == 1{
                //gender female
                genderIsMale = false
            }
            
            let recentStroke : String
            var NSDateStroke: NSDate? = nil
            if recentStrokeField.text != "" {
                recentStroke = recentStrokeField.text!
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = dateFormat
                NSDateStroke = dateFormatter.dateFromString(recentStroke)!
            }
        
            var isAfterEachQuestion : Bool = true
            if confidenceSurveySetting.selectedSegmentIndex == 1{
                isAfterEachQuestion = false
            }
            
            let surveyAnsweredList = realm.objects(SurveyAnswered.self).sorted("id")
            // send survey & patient data to next segue, with confidence level survey settings
            let surveyWillBeAnswered = SurveyAnswered()
            if surveyAnsweredList.count > 0 {
                surveyWillBeAnswered.id = surveyAnsweredList.last!.id + 1
            } else {
                surveyWillBeAnswered.id = 1
            }
			
            surveyWillBeAnswered.dateStarted = NSDate()
            surveyWillBeAnswered.surveyName = survey.name
			surveyWillBeAnswered.question = survey.questions.first!.question
			
			
			for question in survey.questions {
				let device = deviceName()
				device.value = question.deviceName
				surveyWillBeAnswered.devices.append(device)
			}
			
            
            if patients.count == 0 {
                
                let patient = Patients()
                patient.patientsName = name!
                patient.isMale = genderIsMale
                patient.dateOfBirth = NSDateDOB!
                patient.recentStroke = NSDateStroke
                
                let patientData = realm.objects(Patients.self).sorted("id")
                
                if patientData.count > 0{
                    let patientID = patientData.last?.id
                    patient.id = patientID! + 1
                } else {
                    patient.id = 1
                }
                
                surveyWillBeAnswered.patient = patient
                
                try! realm.write{
                    realm.add(patient)
                    patient.surveyDone.append(surveyWillBeAnswered)
                }
                
                print("nearly1")
                
                let destinationSegue = segue.destinationViewController as! SurveyViewController
                destinationSegue.isAfterEachQuestion = isAfterEachQuestion
                destinationSegue.survey = survey
                destinationSegue.patient = patient
                destinationSegue.currentSurveyAnswered = surveyWillBeAnswered
                
                
                print("send1")
            } else {
                /*
                 check whether after selected whether name / dob edited
                 */
                
                if name != patients.first?.patientsName || NSDateDOB != patients.first?.dateOfBirth || genderIsMale != patients.first?.isMale {
                    //create new patient
                    
                    let patient = Patients()
                    patient.patientsName = name!
                    patient.isMale = genderIsMale
                    patient.dateOfBirth = NSDateDOB!
                    patient.recentStroke = NSDateStroke
                    
                    let patientData = realm.objects(Patients.self).sorted("id")
                    
                    if patientData.count > 0 {
                        let patientID = patientData.last?.id
                        patient.id = patientID! + 1
                    } else {
                        patient.id = 1
                    }
                    
                    surveyWillBeAnswered.patient = patient
                    
                    try! realm.write{
                        realm.add(patient)
                        patient.surveyDone.append(surveyWillBeAnswered)
                    }
                    
                    
                    print("nearly2")
                    
                    let destinationSegue = segue.destinationViewController as! SurveyViewController
                    destinationSegue.isAfterEachQuestion = isAfterEachQuestion
                    destinationSegue.survey = survey
                    destinationSegue.patient = patient
                    destinationSegue.currentSurveyAnswered = surveyWillBeAnswered

                    
                    print("send2")
                } else {
                    //when using existing patient
                    let patientData = patients[0]
                    
                    surveyWillBeAnswered.patient = patientData
                    
                    try! realm.write{
                        if recentStrokeField.text != "" {
                            realm.create(Patients.self, value: ["id": patientData.id, "recentStroke" : NSDateStroke!], update: true)
                        }
                        patientData.surveyDone.append(surveyWillBeAnswered)
                    }
                    
                    
                    print("nearly3")
                    
                    let destinationSegue = segue.destinationViewController as! SurveyViewController
                    destinationSegue.isAfterEachQuestion = isAfterEachQuestion
                    destinationSegue.survey = survey
                    destinationSegue.patient = patientData
                    destinationSegue.currentSurveyAnswered = surveyWillBeAnswered

                    print("send3")
                }
            }
        
        }
    }
    

}

extension InputDetailsViewController : UISearchResultsUpdating {
	func updateSearchResultsForSearchController(searchController: UISearchController) {
		filterContent(searchController.searchBar.text!)
	}
}
