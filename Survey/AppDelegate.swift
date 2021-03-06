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


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
		
		
        let colorView = UIView()
        colorView.backgroundColor = colorView.tintColor
		
//         use UITableViewCell.appearance() to configure
//         the default appearance of all UITableViewCells in your app
        UITableViewCell.appearance().selectedBackgroundView = colorView
		
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            print("Not first launch.")
        }
        else {
            print("First launch, setting NSUserDefault.")
            populateRealm()
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func createDir(_ surveyName : String){
        let documentsPath = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let dirPath = documentsPath.appendingPathComponent(surveyName)
        print(dirPath)
        do {
            try FileManager.default.createDirectory(atPath: dirPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
    }
    
    func copyImage(_ surveyName : String, filenameToBe : String) -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print("paths")
        print(paths)
        
        let imageFolderPath = surveyName + "/" + filenameToBe
        
        let imagePath = (paths as NSString).appendingPathComponent(imageFolderPath)
        
        let getImage = UIImage(named: filenameToBe)
        
        if (try? UIImageJPEGRepresentation(getImage!, 1.0)!.write(to: URL(fileURLWithPath: imagePath), options: [.atomic])) != nil{
            print("file saved")
        }else{
            print("file save failed")
        }
        
        return imageFolderPath
    }

    func populateRealm(){
        let survey1 = SurveyData()
        survey1.name = "Aphasia Technology Questionnaire Default"
        survey1.lastUpdated = Date()
        survey1.id = 1
        
        let survey2 = SurveyData()
        survey2.name = "Dummy Survey"
        survey2.lastUpdated = Date()
        survey2.id = 2
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
//        let patient1 = Patients()
//        patient1.patientsName = "Homer Simpson"
//        patient1.dateOfBirth = dateFormatter.dateFromString("Oct 5, 1960")!
//        patient1.isMale = true
//        patient1.id = 1
//        
//        let patient2 = Patients()
//        patient2.patientsName = "Ash Ketchum"
//        patient2.dateOfBirth = dateFormatter.dateFromString("Mar 13, 1980")!
//        patient2.isMale = true
//        patient2.id = 2
//        
//        let patient3 = Patients()
//        patient3.patientsName = "Lyo Dumb"
//        patient3.dateOfBirth = dateFormatter.dateFromString("Dec 10, 1950")!
//        patient3.isMale = false
//        patient3.id = 3
		
        let config = Realm.Configuration(
            schemaVersion: 1
        )
        
        Realm.Configuration.defaultConfiguration = config
        
        let questionString = "Have you used this in the last month?"
        let deviceNameString = ["Television", "Television Remote Control", "Electronic Programme Guide", "DVD/CD Player", "Washing Machine", "Microwave", "Vending Machine"
                        , "Ticket Machine", "Cash Machine", "Mobile Telephone for calls", "Mobile Telephone for text messages", "Mobile/Computer/iPad/ for Email", "Mobile/Computer/iPad/ for Skype", "Mobile/Computer/iPad/ for Online Shopping",
                          "Mobile/Computer/iPad/ for Facebook or Twitter", "Mobile/Computer/iPad/ for Games", "Mobile/Computer/iPad/ for Speech and Language Practice", "Mobile/Computer/iPad/ for Information"]
		
		let deviceName = ["Television", "Television Remote Control", "Electronic Programme Guide", "DVD Player", "Washing Machine", "Microwave", "Vending Machine"
			, "Ticket Machine", "Cash Machine", "Mobile Telephone for calls", "Mobile Telephone for text messages", "Email", "Skype", "Online Shopping",
			  "Facebook or Twitter", "Games", "Speech and Language Practice", "Information"]
		
        var device = ["Telly", "Bank", "PS4"]
        
        let realm = try! Realm()
        
        try! realm.write{
//            realm.add(patient1)
//            realm.add(patient2)
//            realm.add(patient3)
			
            realm.add(survey1)
            createDir(survey1.name)
            
            
            realm.add(survey2)
            createDir(survey2.name)
            
            for i in 0...deviceName.count-1{
                let question = QuestionData()
                question.question = questionString
                question.deviceName = deviceNameString[i]
                question.questionNumber = i+1
                question.surveyName = survey1
                question.imagePath = copyImage(survey1.name, filenameToBe: deviceName[i])
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

