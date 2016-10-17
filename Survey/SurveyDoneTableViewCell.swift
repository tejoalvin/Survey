//
//  SurveyDoneTableViewCell.swift
//  Survey
//
//  Created by Alvin Tejo on 09/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit

class SurveyDoneTableViewCell: UITableViewCell {

    @IBOutlet weak var confidenceDone: UILabel!
    @IBOutlet weak var mainDone: UILabel!
    @IBOutlet weak var surveyName: UILabel!
    @IBOutlet weak var surveyTimestamp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
