//
//  WeekEvent.swift
//  CVCalendar Demo
//
//  Created by Ashif Iqbal on 8/18/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit

class Event: NSObject {
    
    var eventId : Int = 0
    var name : String = ""
    
    var startTime : String = ""
    var endTime : String = ""
    
    var fileName : String = ""
    var filePath : String = ""
    
    var eventDescription : String = ""
}

class ExchangeDay: NSObject {
    
    enum ExchangeType {
        case Sent
        case Received
    }
    
    var exchangeId : Int = 0
    
    var type : ExchangeType = .Received
}

class WeekEvent: NSObject {

    var dateStr : String = ""
    var date : CVDate?
    
    var events = [Event]()
    var pattern : [AnyObject]?
    var exchangeRequest : [AnyObject]?
    var patternExchangeRequest : [AnyObject]?
}
