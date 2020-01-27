//
//  CampusSessionRequest.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class CampusSessionRequest: Request
{
	static func login(
		email email: String,
		password: String,
		successHandler success:((user: CampusUser) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let loginEndpoint = CampusSessionEndpoint.Login(email: email, password: password)
		
		makeRequestToEndpoint(loginEndpoint,
			withJSONResponseHandler: { (json) -> () in
				guard  json["session"].dictionary != nil
					else
				{
					failure?(error: .BadResponseFormat("Missing user from session JSON"))
					return
				}
				
				guard let _ = json["session"]["token"].string
					else
				{
					failure?(error: .BadResponseFormat("Missing auth token from session JSON"))
					return
				}

				guard let user = CampusUser(json: json["session"])
					else
				{
					failure?(error: .BadResponseFormat("Could not parse user from JSON"))
					return
				}
				
				success?(user: user)
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func verifyToken(
		token: String,
		email: String,
		successHandler success: ((user: CampusUser) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let verifyToken = CampusSessionEndpoint.LoginWithAuthToken
		makeRequestToEndpoint(verifyToken,
			withJSONResponseHandler: { (json) -> () in
				guard let user = CampusUser(json: json["session"])
					else
				{
					failure?(error: .BadResponseFormat("Could not parse user from JSON"))
					return
				}
				
				success?(user: user)
			}, failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func logout(
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let logoutEndpoint = CampusSessionEndpoint.Logout
		makeRequestToEndpoint(logoutEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
}