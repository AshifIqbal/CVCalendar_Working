//
//  EventTableViewCell.swift
//  CVCalendar Demo
//
//  Created by Ashif Iqbal on 8/18/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet var taggedUserLabel : UILabel!
    @IBOutlet var eventDescriptionLabel : UILabel!
    @IBOutlet var eventNotesLabel : UILabel!
    @IBOutlet var eventDocumentView : UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
