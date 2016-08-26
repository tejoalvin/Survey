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
    func surveySelected(newSurvey: SurveyData)
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
        editButton = UIBarButtonItem(title: "Delete", style: .Plain, target: self, action: #selector(self.editButtonAction(_:)))
        navigationItem.leftBarButtonItem = editButton
		
//		let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//		tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        print(self.delegate)
    }

    func editButtonAction(sender: UIBarButtonItem){
        if (tableView.editing) {
            sender.title = "Delete";
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		//select first item in the table
		let firstIndex = NSIndexPath(forRow: indexSelected, inSection: 0)
		tableView.selectRowAtIndexPath(firstIndex, animated: true, scrollPosition: UITableViewScrollPosition.Bottom)
	}


    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        
        let questionsData = realm.objects(SurveyData.self)
        print(questionsData.count)
        return questionsData.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "SurveyListTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SurveyListTableViewCell
        
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        
        let surveyData = realm.objects(SurveyData.self)
        
        cell.surveyNameLabel.text = surveyData[indexPath.row].name
        cell.numberOfQuestionsAvailable.text = String(surveyData[indexPath.row].questions.count) + " Questions"

        // Configure the cell...

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        
        let surveyData = realm.objects(SurveyData.self)

        let selectedSurvey = surveyData[indexPath.row]
        self.delegate?.surveySelected(selectedSurvey)
		indexSelected = indexPath.row
		
        if let surveyDetailsViewController = self.delegate as? SurveyDetailsViewController {
            splitViewController?.showDetailViewController(surveyDetailsViewController.navigationController!, sender: nil)
            
        }
        
    }

    @IBAction func addNewSurvey(sender: UIBarButtonItem) {
        print("+ button pressed")
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        
        let newSurvey = SurveyData()
        
        var surveyName = "New Survey"
        
        let predicate = NSPredicate(format: "name contains %@", surveyName)
        let data = realm.objects(SurveyData.self).filter(predicate)
        
        let index = realm.objects(QuestionData.self).sorted("id").last?.id
        
        let surveyData = realm.objects(SurveyData.self)
        
        if data.count > 0 {
            surveyName = surveyName + String(data.count)
        }
        
        newSurvey.name = surveyName
        newSurvey.lastUpdated = NSDate()
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

    func createDir(surveyName : String){
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        let dirPath = documentsPath.URLByAppendingPathComponent(surveyName)
        print(dirPath)
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(dirPath.path!, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
    }

    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        
        let surveyData = realm.objects(SurveyData.self)
		
//		let answeredData = realm.objects(SurveyAnswered.self)
//		let currentData = surveyData[indexPath.row]
//		print("current " + currentData.name)
//		
//		for answer in answeredData {
//			if answer.surveyName!.name == currentData.name {
//				return false
//			}
//		}
		
		if surveyData.count == 1{
			editButton.enabled = false
			return false
		} else {
			editButton.enabled = true
			return true
		}
    }
	
	
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            Realm.Configuration.defaultConfiguration = config
            
            let realm = try! Realm()
            
            let surveyData = realm.objects(SurveyData.self)
            let surveyToBeDeleted = surveyData[indexPath.row]
            let surveyNameToBeDeleted = surveyToBeDeleted.name
            let surveyQuestions = surveyToBeDeleted.questions
            
            try! realm.write{
                for question in surveyQuestions{
                    realm.delete(question)
                }
                realm.delete(surveyToBeDeleted)
            }
            
            //delete survey folder
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            
            let imagePath = (paths as NSString).stringByAppendingPathComponent(surveyNameToBeDeleted)
            
            do{
                try NSFileManager.defaultManager().removeItemAtPath(imagePath)
            } catch let error as NSError{
                print("can't delete photo file \n" + String(error))
            }
            
            tableView.reloadData()
            
            self.delegate?.surveySelected(surveyData[0])
            
            if let surveyDetailsViewController = self.delegate as? SurveyDetailsViewController {
                splitViewController?.showDetailViewController(surveyDetailsViewController.navigationController!, sender: nil)
                
            }
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
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
