//
//  SectionItem.swift
//  CVCalendar Demo
//
//  Created by Ashif Iqbal on 8/18/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

class SectionItem: NSObject {

    var day : Int = 0
    var month : Int = 0
    var year : Int = 0
//    var date : CVDate?
    
    var date : CVDate? {
        didSet {
            self.day = date!.day
            self.year = date!.year
            self.month = date!.month
        }
    }
}
