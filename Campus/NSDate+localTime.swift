//
//  NSDate+localTime.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

extension NSDate
{
	func shortLocalString() -> String
	{
		let formatter = NSDateFormatter()
		formatter.dateStyle = .ShortStyle
		formatter.timeStyle = .ShortStyle
		formatter.timeZone = NSTimeZone.systemTimeZone()
		
		return formatter.stringFromDate(self)
	}
}