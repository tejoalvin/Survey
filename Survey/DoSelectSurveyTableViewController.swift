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
        
        let backButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(self.backButtonAction(_:)))
        navigationItem.setLeftBarButton(backButton, animated: true)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonAction(_ sender:UIBarButtonItem){
        dismiss(animated: true, completion: nil)
    }

    @IBAction func nextStage(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "nextPatient", sender: self)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        
        return survey.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "selectSurveyCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SelectSurveyTableViewCell

        let surveyData = survey[(indexPath as NSIndexPath).row]
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
				
                imageView.contentMode = UIViewContentMode.scaleAspectFit
				
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = (indexPath as NSIndexPath).row
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "nextPatient" {
            if selectedRow == -1 {
                sendAlertNoSelectedSurvey()
            } else {
                let nextPage = segue.destination as! InputDetailsViewController
                nextPage.survey = survey[selectedRow]
				nextPage.isFromNewSurveySelect = true
            }
            
        }
    }
	
	@IBAction func unwindToSelectSurvey(_ sender: UIStoryboardSegue){
		print("unwind To Select Survey")
	}
	
    func sendAlertNoSelectedSurvey(){
        //create notification can't go forward
        let alert = UIAlertController(title: "Please select one of the questionnaire", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
    }

    func retrieveImage(_ imageFolderPath : String) -> UIImage{
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let imagePath = (paths as NSString).appendingPathComponent(imageFolderPath)
        let checkImage = FileManager.default
        print(imagePath)
        var image = UIImage()
        
        if (checkImage.fileExists(atPath: imagePath)) {
            image = UIImage(contentsOfFile: imagePath)!
        } else {
            print("Error: \(imageFolderPath) is not available")
        }
        
        return image
    }

}
