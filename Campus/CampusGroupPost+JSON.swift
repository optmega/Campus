//
//  CampusGroupPost+JSON.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import SwiftyJSON

extension CampusGroupPost
{
	class func fetchFromJSON(json: JSON, handler: (post: CampusGroupPost?) -> ())
	{
		let fetchPostsGroup = dispatch_group_create()
		
		guard let id = json["id"].int
			else
		{
			log.error("No id in group post JSON")
			handler(post: nil)
			return
		}
		
		guard let userId = json["user_id"].int
			else
		{
			log.error("No user id in group post JSON")
			handler(post: nil)
			return
		}
		
		guard let groupId = json["group_id"].int
			else
		{
			log.error("No group id in group post JSON")
			handler(post: nil)
			return
		}
		
		guard let title = json["title"].string
			else
		{
			log.error("No title in group post JSON")
			handler(post: nil)
			return
		}
		
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		
		guard let postDateString = json["posted_date"].string, postDate = formatter.dateFromString(postDateString)
			else
		{
			log.error("No or malformed post date in JSON")
			handler(post: nil)
			return
		}
		
		guard let visibilityString = json["visibility"].string,
			visibility = PostVisibility(rawValue: visibilityString)
			else
		{
			log.error("No or malformed visibility in JSON")
			handler(post: nil)
			return
		}
		
		dispatch_group_enter(fetchPostsGroup)
		dispatch_group_enter(fetchPostsGroup)
		
		var likesUserIds = [Int]()
		if let likesUserIdsJsonArray = json["likes_user_ids"].array
		{
			likesUserIds = likesUserIdsJsonArray.flatMap({$0.int})
		}
		
		var commentIds = [Int]()
		if let commentIdsJsonArray = json["comment_ids"].array
		{
			commentIds = commentIdsJsonArray.flatMap({$0.int})
		}
		
		var closureUser: CampusUser?
		var closureGroup: CampusGroup?
		
		CampusUserRequests.getUser(userId,
			success: { (user) -> () in
				closureUser = user
				dispatch_group_leave(fetchPostsGroup)
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(fetchPostsGroup)
		})
		
		CampusGroupRequest.getGroupWithId(groupId,
			successHandler: { (group) -> () in
				closureGroup = group
				dispatch_group_leave(fetchPostsGroup)
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(fetchPostsGroup)
		})

		
		dispatch_group_notify(fetchPostsGroup, dispatch_get_main_queue()) { () -> Void in
			guard let user = closureUser, group = closureGroup
				else
			{
				handler(post: nil)
				return
			}
			
			let post = CampusGroupPost(
				id: id,
				title: title,
				text: json["text"].string,
				postDate: postDate,
				visibility: visibility,
				user: user,
				group: group,
				likesUserIds: likesUserIds,
				commentIds: commentIds)
			
			if let eventDateString = json["event_date"].string, eventDate = formatter.dateFromString(eventDateString)
			{
				post.eventDate = eventDate
			}
			
			handler(post: post)
		}
	}
}