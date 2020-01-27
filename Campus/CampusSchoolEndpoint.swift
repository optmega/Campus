//
//  CampusSchoolEndpoint.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/8/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire

enum CampusSchoolEndpoint: Endpoint
{
	case GetSchools
	
	var path : String
	{
		switch self
		{
			case .GetSchools: return "/schools"
		}
	}
	
	var method: Alamofire.Method
	{
		switch self
		{
			case .GetSchools: return .GET
		}
	}
	
	var parameters: [String : AnyObject]?
	{
		switch self
		{
			case .GetSchools: return nil
		}
	}
	
	var encoding: Alamofire.ParameterEncoding
	{
		switch self
		{
			case .GetSchools: return .JSON
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
