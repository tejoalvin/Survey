//
//  SurveyListTableViewCell.swift
//  Survey
//
//  Created by Alvin Tejo on 29/07/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit

class SurveyListTableViewCell: UITableViewCell {

    @IBOutlet weak var surveyNameLabel: UILabel!
    @IBOutlet weak var numberOfQuestionsAvailable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
