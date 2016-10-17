//
//  SurveyListTableViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 29/07/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit
import RealmSwift

protocol SurveySelectionDelegate: class {
    func surveySelected(_ newSurvey: SurveyData)
}

class SurveyListTableViewController: UITableViewController {
    

    let config = Realm.Configuration(
        schemaVersion: 1
    )
    
    weak var delegate: SurveySelectionDelegate?
	var indexSelected : Int!
    var editButton : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indexSelected = 0
        editButton = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.editButtonAction(_:)))
        navigationItem.leftBarButtonItem = editButton
		
//		let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//		tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        print(self.delegate)
    }

    func editButtonAction(_ sender: UIBarButtonItem){
        if (tableView.isEditing) {
            sender.title = "Edit";
            tableView.setEditing(false, animated: true)
        } else {
            sender.title = "Done";
            tableView.setEditing(true, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		//select first item in the table
		let firstIndex = IndexPath(row: indexSelected, section: 0)
		tableView.selectRow(at: firstIndex, animated: true, scrollPosition: UITableViewScrollPosition.bottom)
	}


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        
        let questionsData = realm.objects(SurveyData.self)
        print(questionsData.count)
        return questionsData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SurveyListTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SurveyListTableViewCell
        
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        
        let surveyData = realm.objects(SurveyData.self)
        
        cell.surveyNameLabel.text = surveyData[(indexPath as NSIndexPath).row].name
        cell.numberOfQuestionsAvailable.text = String(surveyData[(indexPath as NSIndexPath).row].questions.count) + " Questions"

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        
        let surveyData = realm.objects(SurveyData.self)

        let selectedSurvey = surveyData[(indexPath as NSIndexPath).row]
        self.delegate?.surveySelected(selectedSurvey)
		indexSelected = (indexPath as NSIndexPath).row
		
        if let surveyDetailsViewController = self.delegate as? SurveyDetailsViewController {
            splitViewController?.showDetailViewController(surveyDetailsViewController.navigationController!, sender: nil)
            
        }
        
    }

    @IBAction func addNewSurvey(_ sender: UIBarButtonItem) {
        print("+ button pressed")
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        
        let newSurvey = SurveyData()
        
        var surveyName = "New Questionnaire"
        
        let predicate = NSPredicate(format: "name contains %@", surveyName)
        let data = realm.objects(SurveyData.self).filter(predicate)
        
        let index = realm.objects(QuestionData.self).sorted(byProperty: "id").last?.id
        
        let surveyData = realm.objects(SurveyData.self)
        
        if data.count > 0 {
            surveyName = surveyName + String(data.count)
        }
        
        newSurvey.name = surveyName
        newSurvey.lastUpdated = Date()
        newSurvey.id = surveyData.last!.id + 1
        
        let newQuestion = QuestionData()
        newQuestion.question = "Have you used this in the last month?"
        newQuestion.questionNumber = 1
        newQuestion.surveyName = newSurvey
        newQuestion.deviceName = "New Device"
        newQuestion.id = index! + 1
//        print(newSurvey.name + "-" + String(newQuestion.questionNumber))
//        newQuestion.pKey = newSurvey.name + "-" + String(newQuestion.questionNumber)
        
        try! realm.write{
            realm.add(newSurvey)
            createDir(newSurvey.name)
            newSurvey.questions.append(newQuestion)
        }
        
        tableView.reloadData()
    }

    func createDir(_ surveyName : String){
        let documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let dirPath = documentsPath.appendingPathComponent(surveyName)
        print(dirPath)
        do {
            try FileManager.default.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
    }

    
    
    // Override to support conditional editing of the table view.
//    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        Realm.Configuration.defaultConfiguration = config
//        
//        let realm = try! Realm()
//        
//        let surveyData = realm.objects(SurveyData.self)
//		
//		
////		let answeredData = realm.objects(SurveyAnswered.self)
////		let currentData = surveyData[indexPath.row]
////		print("current " + currentData.name)
////		
////		for answer in answeredData {
////			if answer.surveyName!.name == currentData.name {
////				return false
////			}
////		}
//		
//		if surveyData.count == 1{
//			editButton.enabled = false
//			return false
//		} else {
//			editButton.enabled = true
//			return true
//		}
//    }
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let delete = UITableViewRowAction(style: .default, title: "Delete", handler: {
			action,index in
				print("delete pressed")
				Realm.Configuration.defaultConfiguration = self.config
				
				let realm = try! Realm()
				
				let surveyData = realm.objects(SurveyData.self)
				let surveyToBeDeleted = surveyData[(indexPath as NSIndexPath).row]
				let surveyNameToBeDeleted = surveyToBeDeleted.name
				let surveyQuestions = surveyToBeDeleted.questions
				
				try! realm.write{
					for question in surveyQuestions{
						realm.delete(question)
					}
					realm.delete(surveyToBeDeleted)
				}
				
				//delete survey folder
				let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
				
				let imagePath = (paths as NSString).appendingPathComponent(surveyNameToBeDeleted)
				
				do{
					try FileManager.default.removeItem(atPath: imagePath)
				} catch let error as NSError{
					print("can't delete photo file \n" + String(describing: error))
				}
				
				tableView.reloadData()
				
				self.delegate?.surveySelected(surveyData[0])
				
				if let surveyDetailsViewController = self.delegate as? SurveyDetailsViewController {
					self.splitViewController?.showDetailViewController(surveyDetailsViewController.navigationController!, sender: nil)
					
				}

		})
		
		delete.backgroundColor = UIColor.red
		
		let duplicate = UITableViewRowAction(style: .normal, title: "Duplicate", handler: {
			action,index in
			print("duplicate pressed")
		
			Realm.Configuration.defaultConfiguration = self.config
			
			let realm = try! Realm()
		
			let surveyData = realm.objects(SurveyData.self)
			let questionsData = realm.objects(QuestionData.self)
			let	surveyToBeDuplicated = surveyData[(indexPath as NSIndexPath).row]
			
			let newSurvey = SurveyData()
			var index = 2
			
			while index > 0{
				let newName = surveyToBeDuplicated.name + " " + String(index)
				let predicate = NSPredicate(format: "name = %@", newName)
				let duplicate = realm.objects(SurveyData.self).filter(predicate)
				if duplicate.count > 0 {
					index += 1
					print(newName)
				} else {
					newSurvey.name = newName
					print(newName + " break")
					break
				}
			}
			
			do {
				let documentDirectoryPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
				let originPath = documentDirectoryPath.appendingPathComponent(surveyToBeDuplicated.name)
				let destinationPath = documentDirectoryPath.appendingPathComponent(newSurvey.name)
				try FileManager.default.copyItem(at: originPath, to: destinationPath)
			} catch let error as NSError {
				print(error)
			}

			
			for i in 0...surveyToBeDuplicated.questions.count-1{
				let question = QuestionData()
				question.question = surveyToBeDuplicated.questions[i].question
				question.deviceName = surveyToBeDuplicated.questions[i].deviceName
				question.questionNumber = i+1
				question.surveyName = newSurvey
				
				if surveyToBeDuplicated.questions[i].imagePath != "" {
					question.imagePath = newSurvey.name + "/" + surveyToBeDuplicated.questions[i].deviceName

				}
				question.id = questionsData.last!.id + i + 1
				
				newSurvey.questions.append(question)
			}

			
			newSurvey.id = surveyData.last!.id + 1
			newSurvey.lastUpdated = Date()
			
			try! realm.write{
				realm.add(newSurvey)
			}
			tableView.reloadData()
		})
		
		if (indexPath as NSIndexPath).row == 0 {
			return [duplicate]
		} else {
			return [delete,duplicate]
		}
	}
	
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        
       return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
