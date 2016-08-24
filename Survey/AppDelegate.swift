//
//  AppDelegate.swift
//  Survey
//
//  Created by Alvin Tejo on 25/07/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
//        let colorView = UIView()
//        colorView.backgroundColor = UIColor.lightGrayColor()
		
        // use UITableViewCell.appearance() to configure
        // the default appearance of all UITableViewCells in your app
//        UITableViewCell.appearance().selectedBackgroundView = colorView
		
        let launchedBefore = NSUserDefaults.standardUserDefaults().boolForKey("launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        }
        else {
            print("First launch, setting NSUserDefault.")
            populateRealm()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "launchedBefore")
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func createDir(surveyName : String){
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])
        let dirPath = documentsPath.URLByAppendingPathComponent(surveyName)
        print(dirPath)
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(dirPath.path!, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
    }
    
    func copyImage(surveyName : String, filenameToBe : String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        print("paths")
        print(paths)
        
        let imageFolderPath = surveyName + "/" + filenameToBe
        
        let imagePath = (paths as NSString).stringByAppendingPathComponent(imageFolderPath)
        
        let getImage = UIImage(named: filenameToBe)
        
        if UIImageJPEGRepresentation(getImage!, 1.0)!.writeToFile(imagePath, atomically: true){
            print("file saved")
        }else{
            print("file save failed")
        }
        
        return imageFolderPath
    }

    func populateRealm(){
        let survey1 = SurveyData()
        survey1.name = "Default Survey"
        survey1.lastUpdated = NSDate()
        survey1.id = 1
        
        let survey2 = SurveyData()
        survey2.name = "Dummy Survey"
        survey2.lastUpdated = NSDate()
        survey2.id = 2
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        let patient1 = Patients()
        patient1.patientsName = "Homer Simpson"
        patient1.dateOfBirth = dateFormatter.dateFromString("Oct 5, 1960")!
        patient1.isMale = true
        patient1.id = 1
        
        let patient2 = Patients()
        patient2.patientsName = "Ash Ketchum"
        patient2.dateOfBirth = dateFormatter.dateFromString("Mar 13, 1980")!
        patient2.isMale = true
        patient2.id = 2
        
        let patient3 = Patients()
        patient3.patientsName = "Lyo Dumb"
        patient3.dateOfBirth = dateFormatter.dateFromString("Dec 10, 1950")!
        patient3.isMale = false
        patient3.id = 3
        
        let config = Realm.Configuration(
            schemaVersion: 1
        )
        
        Realm.Configuration.defaultConfiguration = config
        
        let questionString = "Have you used this in the last month?"
        var deviceName = ["Television", "Television Remote Control", "Electronic Programme Guide", "DVD Player", "Washing Machine", "Microwave", "Vending Machine"
                        , "Ticket Machine", "Cash Machine", "Mobile Telephone for calls", "Mobile Telephone for text messages", "Email", "Skype", "Online Shopping",
                          "Facebook or Twitter", "Games", "Speech and Language Practice", "Information"]
        
        var device = ["Telly", "Bank", "PS4"]
        
        let realm = try! Realm()
        
        try! realm.write{
            realm.add(patient1)
            realm.add(patient2)
            realm.add(patient3)
            
            realm.add(survey1)
            createDir(survey1.name)
            
            
            realm.add(survey2)
            createDir(survey2.name)
            
            for i in 0...deviceName.count-1{
                let question = QuestionData()
                question.question = questionString
                question.deviceName = deviceName[i]
                question.questionNumber = i+1
                question.surveyName = survey1
                question.imagePath = copyImage(survey1.name, filenameToBe: question.deviceName)
                question.id = i+1
                //pKey = surveyName-questionNumber i.e. survey1-2
//                question.pKey = survey1.name+"-"+String(i+1)
                
                survey1.questions.append(question)
                
//                realm.add(question)
            }
            
            var index = realm.objects(QuestionData.self).count + 1
            
            for i in 0...device.count-1{
                let q = QuestionData()
                q.question = questionString
                q.deviceName = device[i]
                q.questionNumber = i+1
                q.surveyName = survey2
                q.id = index
                //pKey = surveyName-questionNumber i.e. survey1-2
//                q.pKey = survey2.name+"-"+String(i+1)
                
                survey2.questions.append(q)
                index += 1
            }
        }
    }

}

