//
//  SurveyViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 05/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit
import RealmSwift
import Foundation

class SurveyViewController: UIViewController {

    var survey : SurveyData!
    var patient : Patients!
    var currentSurveyAnswered : SurveyAnswered!
    var isAfterEachQuestion : Bool!
    
    var currentIndex = 0
    var currentPageIsMain = true
    var mainAnswerLastID : Int!
    var confidenceLastID : Int!
    var mainProgressValue : Float = 0
    var currentQ = 1
    
    @IBOutlet weak var mainProgress: UIProgressView!
    @IBOutlet weak var nextQuestionButton: UIButton!
    @IBOutlet weak var prevQuestionButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var totalQuestion: UILabel!
    @IBOutlet weak var currentQuestion: UILabel!
    
    let config = Realm.Configuration(
        schemaVersion: 1
    )
    
    var mainIDStart = 0
    var confidenceIDStart = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("load")
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        let mainResult = realm.objects(SurveyMainResult.self).sorted(byProperty: "id")
        let confidenceResult = realm.objects(SurveyConfidenceResult.self).sorted(byProperty: "id")
        
        if mainResult.count == 0{
            mainIDStart = 1
        } else {
            mainIDStart = mainResult.last!.id + 1
        }
        
        if confidenceResult.count == 0{
            confidenceIDStart = 1
        } else {
            confidenceIDStart = confidenceResult.last!.id + 1
        }
    
        mainProgress.setProgress(mainProgressValue, animated: true)
		//transform progress bar scale
		mainProgress.transform = mainProgress.transform.scaledBy(x: 1,y: 5)
		
        prevQuestionButton.isHidden = true
        finishButton.isHidden = true
        let questionContainer = self.childViewControllers.first as! QuestionContainerViewController
        questionContainer.deviceName.text = survey.questions[currentIndex].deviceName
        questionContainer.question.text = survey.questions[currentIndex].question
        questionContainer.confidenceScale.isHidden = true
        
        currentQuestion.text = String(currentQ)
        totalQuestion.text = String(survey.questions.count * 2)
        
        if survey.questions[currentIndex].imagePath != "" {
            questionContainer.devicePhoto.image = retrieveImage(survey.questions[currentIndex].imagePath)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendAlertNoMainAnswer(){
        //create notification can't go forward
        let alert = UIAlertController(title: "Please answer the question to continue", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
	
//	func sendAlertNoConfidenceAnswer(){
//		let alert = UIAlertController(title: "Skip this question?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
//		let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
//		let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
//		alert.addAction(cancel)
//		alert.addAction(ok)
//		presentViewController(alert, animated: true, completion: nil)
//	}
	
	
    @IBAction func nextButtonAction(_ sender: UIButton) {
        //get answer
        let questionContainer = self.childViewControllers.first as! QuestionContainerViewController
        let yesAnswer = questionContainer.yesButton.isSelected
        let noAnswer = questionContainer.noButton.isSelected
        
        let realm = try! Realm()
        
        if isAfterEachQuestion == true {
            //after each main question
            if currentIndex % 2 == 0 {
                // main answer
                //check if already answered
                if yesAnswer == false && noAnswer == false {
                    sendAlertNoMainAnswer()
                    
                } else {
                    let mainAnswer = SurveyMainResult()
                    mainAnswer.answer = yesAnswer
                    mainAnswer.id = mainIDStart + currentIndex/2
                    mainAnswer.questionNumber = survey.questions[currentIndex/2].questionNumber
                    mainAnswer.patient = patient
                    mainAnswer.surveyName = survey.name
                    
                    try! realm.write{
                        let questionAnsweredOrNot = currentSurveyAnswered.mainAnswer.filter("questionNumber = \(survey.questions[currentIndex/2].questionNumber)")
                        
                        if questionAnsweredOrNot.count == 0 {
                            currentSurveyAnswered.mainAnswer.append(mainAnswer)
                        } else {
                            realm.create(SurveyMainResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : yesAnswer],update: true)
                        }
                    }
                    
                    //later add confidence hidden
                    currentIndex += 1
                    if currentIndex == (survey.questions.count * 2 - 1){
                        nextQuestionButton.isHidden = true
                        prevQuestionButton.isHidden = false
                        finishButton.isHidden = false
                    } else {
                        nextQuestionButton.isHidden = false
                        prevQuestionButton.isHidden = false
                    }
                    
                    mainProgressValue = mainProgressValue + 1/Float(survey.questions.count*2)
                    mainProgress.setProgress(mainProgressValue, animated: true)
                    currentQ += 1
                    currentQuestion.text = String(currentQ)
                    
                    //confidence after main
                    questionContainer.deviceName.text = survey.questions[currentIndex/2].deviceName
                    
                    if noAnswer == false {
                        questionContainer.question.text = "How confident do you feel about using this?"
                    } else {
                        questionContainer.question.text = "Imagine if you use it, how confident do you feel about using this?"
                    }
					
					print("numLines " + String(questionContainer.question.numberOfLines))
					print(questionContainer.question.frame.height)
                    //                    questionContainer.question.text = survey.questions[currentIndex/2].question
                    if survey.questions[currentIndex/2].imagePath != "" {
                        questionContainer.devicePhoto.image = retrieveImage(survey.questions[currentIndex/2].imagePath)
                    }

                    let ifAnswered = currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(survey.questions[currentIndex/2].questionNumber)")
                    
                    questionContainer.confidenceScale.isHidden = false
                    questionContainer.yesButton.isHidden = true
                    questionContainer.noButton.isHidden = true
                    
                    
                    if ifAnswered.count == 0 {
                        questionContainer.confidenceScale.rating = 0
                    } else {
                        questionContainer.confidenceScale.rating = ifAnswered.first!.answer
                    }
                    
                }
            } else {
                // confidence answer
                //check if already answered
                if questionContainer.confidenceScale.rating == 0 {
					let alert = UIAlertController(title: "Skip this question?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
					let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
					let ok = UIAlertAction(title: "OK", style: .default, handler:{
						UIAlertAction in
						/* next after OK */
						let confidenceAnswer = SurveyConfidenceResult()
						confidenceAnswer.answer = questionContainer.confidenceScale.rating
						confidenceAnswer.id = self.confidenceIDStart + self.currentIndex/2
						confidenceAnswer.patient = self.patient
						confidenceAnswer.questionNumber = self.survey.questions[self.currentIndex/2].questionNumber
						confidenceAnswer.surveyName = self.survey.name
						
						try! realm.write{
							let questionAnsweredOrNot = self.currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(self.survey.questions[self.currentIndex/2].questionNumber)")
							
							if questionAnsweredOrNot.count == 0 {
								self.currentSurveyAnswered.confidenceAnswer.append(confidenceAnswer)
							} else {
								realm.create(SurveyConfidenceResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : confidenceAnswer.answer],update: true)
							}
						}
						
						//index for next question
						self.currentIndex += 1
						if self.currentIndex == (self.survey.questions.count * 2 - 1){ //later add yes no button to not hidden
							self.nextQuestionButton.isHidden = true
							self.prevQuestionButton.isHidden = false
							self.finishButton.isHidden = false
						} else {
							self.nextQuestionButton.isHidden = false
							self.prevQuestionButton.isHidden = false
						}
						
						questionContainer.confidenceScale.isHidden = true
						questionContainer.yesButton.isHidden = false
						questionContainer.noButton.isHidden = false
						
						self.mainProgressValue = self.mainProgressValue + 1/Float(self.survey.questions.count*2)
						self.mainProgress.setProgress(self.mainProgressValue, animated: true)
						self.currentQ += 1
						self.currentQuestion.text = String(self.currentQ)
						
						questionContainer.deviceName.text = self.survey.questions[self.currentIndex/2].deviceName
						questionContainer.question.text = self.survey.questions[self.currentIndex/2].question
						if self.survey.questions[self.currentIndex/2].imagePath != "" {
							questionContainer.devicePhoto.image = self.retrieveImage(self.survey.questions[self.currentIndex/2].imagePath)
						}
						
						//after confidence is main
						let ifAnswered = self.currentSurveyAnswered.mainAnswer.filter("questionNumber = \(self.survey.questions[self.currentIndex/2].questionNumber)")
						
						if ifAnswered.count == 0 {
							//check if question already answered, make the button shows
							questionContainer.noButton.isSelected = false
							questionContainer.yesButton.isSelected = false
						} else {
							questionContainer.yesButton.isSelected = ifAnswered[0].answer
							if ifAnswered[0].answer {
								questionContainer.noButton.isSelected = false
							} else {
								questionContainer.noButton.isSelected = true
							}
						}
					})
					alert.addAction(cancel)
					alert.addAction(ok)
					present(alert, animated: true, completion: nil)
					
                } else {
                    let confidenceAnswer = SurveyConfidenceResult()
                    confidenceAnswer.answer = questionContainer.confidenceScale.rating
                    confidenceAnswer.id = confidenceIDStart + currentIndex/2
                    confidenceAnswer.patient = patient
                    confidenceAnswer.questionNumber = survey.questions[currentIndex/2].questionNumber
                    confidenceAnswer.surveyName = survey.name
					
                    try! realm.write{
                        let questionAnsweredOrNot = currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(survey.questions[currentIndex/2].questionNumber)")
						
                        if questionAnsweredOrNot.count == 0 {
                            currentSurveyAnswered.confidenceAnswer.append(confidenceAnswer)
                        } else {
                            realm.create(SurveyConfidenceResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : confidenceAnswer.answer],update: true)
                        }
                    }
                    
                    //index for next question
                    currentIndex += 1
                    if currentIndex == (survey.questions.count * 2 - 1){ //later add yes no button to not hidden
                        nextQuestionButton.isHidden = true
                        prevQuestionButton.isHidden = false
                        finishButton.isHidden = false
                    } else {
                        nextQuestionButton.isHidden = false
                        prevQuestionButton.isHidden = false
                    }
                    
                    questionContainer.confidenceScale.isHidden = true
                    questionContainer.yesButton.isHidden = false
                    questionContainer.noButton.isHidden = false
                    
                    mainProgressValue = mainProgressValue + 1/Float(survey.questions.count*2)
                    mainProgress.setProgress(mainProgressValue, animated: true)
                    currentQ += 1
                    currentQuestion.text = String(currentQ)
                    
                    questionContainer.deviceName.text = survey.questions[currentIndex/2].deviceName
                    questionContainer.question.text = survey.questions[currentIndex/2].question
                    if survey.questions[currentIndex/2].imagePath != "" {
                        questionContainer.devicePhoto.image = retrieveImage(survey.questions[currentIndex/2].imagePath)
                    }
                    
                    //after confidence is main
                    let ifAnswered = currentSurveyAnswered.mainAnswer.filter("questionNumber = \(survey.questions[currentIndex/2].questionNumber)")
                    
                    if ifAnswered.count == 0 {
                        //check if question already answered, make the button shows
                        questionContainer.noButton.isSelected = false
                        questionContainer.yesButton.isSelected = false
                    } else {
                        questionContainer.yesButton.isSelected = ifAnswered[0].answer
                        if ifAnswered[0].answer {
                            questionContainer.noButton.isSelected = false
                        } else {
                            questionContainer.noButton.isSelected = true
                        }
                    }
                    
                    
                }
            }
        } else {
            //after all main questions
            
            if currentIndex < survey.questions.count {
                if yesAnswer == false && noAnswer == false {
                    sendAlertNoMainAnswer()
                    
                } else {
                    let mainAnswer = SurveyMainResult()
                    mainAnswer.answer = yesAnswer
                    mainAnswer.id = mainIDStart + currentIndex
                    mainAnswer.questionNumber = survey.questions[currentIndex].questionNumber
                    mainAnswer.patient = patient
                    mainAnswer.surveyName = survey.name
                    
                    try! realm.write{
                        let questionAnsweredOrNot = currentSurveyAnswered.mainAnswer.filter("questionNumber = \(survey.questions[currentIndex].questionNumber)")
                        
                        if questionAnsweredOrNot.count == 0 {
                            currentSurveyAnswered.mainAnswer.append(mainAnswer)
                        } else {
                            realm.create(SurveyMainResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : yesAnswer],update: true)
                        }
                    }
                    
                    currentIndex += 1
                    if currentIndex == (survey.questions.count * 2 - 1){
                        nextQuestionButton.isHidden = true
                        prevQuestionButton.isHidden = false
                        finishButton.isHidden = false
                    } else {
                        nextQuestionButton.isHidden = false
                        prevQuestionButton.isHidden = false
                    }
                    
                    print(currentIndex)
                    if currentIndex == survey.questions.count {
                        
                        questionContainer.yesButton.isHidden = true
                        questionContainer.noButton.isHidden = true
                        questionContainer.confidenceScale.isHidden = false
                        
                        mainProgressValue = mainProgressValue + 1/Float(survey.questions.count*2)
                        mainProgress.setProgress(mainProgressValue, animated: true)
                        
                        let arrayIndex = currentIndex - survey.questions.count
                        print("from main " + String(arrayIndex))
                        questionContainer.deviceName.text = survey.questions[arrayIndex].deviceName
                        questionContainer.question.text = "How confident do you feel about using this?"
                        if survey.questions[arrayIndex].imagePath != "" {
                            questionContainer.devicePhoto.image = retrieveImage(survey.questions[arrayIndex].imagePath)
                        }
                        
                        //put answer if answered before
                        let ifAnswered = currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(survey.questions[arrayIndex].questionNumber)")
                        
                        if ifAnswered.count == 0 {
                            questionContainer.confidenceScale.rating = 0
                        } else {
                            questionContainer.confidenceScale.rating = ifAnswered.first!.answer
                        }

                    } else {
                        questionContainer.yesButton.isHidden = false
                        questionContainer.noButton.isHidden = false
                        questionContainer.confidenceScale.isHidden = true
                        
                        mainProgressValue = mainProgressValue + 1/Float(survey.questions.count*2)
                        mainProgress.setProgress(mainProgressValue, animated: true)
                        currentQ += 1
                        currentQuestion.text = String(currentQ)
                        
                        questionContainer.deviceName.text = survey.questions[currentIndex].deviceName
                        questionContainer.question.text = survey.questions[currentIndex].question
                        if survey.questions[currentIndex].imagePath != "" {
                            questionContainer.devicePhoto.image = retrieveImage(survey.questions[currentIndex].imagePath)
                        }
                        
                        let ifAnswered = currentSurveyAnswered.mainAnswer.filter("questionNumber = \(survey.questions[currentIndex].questionNumber)")
                        
                        if ifAnswered.count == 0 {
                            //check if question already answered, make the button shows
                            questionContainer.noButton.isSelected = false
                            questionContainer.yesButton.isSelected = false
                        } else {
                            questionContainer.yesButton.isSelected = ifAnswered[0].answer
                            if ifAnswered[0].answer {
                                questionContainer.noButton.isSelected = false
                            } else {
                                questionContainer.noButton.isSelected = true
                            }
                        }
                    }
                }
            } else {
                if questionContainer.confidenceScale.rating == 0 {
					let alert = UIAlertController(title: "Skip this question?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
					let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
					let ok = UIAlertAction(title: "OK", style: .default, handler: {
						UIAlertAction in
						var arrayIndex = self.currentIndex - self.survey.questions.count
						
						let confidenceAnswer = SurveyConfidenceResult()
						confidenceAnswer.answer = questionContainer.confidenceScale.rating
						confidenceAnswer.id = self.confidenceIDStart + arrayIndex
						confidenceAnswer.patient = self.patient
						confidenceAnswer.questionNumber = self.survey.questions[arrayIndex].questionNumber
						confidenceAnswer.surveyName = self.survey.name
						
						try! realm.write{
							let questionAnsweredOrNot = self.currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(self.survey.questions[arrayIndex].questionNumber)")
							
							if questionAnsweredOrNot.count == 0 {
								self.currentSurveyAnswered.confidenceAnswer.append(confidenceAnswer)
							} else {
								realm.create(SurveyConfidenceResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : confidenceAnswer.answer],update: true)
							}
						}
						
						self.currentIndex += 1
						if self.currentIndex == (self.survey.questions.count * 2 - 1){
							self.nextQuestionButton.isHidden = true
							self.prevQuestionButton.isHidden = false
							self.finishButton.isHidden = false
						} else {
							self.nextQuestionButton.isHidden = false
							self.prevQuestionButton.isHidden = false
						}
						print(self.currentIndex)
						
						arrayIndex = self.currentIndex - self.survey.questions.count
						
						self.mainProgressValue = self.mainProgressValue + 1/Float(self.survey.questions.count*2)
						self.mainProgress.setProgress(self.mainProgressValue, animated: true)
						self.currentQ += 1
						self.currentQuestion.text = String(self.currentQ)
						
						questionContainer.yesButton.isHidden = true
						questionContainer.noButton.isHidden = true
						questionContainer.confidenceScale.isHidden = false
						
						print("from confidence " + String(arrayIndex))
						questionContainer.deviceName.text = self.survey.questions[arrayIndex].deviceName
						questionContainer.question.text = "How confident do you feel about using this?"
						if self.survey.questions[arrayIndex].imagePath != "" {
							questionContainer.devicePhoto.image = self.retrieveImage(self.survey.questions[arrayIndex].imagePath)
						}
						
						//put answer if answered before
						let ifAnswered = self.currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(self.survey.questions[arrayIndex].questionNumber)")
						
						if ifAnswered.count == 0 {
							questionContainer.confidenceScale.rating = 0
						} else {
							questionContainer.confidenceScale.rating = ifAnswered.first!.answer
						}

					})
					alert.addAction(cancel)
					alert.addAction(ok)
					present(alert, animated: true, completion: nil)

                } else {
                    var arrayIndex = currentIndex - survey.questions.count
					
                    let confidenceAnswer = SurveyConfidenceResult()
                    confidenceAnswer.answer = questionContainer.confidenceScale.rating
                    confidenceAnswer.id = confidenceIDStart + arrayIndex
                    confidenceAnswer.patient = patient
                    confidenceAnswer.questionNumber = survey.questions[arrayIndex].questionNumber
                    confidenceAnswer.surveyName = survey.name
					
                    try! realm.write{
                        let questionAnsweredOrNot = currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(survey.questions[arrayIndex].questionNumber)")
                        
                        if questionAnsweredOrNot.count == 0 {
                            currentSurveyAnswered.confidenceAnswer.append(confidenceAnswer)
                        } else {
                            realm.create(SurveyConfidenceResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : confidenceAnswer.answer],update: true)
                        }
                    }
                    
                    currentIndex += 1
                    if currentIndex == (survey.questions.count * 2 - 1){
                        nextQuestionButton.isHidden = true
                        prevQuestionButton.isHidden = false
                        finishButton.isHidden = false
                    } else {
                        nextQuestionButton.isHidden = false
                        prevQuestionButton.isHidden = false
                    }
                    print(currentIndex)
                    
                    arrayIndex = currentIndex - survey.questions.count

                    mainProgressValue = mainProgressValue + 1/Float(survey.questions.count*2)
                    mainProgress.setProgress(mainProgressValue, animated: true)
                    currentQ += 1
                    currentQuestion.text = String(currentQ)
                    
                    questionContainer.yesButton.isHidden = true
                    questionContainer.noButton.isHidden = true
                    questionContainer.confidenceScale.isHidden = false
                    
                    print("from confidence " + String(arrayIndex))
                    questionContainer.deviceName.text = survey.questions[arrayIndex].deviceName
                    questionContainer.question.text = "How confident do you feel about using this?"
                    if survey.questions[arrayIndex].imagePath != "" {
                        questionContainer.devicePhoto.image = retrieveImage(survey.questions[arrayIndex].imagePath)
                    }
                    
                    //put answer if answered before
                    let ifAnswered = currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(survey.questions[arrayIndex].questionNumber)")
                    
                    if ifAnswered.count == 0 {
                        questionContainer.confidenceScale.rating = 0
                    } else {
                        questionContainer.confidenceScale.rating = ifAnswered.first!.answer
                    }

                }
            }
			
        }
    }
    
    @IBAction func prevButtonAction(_ sender: UIButton) {
		 let realm = try! Realm()
		 let questionContainer = self.childViewControllers.first as! QuestionContainerViewController
		if questionContainer.yesButton.isHidden == false {
			//main question
			if questionContainer.yesButton.isSelected == true || questionContainer.noButton.isSelected == true {
				//question answered
				let yesAnswer = questionContainer.yesButton.isSelected
				
				let mainAnswer = SurveyMainResult()
				mainAnswer.answer = yesAnswer
				mainAnswer.patient = patient
				mainAnswer.surveyName = survey.name
				
				if isAfterEachQuestion == true {
					//after each
					mainAnswer.id = mainIDStart + currentIndex/2
					mainAnswer.questionNumber = survey.questions[currentIndex/2].questionNumber
					
					try! realm.write{
						
						let questionAnsweredOrNot = currentSurveyAnswered.mainAnswer.filter("questionNumber = \(survey.questions[currentIndex/2].questionNumber)")
						
						if questionAnsweredOrNot.count == 0 {
							currentSurveyAnswered.mainAnswer.append(mainAnswer)
						} else {
							realm.create(SurveyMainResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : mainAnswer.answer],update: true)
						}
					}
					
				} else {
					//after all
					mainAnswer.id = mainIDStart + currentIndex
					mainAnswer.questionNumber = survey.questions[currentIndex].questionNumber
					
					try! realm.write{
						let questionAnsweredOrNot = currentSurveyAnswered.mainAnswer.filter("questionNumber = \(survey.questions[currentIndex].questionNumber)")
						
						if questionAnsweredOrNot.count == 0 {
							currentSurveyAnswered.mainAnswer.append(mainAnswer)
						} else {
							realm.create(SurveyMainResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : mainAnswer.answer],update: true)
						}
					}
				}
				
			}
		} else {
			//confidence question
			let realm = try! Realm()
			
			let questionContainer = self.childViewControllers.first as! QuestionContainerViewController
			
			if questionContainer.confidenceScale.rating != 0 {
				let confidenceAnswer = SurveyConfidenceResult()
				confidenceAnswer.answer = questionContainer.confidenceScale.rating
				confidenceAnswer.patient = patient
				confidenceAnswer.surveyName = survey.name
				
				if isAfterEachQuestion == true {
					//after each
					confidenceAnswer.id = confidenceIDStart + currentIndex/2
					confidenceAnswer.questionNumber = survey.questions[currentIndex/2].questionNumber
					
					try! realm.write{
						
						let questionAnsweredOrNot = currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(survey.questions[currentIndex/2].questionNumber)")
						
						if questionAnsweredOrNot.count == 0 {
							currentSurveyAnswered.confidenceAnswer.append(confidenceAnswer)
						} else {
							realm.create(SurveyConfidenceResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : confidenceAnswer.answer],update: true)
						}
					}
					
				} else {
					//after all
					let index = currentIndex - survey.questions.count
					confidenceAnswer.id = confidenceIDStart + index
					confidenceAnswer.questionNumber = survey.questions[index].questionNumber
					
					try! realm.write{
						
						let questionAnsweredOrNot = currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(survey.questions[index].questionNumber)")
						
						if questionAnsweredOrNot.count == 0 {
							currentSurveyAnswered.confidenceAnswer.append(confidenceAnswer)
						} else {
							realm.create(SurveyConfidenceResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : confidenceAnswer.answer],update: true)
						}
					}
					
				}
				
			}
		}

		
		
		
		currentIndex -= 1
        if currentIndex == 0 {
            prevQuestionButton.isHidden = true
            nextQuestionButton.isHidden = false
            finishButton.isHidden = true
        } else {
            prevQuestionButton.isHidden = false
            nextQuestionButton.isHidden = false
            finishButton.isHidden = true
        }
		
        if isAfterEachQuestion == true {
            if currentIndex % 2 == 0{
                //main
                print("prev after, main")
                let questionContainer = self.childViewControllers.first as! QuestionContainerViewController
				
                questionContainer.yesButton.isHidden = false
                questionContainer.noButton.isHidden = false
                questionContainer.confidenceScale.isHidden = true
				
                mainProgressValue = mainProgressValue - 1/Float(survey.questions.count*2)
                mainProgress.setProgress(mainProgressValue, animated: true)
                currentQ -= 1
                currentQuestion.text = String(currentQ)
				
                questionContainer.deviceName.text = survey.questions[currentIndex/2].deviceName
                questionContainer.question.text = survey.questions[currentIndex/2].question
				
                if survey.questions[currentIndex/2].imagePath != "" {
                    questionContainer.devicePhoto.image = retrieveImage(survey.questions[currentIndex/2].imagePath)
                }
				
                let ifAnswered = currentSurveyAnswered.mainAnswer.filter("questionNumber = \(survey.questions[currentIndex/2].questionNumber)")
				
                if ifAnswered.count == 0 {
                    //check if question already answered, make the button shows
                    questionContainer.noButton.isSelected = false
                    questionContainer.yesButton.isSelected = false
                } else {
                    questionContainer.yesButton.isSelected = ifAnswered[0].answer
                    if ifAnswered[0].answer {
                        questionContainer.noButton.isSelected = false
                    } else {
                        questionContainer.noButton.isSelected = true
                    }
                }

            } else {
                //confidence
                
                print("prev after, confidence")
                print("currentIndex : " + String(currentIndex))
                print("currentIndex/2 : " + String(currentIndex/2))
                
                let questionContainer = self.childViewControllers.first as! QuestionContainerViewController
                
                questionContainer.yesButton.isHidden = true
                questionContainer.noButton.isHidden = true
                questionContainer.confidenceScale.isHidden = false
                
                mainProgressValue = mainProgressValue - 1/Float(survey.questions.count*2)
                mainProgress.setProgress(mainProgressValue, animated: true)
                currentQ -= 1
                currentQuestion.text = String(currentQ)
                
                questionContainer.deviceName.text = survey.questions[currentIndex/2].deviceName
                
                let mainAnswerForSameDevice = currentSurveyAnswered.mainAnswer[currentIndex/2].answer
                
                if mainAnswerForSameDevice == false {
                    questionContainer.question.text = "How confident do you feel about using this?"
                } else {
                    questionContainer.question.text = "Imagine if you use it, how confident do you feel about using this?"
                }
                
                if survey.questions[currentIndex/2].imagePath != "" {
                    questionContainer.devicePhoto.image = retrieveImage(survey.questions[currentIndex/2].imagePath)
                }
                
                let ifAnswered = currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(survey.questions[currentIndex/2].questionNumber)")
                
                
                if ifAnswered.count == 0 {
                    questionContainer.confidenceScale.rating = 0
                } else {
                    questionContainer.confidenceScale.rating = ifAnswered.first!.answer
                }

                
            }
        } else {
            //after all main questions
            if currentIndex < survey.questions.count {
                //Main Question
                
                print("prev all, main")
                let questionContainer = self.childViewControllers.first as! QuestionContainerViewController
                
                questionContainer.yesButton.isHidden = false
                questionContainer.noButton.isHidden = false
                questionContainer.confidenceScale.isHidden = true
                
                mainProgressValue = mainProgressValue - 1/Float(survey.questions.count*2)
                mainProgress.setProgress(mainProgressValue, animated: true)
                currentQ -= 1
                currentQuestion.text = String(currentQ)
                
                questionContainer.deviceName.text = survey.questions[currentIndex].deviceName
                questionContainer.question.text = survey.questions[currentIndex].question
                
                if survey.questions[currentIndex].imagePath != "" {
                    questionContainer.devicePhoto.image = retrieveImage(survey.questions[currentIndex].imagePath)
                }
                
                let ifAnswered = currentSurveyAnswered.mainAnswer.filter("questionNumber = \(survey.questions[currentIndex].questionNumber)")
                
                if ifAnswered.count == 0 {
                    //check if question already answered, make the button shows
                    questionContainer.noButton.isSelected = false
                    questionContainer.yesButton.isSelected = false
                } else {
                    questionContainer.yesButton.isSelected = ifAnswered[0].answer
                    if ifAnswered[0].answer {
                        questionContainer.noButton.isSelected = false
                    } else {
                        questionContainer.noButton.isSelected = true
                    }
                }

                
            } else {
                //Confidence Question
                
                print("prev all, confidence")
                // turn off the yes / no button
                let arrayIndex = currentIndex - survey.questions.count
                
                let questionContainer = self.childViewControllers.first as! QuestionContainerViewController
                
                questionContainer.yesButton.isHidden = true
                questionContainer.noButton.isHidden = true
                questionContainer.confidenceScale.isHidden = false
                
                mainProgressValue = mainProgressValue - 1/Float(survey.questions.count*2)
                mainProgress.setProgress(mainProgressValue, animated: true)
                currentQ -= 1
                currentQuestion.text = String(currentQ)
                
                questionContainer.deviceName.text = survey.questions[arrayIndex].deviceName
                questionContainer.question.text = "How confident do you feel about using this?"

                if survey.questions[arrayIndex].imagePath != "" {
                    questionContainer.devicePhoto.image = retrieveImage(survey.questions[arrayIndex].imagePath)
                }
                
                let ifAnswered = currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(survey.questions[arrayIndex].questionNumber)")
                
                if ifAnswered.count == 0 {
                    questionContainer.confidenceScale.rating = 0
                } else {
                    questionContainer.confidenceScale.rating = ifAnswered.first!.answer
                }
            }
        }
        
//        if currentIndex == 0{
//            prevQuestionButton.hidden = true
//            nextQuestionButton.hidden = false
//            finishButton.hidden = true
//        } else {
//            prevQuestionButton.hidden = false
//            nextQuestionButton.hidden = false
//            finishButton.hidden = true
//        }
//        
//        let questionContainer = self.childViewControllers.first as! QuestionContainerViewController
//        questionContainer.deviceName.text = survey.questions[currentIndex].deviceName
//        questionContainer.question.text = survey.questions[currentIndex].question
//        
//        if survey.questions[currentIndex].imagePath != "" {
//            questionContainer.devicePhoto.image = retrieveImage(survey.questions[currentIndex].imagePath)
//        }
//        
//        let ifAnswered = currentSurveyAnswered.mainAnswer.filter("questionNumber = \(survey.questions[currentIndex].questionNumber)")
//        
//        if ifAnswered.count == 0 {
//            //check if question already answered, make the button shows
//            questionContainer.noButton.selected = false
//            questionContainer.yesButton.selected = false
//        } else {
//            questionContainer.yesButton.selected = ifAnswered[0].answer
//            if ifAnswered[0].answer {
//                questionContainer.noButton.selected = false
//            } else {
//                questionContainer.noButton.selected = true
//            }
//        }
    }
    
    @IBAction func finishButtonAction(_ sender: UIButton) {
        //save last question (confidence question)
        
        let realm = try! Realm()
        
        let questionContainer = self.childViewControllers.first as! QuestionContainerViewController
        
        if questionContainer.confidenceScale.rating == 0 { // later need to change to the rating scale
			let alert = UIAlertController(title: "Skip this question?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
			let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
			let ok = UIAlertAction(title: "OK", style: .default, handler: {
				UIAlertAction in
				
				self.navigationController?.setNavigationBarHidden(false, animated: true)
				let confidenceAnswer = SurveyConfidenceResult()
				confidenceAnswer.answer = questionContainer.confidenceScale.rating
				confidenceAnswer.id = self.confidenceIDStart + self.currentIndex/2
				confidenceAnswer.patient = self.patient
				confidenceAnswer.questionNumber = self.survey.questions[self.currentIndex/2].questionNumber
				confidenceAnswer.surveyName = self.survey.name
				
				try! realm.write{
					let questionAnsweredOrNot = self.currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(self.survey.questions[self.currentIndex/2].questionNumber)")
					
					if questionAnsweredOrNot.count == 0 {
						self.currentSurveyAnswered.confidenceAnswer.append(confidenceAnswer)
					} else {
						realm.create(SurveyConfidenceResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : confidenceAnswer.answer],update: true)
					}
				}
				
				self.performSegue(withIdentifier: "finishSurvey", sender: self)
			})
			alert.addAction(cancel)
			alert.addAction(ok)
			present(alert, animated: true, completion: nil)
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            let confidenceAnswer = SurveyConfidenceResult()
            confidenceAnswer.answer = questionContainer.confidenceScale.rating
            confidenceAnswer.id = confidenceIDStart + currentIndex/2
            confidenceAnswer.patient = patient
            confidenceAnswer.questionNumber = survey.questions[currentIndex/2].questionNumber
            confidenceAnswer.surveyName = survey.name
            
            try! realm.write{
                let questionAnsweredOrNot = currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(survey.questions[currentIndex/2].questionNumber)")
                
                if questionAnsweredOrNot.count == 0 {
                    currentSurveyAnswered.confidenceAnswer.append(confidenceAnswer)
                } else {
                    realm.create(SurveyConfidenceResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : confidenceAnswer.answer],update: true)
                }
            }
        }
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "finishSurvey" {
            let result = segue.destination.childViewControllers.first as! ResultViewController
            result.isFromResultTable = false
            result.surveyFinished = currentSurveyAnswered
        } else if segue.identifier == "abortSurvey" {
            
             let realm = try! Realm()
            
            let questionContainer = self.childViewControllers.first as! QuestionContainerViewController
            if questionContainer.yesButton.isHidden == false {
                //main question
                if questionContainer.yesButton.isSelected == true || questionContainer.noButton.isSelected == true {
                    //question answered
                    let yesAnswer = questionContainer.yesButton.isSelected
                    
                    let mainAnswer = SurveyMainResult()
                    mainAnswer.answer = yesAnswer
                    mainAnswer.patient = patient
                    mainAnswer.surveyName = survey.name
                    
                    if isAfterEachQuestion == true {
                        //after each
                        mainAnswer.id = mainIDStart + currentIndex/2
                        mainAnswer.questionNumber = survey.questions[currentIndex/2].questionNumber
                        
                        try! realm.write{
                        
                            let questionAnsweredOrNot = currentSurveyAnswered.mainAnswer.filter("questionNumber = \(survey.questions[currentIndex/2].questionNumber)")
                            
                            if questionAnsweredOrNot.count == 0 {
                                currentSurveyAnswered.mainAnswer.append(mainAnswer)
                            } else {
                                realm.create(SurveyMainResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : mainAnswer.answer],update: true)
                            }
                        }
                        
                    } else {
                        //after all
                        mainAnswer.id = mainIDStart + currentIndex
                        mainAnswer.questionNumber = survey.questions[currentIndex].questionNumber
                        
                        try! realm.write{
                            let questionAnsweredOrNot = currentSurveyAnswered.mainAnswer.filter("questionNumber = \(survey.questions[currentIndex].questionNumber)")
                            
                            if questionAnsweredOrNot.count == 0 {
                                currentSurveyAnswered.mainAnswer.append(mainAnswer)
                            } else {
                                realm.create(SurveyMainResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : mainAnswer.answer],update: true)
                            }
                        }
                    }
                   
                }
            } else {
                //confidence question
                let realm = try! Realm()
                
                let questionContainer = self.childViewControllers.first as! QuestionContainerViewController
                
                if questionContainer.confidenceScale.rating != 0 {
                    let confidenceAnswer = SurveyConfidenceResult()
                    confidenceAnswer.answer = questionContainer.confidenceScale.rating
                    confidenceAnswer.patient = patient
                    confidenceAnswer.surveyName = survey.name
                    
                    if isAfterEachQuestion == true {
                        //after each
                        confidenceAnswer.id = confidenceIDStart + currentIndex/2
                        confidenceAnswer.questionNumber = survey.questions[currentIndex/2].questionNumber
                        
                        try! realm.write{
                            
                            let questionAnsweredOrNot = currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(survey.questions[currentIndex/2].questionNumber)")
                            
                            if questionAnsweredOrNot.count == 0 {
                                currentSurveyAnswered.confidenceAnswer.append(confidenceAnswer)
                            } else {
                                realm.create(SurveyConfidenceResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : confidenceAnswer.answer],update: true)
                            }
                        }

                    } else {
                        //after all
                        let index = currentIndex - survey.questions.count
                        confidenceAnswer.id = confidenceIDStart + index
                        confidenceAnswer.questionNumber = survey.questions[index].questionNumber
                        
                        try! realm.write{
                            
                            let questionAnsweredOrNot = currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(survey.questions[index].questionNumber)")
                            
                            if questionAnsweredOrNot.count == 0 {
                                currentSurveyAnswered.confidenceAnswer.append(confidenceAnswer)
                            } else {
                                realm.create(SurveyConfidenceResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : confidenceAnswer.answer],update: true)
                            }
                        }

                    }
                    
                }
            }
            
            let result = segue.destination.childViewControllers.first as! ResultViewController
            result.isFromResultTable = false
            result.surveyFinished = currentSurveyAnswered
        }
    }
}

//            currentIndex += 1
//            if currentIndex == (survey.questions.count * 2 - 1){
//                nextQuestionButton.hidden = true
//                prevQuestionButton.hidden = false
//                finishButton.hidden = false
//            } else {
//                nextQuestionButton.hidden = false
//                prevQuestionButton.hidden = false
//            }
////
//            if currentIndex < survey.questions.count {
//                //do main
//                print(currentIndex)
//                questionContainer.deviceName.text = survey.questions[currentIndex].deviceName
//                questionContainer.question.text = survey.questions[currentIndex].question
//                if survey.questions[currentIndex].imagePath != "" {
//                    questionContainer.devicePhoto.image = retrieveImage(survey.questions[currentIndex].imagePath)
//                }
//
//                let ifAnswered = currentSurveyAnswered.mainAnswer.filter("questionNumber = \(survey.questions[currentIndex].questionNumber)")
//
//                if ifAnswered.count == 0 {
//                    //check if question already answered, make the button shows
//                    questionContainer.noButton.selected = false
//                    questionContainer.yesButton.selected = false
//                } else {
//                    questionContainer.yesButton.selected = ifAnswered[0].answer
//                    if ifAnswered[0].answer {
//                        questionContainer.noButton.selected = false
//                    } else {
//                        questionContainer.noButton.selected = true
//                    }
//                }
//
//            } else {
//                //do confidence
//
//                print(currentIndex)
////                questionContainer.yesButton.hidden = true
////                questionContainer.noButton.hidden = true
//
//                let arrayIndex = currentIndex - survey.questions.count
//                print(arrayIndex)
//                questionContainer.deviceName.text = survey.questions[arrayIndex].deviceName
//                questionContainer.question.text = "How confident do you feel about using this?"
//                if survey.questions[arrayIndex].imagePath != "" {
//                    questionContainer.devicePhoto.image = retrieveImage(survey.questions[arrayIndex].imagePath)
//                }
//
//                //put answer if answered before
//                let ifAnswered = currentSurveyAnswered.confidenceAnswer.filter("questionNumber = \(survey.questions[arrayIndex].questionNumber)")
//
//                /*
//                put answer to rating scale later
//                if ifAnswered.count == 0 {
//                    //check if question already answered, make the button shows
//                    questionContainer.noButton.selected = false
//                    questionContainer.yesButton.selected = false
//                } else {
//                    questionContainer.yesButton.selected = ifAnswered[0].answer
//                    if ifAnswered[0].answer {
//                        questionContainer.noButton.selected = false
//                    } else {
//                        questionContainer.noButton.selected = true
//                    }
//                }
//                */
//            }
//        }

//        //check if already answered
//        if yesAnswer == false && noAnswer == false {
//            //create notification can't go forward
//            let alert = UIAlertController(title: "Warning", message: "Answer the question", preferredStyle: UIAlertControllerStyle.Alert)
//            let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
//            alert.addAction(ok)
//            presentViewController(alert, animated: true, completion: nil)
//        } else {
//            //put answer into realm & check whether already has answer then update
//            let mainAnswer = SurveyMainResult()
//            mainAnswer.answer = yesAnswer
//            mainAnswer.id = mainIDStart + currentIndex
//            mainAnswer.questionNumber = survey.questions[currentIndex].questionNumber
//            mainAnswer.patient = patient
//            mainAnswer.surveyName = survey
//
//            try! realm.write{
//                let questionAnsweredOrNot = currentSurveyAnswered.mainAnswer.filter("questionNumber = \(survey.questions[currentIndex].questionNumber)")
//
//                if questionAnsweredOrNot.count == 0 {
//                    currentSurveyAnswered.mainAnswer.append(mainAnswer)
//                } else {
//                    realm.create(SurveyMainResult.self, value: ["id": questionAnsweredOrNot[0].id, "answer" : yesAnswer],update: true)
//                }
//            }
//
//            //index for next question
//            currentIndex += 1
//            if currentIndex == (survey.questions.count * 2 - 1){
//                nextQuestionButton.hidden = true
//                prevQuestionButton.hidden = false
//                finishButton.hidden = false
//            } else {
//                nextQuestionButton.hidden = false
//                prevQuestionButton.hidden = false
//            }
//
//            if isAfterEachQuestion == true {
//                //set after each question
//                print(currentIndex)
//                if currentIndex % 2 == 0{
//                    //main
//                    print(currentIndex % 2)
//                    questionContainer.deviceName.text = survey.questions[currentIndex/2].deviceName
//                    questionContainer.question.text = survey.questions[currentIndex/2].question
//                    if survey.questions[currentIndex/2].imagePath != "" {
//                        questionContainer.devicePhoto.image = retrieveImage(survey.questions[currentIndex/2].imagePath)
//                    }
//                } else {
//                    //confidence
//                    questionContainer.deviceName.text = survey.questions[currentIndex/2].deviceName
//
//                    if noAnswer == true {
//                        questionContainer.question.text = "How confident do you feel about using this?"
//                    } else {
//                        questionContainer.question.text = "Imagine if you use it, how confident do you feel about using this?"
//                    }
//
////                    questionContainer.question.text = survey.questions[currentIndex/2].question
//                    if survey.questions[currentIndex/2].imagePath != "" {
//                        questionContainer.devicePhoto.image = retrieveImage(survey.questions[currentIndex/2].imagePath)
//                    }
//                }
//            } else {
//                //set after all
//
//            }

//            questionContainer.deviceName.text = survey.questions[currentIndex].deviceName
//            questionContainer.question.text = survey.questions[currentIndex].question
//            if survey.questions[currentIndex].imagePath != "" {
//                questionContainer.devicePhoto.image = retrieveImage(survey.questions[currentIndex].imagePath)
//            }

//            let ifAnswered = currentSurveyAnswered.mainAnswer.filter("questionNumber = \(survey.questions[currentIndex/2].questionNumber)")
//
//            if ifAnswered.count == 0 {
//                //check if question already answered, make the button shows
//                questionContainer.noButton.selected = false
//                questionContainer.yesButton.selected = false
//            } else {
//                questionContainer.yesButton.selected = ifAnswered[0].answer
//                if ifAnswered[0].answer {
//                    questionContainer.noButton.selected = false
//                } else {
//                    questionContainer.noButton.selected = true
//                }
//            }
