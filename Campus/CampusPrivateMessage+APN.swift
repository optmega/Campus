//
//  CampusPrivateMessage+APN.swift
//  Campus
//
//  Created by Ivan Dilchovski on 3/20/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import SwiftyJSON

extension CampusPrivateMessage
{
	static func buildFromJson(json: JSON, handler: (pm: CampusPrivateMessage?) -> ())
	{
		guard let id = json["id"].int
			else
		{
			log.error("No id in private message JSON")
			handler(pm: nil)
			return
		}
		
		guard let text = json["text"].string
			else
		{
			log.error("No text in private message JSON")
			handler(pm: nil)
			return
		}
		
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		
		guard let sentDateString = json["sent_date"].string, sentDate = formatter.dateFromString(sentDateString)
			else
		{
			log.error("No or malformed sent date in private message JSON")
			handler(pm: nil)
			return
		}
		
		guard let conversationId = json["conversation_id"].int
			else
		{
			log.error("No conversation in private message JSON")
			handler(pm: nil)
			return
		}
		
		guard let sender_id = json["sender_id"].int
			else
		{
			log.error("No sender in private message JSON")
			handler(pm: nil)
			return	
		}
		
		var conversation: CampusConversation? = nil
		var sender: CampusUser? = nil
		
		let group = dispatch_group_create()
		dispatch_group_enter(group)
		dispatch_group_enter(group)
		
		CampusConversationsRequest.getConversation(id: conversationId,
			successHandler: { (closureConversation) -> () in
				conversation = closureConversation
				dispatch_group_leave(group)
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(group)
		})
		
		CampusUserRequests.getUser(sender_id,
			success: { (user) -> () in
				sender = user
				dispatch_group_leave(group)
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(group)
		})
		
		dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
			if let conversation = conversation, sender = sender
			{
				let pm = CampusPrivateMessage (
					id: id,
					text: text,
					conversation: conversation,
					sender: sender,
					sentDate: sentDate)
				handler(pm: pm)
			} else
			{
				handler(pm: nil)
			}
		}
		

	}

}