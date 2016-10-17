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
		
		patients = Array(realm.objects(Patients.self).sorted(byProperty: "patientsName"))
		
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
	
	func filterContent(_ searchText : String){
		filteredPatients = patients.filter{
			patient in return patient.patientsName.lowercased().contains(searchText.lowercased())
		}
		tableView.reloadData()
	}
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation,
        //return the number of rows
		
		if searchController.isActive && searchController.searchBar.text != "" {
			return filteredPatients.count
		}
		
        return patients.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let identifier = "patients"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PatientListTableViewCell
        
		var patient : Patients
		
		if searchController.isActive && searchController.searchBar.text != "" {
			patient = filteredPatients[(indexPath as NSIndexPath).row]
		} else {
			patient = patients[(indexPath as NSIndexPath).row]
		}
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.string(from: patient.dateOfBirth as Date)
		let mostRecentSurvey = patient.surveyDone.sorted(byProperty: "dateStarted", ascending: false)
		dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
		if mostRecentSurvey.count > 0 {
			let lastSurveyDone = dateFormatter.string(from: mostRecentSurvey.first!.dateStarted)
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        Realm.Configuration.defaultConfiguration = config
//        let realm = try! Realm()
//        
//        let patients = realm.objects(Patients.self).sorted("patientsName")
		
		var patient : Patients
		
		if searchController.isActive && searchController.searchBar.text != "" {
			patient = filteredPatients[(indexPath as NSIndexPath).row]
		} else {
			patient = patients[(indexPath as NSIndexPath).row]
		}
		
        nameField.text = patient.patientsName
        if patient.isMale {
            genderChooser.selectedSegmentIndex = 0
        } else {
            genderChooser.selectedSegmentIndex = 1
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.string(from: patient.dateOfBirth as Date)
        dobField.text = date
        
        id = patient.id
        print(patient.patientsName)
        
        if patient.recentStroke != nil {
            print("not nil")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            let stringRecentStroke = dateFormatter.string(from: patient.recentStroke! as Date)
            recentStrokeField.text = stringRecentStroke
        }
        
    }
    
    @IBAction func dobAction(_ sender: UITextField) {
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
        
        let datePicker  : UIDatePicker = UIDatePicker(frame: CGRect(x: 0, y: 40, width: self.view.frame.size.width, height: 180))
        
        datePicker.datePickerMode = UIDatePickerMode.date
        inputView.addSubview(datePicker) // add date picker to UIView
        
        let doneButton = UIButton(frame: CGRect(x: (self.view.frame.size.width/2) - (100/2), y: 0, width: 100, height: 50))
        doneButton.setTitle("Done", for: UIControlState())
        doneButton.setTitle("Done", for: UIControlState.highlighted)
        doneButton.setTitleColor(UIColor.black, for: UIControlState())
        doneButton.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        
        inputView.addSubview(doneButton) // add Button to UIView
        
        doneButton.addTarget(self, action: #selector(InputDetailsViewController.doneButton(_:)), for: UIControlEvents.touchUpInside) // set button click event
        
        sender.inputView = inputView
		datePicker.locale = Locale.init(identifier: "en_GB")
        datePicker.addTarget(self, action: #selector(self.datePickerValueChangedDOB), for: UIControlEvents.valueChanged)
    }
    
    func doneButton(_ sender:UIButton){
        dobField.resignFirstResponder()
        recentStrokeField.resignFirstResponder()
    }
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		nameField.resignFirstResponder()
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		nameField.resignFirstResponder()
		return true
	}
	
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		nameField.resignFirstResponder()
		return true
	}
	
//	func tapToResignKeyboard(gestures: UITapGestureRecognizer){
//		nameField.resignFirstResponder()
//		dobField.resignFirstResponder()
//		recentStrokeField.resignFirstResponder()
//	}
	
    @IBAction func recentStrokeAction(_ sender: UITextField) {
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
        
        let datePicker  : UIDatePicker = UIDatePicker(frame: CGRect(x: 0, y: 40, width: self.view.frame.size.width, height: 180))
        
        datePicker.datePickerMode = UIDatePickerMode.date
        inputView.addSubview(datePicker) // add date picker to UIView
        
        let doneButton = UIButton(frame: CGRect(x: (self.view.frame.size.width/2) - (100/2), y: 0, width: 100, height: 50))
        doneButton.setTitle("Done", for: UIControlState())
        doneButton.setTitle("Done", for: UIControlState.highlighted)
        doneButton.setTitleColor(UIColor.black, for: UIControlState())
        doneButton.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        
        inputView.addSubview(doneButton) // add Button to UIView
        
        doneButton.addTarget(self, action: #selector(InputDetailsViewController.doneButton(_:)), for: UIControlEvents.touchUpInside) // set button click event
        
        sender.inputView = inputView
        
        datePicker.addTarget(self, action: #selector(self.datePickerValueChangedRecentStroke), for: UIControlEvents.valueChanged)
    }
    

    
    func datePickerValueChangedDOB(_ sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        
//        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        dateFormatter.dateStyle = DateFormatter.Style.long
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        dobField.text = dateFormatter.string(from: sender.date)
        
    }
    
    func datePickerValueChangedRecentStroke(_ sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale.init(identifier: "en_GB")
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        
//        dateFormatter.dateFormat = "dd MMMM yyyy"
        
        dateFormatter.dateStyle = DateFormatter.Style.long
        
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        recentStrokeField.text = dateFormatter.string(from: sender.date)
        
    }
    
    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
		dateFormatter.locale = Locale.init(identifier: "en_GB")
		let dateSelected = dobField.text!
		print(dateSelected)
        let NSDateDOB = dateFormatter.date(from: dateSelected)
		print(dateFormatter.string(from: Date()))
        let earlierDate = (NSDateDOB as NSDate?)?.earlierDate(Date())
        
//        let dateComponent = NSCalendar.currentCalendar().components([.Day,.Month,.Year], fromDate: NSDate())
//        let date = NSCalendar.dateFromComponents(dateComponent)
//        dateFormatter.dateFormat = dateFormat
//        let NSDateStroke = dateFormatter.dateFromString(recentStrokeField.text!)
        
//        let order = NSCalendar.currentCalendar().compareDate(NSDateDOB!, toDate: NSDate(), toUnitGranularity: .Day)
        
        
        
        if identifier == "backToPreview"{
            let alert = UIAlertController(title: "You will lose any data you have inputted", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                UIAlertAction in
                
            })
            
            let ok = UIAlertAction(title: "OK", style: .default, handler: {
                UIAlertAction in
				if self.isFromNewSurveySelect == true {
					self.performSegue(withIdentifier: "unwindToSelectSurvey", sender: nil)
				} else {
					self.performSegue(withIdentifier: "backToPreview", sender: nil)
				}
            })
            
            alert.addAction(cancel)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            
            return true
        } else if identifier == "startSurvey" {
            print(nameField.text)
            print(dobField.text)
            if (nameField.text == "") || (dobField.text == ""){
                let alert = UIAlertController(title: "Name / Date Of Birth is empty", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
                return false
            } else if (earlierDate == NSDateDOB!) == false {
                //need to check again when time today is with time while date from textfield is 00
                let alert = UIAlertController(title: "Date Of Birth can't be later or same as today date", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                present(alert, animated: true, completion: nil)
                return false
            } else {
                return true
            }
        } else {
            return true
        }
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "startSurvey" {
        
            print("Start survey")
            
            Realm.Configuration.defaultConfiguration = config
            let realm = try! Realm()
            
            let patients = realm.objects(Patients.self).filter("id = \(id)")
            
            let name = nameField.text
            let dob = dobField.text
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            let NSDateDOB = dateFormatter.date(from: dob!)
            print(NSDateDOB)
            
            var genderIsMale = true
            if genderChooser.selectedSegmentIndex == 1{
                //gender female
                genderIsMale = false
            }
            
            let recentStroke : String
            var NSDateStroke: Date? = nil
            if recentStrokeField.text != "" {
                recentStroke = recentStrokeField.text!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = dateFormat
                NSDateStroke = dateFormatter.date(from: recentStroke)!
            }
        
            var isAfterEachQuestion : Bool = true
            if confidenceSurveySetting.selectedSegmentIndex == 1{
                isAfterEachQuestion = false
            }
            
            let surveyAnsweredList = realm.objects(SurveyAnswered.self).sorted(byProperty: "id")
            // send survey & patient data to next segue, with confidence level survey settings
            let surveyWillBeAnswered = SurveyAnswered()
            if surveyAnsweredList.count > 0 {
                surveyWillBeAnswered.id = surveyAnsweredList.last!.id + 1
            } else {
                surveyWillBeAnswered.id = 1
            }
			
            surveyWillBeAnswered.dateStarted = Date()
            surveyWillBeAnswered.surveyName = survey.name
			surveyWillBeAnswered.question = survey.questions.first!.question
			
			
			for question in survey.questions {
				let device = deviceName()
				device.value = question.deviceName
				surveyWillBeAnswered.devices.append(device)
			}
			
            //not from existing
            if patients.count == 0 {
				
				let predicate = NSPredicate(format: "patientsName = %@ AND dateOfBirth = %@ AND isMale = %@", name!, NSDateDOB! as CVarArg, genderIsMale as CVarArg)
				let ifAvail = realm.objects(Patients.self).filter(predicate)
				
				if ifAvail.count == 0 {
					let patient = Patients()
					patient.patientsName = name!
					patient.isMale = genderIsMale
					patient.dateOfBirth = NSDateDOB!
					patient.recentStroke = NSDateStroke
					
					let patientData = realm.objects(Patients.self).sorted(byProperty: "id")
					
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
					
					let destinationSegue = segue.destination as! SurveyViewController
					destinationSegue.isAfterEachQuestion = isAfterEachQuestion
					destinationSegue.survey = survey
					destinationSegue.patient = patient
					destinationSegue.currentSurveyAnswered = surveyWillBeAnswered
					
					
					print("send1")
				} else {
					print("same person")
					surveyWillBeAnswered.patient = ifAvail.first
					
					try! realm.write{
						ifAvail.first!.surveyDone.append(surveyWillBeAnswered)
					}
					
					let destinationSegue = segue.destination as! SurveyViewController
					destinationSegue.isAfterEachQuestion = isAfterEachQuestion
					destinationSegue.survey = survey
					destinationSegue.patient = ifAvail.first
					destinationSegue.currentSurveyAnswered = surveyWillBeAnswered
				}
            } else {
                /*
                 check whether after selected whether name / dob edited
                 */
                //from existing
                if name != patients.first?.patientsName || NSDateDOB != patients.first?.dateOfBirth || genderIsMale != patients.first?.isMale {
                    //create new patient
                    
                    let patient = Patients()
                    patient.patientsName = name!
                    patient.isMale = genderIsMale
                    patient.dateOfBirth = NSDateDOB!
                    patient.recentStroke = NSDateStroke
                    
                    let patientData = realm.objects(Patients.self).sorted(byProperty: "id")
                    
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
                    
                    let destinationSegue = segue.destination as! SurveyViewController
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
                    
                    let destinationSegue = segue.destination as! SurveyViewController
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
	func updateSearchResults(for searchController: UISearchController) {
		filterContent(searchController.searchBar.text!)
	}
}
