//
//  User.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/6/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

// TODO: Some sort of caching for user objects for basic things like name, picture 

class CampusUser
{
	static var currentUser: CampusUser = CampusUser()
	static var currentUserAuthToken: String? // Static var, because currentUser is often updated with new objects when receiving updated JSON from server
	
	var id:					Int				= -1
	var email:				String?			= nil
	var authToken:			String?			= nil
	var firstName:			String			= ""
	var lastName:			String			= ""
	var about:				String			= ""
	
	var followedUsers:		[CampusUser]?	= nil
	
	var major:				String?			= nil
	var bio:				String?			= nil
	var dreamJob:			String?			= nil
	var hobbies:			String?			= nil
	var favouriteQuote:		String?			= nil
	var birthday:			NSDate?			= nil
	
	var profilePicturePath:	String?			= nil
	var firstLogin:			Bool			= false
	
	var createdAt:			NSDate?			= nil
	var updatedAt:			NSDate?			= nil
	
	var school:				CampusSchool	= CampusSchool(id: -1, name: "", emailDomain: "")
	var subscribedPosts: [CampusGroupPost]? = nil // TODO:
	
	var task: AWSTask?						= nil // Can't declare stored properties in extensions :(
	
	init()
	{
		id = -1
	}
	
	init(id: Int,
		email: String,
		firstName: String,
		lastName: String,
		school: CampusSchool)
	{
		self.id = id
		self.email = email
		self.firstName = firstName
		self.lastName = lastName
		self.school = school
	}
}

extension CampusUser: Hashable
{
	var hashValue : Int
	{
		get
		{
			return email?.hash ?? "".hash
		}
	}
}

func ==(lhs: CampusUser, rhs: CampusUser) -> Bool
{
	return lhs.hashValue == rhs.hashValue
}