//
//  SelectSurveyTableViewCell.swift
//  Survey
//
//  Created by Alvin Tejo on 11/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit

class SelectSurveyTableViewCell: UITableViewCell {

    @IBOutlet weak var uiView: UIView!
    @IBOutlet weak var surveyName: UILabel!
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var noOfQuestion: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
