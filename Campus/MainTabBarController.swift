//
//  MainTabBarController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/18/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

import RKNotificationHub

class MainTabBarController: UITabBarController
{
	private var observer: NSObjectProtocol?

	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		CampusConversationsRequest.getTotalUnreadCount(
			successHandler: { (count) -> () in
				if count > 0
				{
					self.viewControllers![0].tabBarItem.badgeValue = "\(count)"
				}
			},
			failureHandler: nil)
		
		observer = NSNotificationCenter.defaultCenter().addObserverForName(Constants.NotificationIds.NotificationNewPrivateMessage, object: nil, queue: nil) { (notification) -> Void in
			CampusConversationsRequest.getTotalUnreadCount(
				successHandler: { (count) -> () in
					if count > 0
					{
						self.viewControllers![0].tabBarItem.badgeValue = "\(count)"
					}
				},
				failureHandler: nil)
		}
	}
	
	override func viewWillDisappear(animated: Bool)
	{
		super.viewWillDisappear(animated)
		
		if let observer = observer
		{
			NSNotificationCenter.defaultCenter().removeObserver(observer)
		}
	}
	
	
	
	
}
