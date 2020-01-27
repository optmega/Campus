//
//  CampusGroupPostRequest.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

class CampusGroupPostRequest: Request
{
	class func createGroupPost(
		post: CampusGroupPost,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let createPostEndpoint = CampusGroupPostEndpoint.CreateGroupPost(post: post)
		makeRequestToEndpoint(createPostEndpoint,
			withJSONResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func deletePost(
		post: CampusGroupPost,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let deletePostEndpoint = CampusGroupPostEndpoint.DeletePost(post: post)
		makeRequestToEndpoint(deletePostEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	// TODO: Mind blowingly inefficient. Nuke and rewrite
	// This can potentially load huge amounts of posts with related users and groups
	// Thus, it first gets all users and groups, so that they are cached
	class func getAllPostsForUser(
		sincePostId sincePostId: Int?,
		successHandler success: ((posts: [CampusGroupPost]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let getAllPostsEndpoint = CampusGroupPostEndpoint.GetAllPostsForUser(sincePostId: sincePostId)
		makeRequestToEndpoint(getAllPostsEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let jsonPosts = json["group_posts"].array
				{
					let fetchPostsGroup = dispatch_group_create()	// Use a group to signal when all posts are fetched for the calling the handler
					let fetchUsersGroup = dispatch_group_create()	// Get all users at the same time to fill in the cache.
																	//Otherwise, requests for all users for all posts will fire at almost the same time, with no time to cache
					var posts = [CampusGroupPost]()
					let userIds = Set(jsonPosts.flatMap({ (json) -> Int? in
						return json["user_id"].int
					})).filter { ModelCache.sharedInstance.getCachedUser($0) == nil }
					let groupIds = Set(jsonPosts.flatMap({ (json) -> Int? in
						return json["group_id"].int
					})).filter { ModelCache.sharedInstance.getCachedGroup($0) == nil }
					
					dispatch_group_enter(fetchUsersGroup)
					dispatch_group_enter(fetchUsersGroup)
					dispatch_group_enter(fetchPostsGroup) //Enter now to lock the last group_notify
					
					CampusUserRequests.getUsers(Array(userIds),
						success: { (users) -> () in
							dispatch_group_leave(fetchUsersGroup)
						}, failureHandler: { (error) -> () in
							dispatch_group_leave(fetchUsersGroup)
					})
					
					
					CampusGroupRequest.getGroups(Array(groupIds),
						success: { (groups) -> () in
							dispatch_group_leave(fetchUsersGroup)
						},
						failureHandler: { (error) -> () in
							dispatch_group_leave(fetchUsersGroup)
					})
					
					dispatch_group_notify(fetchUsersGroup, dispatch_get_main_queue()) { () -> Void in
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
						dispatch_group_leave(fetchPostsGroup) //Without this no notify
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
	
	class func getPostsFromGroup(
		group: CampusGroup,
		sincePostId: Int?,
		successHandler success: ((posts: [CampusGroupPost]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let getPostsEndpoint = CampusGroupPostEndpoint.GetGroupPosts(group: group, sincePostId: sincePostId)
		makeRequestToEndpoint(getPostsEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let jsonPosts = json["group_posts"].array
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
	
	class func getGroupPostsCount(
		group: CampusGroup,
		sincePostId: Int?,
		successHandler success: ((count: Int) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let groupPostsCountEndpoint = CampusGroupPostEndpoint.GetGroupPostsCount(group: group, sincePostId: sincePostId)
		makeRequestToEndpoint(groupPostsCountEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let count = json["count"].int
				{
					success?(count: count)
				} else
				{
					log.error("No count in JSON")
					failure?(error: RequestError.BadResponseFormat("No count in JSON"))
					
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)

		})
	}
	
	class func getGroupPostsUnreadCount(
		group: CampusGroup,
		successHandler success: ((count: Int) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let groupPostsUnreadCountEndpoint = CampusGroupPostEndpoint.GetGroupPostsUnreadCount(group: group)
		makeRequestToEndpoint(groupPostsUnreadCountEndpoint,
			withJSONResponseHandler: { (json) -> () in
				if let count = json["count"].int
				{
					success?(count: count)
				} else
				{
					log.error("No count in JSON")
					failure?(error: RequestError.BadResponseFormat("No count in JSON"))
					
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
				
		})
	}
	
	class func subscribe(
		post: CampusGroupPost,
		notificationInterval: Int?,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let subscribeEndpoint = CampusGroupPostEndpoint.Subscribe(post: post, notificationInterval: notificationInterval)
		makeRequestToEndpoint(subscribeEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func unsubscribe(
		post: CampusGroupPost,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let unsubscribeEndpoint = CampusGroupPostEndpoint.Unsubscribe(post: post)
		makeRequestToEndpoint(unsubscribeEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func getSubscribers(
		post: CampusGroupPost,
		successHandler success: ((users: [CampusUser]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusGroupPostEndpoint.Subscribers(post: post)
		makeRequestToEndpoint(endpoint,
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
	
	class func commentOnPost(
		text: String,
		post: CampusGroupPost,
		successHandler success: ((comment: CampusComment) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusGroupPostEndpoint.CommentOnPost(text: text, post: post)
		makeRequestToEndpoint(endpoint,
			withJSONResponseHandler: { (json) -> () in
				if let comment = CampusComment(json: json["post_comment"])
				{
					success?(comment: comment)
				}  else
				{
					log.error("Could not get comment from JSON response")
					failure?(error: RequestError.BadResponseFormat("Could not get comment from JSON response"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}

	class func getCommentsForPost(
		post: CampusGroupPost,
		successHandler success: ((comments: [CampusComment]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusGroupPostEndpoint.GetPostComments(post: post)
		makeRequestToEndpoint(endpoint,
			withJSONResponseHandler: { (json) -> () in
				if let commentsJson = json["post_comments"].array
				{
					var comments = [CampusComment]()
					for commentJson in commentsJson
					{
						if let comment = CampusComment(json: commentJson)
						{
							comments.append(comment)
						}
					}
					
					success?(comments: comments)
				} else
				{
					log.error("No comments array in JSON")
					failure?(error: RequestError.BadResponseFormat("No comments array in JSON"))

				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func likePost(
		post: CampusGroupPost,
		successHandler success: ((post: CampusGroupPost) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusGroupPostEndpoint.LikePost(post: post)
		makeRequestToEndpoint(endpoint,
			withJSONResponseHandler: { (json) -> () in
				if json["group_post"].error == nil
				{
					CampusGroupPost.fetchFromJSON(json["group_post"]) { (post) -> () in
						if let post = post
						{
							success?(post: post)
						} else
						{
							log.error("Could not fetch group post details from JSON")
							failure?(error: RequestError.BadResponseFormat("Could not fetch group post details from JSON"))
						}
					}
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func unlikePost(
		post: CampusGroupPost,
		successHandler success: ((post: CampusGroupPost) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusGroupPostEndpoint.UnlikePost(post: post)
		makeRequestToEndpoint(endpoint,
			withJSONResponseHandler: { (json) -> () in
				if json["group_post"].error == nil
				{
					CampusGroupPost.fetchFromJSON(json["group_post"]) { (post) -> () in
						if let post = post
						{
							success?(post: post)
						} else
						{
							log.error("Could not fetch group post details from JSON")
							failure?(error: RequestError.BadResponseFormat("Could not fetch group post details from JSON"))
						}
					}
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})

	}
	
}