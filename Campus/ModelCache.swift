//
//  ModelCache.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/18/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

class ModelCache
{
	static let sharedInstance = ModelCache()
	
	private var cachedUsers = [Int : CampusUser]()
	private var cachedUsersAge = [Int : NSDate]()
	
	private var cachedGroups = [Int : CampusGroup]()
	private var cachedGroupsAge = [Int : NSDate]()
	
	private var cachedGroupPosts = [Int : CampusGroupPost]()
	
	private var cachedPrivateMessages = [Int : CampusPrivateMessage]()
	
	private let usersMaxAge = 3600.0 // Refresh users every one hour running time
	private let groupsMaxAge = 1800.0
	
	func cacheUser(user: CampusUser)
	{
		cachedUsers[user.id] = user
		cachedUsersAge[user.id] = NSDate()
	}
	
	func cacheUsers(users: [CampusUser])
	{
		for user in users
		{
			cachedUsers[user.id] = user
			cachedUsersAge[user.id] = NSDate()
		}
	}
	
	func getCachedUser(id: Int) -> CampusUser?
	{
		guard let userAge = cachedUsersAge[id] where NSDate().timeIntervalSinceDate(userAge) < usersMaxAge
			else
		{
			return nil
		}
		
		return cachedUsers[id]
	}
	
	func cacheGroup(group: CampusGroup)
	{
		cachedGroups[group.id] = group
		cachedGroupsAge[group.id] = NSDate()
	}
	
	func cacheGroups(groups: [CampusGroup])
	{
		for group in groups
		{
			cachedGroups[group.id] = group
			cachedGroupsAge[group.id] = NSDate()
		}
	}
	
	func getCachedGroup(id: Int) -> CampusGroup?
	{
		guard let groupAge = cachedGroupsAge[id] where NSDate().timeIntervalSinceDate(groupAge) < groupsMaxAge
			else
		{
			return nil
		}
		
		return cachedGroups[id]
	}
	
	func cachePrivateMessage(message: CampusPrivateMessage)
	{
		cachedPrivateMessages[message.id] = message
	}
	
	func getCachedMessage(id: Int) -> CampusPrivateMessage?
	{
		return cachedPrivateMessages[id]
	}
}