//
//  ResultPatientTableViewCell.swift
//  Survey
//
//  Created by Alvin Tejo on 07/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit

class ResultPatientTableViewCell: UITableViewCell {

    @IBOutlet weak var patientName: UILabel!
    @IBOutlet weak var surveyDone: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
