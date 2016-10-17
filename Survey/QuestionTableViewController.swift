//
//  QuestionTableViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 25/07/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit
import RealmSwift

class QuestionTableViewController: UITableViewController{

    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var surveyData : SurveyData!
    var surveyName = "Default Survey"
    
    let config = Realm.Configuration(
        schemaVersion: 1
    )
    
    var data = [QuestionData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        
        let surveyData = realm.objects(SurveyData.self)
        
        //later change using the data from master list
        data = Array(surveyData[0].questions)
    }
    
    func loadList(_ notification: Foundation.Notification){
        //load data here
        print("loadList")
//        self.tableView.reloadData()
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

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, 
        //return the number of rows

        return data.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "QuestionTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! QuestionTableViewCell

        
        Realm.Configuration.defaultConfiguration = config

        let realm = try! Realm()
        let predicate = NSPredicate(format: "pKey contains %@", surveyName)
        
        let questionData = realm.objects(QuestionData.self).filter(predicate)
        
        let data = questionData[(indexPath as NSIndexPath).row]
        
        cell.deviceNameLabel.text = data.deviceName
        cell.questionNumberLabel.text = String(data.questionNumber)
        
        
        // Configure the cell...

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showQuestionDetails"{
            
            let surveyDetailView = segue.destination as! QuestionsDetailsViewController
        
            Realm.Configuration.defaultConfiguration = config
            
            let realm = try! Realm()
            let predicate = NSPredicate(format: "pKey contains %@", surveyName)
            
            let questionData = realm.objects(QuestionData.self).filter(predicate)

            if let selectedQuestionCell = sender as? QuestionTableViewCell {
                let indexPath = tableView.indexPath(for: selectedQuestionCell)!
                let selectedQuestion = questionData[(indexPath as NSIndexPath).row]

                surveyDetailView.questionData = selectedQuestion
            }

        }
    }
    

}



