//
//  Endpoint.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Alamofire

protocol Endpoint
{
	var baseURL: String { get }
	var path: String { get }
	var method: Alamofire.Method { get }
	var parameters: [String : AnyObject]? { get }
	var encoding: Alamofire.ParameterEncoding { get }
	var headers: [String : String]? { get }
}

extension Endpoint
{
	var baseURL: String {
		return Constants.URLStrings.CampusServer
	}
	
	var authTokenAndMail: (email: String, token: String)? {
		if let (email, token) = LoginHelper.getEmailAndTokenFromKeychain()
		{
			return (email, token)
		} else if let email = CampusUser.currentUser.email, token = CampusUser.currentUserAuthToken
		{
			return (email, token)
		} else
		{
			return nil
		}
	}
}