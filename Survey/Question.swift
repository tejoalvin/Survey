//
//  Question.swift
//  Survey
//
//  Created by Alvin Tejo on 25/07/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//
import RealmSwift
import UIKit

class Question{
    
//    var pKey : String
    var deviceName:String
    var image:UIImage
    var id:Int
    var questionNumber : Int
    
    init(deviceName: String, image: UIImage, id: Int, questionNumber: Int){
//        , pKey: String){
        self.deviceName = deviceName
        self.image = image
        self.id = id
        self.questionNumber = questionNumber
//        self.pKey = pKey
    }
    
}