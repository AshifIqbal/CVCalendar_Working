//
//  ViewController.swift
//  CVCalendar Demo
//
//  Created by Мак-ПК on 1/3/15.
//  Copyright (c) 2015 GameApp. All rights reserved.
//

import UIKit
import QuartzCore

let kTaBarBackgroundColor = "#578700"

enum WeekType {
    case Odd
    case Even
}

@objc enum SOBWeekday: Int {
    case SOBSunday = 6
    case SOBMonday = 0
    case SOBTuesday = 1
    case SOBWednesday = 2
    case SOBThursday = 3
    case SOBFriday = 4
    case SOBSaturday = 5
}


class ViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var calendarView: CVCalendarView!
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var daysOutSwitch: UISwitch!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var weekNumber: UILabel!
    @IBOutlet weak var eventListView: UITableView!
    
    var sectionTitleArray : NSMutableArray = NSMutableArray()
    var sectionContentDict : NSMutableDictionary = NSMutableDictionary()
    var arrayForBool : NSMutableArray = NSMutableArray()
    
    var parsingDone = false
    var firstLaunch = true
    var currentSelectedWeek : Int = 0
    
    var shouldShowDaysOut = true
    var animationFinished = true
    
    var monthEvents = [MonthEvent]()
    var weekEvents = [WeekEvent]()
    
    var oddPattern = [Int]()
    var evenPattern = [Int]()
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let rotate = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        let translate = CGAffineTransformMakeTranslation((self.monthLabel.bounds.height / 2)-(self.monthLabel.bounds.width / 2), (self.monthLabel.bounds.width / 2)-(self.monthLabel.bounds.height / 2))
        self.monthLabel.transform = CGAffineTransformConcat(rotate, translate)

        monthLabel.text = CVDate(date: NSDate()).globalDescription
        
        oddPattern  = [0, 0, 1, 1, 1, 0, 0]
        evenPattern = [1, 1, 0, 0, 0, 1, 1]
        
        
        self.eventListView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        headerView.layer.borderColor = UIColor.blackColor().CGColor
        headerView.layer.borderWidth = 0.5
        
        headerView.layer.cornerRadius = 1.0
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOpacity = 0.4
        headerView.layer.shadowRadius = 1.0
        headerView.layer.shadowOffset = CGSizeMake(0.0, 1.0)
        
        //
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.timeZone = NSTimeZone.systemTimeZone()
        dateFormatter.locale =  NSLocale.currentLocale()
        //                    dateFormatter.dateFormat = "dd-MM-YYYY" // this format doesn't work. Have to use the below one.
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        let date : NSDate = dateFormatter.dateFromString("2016-01-1")!
        
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierISO8601)!
        myCalendar.firstWeekday = 2
        //        let myComponents = myCalendar.components(.CalendarUnitWeekOfYear, fromDate: self.date)
        let myComponents = myCalendar.components(.CalendarUnitWeekOfYear | .CalendarUnitYearForWeekOfYear, fromDate: date)
        let week = myComponents.weekOfYear
        
        println("week number of year \(week)")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        calendarView.commitCalendarViewUpdate()
        menuView.commitMenuViewUpdate()
        
        if !parsingDone
        {
            self.parseJsonForMonth()
        }
    }
}

// MARK: - CVCalendarViewDelegate

extension ViewController: CVCalendarViewDelegate
{
    
    // TODO: Implement pattern selection color for values
    
    // START: Implement pattern selection color for values 
    
    func preliminaryView(viewOnDayView dayView: DayView) -> UIView
    {
        // Implement pattern days here
        
//        var circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Rect)
        
        var circleView : CVAuxiliaryView!
        
//        circleView.fillColor = UIColor.whiteColor()
        
        let date : CVDate? = dayView.date
        if date != nil
        {
            if dayView.date.weekOfYear() % 2 == 0 // even week of year
            {
                evenPattern = [1, 1, 0, 0, 0, 1, 1]
                
                let index = self.getChangedWeekIndexFor(dayView.date.getDayOfWeek())
                
                if index >= 0
                {
                    if evenPattern[index] == 1
                    {
                        if index == 0
                        {
                            let val = oddPattern[oddPattern.count-1]
                            if val == 1
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Rect)
                                
                                circleView.fillColor = self.colorWithHexString(kTaBarBackgroundColor)
                            }
                            else
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.RightFill)
                                
                                circleView.fillColor = self.colorWithHexString(kTaBarBackgroundColor)
                                circleView.oppositeFillColor = .colorFromCode(0xCCCCCC)
                            }
                        }
                        else
                        {
                            let val = evenPattern[index - 1]
                            if val == 1
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Rect)
                                
                                circleView.fillColor = self.colorWithHexString(kTaBarBackgroundColor)
                            }
                            else
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.RightFill)
                                
                                circleView.fillColor = self.colorWithHexString(kTaBarBackgroundColor)
                                circleView.oppositeFillColor = .colorFromCode(0xCCCCCC)
                            }
                        }
                    }
                    else
                    {
                        if index == 0
                        {
                            let val = oddPattern[oddPattern.count-1]
                            if val == 1
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.LeftFill)
                                circleView.fillColor = self.colorWithHexString(kTaBarBackgroundColor)
                                circleView.oppositeFillColor = .colorFromCode(0xCCCCCC)
                            }
                            else
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Rect)
                                circleView.fillColor = .colorFromCode(0xCCCCCC)
                            }
                        }
                        else
                        {
                            let val = evenPattern[index - 1]
                            if val == 1
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.LeftFill)
                                circleView.fillColor = self.colorWithHexString(kTaBarBackgroundColor)
                                circleView.oppositeFillColor = .colorFromCode(0xCCCCCC)
                            }
                            else
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Rect)
                                circleView.fillColor = .colorFromCode(0xCCCCCC)
                            }
                        }
                    }
                }
            }
            else                                  // odd week of year
            {
                oddPattern  = [0, 0, 1, 1, 1, 0, 0]
                
                let index = self.getChangedWeekIndexFor(dayView.date.getDayOfWeek())
                
                if index >= 0
                {
                    if oddPattern[index] == 1
                    {
                        if index == 0
                        {
                            let val = evenPattern[evenPattern.count-1]
                            if val == 1
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Rect)
                                circleView.fillColor = self.colorWithHexString(kTaBarBackgroundColor)
                            }
                            else
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.RightFill)
                                circleView.fillColor = self.colorWithHexString(kTaBarBackgroundColor)
                                circleView.oppositeFillColor = .colorFromCode(0xCCCCCC)
                            }
                        }
                        else
                        {
                            let val = oddPattern[index - 1]
                            if val == 1
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Rect)
                                circleView.fillColor = self.colorWithHexString(kTaBarBackgroundColor)
                            }
                            else
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.RightFill)
                                circleView.fillColor = self.colorWithHexString(kTaBarBackgroundColor)
                                circleView.oppositeFillColor = .colorFromCode(0xCCCCCC)
                            }
                        }
                    }
                    else
                    {
                        if index == 0
                        {
                            let val = evenPattern[evenPattern.count-1]
                            if val == 1
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.LeftFill)
                                circleView.fillColor = self.colorWithHexString(kTaBarBackgroundColor)
                                circleView.oppositeFillColor = .colorFromCode(0xCCCCCC)
                            }
                            else
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Rect)
                                circleView.fillColor = .colorFromCode(0xCCCCCC)
                            }
                        }
                        else
                        {
                            let val = oddPattern[index - 1]
                            if val == 1
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.LeftFill)
                                circleView.fillColor = self.colorWithHexString(kTaBarBackgroundColor)
                                circleView.oppositeFillColor = .colorFromCode(0xCCCCCC)
                            }
                            else
                            {
                                circleView = CVAuxiliaryView(dayView: dayView, rect: dayView.bounds, shape: CVShape.Rect)
                                circleView.fillColor = .colorFromCode(0xCCCCCC)
                            }
                        }
                    }
                }
            }
        }
        
        if (dayView.isCurrentDay)
        {
            circleView.borderStrokeColor = UIColor.redColor()            
        }
        else
        {
            circleView.borderStrokeColor = UIColor.clearColor()
        }
        
        return circleView
    }
    
    func getChangedWeekIndexFor(day : Int)->Int{
     
        switch (day)
        {
            case CVCalendarWeekday.Monday.rawValue : return SOBWeekday.SOBMonday.rawValue
            case CVCalendarWeekday.Tuesday.rawValue : return SOBWeekday.SOBTuesday.rawValue
            case CVCalendarWeekday.Wednesday.rawValue : return SOBWeekday.SOBWednesday.rawValue
            case CVCalendarWeekday.Thursday.rawValue : return SOBWeekday.SOBThursday.rawValue
            case CVCalendarWeekday.Friday.rawValue : return SOBWeekday.SOBFriday.rawValue
            case CVCalendarWeekday.Saturday.rawValue : return SOBWeekday.SOBSaturday.rawValue
            case CVCalendarWeekday.Sunday.rawValue : return SOBWeekday.SOBSunday.rawValue
            default: return -1
        }
    }
    
    func preliminaryView(shouldDisplayOnDayView dayView: DayView) -> Bool
    {
        if (dayView.isCurrentDay) {
            return true
        }
        
        return true
    }
    
    // END: Implement pattern selection color for values
    
    func supplementaryView(viewOnDayView dayView: DayView) -> UIView
    {
        let π = M_PI
        
        // draw style for marked dates
        let ringSpacing: CGFloat = 3.0
        let ringInsetWidth: CGFloat = 1.0
        let ringVerticalOffset: CGFloat = 1.0
        var ringLayer: CAShapeLayer!
        let ringLineWidth: CGFloat = 4.0
//        let ringLineColour: UIColor = .blueColor()
        let ringLineColour: UIColor = .clearColor()
        
        var newView = UIView(frame: dayView.bounds)
        
        let diameter: CGFloat = (newView.bounds.width) - ringSpacing
        let radius: CGFloat = diameter / 2.0
        
        let rect = CGRectMake(newView.frame.midX-radius, newView.frame.midY-radius-ringVerticalOffset, diameter, diameter)
        
        ringLayer = CAShapeLayer()
        newView.layer.addSublayer(ringLayer)
        
        ringLayer.fillColor = nil
        ringLayer.lineWidth = ringLineWidth
        ringLayer.strokeColor = ringLineColour.CGColor
        
        var ringLineWidthInset: CGFloat = CGFloat(ringLineWidth/2.0) + ringInsetWidth
        let ringRect: CGRect = CGRectInset(rect, ringLineWidthInset, ringLineWidthInset)
        let centrePoint: CGPoint = CGPointMake(ringRect.midX, ringRect.midY)
        let startAngle: CGFloat = CGFloat(-π/2.0)
        let endAngle: CGFloat = CGFloat(π * 2.0) + startAngle
        let ringPath: UIBezierPath = UIBezierPath(arcCenter: centrePoint, radius: ringRect.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        ringLayer.path = ringPath.CGPath
        ringLayer.frame = newView.layer.bounds
        
        return newView
    }
    
    func supplementaryView(shouldDisplayOnDayView dayView: DayView) -> Bool
    {
//        if (Int(arc4random_uniform(3)) == 1)
//        {
//            return true
//        }
        return false
    }
}


extension ViewController: CVCalendarViewDelegate {
    func presentationMode() -> CalendarMode {
        return .MonthView
    }
    
    func firstWeekday() -> Weekday {
        return .Monday
    }
    
    func shouldShowWeekdaysOut() -> Bool {
        return shouldShowDaysOut
    }
    
    func didSelectDayView(dayView: CVCalendarDayView) {
        let date = dayView.date
        
        println("\(calendarView.presentedDate.commonDescription) is selected!")
        
        println("current week number of month \(dayView.date.week) week number of year \(dayView.date.weekOfYear())")
        
//        println("Days for week index \(date.weekOfYear())")
        
        self.weekNumber.text = "Week \(date.weekOfYear())"
        
        if currentSelectedWeek != dayView.date.weekOfYear()
        {
            self.parseJsonForWeek()
            
            currentSelectedWeek = dayView.date.weekOfYear()
            
            arrayForBool = ["0","0","0","0","0","0","0"]
            
            sectionTitleArray = NSMutableArray()
            sectionContentDict = NSMutableDictionary()
            
            for i in 0..<dayView.weekView.dayViews.count
            {
                let item  = dayView.weekView.dayViews[i] as CVCalendarDayView
                
                println("day \(item.date.day), \(item.date.month), \(item.date.year)")
                
                var sectionItem : SectionItem = SectionItem()
                sectionItem.date = item.date
                
                sectionTitleArray.addObject(sectionItem)
                
                for j in 0..<self.weekEvents.count
                {
                    let week  = self.weekEvents[j]
                    if (item.date?.year == week.date?.year && item.date?.month == week.date?.month)
                    {
                        if (item.date?.day == week.date?.day)
                        {
                            var secItem = sectionTitleArray.objectAtIndex(i) as! SectionItem
                            var key : String = "\(self.getDayNameForDate(secItem.date!))"
                            
                            sectionContentDict.setObject(week.events, forKey:key)
                        }
                    }
                }
            }
            
            self.eventListView.reloadData()
        }
    }
    
    // calls after month/view update
    func presentedDateUpdated(date: CVDate) {
        
        if monthLabel.text != date.globalDescription && self.animationFinished {
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.animationFinished = false
                
                }) { _ in
                    
                    self.animationFinished = true
                    self.monthLabel.text = date.globalDescription
            }
        }
        
//        println("week no index \(date.week)")
        
        if firstLaunch
        {
            firstLaunch = false
            
            let calendarMonth : CVCalendarMonthView = CVCalendarMonthView(calendarView: self.calendarView, date: date.date)
//            println("calendarMonth date \(date.date.description)")
            let weekView : CVCalendarWeekView = CVCalendarWeekView(monthView: calendarMonth, index: date.week - 1) // subtract 1 from day's month week number as the index while creating a view from scratch uses a zero based index key
            //
//            println("weekView index \(date.week)")
            let dayView :CVCalendarDayView = CVCalendarDayView(weekView: weekView, weekdayIndex: date.getDayOfWeek())
            
            self.didSelectDayView(dayView)
        }
        
        /*
        if monthLabel.text != date.globalDescription && self.animationFinished {
            
            let updatedMonthLabel = UILabel()
            updatedMonthLabel.textColor = monthLabel.textColor
            updatedMonthLabel.font = monthLabel.font
            updatedMonthLabel.textAlignment = .Center
            updatedMonthLabel.text = date.globalDescription
            updatedMonthLabel.sizeToFit()
            updatedMonthLabel.alpha = 0
            updatedMonthLabel.center = self.monthLabel.center
            
            let offset = CGFloat(48)
//            updatedMonthLabel.transform = CGAffineTransformMakeTranslation(0, offset)
//            updatedMonthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
            
            UIView.animateWithDuration(0.35, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.animationFinished = false
//                self.monthLabel.transform = CGAffineTransformMakeTranslation(0, -offset)
//                self.monthLabel.transform = CGAffineTransformMakeScale(1, 0.1)
                self.monthLabel.alpha = 0
                
                updatedMonthLabel.alpha = 1
                updatedMonthLabel.transform = CGAffineTransformIdentity
                
                }) { _ in
                    
                    self.animationFinished = true
                    self.monthLabel.frame = updatedMonthLabel.frame
                    self.monthLabel.text = updatedMonthLabel.text
//                    self.monthLabel.transform = CGAffineTransformIdentity
                    self.monthLabel.alpha = 1
                    updatedMonthLabel.removeFromSuperview()
            }
            
            self.view.insertSubview(updatedMonthLabel, aboveSubview: self.monthLabel)
        }
        */
    }
    
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    func dotMarker(shouldShowOnDayView dayView: CVCalendarDayView) -> Bool {
        
//        self.calendarView.contentController
        
        let day = dayView.date.day
        
        for i in 0..<self.monthEvents.count
        {
            let item  = self.monthEvents[i]
            if (item.date?.year == dayView.date.year && item.date?.month == dayView.date.month)
            {
                if (item.date?.day == day)
                {
                    return true
                }
            }
        }
        
        return false
    }
    
    func dotMarker(colorOnDayView dayView: CVCalendarDayView) -> [UIColor] {
        let day = dayView.date.day
        
        // set dot color
        /*
        let red = CGFloat(arc4random_uniform(600) / 255)
        let green = CGFloat(arc4random_uniform(600) / 255)
        let blue = CGFloat(arc4random_uniform(600) / 255)
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        */
        
        let color = UIColor.greenColor()
        
        var numberOfDots = 0
        
        for i in 0..<self.monthEvents.count
        {
            let item  = self.monthEvents[i]
            if (item.date?.day == day)
            {
                numberOfDots = item.events
            }
        }

        switch(numberOfDots) {
        case 2:
            return [color, color]
        case 3:
            return [color, color, color]
        case 4:
            return [color, color, UIColor.redColor()]
        default:
            return [color] // return 1 dot
        }
    }
    
    func dotMarker(shouldMoveOnHighlightingOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
}

// MARK: - CVCalendarViewAppearanceDelegate

extension ViewController: CVCalendarViewAppearanceDelegate {
    func dayLabelPresentWeekdayInitallyBold() -> Bool {
        return false
    }
    
    func spaceBetweenDayViews() -> CGFloat {
        return 2
    }
    
    /// Highlighted state background & alpha.
    func dayLabelWeekdayHighlightedBackgroundColor() -> UIColor{
     
        return UIColor.blackColor()
    }
//    func dayLabelWeekdayHighlightedBackgroundAlpha() -> CGFloat{
//        
//    }
    func dayLabelPresentWeekdayHighlightedBackgroundColor() -> UIColor{
        return UIColor.blackColor()
    }
//    func dayLabelPresentWeekdayHighlightedBackgroundAlpha() -> CGFloat{
//        
//    }
    
    /// Selected state background & alpha.
    func dayLabelWeekdaySelectedBackgroundColor() -> UIColor{
//        return UIColor.greenColor()
        return UIColor.clearColor()
    }
    func dayLabelWeekdaySelectedBackgroundAlpha() -> CGFloat{
        
        return 0.7
    }
    func dayLabelPresentWeekdaySelectedBackgroundColor() -> UIColor{
        
//        return UIColor.blueColor()
        return UIColor.clearColor()
    }
    func dayLabelPresentWeekdaySelectedBackgroundAlpha() -> CGFloat{
        
        return 0.7
    }
}

// MARK: - CVCalendarMenuViewDelegate

extension ViewController: CVCalendarMenuViewDelegate {
    // firstWeekday() has been already implemented.
}

// MARK: - IB Actions

extension ViewController {
    @IBAction func switchChanged(sender: UISwitch) {
        if sender.on {
            calendarView.changeDaysOutShowingState(false)
            shouldShowDaysOut = true
        } else {
            calendarView.changeDaysOutShowingState(true)
            shouldShowDaysOut = false
        }
    }
    
    @IBAction func todayMonthView() {
        calendarView.toggleCurrentDayView()
    }
    
    /// Switch to WeekView mode.
    @IBAction func toWeekView(sender: AnyObject) {
        calendarView.changeMode(.WeekView)
    }
    
    /// Switch to MonthView mode.
    @IBAction func toMonthView(sender: AnyObject) {
        calendarView.changeMode(.MonthView)
    }
    
    @IBAction func loadPrevious(sender: AnyObject) {
        calendarView.loadPreviousView()
    }
    
    
    @IBAction func loadNext(sender: AnyObject) {
        calendarView.loadNextView()
    }
}

// MARK: - UITableView Delegate and Datasource

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitleArray.count
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        
        if(arrayForBool.objectAtIndex(section).boolValue == true)
        {
            var tps = sectionTitleArray.objectAtIndex(section) as! SectionItem
            var key : String = "\(self.getDayNameForDate(tps.date!))"
            var count1 = (sectionContentDict.objectForKey(key)) as? NSArray
            if let array = count1
            {
                return array.count
            }
        }
        return 0;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(arrayForBool.objectAtIndex(indexPath.section).boolValue == true){
            return 88
        }
        
        return 2;
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 30))
        headerView.backgroundColor = UIColor.whiteColor()
        headerView.tag = section
        
        let headerImageView = UIView(frame: CGRectMake(10, 5, 20, 20))
        headerImageView.backgroundColor = self.colorWithHexString(kTaBarBackgroundColor)
        
        headerImageView.layer.borderColor = UIColor.clearColor().CGColor
        headerImageView.layer.borderWidth = 1.0
        headerImageView.layer.cornerRadius = headerImageView.frame.size.width/2
        headerImageView.layer.masksToBounds = true
        
        headerView.addSubview(headerImageView)
        
        let sectionItem : SectionItem = self.sectionTitleArray[section] as! SectionItem
        
        let headerString = UILabel(frame: CGRect(x: headerImageView.frame.origin.x + headerImageView.frame.size.width + 5, y: 2, width: tableView.frame.size.width - 10 - headerImageView.frame.size.width, height: 15)) as UILabel
//        headerString.text = sectionTitleArray.objectAtIndex(section) as? String
        headerString.text = "\(self.getDayNameForDate(sectionItem.date!)) \(sectionItem.date!.day)"
        headerString.font = UIFont.systemFontOfSize(15.0)
//        headerString.backgroundColor = UIColor.greenColor()
        headerView.addSubview(headerString)
        
        let headerubString = UILabel(frame: CGRect(x: headerString.frame.origin.x, y: headerString.frame.origin.y + headerString.frame.size.height + 2, width: headerString.frame.size.width, height: 11)) as UILabel
        
        headerubString.text = "\(self.getMonthNameForDate(sectionItem.date!)) \(sectionItem.date!.year)"
        headerubString.font = UIFont.systemFontOfSize(10.0)
//        headerubString.backgroundColor = UIColor.yellowColor()
        headerView.addSubview(headerubString)
        
        let headerTapped = UITapGestureRecognizer (target: self, action:"sectionHeaderTapped:")
        headerView .addGestureRecognizer(headerTapped)
        
        headerView.layer.borderColor = UIColor.blackColor().CGColor
        headerView.layer.borderWidth = 0.5
        
        headerView.layer.cornerRadius = 1.0
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOpacity = 0.4
        headerView.layer.shadowRadius = 1.0
        headerView.layer.shadowOffset = CGSizeMake(0.0, 1.0)
        
        return headerView
    }
    
    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
//        println("Tapping working")
//        println(recognizer.view?.tag)
        
        var indexPath : NSIndexPath = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
        if (indexPath.row == 0) {
            
            var collapsed = arrayForBool.objectAtIndex(indexPath.section).boolValue
            collapsed       = !collapsed
            
            arrayForBool.replaceObjectAtIndex(indexPath.section, withObject: collapsed)
            //reload specific section animated
            var range = NSMakeRange(indexPath.section, 1)
            var sectionToReload = NSIndexSet(indexesInRange: range)
            self.eventListView.reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Fade)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        tableView.separatorColor = UIColor.lightGrayColor()
        
        var manyCells : Bool = arrayForBool .objectAtIndex(indexPath.section).boolValue
        
        if (!manyCells) {
            
            let cellId = "Cell"
            var cell : UITableViewCell
            cell = self.eventListView.dequeueReusableCellWithIdentifier(cellId) as! UITableViewCell
            
//            cell.textLabel.text = "click to enlarge"
            
            return cell
        }
        else{
            
            var cellIdentifier : String = "\(indexPath.section).\(indexPath.row)Cell"
            var cell:EventTableViewCell? = tableView.dequeueReusableCellWithIdentifier("cellIdentifier") as? EventTableViewCell
            
            if (cell == nil)
            {
                var arr = NSBundle.mainBundle().loadNibNamed("EventTableViewCell", owner: self, options: nil)
                cell = arr [0] as? EventTableViewCell
            }
            
            cell!.backgroundColor = UIColor.clearColor()
            
            var tps = sectionTitleArray.objectAtIndex(indexPath.section) as! SectionItem
            var key : String = "\(self.getDayNameForDate(tps.date!))"
            var count1 = (sectionContentDict.objectForKey(key)) as? NSArray
            
            if let array = count1
            {
                let item : Event = array[indexPath.row] as! Event
                cell!.eventDescriptionLabel.text = "\(item.startTime) - \(item.endTime) \(item.eventDescription)"
                cell!.taggedUserLabel.text = "\(item.name)"
                cell!.eventNotesLabel.text = ""
            }
            
            return cell!
        }
    }
}

// MARK: - Parsing APIs Demo

extension ViewController {
    
    func parseJsonForMonth() {
        
        let path = NSBundle.mainBundle().pathForResource("month", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!, options: .DataReadingMappedIfSafe, error: nil)
        var jsonResult: Dictionary <String, AnyObject> = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! Dictionary <String, AnyObject>
        
        
        var data : Dictionary<String, AnyObject>? = jsonResult["data"] as? Dictionary<String, AnyObject>
        
        if data != nil
        {
            var dates : [Dictionary<String, AnyObject>]? = data!["dates"] as? Array
            
            if dates != nil
            {
                for i in 0..<dates!.count
                {
                    let item : Dictionary<String, AnyObject> = dates![i]
                    
                    var event : MonthEvent = MonthEvent()
                    
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.timeZone = NSTimeZone.systemTimeZone()
                    dateFormatter.locale =  NSLocale.currentLocale()
                    //                    dateFormatter.dateFormat = "dd-MM-YYYY" // this format doesn't work. Have to use the below one.
                    dateFormatter.dateFormat = "YYYY-MM-dd"
                    
                    var dateStr : String? = item["date"] as? String
                    event.dateStr = dateStr!
                    let date : NSDate = dateFormatter.dateFromString(event.dateStr)!
                    event.date = CVDate(date: date)
                    
                    var events : Int = item["events"] as! Int
                    event.events = events
                    
                    var pattern : Int = item["pattern"] as! Int
                    event.pattern = pattern
                    
                    var exchangeRequests : Int = item["exchangeRequests"] as! Int
                    event.exchangeRequest = exchangeRequests
                    
                    var patternChangeRequests : Int = item["patternChangeRequests"] as! Int
                    event.patternExchangeRequest = patternChangeRequests
                    
                    monthEvents.append(event)
                    
                    parsingDone = true
                }
            }
        }
        
        calendarView.reloadCalendar(.MonthView)
    }
    
    func parseJsonForWeek() {
        
        let path = NSBundle.mainBundle().pathForResource("week", ofType: "json")
        let jsonData = NSData(contentsOfFile: path!, options: .DataReadingMappedIfSafe, error: nil)
        var jsonResult: Dictionary <String, AnyObject> = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! Dictionary <String, AnyObject>
        
        
        var data : Dictionary<String, AnyObject>? = jsonResult["data"] as? Dictionary<String, AnyObject>
        
        weekEvents = [WeekEvent]()
        
        if data != nil
        {
            var dates : [Dictionary<String, AnyObject>]? = data!["dates"] as? Array
            
            if dates != nil
            {
                for i in 0..<dates!.count
                {
                    let item : Dictionary<String, AnyObject> = dates![i]
                    
                    var event : WeekEvent = WeekEvent()
                    
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.timeZone = NSTimeZone.systemTimeZone()
                    dateFormatter.locale =  NSLocale.currentLocale()
                    dateFormatter.dateFormat = "YYYY-MM-dd"
                    
                    var dateStr : String? = item["date"] as? String
                    event.dateStr = dateStr!
                    let date : NSDate = dateFormatter.dateFromString(event.dateStr)!
                    event.date = CVDate(date: date)
                    
                    var events : [Dictionary<String, AnyObject>]? = item["events"] as? Array
                    
                    if let eItems = events
                    {
                        for i in 0..<events!.count
                        {
                            let eventItem : Dictionary<String, AnyObject> = events![i]
                            
                            var eItem : Event = Event()
                            
                            eItem.eventId = eventItem["id"] as! Int
                            eItem.name = eventItem["name"] as! String
                            eItem.startTime = eventItem["startTime"] as! String
                            eItem.endTime = eventItem["endTime"] as! String
                            
                            if let fileName: AnyObject = eventItem["fileName"]
                            {
                                eItem.fileName = eventItem["fileName"] as! String
                            }
                            if let filePath: AnyObject = eventItem["filePath"]
                            {
                                eItem.filePath = eventItem["filePath"] as! String
                            }
                            if let desc: AnyObject = eventItem["desc"]
                            {
                                eItem.eventDescription = eventItem["desc"] as! String
                            }
                            
                            event.events.append(eItem)
                        }
                    }
                    weekEvents.append(event)
                    println("weekEvents count \(weekEvents.count)")
                }
            }
        }
    }
}

// MARK: - Convenience API Demo

extension ViewController {
    func toggleMonthViewWithMonthOffset(offset: Int) {
        let calendar = NSCalendar.currentCalendar()
        let calendarManager = calendarView.manager
        let components = Manager.componentsForDate(NSDate()) // from today
        
        components.month += offset
        
        let resultDate = calendar.dateFromComponents(components)!
        
        self.calendarView.toggleViewWithDate(resultDate)
    }
    
    func colorWithHexString (hex:String) -> UIColor {
        
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (count(cString) != 6) {
            return UIColor.grayColor()
        }
        
        var rString = (cString as NSString).substringToIndex(2)
        var gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        var bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    func getMonthNameForDate(date : CVDate) ->String
    {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let receivedDate = formatter.dateFromString("\(date.year)-\(date.month)-\(date.day)")
        formatter.locale = NSLocale.currentLocale()
        
        formatter.dateFormat = "MMMM"
        
        let monthName = formatter.stringFromDate(receivedDate!) as String
        return monthName
    }
    
    func getDayNameForDate(date : CVDate) ->String
    {
        var formatter = NSDateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let receivedDate = formatter.dateFromString("\(date.year)-\(date.month)-\(date.day)")
        formatter.locale = NSLocale.currentLocale()
        
        formatter.dateFormat = "EEEE"
        
        let dayName = formatter.stringFromDate(receivedDate!) as String
        return dayName
    }
}

