////
////  Preview.swift
////  Survey
////
////  Created by Alvin Tejo on 25/07/2016.
////  Copyright © 2016 Alvin Tejo. All rights reserved.
////
//
//import UIKit
//
//class Preview: UIScrollView {
//
//    /*
//    // Only override drawRect: if you perform custom drawing.
//    // An empty implementation adversely affects performance during animation.
//    override func drawRect(rect: CGRect) {
//        // Drawing code
//    }
//    */
//
//    
//    var dummySurvey = [Question]()
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        loadDummySurvey()
//        createPreviewPage()
//    }
//    
//    func createPreviewPage(){
//        
//        var height = 40
//        
//        for i in 0...dummySurvey.count{
//            
//            let text = UILabel(frame: CGRect(x: 0, y: height, width: 280, height: 40))
//            text.text = dummySurvey[i].question
//            
//            height += 60
//            
//            let image = UIImageView(frame: CGRect(x: 0, y: height, width: 280, height: 280))
//            image.image = dummySurvey[i].image
//            
//            height += 300
//            
//            let deviceName = UILabel(frame: CGRect(x: 0, y: height, width: 280, height: 40))
//            deviceName.text = dummySurvey[i].deviceName
//            
//            height += 60
//            
//            addSubview(text)
//            addSubview(image)
//            addSubview(deviceName)
//        }
//        
//    }
//    
//    func loadDummySurvey(){
//        let defaultPhoto = UIImage(named: "defaultPhoto")
//        let dummyQ = Question(question: "Have you use this in the last month", deviceName: "Telly", image: defaultPhoto!)
//        
//        dummySurvey += [dummyQ, dummyQ, dummyQ]
//    }
//}
