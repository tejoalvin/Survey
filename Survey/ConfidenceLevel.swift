//
//  ConfidenceLevel.swift
//  Survey
//
//  Created by Alvin Tejo on 08/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit

class ConfidenceLevel: UIView {

    var rating = 0{
        didSet{
            setNeedsLayout()
        }
    }
    var scaleButtons = [UIButton]()
    var scale = 5
    var spacing = 10
    
    //Mark: Initialisation
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        for index in 0..<scale {
			let con = "confidence" + String(index+1)
			let confidence = UIImage(named: con)
			
			let conSel = con + " selected"
			let confidenceSelected = UIImage(named: conSel)
			
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            button.setImage(confidence, for: UIControlState())
            button.setImage(confidenceSelected, for: .selected)
            button.setImage(confidenceSelected, for: [.highlighted, .selected])
            
            button.adjustsImageWhenHighlighted = false
            
            button.addTarget(self, action: #selector(ConfidenceLevel.buttonTapped(_:)), for: .touchUpInside)
            scaleButtons += [button]
            addSubview(button)
        }
		
		let notConfident = UILabel(frame: CGRect(x:0, y:90, width:100, height:80))
		notConfident.numberOfLines = 4
		notConfident.text = "Not confident at all"
		notConfident.lineBreakMode = NSLineBreakMode.byWordWrapping
		
		let confident = UILabel(frame: CGRect(x: 400, y: 90, width: 100, height: 60))
		confident.numberOfLines = 2
		confident.text = "Very Confident"
		confident.lineBreakMode = NSLineBreakMode.byWordWrapping
		
		addSubview(notConfident)
		addSubview(confident)
    }
    
    override func layoutSubviews() {
        let buttonSize = 100
        var buttonFrame = CGRect(x: 20, y: 0, width: buttonSize , height: buttonSize)
        
        for (index, button) in scaleButtons.enumerated() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize))
            button.frame = buttonFrame
        }
        
        updateButtonSelectedState()
    }
    
    override var intrinsicContentSize : CGSize {
        return CGSize(width: 500, height: 180)
    }
    
    func buttonTapped(_ button: UIButton) {
        rating = scaleButtons.index(of: button)! + 1
        print(rating)
        updateButtonSelectedState()
    }
    
    func updateButtonSelectedState(){
        for (index, button) in scaleButtons.enumerated(){
            button.isSelected = false
            if index == (rating - 1){
                button.isSelected = true
            }
        }
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
