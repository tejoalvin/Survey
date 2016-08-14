//
//  PatientListTableViewCell.swift
//  Survey
//
//  Created by Alvin Tejo on 04/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit

class PatientListTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
	@IBOutlet weak var lastSurveyDone: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
