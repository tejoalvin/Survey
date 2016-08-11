//
//  QuestionContainerViewController.swift
//  Survey
//
//  Created by Alvin Tejo on 05/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit

class QuestionContainerViewController: UIViewController {

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var devicePhoto: UIImageView!
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var confidenceScale: ConfidenceLevel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        yesButton.adjustsImageWhenHighlighted = false
        noButton.adjustsImageWhenHighlighted = false
        
        yesButton.setImage(UIImage(named: "yes Button pressed"), forState: .Selected)
        noButton.setImage(UIImage(named: "no button pressed"), forState: .Selected)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func noButtonAction(sender: UIButton) {
        
        print("noButton " + String(noButton.highlighted))
        print("yesButton " + String(yesButton.highlighted))
        
        noButton.highlighted = true
        yesButton.highlighted = false
        noButton.selected = true
        yesButton.selected = false
    }

    @IBAction func yesButtonAction(sender: UIButton) {
        yesButton.highlighted = true
        noButton.highlighted = false
        
        yesButton.selected = true
        noButton.selected = false
        
        
        print("noButton " + String(noButton.highlighted))
        print("yesButton " + String(yesButton.highlighted))
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
