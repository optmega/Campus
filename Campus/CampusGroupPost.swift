//
//  CampusGroupPost.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

class CampusGroupPost
{
	enum PostVisibility: String
	{
        case Admins  = "admins"
        case Members = "members"
        case Public  = "public"
	}
	
    var id: Int
    var title: String
	var postDate: NSDate
	var visibility: PostVisibility
	
    var text: String?
    var eventDate: NSDate?
	
	var user: CampusUser
	var group: CampusGroup
	
	var likesUserIds: [Int]
	var commentIds: [Int]
	
	required init(
		id: Int,
		title: String,
		text: String?,
		postDate: NSDate,
		visibility: PostVisibility,
		user: CampusUser,
		group: CampusGroup,
		likesUserIds: [Int] = [Int](),
		commentIds: [Int] = [Int]())
	{
		self.id = id
		self.title = title
		
		self.text = text
		
		self.postDate = postDate
		self.visibility = visibility
		self.user = user
		self.group = group
		
		self.likesUserIds = likesUserIds
		self.commentIds = commentIds
	}
}