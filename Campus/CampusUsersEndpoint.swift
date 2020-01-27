//
//  UsersEndpoint.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire

enum CampusUsersEndpoint: Endpoint
{
	case GetUser(id: Int)
	case GetUsers(ids: [Int])
	case GetAllUsers
	case FindEmail(email: String)
	case FindName(name: String)
	case CreateUser(user: CampusUser, password: String, passwordConfirm: String)
	case UpdateUser(user: CampusUser)
	case UpdateUserPicture(user: CampusUser)
	
	case AdministeredGroups(user: CampusUser)
	case JoinedGroups(user: CampusUser)
	case FollowedGroups(user: CampusUser)
	
	case GetSubscribedEvents
	
	case FollowUser(user: CampusUser)
	case UnfollowUser(user: CampusUser)
	case FollowedUsers(user: CampusUser)
	
	var path : String
	{
		switch self
		{
			case .GetUser(let id):				return "/users/\(id)"
			case .GetUsers:						return "/users/multiple"
			case .GetAllUsers:					return "/users"
			case .FindEmail(let email):			return "/users/find_email/\(email)"
			case .FindName(let name):			return "/users/find_name/\(name)"
			case .CreateUser(_):				return "/users"
			case .UpdateUser(let user):			return "/users/\(user.id)"
			case .UpdateUserPicture(let user):	return "/users/\(user.id)"
			
			case .AdministeredGroups(let user): return "/users/\(user.id)/administered_groups"
			case .JoinedGroups(let user):		return "/users/\(user.id)/joined_groups"
			case .FollowedGroups(let user):		return "/users/\(user.id)/followed_groups"
			
			case .GetSubscribedEvents:			return "/users/subscribed_events"
			
			case .FollowUser(let user):			return "/users/\(user.id)/follow_user"
			case .UnfollowUser(let user):		return "/users/\(user.id)/unfollow_user"
			case .FollowedUsers(let user):		return "/users/\(user.id)/followed_users"
		}
	}
	
	var method: Alamofire.Method
	{
		switch self
		{
			case .GetUser:				return .GET
			case .GetUsers:				return .GET
			case .GetAllUsers:			return .GET
			case .FindEmail:			return .GET
			case .FindName:				return .GET
			case .CreateUser:			return .POST
			case .UpdateUser:			return .PUT
			case .UpdateUserPicture:	return .PUT
			
			case .AdministeredGroups:	return .GET
			case .JoinedGroups:			return .GET
			case .FollowedGroups:		return .GET
			
			case .GetSubscribedEvents:	return .GET
			
			case .FollowUser:			return .POST
			case .UnfollowUser:			return .POST
			case .FollowedUsers:		return .GET
		}
	}
	
	var parameters: [String : AnyObject]?
	{
		switch self
		{
			case .GetUsers(let ids):	return ["ids" : ids]
			case .CreateUser(let user, let password, let passwordConfirm):
				var parameters = [String : [String : AnyObject]]()
				parameters = ["user" :	["email"				: user.email ?? "",
										"password"				: password,
										"password_confirmation" : passwordConfirm,
										"firstname"				: user.firstName,
										"lastname"				: user.lastName,
										"school_id"				: user.school.id]]
			
				if let major = user.major
				{
					parameters["user"]!["major"] = major
				}
				
				if let bio = user.bio
				{
					parameters["user"]!["bio"] = bio
				}
				
				if let dreamJob = user.dreamJob
				{
					parameters["user"]!["dream_job"] = dreamJob
				}
				
				if let hobbies = user.hobbies
				{
					parameters["user"]!["hobbies"] = hobbies
				}
				
				if let favouriteQuote = user.favouriteQuote
				{
					parameters["user"]!["favourite_quote"] = favouriteQuote
				}
				
				if let birthday = user.birthday
				{
					let formatter = NSDateFormatter()
					formatter.dateFormat = "dd/MM/yyyy"
					parameters["user"]!["birthday"] = formatter.stringFromDate(birthday)
				}

				return parameters
			
			case .UpdateUser(let user):
				var parameters = [String : [String : AnyObject]]()
				parameters =  ["user" :	["email"				: user.email ?? "",
										"firstname"				: user.firstName,
										"lastname"				: user.lastName,
										"about"					: user.about,
										"school_id"				: user.school.id]]
				
				if let major = user.major
				{
					parameters["user"]!["major"] = major
				}
				
				if let bio = user.bio
				{
					parameters["user"]!["bio"] = bio
				}
				
				if let dreamJob = user.dreamJob
				{
					parameters["user"]!["dream_job"] = dreamJob
				}
				
				if let hobbies = user.hobbies
				{
					parameters["user"]!["hobbies"] = hobbies
				}
				
				if let favouriteQuote = user.favouriteQuote
				{
					parameters["user"]!["favourite_quote"] = favouriteQuote
				}
				
				if let birthday = user.birthday
				{
					let formatter = NSDateFormatter()
					formatter.dateFormat = "dd/MM/yyyy"
					parameters["user"]!["birthday"] = formatter.stringFromDate(birthday)
				}
				
			return parameters
			
			case .UpdateUserPicture(let user):									return ["user" :	["profile_picture_path" : user.profilePicturePath ?? ""]]
			
			default: return nil
		}
	}
	
	var encoding: Alamofire.ParameterEncoding
	{
		switch self
		{
			case .GetUsers: return .URLEncodedInURL
			default: return .JSON
		}
	}
	
	var headers: [String : String]?
	{
		var headers = [String : String]()
		
		switch self
		{
			default:
				headers["Accept"] = "application/json"
		}
		
		switch self
		{
			case .CreateUser: ()
			
			default:
				if let (email, token) = authTokenAndMail
				{
					let authHeader = "Token token=\"\(token)\", email=\"\(email)\""
					headers["Authorization"] = authHeader
				}
		}
		
		return headers
	}
	
}