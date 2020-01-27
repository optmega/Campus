//
//  Settings.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/9/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

struct Settings
{
	static let defaults = NSUserDefaults.standardUserDefaults()

	struct Device
	{
		private static let pushTokenKey = "defaults.device.pushToken"
		static var pushToken: String?
		{
			get
			{
				return defaults.objectForKey(pushTokenKey) as? String
			}
			
			set
			{
				defaults.setObject(newValue, forKey: pushTokenKey)
			}
		}
	}
	
	struct User
	{
		private static let rememberUserKey = "defaults.user.rememberUser"
		static var rememberUser: Bool
		{
			get
			{
				return defaults.boolForKey(rememberUserKey)
			}
			
			set
			{
				defaults.setBool(newValue, forKey: rememberUserKey)
			}
		}
	}
}
