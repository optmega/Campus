//
//  CampusGroupRequest.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/11/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class CampusGroupRequest: Request
{
	static func getGroupWithId(
		groupId: Int,
		successHandler success: ((group: CampusGroup) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		if let group = ModelCache.sharedInstance.getCachedGroup(groupId)
		{
			success?(group: group)
		} else
		{
			let getGroupEndpoint = CampusGroupsEndpoint.GetGroup(id: groupId)
			makeRequestToEndpoint(
				getGroupEndpoint,
				withJSONResponseHandler: { (json) -> () in
					if let group = CampusGroup(json: json["group"])
					{
						ModelCache.sharedInstance.cacheGroup(group)
						success?(group: group)
					}  else
					{
						log.error("Could not get group from JSON response")
						failure?(error: RequestError.BadResponseFormat("Could not get group from JSON response"))
					}
				},
				failureHandler: { (requestError) -> () in
					failure?(error: requestError)
			})
		}
	}
	
	
	static func getGroups(
		groupIds: [Int],
		success: ((groups: [CampusGroup]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		// TODO: Maybe get some from cache
		let getGroupsEndpoint = CampusGroupsEndpoint.GetGroups(ids: groupIds)
		makeRequestToEndpoint(getGroupsEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let jsonGroups = json["groups"].array
				{
					var groups = [CampusGroup]()
					for groupJson in jsonGroups
					{
						if let group = CampusGroup(json: groupJson)
						{
							groups.append(group)
						}
					}
					
					ModelCache.sharedInstance.cacheGroups(groups)
					success?(groups: groups)
				} else
				{
					log.error("No groups array in JSON")
					failure?(error: RequestError.BadResponseFormat("No groups array in JSON"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	
	//The success handler returns the used searchString for easier filtering of returned results (e.g. in case of slow connection and fast typing when multiple results can arrive at the same time)
	static func searchGroupsWithName(
		name: String,
		successHandler success: ((groups: [CampusGroup], searchString: String) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		guard let name = name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
			else
		{
			failure?(error: RequestError.BadRequest("Could not percent escape name"))
			return
		}
		
		let searchGroupsEndpoint = CampusGroupsEndpoint.SearchGroupsName(name: name)
		makeRequestToEndpoint(searchGroupsEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let jsonGroups = json["groups"].array
				{
					var groups = [CampusGroup]()
					for groupJson in jsonGroups
					{
						if let group = CampusGroup(json: groupJson)
						{
							groups.append(group)
						}
					}
					
					success?(groups: groups, searchString: name)
				} else
				{
					log.error("No groups array in JSON")
					failure?(error: RequestError.BadResponseFormat("No groups array in JSON"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func createNewGroup(
		group: CampusGroup,
		owner: CampusUser,
		successHandler success: ((group: CampusGroup) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let createGroupEndpoint = CampusGroupsEndpoint.CreateGroup(group: group, owner: owner)
		
		guard group.name != nil && group.description != nil
			else
		{
			let error = RequestError.BadRequest("Nil parameters in request")
			failure?(error: error)
			return
		}
		
		makeRequestToEndpoint(createGroupEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let group = CampusGroup(json: json["group"])
				{
					success?(group: group)
				}  else
				{
					log.error("Could not get group from JSON response")
					failure?(error: RequestError.BadResponseFormat("Could not get group from JSON response"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func editGroup(
		group: CampusGroup,
		successHandler success: ((group: CampusGroup) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let editGroupEndpoint = CampusGroupsEndpoint.EditGroup(group: group)
		makeRequestToEndpoint(editGroupEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let group = CampusGroup(json: json["group"])
				{
					success?(group: group)
				}  else
				{
					log.error("Could not get group from JSON response")
					failure?(error: RequestError.BadResponseFormat("Could not get group from JSON response"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func updateGroupPicture(
		group: CampusGroup,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let editGroupPictureEndpoint = CampusGroupsEndpoint.EditGroupPicture(group: group)
		makeRequestToEndpoint(editGroupPictureEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func addUser(
		user: CampusUser,
		isAdmin: Bool,
		toGroup group: CampusGroup,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let addUserEndpoint = CampusGroupsEndpoint.AddUser(user: user, isAdmin: isAdmin, group: group)
		makeRequestToEndpoint(addUserEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func removeUser(
		user: CampusUser,
		fromGroup group: CampusGroup,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let removeUserEndoint = CampusGroupsEndpoint.RemoveUser(user: user, group: group)
		makeRequestToEndpoint(removeUserEndoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func follow(
		group: CampusGroup,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let followEndpoint = CampusGroupsEndpoint.Follow(group: group)
		makeRequestToEndpoint(followEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func unfollow(
		group: CampusGroup,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let unfollowEndpoint = CampusGroupsEndpoint.Unfollow(group: group)
		makeRequestToEndpoint(unfollowEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func getMembers(
		forGroup group: CampusGroup,
		successHandler success: ((users: [CampusUser]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let getMembersEndpoint = CampusGroupsEndpoint.Members(group: group)
		makeRequestToEndpoint(getMembersEndpoint,
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
	
	static func getAdmins(
		forGroup group: CampusGroup,
		successHandler success: ((users: [CampusUser]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let getAdminsEndpoint = CampusGroupsEndpoint.Admins(group: group)
		makeRequestToEndpoint(getAdminsEndpoint,
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
	
	static func getNonMembers(
		forGroup group: CampusGroup,
		successHandler success: ((users: [CampusUser]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let getAdminsEndpoint = CampusGroupsEndpoint.NonMembers(group: group)
		makeRequestToEndpoint(getAdminsEndpoint,
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
	static func getAccessLevelForUser(
		user: CampusUser,
		inGroup group: CampusGroup,
		successHandler success: ((accessLevel: CampusGroup.UserAccessLevel) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let getAccessLevelEndpoint = CampusGroupsEndpoint.UserAccessLevel(user: user, group: group)
		makeRequestToEndpoint(
			getAccessLevelEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let userAccessLevelString = json["user_access_level"].string
				{
					if let userAccessLevel = CampusGroup.UserAccessLevel(rawValue: userAccessLevelString)
					{
						success?(accessLevel: userAccessLevel)
					} else
					{
						log.info("Unknown access level string \"\(userAccessLevelString)\" in JSON")
						failure?(error: RequestError.BadResponseFormat("Unknown access level string \"\(userAccessLevelString)\" in JSON"))
					}
				} else
				{
					log.info("No \"user_access_level\" key in JSON")
					failure?(error: RequestError.BadResponseFormat("No \"user_access_level\" key in JSON"))
				}
			},
			failureHandler: { (requestError) -> () in
				
		})
	}
	
}