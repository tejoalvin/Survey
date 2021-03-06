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
        
        patient = realm.objects(Patients.self).sorted(byProperty: "patientsName").first
		
		if realm.objects(Patients.self).count == 0 {
			pageName.title = "Result"
		} else {
			 pageName.title = patient.patientsName
		}
		
		
        
//        navigationItem.leftItemsSupplementBackButton = true
//        let showMasterButton = splitViewController!.displayModeButtonItem()
		
//        let homeButton = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: #selector(self.homeButtonAction(_:)))
//        navigationItem.setLeftBarButtonItems([homeButton], animated: true)
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    func homeButtonAction(sender: UIBarButtonItem) {
//        print("home button clicked")
//        dismissViewControllerAnimated(true, completion: nil)
//    }
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		
		if patient == nil {
			return 0
		} else {
			return patient.surveyDone.count
		}
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
        let identifier = "surveyDoneCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SurveyDoneTableViewCell
		
		let sortedList = patient.surveyDone.sorted(byProperty: "dateStarted", ascending: false)
		
        cell.surveyName.text = sortedList[(indexPath as NSIndexPath).row].surveyName
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        if sortedList[(indexPath as NSIndexPath).row].confidenceAnswer.count > 0{
            cell.confidenceDone.text = String(sortedList[(indexPath as NSIndexPath).row].confidenceAnswer.count) + "/" + String(sortedList[(indexPath as NSIndexPath).row].devices.count) + " questions done"
        } else {
            cell.confidenceDone.text = "0/" + String(sortedList[(indexPath as NSIndexPath).row].devices.count) + " questions done"
        }
        
        if sortedList[(indexPath as NSIndexPath).row].mainAnswer.count > 0{
             cell.mainDone.text = String(sortedList[(indexPath as NSIndexPath).row].mainAnswer.count) + "/" + String(sortedList[(indexPath as NSIndexPath).row].devices.count) + " questions done"
        } else {
            cell.mainDone.text = "0/" + String(sortedList[(indexPath as NSIndexPath).row].devices.count) + " questions done"
        }

        let date = sortedList[(indexPath as NSIndexPath).row].dateStarted
        let time = DateFormatter()
        time.dateFormat = "dd MMM yyyy HH.mm"
        
        cell.surveyTimestamp.text = time.string(from: date)

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
        
        splitViewController?.presentsWithGesture = false
        
        if segue.identifier == "showPatientResult" {
            let resultViewController = segue.destination.childViewControllers.first as! ResultViewController
            if let selectedSurveyDoneCell = sender as? SurveyDoneTableViewCell {
                let indexPath = tableView.indexPath(for: selectedSurveyDoneCell)!
				
				let sortedSurvey = patient.surveyDone.sorted(byProperty: "dateStarted", ascending: false)
				
                resultViewController.surveyFinished = sortedSurvey[(indexPath as NSIndexPath).row]
                resultViewController.isFromResultTable = true
            }
        }
    }
 
    @IBAction func unwindToSurveyDone(_ sender: UIStoryboardSegue){
        print("unwind")
        splitViewController?.presentsWithGesture = true
    }
}

extension SurveyDoneTableViewController : patientSelectionDelegate{
    func patientSelected(_ patientSelected: Patients) {
        patient = patientSelected
        tableView.reloadData()
        pageName.title = patient.patientsName
		print(pageName.title)
    }
}
