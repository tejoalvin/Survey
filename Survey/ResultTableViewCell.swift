//
//  ResultTableViewCell.swift
//  Survey
//
//  Created by Alvin Tejo on 09/08/2016.
//  Copyright © 2016 Alvin Tejo. All rights reserved.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var mainQuestionAnswer: UILabel!
    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var questionNumber: UILabel!
    @IBOutlet weak var confidentQuestionAnswer: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
