//
//  MainViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 03/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func unwindToMain(sender: UIStoryboardSegue){
		print("unwind To Main")
	}

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "doSurvey"{
            let splitView = segue.destinationViewController as! UISplitViewController
            print("doSurvey split: " + String(splitView))
            let masterNav = splitView.viewControllers.first as! UINavigationController
            print("doSurvey masterNav: " + String(masterNav))
            let master = masterNav.topViewController as! SelectSurveyTableViewController
            let detailNav = splitView.viewControllers.last as! UINavigationController
            let detail = detailNav.topViewController as! PreviewCollectionViewController
            
            master.delegate = detail
		} else if segue.identifier == "createEditSegue" {
			let split = segue.destinationViewController as! UISplitViewController
			let master = split.viewControllers.first as! UINavigationController
			let surveyList = master.topViewController as! SurveyListTableViewController
			let detail = split.viewControllers.last as! UINavigationController
			let qList = detail.topViewController as! SurveyDetailsViewController
			
			surveyList.delegate = qList
		} else if segue.identifier == "resultSegue"{
			let splitResult = segue.destinationViewController as! UISplitViewController
			
			let masterNav = splitResult.viewControllers.first as! UINavigationController
			let masterPatient = masterNav.topViewController as! ResultPatientTableViewController
			
			let detailNav = splitResult.viewControllers.last as! UINavigationController
			let surveyDoneDetail = detailNav.topViewController as! SurveyDoneTableViewController
			
			masterPatient.delegate = surveyDoneDetail

		}
    }
	

}
