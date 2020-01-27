//
//  CampusComment+JSON.swift
//  Campus
//
//  Created by Ivan Dilchovski on 3/21/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import SwiftyJSON

extension CampusComment
{
	convenience init?(json: JSON)
	{
		guard let id = json["id"].int
			else
		{
			log.error("No id in comment JSON")
			return nil
		}
		
		guard let postId = json["group_post_id"].int
			else
		{
			log.error("No post id in comment JSON")
			return nil
		}
		
		guard let text = json["text"].string
			else
		{
			log.error("No text in comment JSON")
			return nil
		}
		
		guard let user = CampusUser(json: json["user"])
			else
		{
			log.error("No user in comment JSON")
			return nil
		}
		
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		
		guard let commentDateString = json["comment_date"].string, commentDate = formatter.dateFromString(commentDateString)
			else
		{
			log.error("No comment date in comment JSON")
			return nil
		}
		
		self.init(id: id,
			text: text,
			commentDate: commentDate,
			postId: postId,
			user: user)
	}
	
}