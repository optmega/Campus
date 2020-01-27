//
//  CampusPasswordResetEndpoint.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/14/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Alamofire

enum CampusPasswordResetEndpoint: Endpoint
{
	case RequestReset(email: String)
	
	var path : String
	{
		switch self
		{
			case .RequestReset: return "/password_resets"
		}
	}
	
	var method: Alamofire.Method
	{
		switch self
		{
			case .RequestReset: return .POST
		}
	}
	
	var parameters: [String : AnyObject]?
	{
		switch self
		{
			case .RequestReset(let email):
				return ["password_reset" :	["email" : email]]
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
		
		return headers
	}
}