//
//  NSDate+IsToday.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/10/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

extension NSDate
{
	func isToday() -> Bool
	{
		let dateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Era, .Year, .Month, .Day], fromDate: self)
		let todayComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Era, .Year, .Month, .Day], fromDate: NSDate())
		
		return dateComponents.day == todayComponents.day &&
			dateComponents.month == todayComponents.month &&
			dateComponents.year == todayComponents.year &&
			dateComponents.era == todayComponents.era
	}
	
	func isDifferentDayFrom(date: NSDate) -> Bool
	{
		let selfComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Era, .Year, .Month, .Day], fromDate: self)
		let dateComponents = NSCalendar.currentCalendar().components([NSCalendarUnit.Era, .Year, .Month, .Day], fromDate: date)
		
		return selfComponents.day != dateComponents.day ||
			selfComponents.month != dateComponents.month ||
			selfComponents.year != dateComponents.year ||
			selfComponents.era != dateComponents.era
	}
}