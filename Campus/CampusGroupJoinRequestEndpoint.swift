//
//  CampusGroupJoinRequestEndpoint.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Alamofire

enum CampusGroupJoinRequestEndpoint: Endpoint
{
	case GetJoinRequests(group: CampusGroup)
	case CreateJoinRequest(group: CampusGroup)
	
	case UserStatus(group: CampusGroup)
	
	case Approve(user: CampusUser, group: CampusGroup)
	case Decline(user: CampusUser, group: CampusGroup)
	
	var path : String
	{
		switch self
		{
			case .GetJoinRequests(let group):	return "/group_join_requests/requests_for_group/\(group.id)"
			case .CreateJoinRequest:			return "/group_join_requests"
			
			case .UserStatus(let group):		return "/group_join_requests/user_status/\(group.id)"
			
			case .Approve:						return "/group_join_requests/approve"
			case .Decline:						return "/group_join_requests/decline"
		}
	}
	
	var method: Alamofire.Method
	{
		switch self
		{
			case .GetJoinRequests:		return .GET
			case .CreateJoinRequest:	return .POST
			
			case .UserStatus:			return .GET
			
			case .Approve:				return .POST
			case .Decline:				return .POST
		}
	}
	
	var parameters: [String : AnyObject]?
	{
		switch self
		{
			case .CreateJoinRequest(let group): return ["group_join_request" : ["group_id" : group.id]]
			
			case .Approve(let user, let group): return ["group_join_request" : ["group_id" : group.id,
																				"user_id" : user.id]]
			
			case .Decline(let user, let group): return ["group_join_request" : ["group_id" : group.id,
																				"user_id" : user.id]]
			
			default: return nil
		}
	}
	
	var encoding: Alamofire.ParameterEncoding
	{
		switch self
		{
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