//
//  PreviewCollectionViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 03/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "previewCell"

class PreviewCollectionViewController: UICollectionViewController {

    var survey : SurveyData!
    
    let config = Realm.Configuration(
        schemaVersion: 1
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()


        let homeButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(self.homeButtonAction(_:)))
        
        navigationItem.setLeftBarButton(homeButton, animated: true)

        
        navigationItem.title = survey.name + " Preview"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        splitViewController?.presentsWithGesture = false
        
        if segue.identifier == "patientDetailSegue" {
            let inputDetail = segue.destination as! InputDetailsViewController
            inputDetail.survey = survey
        }
    }
    
    @IBAction func unwindToPreview(_ sender: UIStoryboardSegue) {
        splitViewController?.presentsWithGesture = true
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return survey.questions.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "previewCell"
        let questionsData = Array(survey.questions.sorted(byProperty: "questionNumber"))
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! PreviewCollectionViewCell
    
        let thisCellData = questionsData[(indexPath as NSIndexPath).row]
        cell.deviceName.text = thisCellData.deviceName
        cell.question.text = thisCellData.question
        if thisCellData.imagePath != "" {
            cell.devicePicture.image = retrieveImage(thisCellData.imagePath)
        } else {
            cell.devicePicture.image = UIImage(named: "defaultPhoto")
        }
        return cell
    }
    
    func homeButtonAction(_ sender: UIBarButtonItem) {
        print("home button clicked")
        dismiss(animated: true, completion: nil)

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
    
    func refreshUI(){
        collectionView?.reloadData()
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}

//extension PreviewCollectionViewController: selectedSurveyDelegate {
//    func selectedSurvey(surveySelected: SurveyData) {
//        self.survey = surveySelected
//        print(self.survey.name)
//        refreshUI()
//    }
//}
