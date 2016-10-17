//
//  SelectSurveyTableViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 30/07/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit
import RealmSwift

protocol selectedSurveyDelegate : class {
    func selectedSurvey(_ surveySelected : SurveyData)
}

class SelectSurveyTableViewController: UITableViewController {

    let config = Realm.Configuration(
        schemaVersion: 1
    )
    
    weak var delegate: selectedSurveyDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        // #warning Incomplete implementation, return the number of rows
        
        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        let surveys = realm.objects(SurveyData.self)
        
        return surveys.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "SurveyListTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SurveyListTableViewCell

        // Configure the cell...

        Realm.Configuration.defaultConfiguration = config
        
        let realm = try! Realm()
        
        let surveyData = realm.objects(SurveyData.self)
        
        cell.surveyNameLabel.text = surveyData[(indexPath as NSIndexPath).row].name
        cell.numberOfQuestionsAvailable.text = String(surveyData[(indexPath as NSIndexPath).row].questions.count) + " Questions"
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        let surveys = realm.objects(SurveyData.self)
        
        let surveySelected = surveys[(indexPath as NSIndexPath).row]
        self.delegate?.selectedSurvey(surveySelected)
        
        if let previewViewController = self.delegate as? PreviewCollectionViewController {
            splitViewController?.showDetailViewController(previewViewController.navigationController!, sender: nil)
            
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
