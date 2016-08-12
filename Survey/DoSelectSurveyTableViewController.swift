//
//  DoSelectSurveyTableViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 11/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit
import RealmSwift

class DoSelectSurveyTableViewController: UITableViewController {

    let config = Realm.Configuration(
        schemaVersion: 1
    )

    var selectedRow : Int = -1
    
    var survey = [SurveyData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        
        survey = Array(realm.objects(SurveyData.self))
        
        let backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: #selector(self.backButtonAction(_:)))
        navigationItem.setLeftBarButtonItem(backButton, animated: true)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonAction(sender:UIBarButtonItem){
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func nextStage(sender: UIBarButtonItem) {
        performSegueWithIdentifier("nextPatient", sender: self)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        
        return survey.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = "selectSurveyCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! SelectSurveyTableViewCell

        let surveyData = survey[indexPath.row]
        cell.surveyName.text = surveyData.name
        cell.question.text = surveyData.questions.first!.question
        cell.noOfQuestion.text = String(surveyData.questions.count) + " questions"
        
        for index in 0..<surveyData.questions.count{
            
            if index > 2 {
                break
            } else {
                var rect = CGRect(x: 400, y: 25, width: 100, height: 100)
                rect.origin.x = 400 + CGFloat(index) * (rect.width + 20)
                let imageView = UIImageView(frame: rect)
                
                let imgPath = surveyData.questions[index].imagePath
                if  imgPath != "" {
                    imageView.image = retrieveImage(imgPath)
                } else {
                    imageView.image = UIImage(named: "defaultPhoto")
                }
                
                cell.uiView.addSubview(imageView)
            }
        }
        // Configure the cell...
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedRow = indexPath.row
        print(selectedRow)
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
        if segue.identifier == "nextPatient" {
            if selectedRow == -1 {
                sendAlertNoSelectedSurvey()
            } else {
                let nextPage = segue.destinationViewController as! InputDetailsViewController
                nextPage.survey = survey[selectedRow]
            }
            
        }
    }
    
    func sendAlertNoSelectedSurvey(){
        //create notification can't go forward
        let alert = UIAlertController(title: "Warning", message: "Please select one of the survey", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(ok)
        presentViewController(alert, animated: true, completion: nil)
        
    }

    func retrieveImage(imageFolderPath : String) -> UIImage{
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let imagePath = (paths as NSString).stringByAppendingPathComponent(imageFolderPath)
        let checkImage = NSFileManager.defaultManager()
        print(imagePath)
        var image = UIImage()
        
        if (checkImage.fileExistsAtPath(imagePath)) {
            image = UIImage(contentsOfFile: imagePath)!
        } else {
            print("Error: \(imageFolderPath) is not available")
        }
        
        return image
    }

}
