//
//  SurveyDetailsViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 28/07/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit
import RealmSwift

class SurveyDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var surveyTitleTextField: UITextField!
    @IBOutlet weak var surveyTitleLabel: UILabel!
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var surveyData : SurveyData!
//    var editButton : UIBarButtonItem!
	@IBOutlet weak var deleteQButton: UIButton!
	@IBOutlet weak var navItem: UINavigationItem!

    @IBOutlet weak var saveButton: UIBarButtonItem!
	@IBOutlet weak var bgView: UIView!
    
    var surveyName = "Default Survey"
    
    let config = Realm.Configuration(
        schemaVersion: 1
    )
    
    var survey: SurveyData!
//        {
//        didSet(newSurvey){
//            self.refreshUI()
//        }
//    }
    
    override func viewDidLoad() {
//        editButton = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(self.editButtonAction(_:)))
        let homeButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(self.homeButtonAction(_:)))
        navigationItem.setLeftBarButtonItems([homeButton], animated: true)
        
        super.viewDidLoad()
		
        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        
        let surveyList = realm.objects(SurveyData.self)
		
        survey = surveyList[0]
		
		surveyTitleTextField.text = survey.name
		questionTextField.text = survey.questions.first!.question
		navItem.title = survey.name
		
        tableView.delegate = self
        tableView.dataSource = self
        
        surveyTitleTextField.delegate = self
        questionTextField.delegate = self
        
        saveButton.isEnabled = false
		
		tableView.separatorColor = UIColor.clear
		
//		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapToRemoveKeyboard(_:)))
//		view.addGestureRecognizer(tapGesture)
//		bgView.addGestureRecognizer(tapGesture)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//	func tapToRemoveKeyboard(gesture: UITapGestureRecognizer) {
//		textChecker()
//		surveyTitleTextField.resignFirstResponder()
//		questionTextField.resignFirstResponder()
//	}
	
    func textFieldDidEndEditing(_ textField: UITextField) {
        textChecker()
		surveyTitleTextField.resignFirstResponder()
		questionTextField.resignFirstResponder()
    }
	
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = true
    }
	
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        surveyTitleTextField.resignFirstResponder()
        questionTextField.resignFirstResponder()
        return true
	}
	
    func textChecker(){
        if surveyTitleTextField.text == "" || questionTextField.text == "" {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation,
        //return the number of rows
        
        return survey.questions.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "QuestionTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! QuestionTableViewCell
        
        
//        Realm.Configuration.defaultConfiguration = config
//        
//        let realm = try! Realm()
//        let predicate = NSPredicate(format: "pKey contains %@", surveyName)
//        
//        let questionData = realm.objects(QuestionData.self).filter(predicate)
//        
        let questionData = Array(survey.questions.sorted(byProperty: "questionNumber"))
        
        let data = questionData[(indexPath as NSIndexPath).row]
        
        cell.deviceNameLabel.text = data.deviceName
        cell.questionNumberLabel.text = String(data.questionNumber)
        print("imagePath")
        print(data.imagePath)
        if !data.imagePath.isEmpty {
            let img = retrieveImage(data.imagePath)
            cell.deviceImage.image = img
        } else {
            cell.deviceImage.image = UIImage(named: "defaultPhoto")
        }
        // Configure the cell...
		
		if (indexPath as NSIndexPath).row == questionData.count - 1 {
			cell.separatorInset = UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0)
		}
        return cell
    }
    
//    func editButtonAction(sender: UIBarButtonItem){
//        if (tableView.editing) {
//            sender.title = "Edit";
//            tableView.setEditing(false, animated: true)
//        } else {
//            sender.title = "Done";
//            tableView.setEditing(true, animated: true)
//        }
//    }

	
	@IBAction func deleteQuestionAction(_ sender: UIButton) {
		if (tableView.isEditing) {
			sender.setTitle("Delete Question", for: UIControlState())
			tableView.setEditing(false, animated: true)
		} else {
			sender.setTitle("Done", for: UIControlState())
			tableView.setEditing(true, animated: true)
		}
		
	}
	
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            print("delete")
            print((indexPath as NSIndexPath).row)
            
            let questionsArray = Array(survey.questions.sorted(byProperty: "questionNumber"))
            let questionToBeDeleted = questionsArray[(indexPath as NSIndexPath).row]
            
            deleteQuestionFromRealm(questionToBeDeleted, index: (indexPath as NSIndexPath).row)
            tableView.reloadData()
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if survey.questions.count == 1{
            deleteQButton.isEnabled = false
            return false
        } else {
            deleteQButton.isEnabled = true
            return true
        }
    }
    
    fileprivate func deleteQuestionFromRealm(_ questionToBeDeleted: QuestionData, index:Int){
//        let deletedID = questionToBeDeleted.id
        let deletedQNumber = questionToBeDeleted.questionNumber
        let deletedImagePath = questionToBeDeleted.imagePath
        let surveyBeforeDeleted = survey
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()

        try! realm.write{
            realm.delete(questionToBeDeleted)
        }
        
        let id = survey.id
        let surveyObject = realm.objects(SurveyData.self).filter("id = \(id)")
        print(surveyObject[0].questions.count)
        
        let newSurvey = Array(surveyObject[0].questions)
        print(newSurvey.count)
        if deletedQNumber-1 != surveyBeforeDeleted?.questions.sorted(byProperty: "questionNumber").last?.questionNumber {
            try! realm.write{
                //because QNumber 1 more than index in array
                let i = deletedQNumber - 1
                print("i : " + String(i))
                print(newSurvey.count)
                for index in i...newSurvey.count-1{
                    print("index:" + String(index))
                    let currentID = newSurvey[index].id
                    let currentQuestionNumber : Int = newSurvey[index].questionNumber
                    print("current: " + String(currentQuestionNumber))
                    print("tobe: " + String(currentQuestionNumber-1))
                    realm.create(QuestionData.self, value: ["questionNumber": currentQuestionNumber-1, "id":currentID], update: true)
                }
                realm.create(SurveyData.self, value: ["id": id, "lastUpdated": Date()], update: true)

            }
        }
        
        //delete file used
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
		
		if deletedImagePath != "" {
			let imagePath = (paths as NSString).appendingPathComponent(deletedImagePath)
			do{
				try FileManager.default.removeItem(atPath: imagePath)
				print("deleted " + imagePath)
			} catch let error as NSError{
				print("can't delete photo file \n" + String(describing: error))
			}
		}

		//update the master split to show the current total questions
		let splitMaster = splitViewController?.viewControllers[0].childViewControllers.first as! SurveyListTableViewController
		splitMaster.tableView.reloadData()
    }

    func retrieveImage(_ imageFolderPath : String) -> UIImage{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let imagePath = (paths as NSString).appendingPathComponent(imageFolderPath)
        let checkImage = FileManager.default
        print(imagePath)
        var image = UIImage()
        
        if (checkImage.fileExists(atPath: imagePath)) {
            image = UIImage(contentsOfFile: imagePath)!
        } else {
            print("Error: \(imageFolderPath) is not available")
        }
        
        return image
    }
    
    func refreshUI(){
//        let childContainer = self.childViewControllers[0] as! QuestionTableViewController
//        childContainer.surveyData = survey
//        
//        print("refresh")
//        print(childContainer.surveyData.name)
        
        surveyTitleTextField.text = survey.name
        questionTextField.text = survey.questions.first!.question
        
        tableView.reloadData()
    }
    
    @IBAction func saveButtonAction(_ sender: UIBarButtonItem) {
        let surveyTitle = surveyTitleTextField.text
        let surveyQuestion = questionTextField.text
        
        let config = Realm.Configuration(
            schemaVersion: 1
        )
        
        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        
        let questionsData = Array(survey.questions.sorted(byProperty: "questionNumber"))
        let oldSurveyName = survey.name
        let oldQuestion = survey.questions.last?.question
        
        try! realm.write{
            if oldSurveyName != surveyTitle {
                survey.name = surveyTitle!
            }
            
            if (oldSurveyName != surveyTitle || oldQuestion != surveyQuestion) {
                for qd in questionsData{
                    let id = qd.id
                    
                    if oldSurveyName != surveyTitle {
                        //change path into new
                        if !qd.imagePath.isEmpty{
                            let imgPath = qd.imagePath
                            let imgPathArray = imgPath.components(separatedBy: "/")
                            let newImgPath = surveyTitle! + "/" + imgPathArray[1]
                            realm.create(QuestionData.self, value: ["id":id, "imagePath":newImgPath], update: true)
                            realm.create(SurveyData.self, value: ["id": survey.id, "lastUpdated": Date()], update: true)

                        }
                    }
                    
                    if oldQuestion != surveyQuestion{
                        //change questions name on all question data
                        realm.create(QuestionData.self, value: ["id":id, "question":surveyQuestion!], update: true)
                        realm.create(SurveyData.self, value: ["id": survey.id, "lastUpdated": Date()], update: true)

                    }
                }
            }
        }

        if oldSurveyName != surveyTitle {
            //change folder name into new name
            do {
                let documentDirectoryPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
                let originPath = documentDirectoryPath.appendingPathComponent(oldSurveyName)
                let destinationPath = documentDirectoryPath.appendingPathComponent(surveyTitle!)
                try FileManager.default.moveItem(at: originPath, to: destinationPath)
            } catch let error as NSError {
                print(error)
            }
        }
		
		saveButton.isEnabled = false
		surveyTitleTextField.resignFirstResponder()
		questionTextField.resignFirstResponder()

		let splitMaster = splitViewController?.viewControllers[0].childViewControllers.first as! SurveyListTableViewController
		splitMaster.tableView.reloadData()

    }
    
    func homeButtonAction(_ sender: UIBarButtonItem) {
        print("home button clicked")
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        splitViewController?.presentsWithGesture = false
        
        if segue.identifier == "showQuestionDetail"{
            
            let surveyDetailView = segue.destination.childViewControllers.first as! QuestionsDetailsViewController
            
//            Realm.Configuration.defaultConfiguration = config
//            
//            let realm = try! Realm()
//            let predicate = NSPredicate(format: "pKey contains %@", surveyName)
//            
//            let questionData = realm.objects(QuestionData.self).filter(predicate)
            
            let questionData = Array(survey.questions.sorted(byProperty: "questionNumber"))
            
            if let selectedQuestionCell = sender as? QuestionTableViewCell {
                let indexPath = tableView.indexPath(for: selectedQuestionCell)!
                
                let selectedQuestion = questionData[(indexPath as NSIndexPath).row]
                surveyDetailView.questionData = selectedQuestion
                surveyDetailView.isNewQuestion = false
            }
            
        }
        else if segue.identifier == "addNew" {
            let uiNav = segue.destination as! UINavigationController
            let surveyDetailView = uiNav.topViewController as! QuestionsDetailsViewController
            
            let config = Realm.Configuration(
                schemaVersion: 1
            )
            
            Realm.Configuration.defaultConfiguration = config
            
            let realm = try! Realm()
            
            let index = realm.objects(QuestionData.self).sorted(byProperty: "id").last!.id
            
            let qData = QuestionData()
            qData.questionNumber = survey.questions.count + 1
            qData.id = index + 1
            print(qData.id)
//            qData.pKey = survey.name + "-" + String(qData.questionNumber)
            
            surveyDetailView.questionData = qData
            surveyDetailView.isNewQuestion = true
        } else if segue.identifier == "showPreview"{
			let navView = segue.destination as! UINavigationController
			let previewView = navView.topViewController as! PreviewCollectionViewController
			previewView.survey = survey
		}

    }
    
    @IBAction func unwindToSurveyDetails(_ sender: UIStoryboardSegue){
        
         splitViewController?.presentsWithGesture = true
        
         if let sourceViewController = sender.source as? QuestionsDetailsViewController, let question = sourceViewController.question {
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                let name = question.deviceName
                let picture = question.image
                let id = question.id

                let config = Realm.Configuration(
                    schemaVersion: 1
                )

                Realm.Configuration.defaultConfiguration = config

                let realm = try! Realm()
                
                try! realm.write{
                    let imgPath = saveImage(picture, surveyName: survey.name, filenameToBe: name)
                    realm.create(QuestionData.self, value: ["imagePath": imgPath,"deviceName": name, "id": id], update: true)

                    realm.create(SurveyData.self, value: ["id": survey.id, "lastUpdated": Date()], update: true)
                }
                
                tableView.reloadData()
                print(selectedIndexPath)
            } else {
                //adding new 
                let name = question.deviceName
                let picture = question.image
                let id = question.id
//                let pKeyArray = pKey.componentsSeparatedByString("-")
                
                let config = Realm.Configuration(
                    schemaVersion: 1
                )
                
                Realm.Configuration.defaultConfiguration = config
                
                let realm = try! Realm()
                
                try! realm.write{
                    let imgPath = saveImage(picture, surveyName: survey.name, filenameToBe: name)
                    
                    let questionData = QuestionData()
                    questionData.deviceName = name
                    questionData.imagePath = imgPath
                    questionData.question = survey.questions.first!.question
                    questionData.questionNumber = question.questionNumber
                    questionData.id = id
                    questionData.surveyName = survey
                    
                    survey.questions.append(questionData)
                    realm.create(SurveyData.self, value: ["id": survey.id, "lastUpdated": Date()], update: true)

                }
                tableView.reloadData()
				
				//update the master split to show the current total questions
				let splitMaster = splitViewController?.viewControllers[0].childViewControllers.first as! SurveyListTableViewController
				splitMaster.tableView.reloadData()
            }
        
        }
        
    }
    
    func saveImage(_ image : UIImage, surveyName : String, filenameToBe : String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("paths")
        print(paths)
		
		let filenameToBeSaved = filenameToBe.replacingOccurrences(of: "/", with: "")
        let imageFolderPath = surveyName + "/" + filenameToBeSaved
        
        let imagePath = (paths as NSString).appendingPathComponent(imageFolderPath)
        
        if (try? UIImageJPEGRepresentation(image, 1.0)!.write(to: URL(fileURLWithPath: imagePath), options: [.atomic])) != nil{
            print("file saved")
        }else{
            print("file save failed")
        }
        
        return imageFolderPath
    }

}

extension SurveyDetailsViewController: SurveySelectionDelegate {
    func surveySelected(_ newSurvey: SurveyData) {
        self.survey = newSurvey
        print(self.survey.name)
//        print(self.survey.questions.first!.question)
        surveyName = survey.name
		navItem.title = survey.name
        self.refreshUI()
    }
}
