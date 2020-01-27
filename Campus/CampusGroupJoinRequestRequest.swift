//
//  CampusGroupJoinRequestRequest.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

class CampusGroupJoinRequestRequest: Request
{
	class func getJoinRequests(
		group: CampusGroup,
		successHandler success: ((users: [CampusUser]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let getRequestsEndpoint = CampusGroupJoinRequestEndpoint.GetJoinRequests(group: group)
		makeRequestToEndpoint(getRequestsEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let jsonUsers = json["users"].array
				{
					var users = [CampusUser]()
					for userJson in jsonUsers
					{
						if let user = CampusUser(json: userJson)
						{
							users.append(user)
						}
					}
					
					success?(users: users)
				} else
				{
					log.error("No users array in JSON")
					failure?(error: RequestError.BadResponseFormat("No users array in JSON"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func createJoinRequestForGroup(
		group: CampusGroup,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let createJoinRequestEndpoint = CampusGroupJoinRequestEndpoint.CreateJoinRequest(group: group)
		makeRequestToEndpoint(createJoinRequestEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func getUserStatusForGroup(
		group: CampusGroup,
		successHandler success: ((status: CampusGroup.JoinRequestStatus) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let statusEndpoint = CampusGroupJoinRequestEndpoint.UserStatus(group: group)
		makeRequestToEndpoint(statusEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let statusString = json["status"].string, status = CampusGroup.JoinRequestStatus(rawValue: statusString)
				{
					success?(status: status)
				} else
				{
					log.error("Missing or malformed status in JSON")
					failure?(error: RequestError.BadResponseFormat("Missing or malformed status in JSON"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func approveRequestForUser(
		user: CampusUser,
		group: CampusGroup,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let approveEndpoint = CampusGroupJoinRequestEndpoint.Approve(user: user, group: group)
		makeRequestToEndpoint(approveEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func declineRequestForUser(
		user: CampusUser,
		group: CampusGroup,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let declineEndpoint = CampusGroupJoinRequestEndpoint.Decline(user: user, group: group)
		makeRequestToEndpoint(declineEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
}