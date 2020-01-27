//
//  UserRequests.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class CampusUserRequests: Request
{
	// MARK: - Public requests
	
	// MARK: Get user
	
	static func getUser(id: Int,
		success: ((user: CampusUser) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		if let user = ModelCache.sharedInstance.getCachedUser(id)
		{
			success?(user: user)
		} else
		{
			let getUserEndpoint = CampusUsersEndpoint.GetUser(id: id)
			makeRequestToEndpoint(getUserEndpoint,
				withJSONResponseHandler: { (json) -> () in
					if let user = CampusUser(json: json["user"])
					{
						ModelCache.sharedInstance.cacheUser(user)
						success?(user: user)
					} else
					{
						log.error("Could not get user from JSON response")
						failure?(error: RequestError.BadResponseFormat("Could not get user from JSON response"))
					}
				},
				failureHandler: { (requestError) -> () in
					failure?(error: requestError)
			})
		}
	}
	
	
	// Always get all from server, not from cache
	static func getUsers(
		userIds: [Int],
		success: ((users: [CampusUser]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let getUsersEndpoint = CampusUsersEndpoint.GetUsers(ids: userIds)
		makeRequestToEndpoint(getUsersEndpoint,
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
					
					ModelCache.sharedInstance.cacheUsers(users)
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
	
	static func getAllUsers(
		success: ((users: [CampusUser]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let getAllUsersEndpoint = CampusUsersEndpoint.GetAllUsers
		makeRequestToEndpoint(getAllUsersEndpoint,
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
					
					ModelCache.sharedInstance.cacheUsers(users)
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
	
	// MARK: Search
	
	static func searchUserByEmail(
		email: String,
		success: ((user: CampusUser) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let searchEmailEndpoint = CampusUsersEndpoint.FindEmail(email: email)

		makeRequestToEndpoint(searchEmailEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let user = CampusUser(json: json["user"])
				{
					success?(user: user)
				} else
				{
					log.error("Could not get user from JSON response")
					failure?(error: RequestError.BadResponseFormat("Could not get user from JSON response"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func searchUsersByName(
		name: String,
		success: ((users: [CampusUser]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		guard let name = name.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
			else
		{
			failure?(error: RequestError.BadRequest("Could not percent escape name"))
			return
		}
		
		let searchNameEndpoint = CampusUsersEndpoint.FindName(name: name)
		makeRequestToEndpoint(searchNameEndpoint,
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
					log.error("No groups array in JSON")
					failure?(error: RequestError.BadResponseFormat("No groupsjsonGroups array in JSON"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	// MARK: Create/Edit
	
	static func createNewUser(
		user: CampusUser,
		password: String,
		passwordConfirmation: String,
		successHandler success: ((user: CampusUser) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let createUserEndpoint = CampusUsersEndpoint.CreateUser(user: user, password: password, passwordConfirm: passwordConfirmation)
		
		makeRequestToEndpoint(createUserEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let user = CampusUser(json: json["user"])
				{
					success?(user: user)
				} else
				{
					log.error("Could not get user from JSON response")
					failure?(error: RequestError.BadResponseFormat("Could not get user from JSON response"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func updateUser(
		user: CampusUser,
		successHandler success: ((user: CampusUser) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let updateUserEndpoint = CampusUsersEndpoint.UpdateUser(user: user)
		
		makeRequestToEndpoint(updateUserEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let user = CampusUser(json: json["user"])
				{
					success?(user: user)
				} else
				{
					log.error("Could not get user from JSON response")
					failure?(error: RequestError.BadResponseFormat("Could not get user from JSON response"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func updateUserPicture(
		user: CampusUser,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let updatePictureEndpoint = CampusUsersEndpoint.UpdateUserPicture(user: user)
		makeRequestToEndpoint(updatePictureEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	// MARK: Groups & Events
	
	static func getAdministeredGroups(forUser user: CampusUser,
		success: ((groups: [CampusGroup]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let administeredGroupsEndpoint = CampusUsersEndpoint.AdministeredGroups(user: user)
		makeRequestToEndpoint(administeredGroupsEndpoint,
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
					
					success?(groups: groups)
				} else
				{
					log.error("No groups array in JSON")
					failure?(error: RequestError.BadResponseFormat("No groupsjsonGroups array in JSON"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func getJoinedGroups(forUser user: CampusUser,
		success: ((groups: [CampusGroup]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let joinedGroupsEndpoint = CampusUsersEndpoint.JoinedGroups(user: user)
		makeRequestToEndpoint(joinedGroupsEndpoint,
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
					
					success?(groups: groups)
				} else
				{
					log.error("No groups array in JSON")
					failure?(error: RequestError.BadResponseFormat("No groupsjsonGroups array in JSON"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	
	static func getFollowedGroups(forUser user: CampusUser,
		success: ((groups: [CampusGroup]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let followedGroupsEndpoint = CampusUsersEndpoint.FollowedGroups(user: user)
		makeRequestToEndpoint(followedGroupsEndpoint,
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
					
					success?(groups: groups)
				} else
				{
					log.error("No groups array in JSON")
					failure?(error: RequestError.BadResponseFormat("No groupsjsonGroups array in JSON"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func getSubscribedEvents(
		success: ((posts: [CampusGroupPost]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let subscribedEventsEndpoint = CampusUsersEndpoint.GetSubscribedEvents
		makeRequestToEndpoint(subscribedEventsEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let jsonPosts = json["group_posts"].array //There must be an array, even if empty
				{
					let fetchPostsGroup = dispatch_group_create() // Use a group to signal when all posts are fetched
					var posts = [CampusGroupPost]()
					
					for postJson in jsonPosts
					{
						dispatch_group_enter(fetchPostsGroup)
						CampusGroupPost.fetchFromJSON(postJson) { (post) -> () in
							if let post = post
							{
								posts.append(post)
							}
							dispatch_group_leave(fetchPostsGroup)
						}

					}
					dispatch_group_notify(fetchPostsGroup, dispatch_get_main_queue()) { () -> Void in
						success?(posts: posts)
					}
					
				} else
				{
					log.error("No group posts array in JSON")
					failure?(error: RequestError.BadResponseFormat("No group posts array in JSON"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	// MARK: Follow
	
	
	static func followUser(user: CampusUser,
		successHandler success: ((users: [CampusUser]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let followUserEndpoint = CampusUsersEndpoint.FollowUser(user: user)
		makeRequestToEndpoint(followUserEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let jsonUsers = json["users"].array
				{
					var users = [CampusUser]()
					for userJson in jsonUsers
					{
						if let user = CampusUser(json: userJson)
						{
							users.append(user)
						} else
						{
							log.error("Could not parse json to user")
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
	
	static func unfollowUser(user: CampusUser,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let unfollowUserEndpoint = CampusUsersEndpoint.UnfollowUser(user: user)
		makeRequestToEndpoint(unfollowUserEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	static func getFollowedUsers(
		success: ((users: [CampusUser]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let followedUsersEndpoint = CampusUsersEndpoint.FollowedUsers(user: CampusUser.currentUser)
		makeRequestToEndpoint(followedUsersEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let jsonUsers = json["users"].array
				{
					var users = [CampusUser]()
					for userJson in jsonUsers
					{
						if let user = CampusUser(json: userJson)
						{
							users.append(user)
						} else
						{
							log.error("Could not parse json to user")
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
	
	
	
	
}