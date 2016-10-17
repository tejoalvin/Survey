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
        
        yesButton.setImage(UIImage(named: "yes Button pressed"), for: .selected)
        noButton.setImage(UIImage(named: "no button pressed"), for: .selected)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func noButtonAction(_ sender: UIButton) {
        
        print("noButton " + String(noButton.isHighlighted))
        print("yesButton " + String(yesButton.isHighlighted))
        
        noButton.isHighlighted = true
        yesButton.isHighlighted = false
        noButton.isSelected = true
        yesButton.isSelected = false
    }

    @IBAction func yesButtonAction(_ sender: UIButton) {
        yesButton.isHighlighted = true
        noButton.isHighlighted = false
        
        yesButton.isSelected = true
        noButton.isSelected = false
        
        
        print("noButton " + String(noButton.isHighlighted))
        print("yesButton " + String(yesButton.isHighlighted))
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
