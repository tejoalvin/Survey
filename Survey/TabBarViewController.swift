//
//  TabBarViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 29/07/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit
import RealmSwift

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //for the therapist part
        
        let split = self.viewControllers![0] as! UISplitViewController
        print("split")
        print(split)
        
        let master = split.viewControllers.first as! UINavigationController
        print("master")
        print(master)
        
        let surveyList = master.topViewController as! SurveyListTableViewController
        print("sList")
        print(surveyList)
        
        let detail = split.viewControllers.last as! UINavigationController
        print("detail")
        print(detail)
        
        let qList = detail.topViewController as! SurveyDetailsViewController
        print("qList")
        print(qList)

        surveyList.delegate = qList
        
        let splitResult = self.viewControllers![1] as! UISplitViewController
        let masterNav = splitResult.viewControllers.first as! UINavigationController
        let masterPatient = masterNav.topViewController as! ResultPatientTableViewController
        
        let detailNav = splitResult.viewControllers.last as! UINavigationController
        let surveyDoneDetail = detailNav.topViewController as! SurveyDoneTableViewController
        
        masterPatient.delegate = surveyDoneDetail
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
