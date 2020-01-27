//
//  CampusComment.swift
//  Campus
//
//  Created by Ivan Dilchovski on 3/21/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

class CampusComment
{
	var id: Int
	var text: String
	var commentDate: NSDate
	var postId: Int
	
	var user: CampusUser
	
	init(
		id: Int,
		text: String,
		commentDate: NSDate,
		postId: Int,
		user: CampusUser)
	{
		self.id = id
		self.text = text
		self.commentDate = commentDate
		self.postId = postId
		self.user = user
	}
}