//
//  DetailsViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 28/07/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit
import RealmSwift

class QuestionsDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var qNumber: UILabel!
    @IBOutlet weak var deviceName: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var questionData : QuestionData!
    var isNewQuestion : Bool!
    var question:Question!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        deviceName.delegate = self
        
        // Do any additional setup after loading the view.
        qNumber.text = "Question " + String(questionData.questionNumber)
        deviceName.text = questionData.deviceName
        
        if !questionData.imagePath.isEmpty{
            imageView.image = retrieveImage(questionData.imagePath)
        }
        
        textChecker()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func cancelNavigation(sender: UIBarButtonItem) {
//        let isPresentingNewQuestion = presentingViewController is UITabBarController
//        print(presentingViewController)
//        if isPresentingNewQuestion{
//            dismissViewControllerAnimated(true, completion: nil)
//        } else {
//            navigationController!.popViewControllerAnimated(true)
//        }
//    }
    
	@IBAction func selectImage(_ sender: UITapGestureRecognizer) {
		print("image clicked")
		deviceName.resignFirstResponder()
		// UIImagePickerController is a view controller that lets a user pick media from their photo library.
		let imagePickerController = UIImagePickerController()
		imagePickerController.sourceType = .photoLibrary
		
		imagePickerController.delegate = self
		
		present(imagePickerController, animated: true, completion: nil)
	}


    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
//        let selectedImage = image
//        
//        imageView.image = selectedImage
//        presentViewController(picker, animated: true, completion: nil)
//    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
//        let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
//        let imagePath =  imageURL.path!
//        let localPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(imagePath)
//        print(localPath)
        
        // Set photoImageView to display the selected image.
        imageView.image = selectedImage
        
        // Dismiss the picker.
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

    func textFieldDidEndEditing(_ textField: UITextField) {
		deviceName.resignFirstResponder()
        textChecker()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        deviceName.resignFirstResponder()
        return true
    }
    
    func textChecker(){
        if deviceName.text == "" {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		print("going in prepare")
		
        if saveButton == sender as? UIBarButtonItem{
            let name = self.deviceName.text ?? ""
            let picture = self.imageView.image
//            let pKey = questionData!.pKey

            question = Question(deviceName: name, image: picture!, id: questionData.id, questionNumber: questionData.questionNumber)
//                , pKey: pKey)
			print("going in saveButton === sender")
        }
    }
    
    }
