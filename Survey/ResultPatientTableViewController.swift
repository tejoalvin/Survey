//
//  ResultPatientTableViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 07/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit
import RealmSwift

protocol patientSelectionDelegate : class {
    func patientSelected(_ patientSelected : Patients)
}

class ResultPatientTableViewController: UITableViewController {

    weak var delegate : patientSelectionDelegate?
    
    let config = Realm.Configuration(
        schemaVersion: 1
    )
	
	@IBOutlet weak var searchBar: UISearchBar!
	let searchController = UISearchController(searchResultsController: nil)
	var patientList = [Patients]()
	var filteredPatientList = [Patients]()
	
	var selectedIndex : Int!
	
    override func viewDidLoad() {
        super.viewDidLoad()

		let homeButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(self.homeButtonAction(_:)))
		navigationItem.setLeftBarButtonItems([homeButton], animated: true)

		
		Realm.Configuration.defaultConfiguration = config
		let realm = try! Realm()
		patientList = Array(realm.objects(Patients.self).sorted(byProperty: "patientsName"))
		
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		definesPresentationContext = true
		tableView.tableHeaderView = searchController.searchBar
		
		selectedIndex = 0
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		//select first item in the table
		if patientList.count != 0{
			let firstIndex = IndexPath(row: selectedIndex, section: 0)
			tableView.selectRow(at: firstIndex, animated: true, scrollPosition: UITableViewScrollPosition.bottom)
		}
	}
	
	func homeButtonAction(_ sender: UIBarButtonItem) {
		print("home button clicked")
		dismiss(animated: true, completion: nil)
	}

	
	func filterContent(_ searchText : String){
		print(searchText)
		filteredPatientList = patientList.filter {
			eachPatient in return eachPatient.patientsName.lowercased().contains(searchText.lowercased())
		}
		tableView.reloadData()
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		
		if searchController.isActive && searchController.searchBar.text != "" {
			return filteredPatientList.count
		}
		
        return patientList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "patientCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ResultPatientTableViewCell
		
		let patient : Patients
		if searchController.isActive && searchController.searchBar.text != "" {
			patient = filteredPatientList[(indexPath as NSIndexPath).row]
		} else {
			patient = patientList[(indexPath as NSIndexPath).row]
		}
		
        cell.patientName.text = patient.patientsName
        cell.surveyDone.text = String(patient.surveyDone.count) + " Questionnaire(s) Done"

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let patient : Patients
		if searchController.isActive && searchController.searchBar.text != "" {
			patient = filteredPatientList[(indexPath as NSIndexPath).row]
		} else {
			patient = patientList[(indexPath as NSIndexPath).row]
		}
		selectedIndex = (indexPath as NSIndexPath).row
        self.delegate?.patientSelected(patient)

        if let surveyDoneViewController = self.delegate as? SurveyDoneTableViewController {
            splitViewController?.showDetailViewController(surveyDoneViewController.navigationController!, sender: nil)
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

extension ResultPatientTableViewController: UISearchResultsUpdating {
	func updateSearchResults(for searchController: UISearchController) {
		filterContent(searchController.searchBar.text!)
	}
}
