//
//  ResultViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 09/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var surveyNameLabel: UILabel!
    @IBOutlet weak var timeSurveyStarted: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var isFromResultTable : Bool!
    var surveyFinished : SurveyAnswered!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        if isFromResultTable == false {
            let homeButton = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: #selector(self.homeButtonAction(_:)))
            navigationItem.setLeftBarButtonItem(homeButton, animated: true)
            navigationItem.title = "Result"
        } else {
            let backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(self.backButtonAction(_:)))
            navigationItem.setLeftBarButtonItem(backButton, animated: true)
            navigationItem.title = surveyFinished.surveyName!.name + " Result"
        }
        
        let saveButton = UIBarButtonItem(title: "Save Comments", style:.Plain, target: self, action: #selector(self.saveButtonAction(_:)))
        navigationItem.setRightBarButtonItem(saveButton, animated: true)
        
        patientNameLabel.text = surveyFinished.patient!.patientsName
        surveyNameLabel.text = surveyFinished.surveyName!.name
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        
        timeSurveyStarted.text = dateFormatter.stringFromDate(surveyFinished.dateStarted)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func homeButtonAction(sender:UIBarButtonItem){
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func backButtonAction(sender:UIBarButtonItem){
        print("backButton pressed")
        
        self.performSegueWithIdentifier("unwindToSurveyDone", sender: self)
    }
    
    func saveButtonAction(sender:UIBarButtonItem){
        print("save comments")
        
        
        
        let a = tableView.visibleCells[1] as! ResultTableViewCell
        print(a.deviceName.text!)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return surveyFinished.surveyName!.questions.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "resultCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! ResultTableViewCell
        
        let eachSurvey = surveyFinished.surveyName!.questions[indexPath.row]
        cell.questionNumber.text = String(eachSurvey.questionNumber)
        cell.deviceName.text = eachSurvey.deviceName
        
        cell.commentTextField.enabled = false
        
        if indexPath.row > surveyFinished.mainAnswer.count-1{
            cell.mainQuestionAnswer.text = "N/A"
        } else {
            let mainAnswer = surveyFinished.mainAnswer[indexPath.row]
            
            if mainAnswer.answer == true {
                cell.mainQuestionAnswer.text = "Yes"
            } else {
                cell.mainQuestionAnswer.text = "No"
            }
            
            cell.commentTextField.enabled = true
        }
        
       
        if indexPath.row > surveyFinished.confidenceAnswer.count-1{
             cell.confidentQuestionAnswer.text = "N/A"
        } else {
            let confidenceAnswer = surveyFinished.confidenceAnswer[indexPath.row]
            cell.confidentQuestionAnswer.text = String(confidenceAnswer.answer)
        }
       
        return cell
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
