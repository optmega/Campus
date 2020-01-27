//
//  CampusGroupsEndpoint.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/11/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Alamofire

enum CampusGroupsEndpoint: Endpoint
{
	case SearchGroupsName(name: String)
	case GetGroup(id: Int)
	case GetGroups(ids: [Int])
	
	case CreateGroup(group: CampusGroup, owner: CampusUser)
	case EditGroup(group: CampusGroup)
	case EditGroupPicture(group: CampusGroup)
	
	case AddUser(user: CampusUser, isAdmin: Bool, group: CampusGroup)
	case RemoveUser(user: CampusUser, group: CampusGroup)
	case Follow(group: CampusGroup)
	case Unfollow(group: CampusGroup)
	
	case Members(group: CampusGroup)
	case Admins(group: CampusGroup)
	case NonMembers(group: CampusGroup)
	
	case UserAccessLevel(user: CampusUser, group: CampusGroup)
	
	var path : String
	{
		
		switch self
		{
			case .SearchGroupsName(let name):			return "/groups/search_name/\(name)" // Percent escape name yourself!
			case .GetGroup(let id):						return "/groups/\(id)"
			case .GetGroups:							return "/groups/multiple"
			
			case .CreateGroup(_):						return "/groups"
			case .EditGroup(let group):					return "/groups/\(group.id)"
			case .EditGroupPicture(let group):			return "/groups/\(group.id)"
			
			case .AddUser(_, _, let group):				return "/groups/\(group.id)/add_user"
			case .RemoveUser(_, let group):				return "/groups/\(group.id)/remove_user"
			case .Follow(let group):					return "/groups/\(group.id)/follow"
			case .Unfollow(let group):					return "/groups/\(group.id)/unfollow"
			
			case .Members(let group):					return "/groups/\(group.id)/members"
			case .Admins(let group):					return "/groups/\(group.id)/admins"
			case .NonMembers(let group):				return "/groups/\(group.id)/non_members"
			
			case .UserAccessLevel(let user, let group):	return "/groups/\(group.id)/user_access_level/\(user.id)"
		}
	}
	
	var method: Alamofire.Method
	{
		switch self
		{
			case .SearchGroupsName:			return .GET
			case .GetGroup:					return .GET
			case .GetGroups:				return .GET
			
			case .CreateGroup:				return .POST
			case .EditGroup:				return .PUT
			case .EditGroupPicture:			return .PUT
			
			case .AddUser:					return .POST
			case .RemoveUser:				return .POST
			case .Follow:					return .POST
			case .Unfollow:					return .POST
			
			case .Members:					return .GET
			case .Admins:					return .GET
			case .NonMembers:				return .GET
			
			case .UserAccessLevel:			return .GET
		}
	}
	
	var parameters: [String : AnyObject]?
	{
		switch self
		{
			case .GetGroup(_):								return nil
			case .GetGroups(let ids):						return ["ids" : ids]
			
			case .CreateGroup(let group, let owner):
				var parameters = [String : [String : AnyObject]]()
				parameters = ["group" :	["name"	: group.name!,
										"description"	: group.description!,
										"school_id"		: owner.school.id]]
				
				if let groupType = group.groupType
				{
					parameters["group"]!["group_type"] = groupType.rawValue
				}
				
				if let recognizedType = group.recognizedGroupType
				{
					parameters["group"]!["recognized_group_type"] = recognizedType.rawValue
				}
				
				if let president = group.president
				{
					parameters["group"]!["president"] = president
				}
				
				if let executive = group.executive
				{
					parameters["group"]!["executive"] = executive
				}
				
				if let executive2 = group.executive2
				{
					parameters["group"]!["executive2"] = executive2
				}
				
				if let executive3 = group.executive3
				{
					parameters["group"]!["executive3"] = executive3
				}
				
				return parameters
			
			case .EditGroup(let group):
				var parameters = [String : [String : AnyObject]]()
				parameters = ["group" :	["name"	: group.name!,
										"description"	: group.description!]]
				
				if let groupType = group.groupType
				{
					parameters["group"]!["group_type"] = groupType.rawValue
				} else
				{
					parameters["group"]!["group_type"] = ""
				}
				
				if let recognizedType = group.recognizedGroupType
				{
					parameters["group"]!["recognized_group_type"] = recognizedType.rawValue
				} else
				{
					parameters["group"]!["recognized_group_type"] = ""
				}
				
				if let president = group.president
				{
					parameters["group"]!["president"] = president
				}
				
				if let executive = group.executive
				{
					parameters["group"]!["executive"] = executive
				}
				
				if let executive2 = group.executive2
				{
					parameters["group"]!["executive2"] = executive2
				}
				
				if let executive3 = group.executive3
				{
					parameters["group"]!["executive3"] = executive3
				}
				
				return parameters
			
			case .EditGroupPicture(let group):				return ["group" :	["group_picture_path" : group.groupPicturePath ?? ""]]
			
			case .AddUser(let user, let isAdmin, _):		return ["user" :	["id" : user.id,
																				"is_admin" : isAdmin]]
			
			case .RemoveUser(let user, _):					return ["user" :	["id" : user.id]]
			
			case .Follow:									return nil
			case .Unfollow:									return nil
			
			
			default:										return nil
		}
	}
	
	var encoding: Alamofire.ParameterEncoding
	{
		switch self
		{
			case .GetGroups:	return .URLEncodedInURL
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