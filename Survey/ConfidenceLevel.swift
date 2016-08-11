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
        
        let notSelected = UIImage(named: "yellow")
        let selected = UIImage(named: "green")
        
        for _ in 0..<scale {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            button.setImage(notSelected, forState: .Normal)
            button.setImage(selected, forState: .Selected)
            button.setImage(selected, forState: [.Highlighted, .Selected])
            
            button.adjustsImageWhenHighlighted = false
            
            button.addTarget(self, action: #selector(ConfidenceLevel.buttonTapped(_:)), forControlEvents: .TouchUpInside)
            scaleButtons += [button]
            addSubview(button)
        }
    }
    
    override func layoutSubviews() {
        let buttonSize = 100
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize , height: buttonSize)
        
        for (index, button) in scaleButtons.enumerate() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            button.frame = buttonFrame
        }
        
        updateButtonSelectedState()
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 540, height: 160)
    }
    
    func buttonTapped(button: UIButton) {
        rating = scaleButtons.indexOf(button)! + 1
        print(rating)
        updateButtonSelectedState()
    }
    
    func updateButtonSelectedState(){
        for (index, button) in scaleButtons.enumerate(){
            button.selected = false
            if index == (rating - 1){
                button.selected = true
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
