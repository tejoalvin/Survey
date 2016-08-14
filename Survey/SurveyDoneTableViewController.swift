//
//  SurveyDoneTableViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 09/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import RealmSwift
import UIKit

class SurveyDoneTableViewController: UITableViewController {

    let config = Realm.Configuration(
        schemaVersion: 1
    )
    
    var patient : Patients!
    
    @IBOutlet weak var pageName: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        
        patient = realm.objects(Patients.self).sorted("patientsName").first
        
        pageName.title = patient.patientsName
        
        navigationItem.leftItemsSupplementBackButton = true
        let showMasterButton = splitViewController!.displayModeButtonItem()
        
        let homeButton = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: #selector(self.homeButtonAction(_:)))
        navigationItem.setLeftBarButtonItems([showMasterButton, homeButton], animated: true)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func homeButtonAction(sender: UIBarButtonItem) {
        print("home button clicked")
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return patient.surveyDone.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "surveyDoneCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! SurveyDoneTableViewCell
		
		let sortedList = patient.surveyDone.sorted("dateStarted", ascending: false)
		
        cell.surveyName.text = sortedList[indexPath.row].surveyName!.name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        if sortedList[indexPath.row].confidenceAnswer.count > 0{
            cell.confidenceDone.text = String(sortedList[indexPath.row].confidenceAnswer.count) + "/" + String(sortedList[indexPath.row].surveyName!.questions.count) + " questions done"
        } else {
            cell.confidenceDone.text = "0/" + String(sortedList[indexPath.row].surveyName!.questions.count) + " questions done"
        }
        
        if sortedList[indexPath.row].mainAnswer.count > 0{
             cell.mainDone.text = String(sortedList[indexPath.row].mainAnswer.count) + "/" + String(sortedList[indexPath.row].surveyName!.questions.count) + " questions done"
        } else {
            cell.mainDone.text = "0/" + String(sortedList[indexPath.row].surveyName!.questions.count) + " questions done"
        }

        let date = sortedList[indexPath.row].dateStarted
        let time = NSDateFormatter()
        time.dateFormat = "dd MMM yyyy HH.mm"
        
        cell.surveyTimestamp.text = time.stringFromDate(date)

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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        splitViewController?.presentsWithGesture = false
        
        if segue.identifier == "showPatientResult" {
            let resultViewController = segue.destinationViewController as! ResultViewController
            if let selectedSurveyDoneCell = sender as? SurveyDoneTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedSurveyDoneCell)!
                
                resultViewController.surveyFinished = patient.surveyDone[indexPath.row]
                resultViewController.isFromResultTable = true
            }
        }
    }
 
    @IBAction func unwindToSurveyDone(sender: UIStoryboardSegue){
        print("unwind")
        splitViewController?.presentsWithGesture = true
    }
}

extension SurveyDoneTableViewController : patientSelectionDelegate{
    func patientSelected(patientSelected: Patients) {
        patient = patientSelected
        tableView.reloadData()
        pageName.title = patient.patientsName
    }
}
