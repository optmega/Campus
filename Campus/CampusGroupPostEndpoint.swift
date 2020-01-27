//
//  CampusGroupPostEndpoint.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Alamofire

enum CampusGroupPostEndpoint: Endpoint
{
	case CreateGroupPost(post: CampusGroupPost)
	case DeletePost(post: CampusGroupPost)
	
	case GetAllPostsForUser(sincePostId: Int?)
	case GetGroupPosts(group: CampusGroup, sincePostId: Int?)
	
	case GetGroupPostsCount(group: CampusGroup, sincePostId: Int?)
	case GetGroupPostsUnreadCount(group: CampusGroup)
	
	case Subscribe(post: CampusGroupPost, notificationInterval: Int?)
	case Unsubscribe(post: CampusGroupPost)
	case Subscribers(post: CampusGroupPost)
	
	case CommentOnPost(text: String, post: CampusGroupPost)
	case GetPostComments(post: CampusGroupPost)
	
	case LikePost(post: CampusGroupPost)
	case UnlikePost(post: CampusGroupPost)
	
	var path : String
	{
		switch self
		{
			case .CreateGroupPost:						return "/group_posts"
			case .DeletePost(let post):					return "/group_posts/\(post.id)"
			
			case .GetAllPostsForUser(let sincePostId):
				if let sincePostId = sincePostId
				{
					return "/group_posts/posts_for_user/since/\(sincePostId)"
				} else
				{
					return "/group_posts/posts_for_user"
			}
			case .GetGroupPosts(let group, let sincePostId):
				if let sincePostId = sincePostId
				{
					return "/group_posts/group/\(group.id)/since/\(sincePostId)"
				} else
				{
					return "/group_posts/group/\(group.id)"
				}
			
			case .GetGroupPostsCount(let group, let sincePostId):
				if let sincePostId = sincePostId
				{
					return "/group_posts/group/\(group.id)/count/since/\(sincePostId)"
				} else
				{
					return "/group_posts/group/\(group.id)/count"
				}
			case .GetGroupPostsUnreadCount(let group):	return "/group_posts/group/\(group.id)/unread_count"
			
			case .Subscribe(let post, _):				return "/group_posts/\(post.id)/subscribe"
			case .Unsubscribe(let post):				return "/group_posts/\(post.id)/unsubscribe"
			case .Subscribers(let post):				return "/group_posts/\(post.id)/subscribers"
			
			case .CommentOnPost(_, let post):			return "/group_posts/\(post.id)/comment"
			case .GetPostComments(let post):			return "/group_posts/\(post.id)/comments"
			
			case .LikePost(let post):					return "/group_posts/\(post.id)/like"
			case .UnlikePost(let post):					return "/group_posts/\(post.id)/unlike"
		}
	}
	
	var method: Alamofire.Method
	{
		switch self
		{
			case .CreateGroupPost:			return .POST
			case .DeletePost:				return .DELETE
			
			case .GetAllPostsForUser:		return .GET
			case .GetGroupPosts:			return .GET
			
			case .GetGroupPostsCount:		return .GET
			case .GetGroupPostsUnreadCount:	return .GET
			
			case .Subscribe:				return .POST
			case .Unsubscribe:				return .POST
			case .Subscribers:				return .GET
			
			case .CommentOnPost:			return .POST
			case .GetPostComments:			return .GET
			
			case .LikePost:					return .POST
			case .UnlikePost:				return .POST
		}
	}
	
	var parameters: [String : AnyObject]?
	{
		switch self
		{
			case .CreateGroupPost(let post):
				var parameters = [String : [String : AnyObject]]()
				let dateFormatter = NSDateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
				
				parameters = ["group_post" : ["group_id" : post.group.id,
												"title" : post.title,
												"visibility" : post.visibility.rawValue]]
				
				if let text = post.text
				{
					parameters["group_post"]!["text"] = text
				}
				
				if let eventDate = post.eventDate
				{
					parameters["group_post"]!["event_date"] = dateFormatter.stringFromDate(eventDate)
				}
			
				return parameters
			
			case .Subscribe(_, let notificationInterval):
				if let notificationInterval = notificationInterval
				{
					return ["notification_interval" : notificationInterval]
				} else
				{
					return nil
				}
			
			case .CommentOnPost(let text, _): return ["post_comment" :	["text" : text]]
			
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
