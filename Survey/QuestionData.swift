//
//  QuestionData.swift
//  Survey
//
//  Created by Alvin Tejo on 26/07/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//
import Foundation
import RealmSwift

class QuestionData: Object {
    dynamic var question = ""
    dynamic var imagePath = ""
    dynamic var deviceName = ""
    dynamic var surveyName : SurveyData?
    dynamic var id = 0
    dynamic var questionNumber = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class SurveyData : Object {
    dynamic var name = ""
    let questions = List<QuestionData>()
    dynamic var lastUpdated = Date()
    dynamic var id = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class SurveyMainResult : Object{
    dynamic var questionNumber = 0
    dynamic var answer = false
    dynamic var surveyName = ""
    dynamic var id = 0
    dynamic var patient : Patients?
    dynamic var comments = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class SurveyConfidenceResult : Object {
    dynamic var questionNumber = 0
    dynamic var answer = 0
    dynamic var surveyName = ""
    dynamic var id = 0
    dynamic var patient : Patients?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class SurveyAnswered : Object {
    dynamic var dateStarted = Date()
    dynamic var dateFinished : Date? = nil
    let mainAnswer = List<SurveyMainResult>()
    let confidenceAnswer = List<SurveyConfidenceResult>()
    dynamic var id = 0
    dynamic var patient : Patients?
    dynamic var surveyName = ""
	dynamic var question = ""
	let devices = List<deviceName>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class deviceName : Object {
	dynamic var value = ""
}

class Patients : Object {
    dynamic var patientsName = ""
    dynamic var dateOfBirth = Date()
    dynamic var recentStroke : Date? = nil
    dynamic var isMale = true
    dynamic var id = 0
    let surveyDone = List<SurveyAnswered>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
