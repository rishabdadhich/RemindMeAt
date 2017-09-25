//
//  ReminderTableViewCell.swift
//  Remind Me At
//
//  Created by Rishabh on 30/06/1939 Saka.
//  Copyright © 1939 Saka rishi. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    ///Configure the cell: it sets the titleLabel and the accessory Type
    func configure(withReminder reminder: Reminder) {
        
        self.titleLabel.text = reminder.text
        //if is completes
        if reminder.isCompleted {
            //show the checkmark
            self.accessoryType = .checkmark
        } else {
            //otherwise the arrow
            self.accessoryType = .disclosureIndicator
        }
    }
    
}
