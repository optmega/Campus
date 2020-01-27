//
//  CampusConversation+JSON.swift
//  Campus
//
//  Created by Ivan Dilchovski on 3/18/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import SwiftyJSON

extension CampusConversation
{
	convenience init?(json: JSON)
	{
		guard let id = json["id"].int
			else
		{
			log.error("No id in conversation JSON")
			return nil
		}
		
		var participants = [CampusUser]()
		if let jsonParticipants = json["participants"].array
		{
			for participantJson in jsonParticipants
			{
				if let user = CampusUser(json: participantJson)
				{
					participants.append(user)
				}
			}
		}
		
		let title = json["title"].string
		
		self.init(id: id, title: title, participants: participants)
		
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		
		if let dateString = json["last_message_date"].string, lastMessageDate = formatter.dateFromString(dateString)
		{
			self.lastMessageDate = lastMessageDate
		}

	}
}