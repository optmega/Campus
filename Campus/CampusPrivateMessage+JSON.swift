//
//  CampusPrivateMessage+JSON.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/10/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import SwiftyJSON

extension CampusPrivateMessage
{
	convenience init?(json: JSON)
	{
		guard let id = json["id"].int
			else
		{
			log.error("No id in private message JSON")
			return nil
		}
		
		guard let text = json["text"].string
			else
		{
			log.error("No text in private message JSON")
			return nil
		}
		
		guard let conversation = CampusConversation(json: json["conversation"])
			else
		{
			log.error("No conversation in private message JSON")
			return nil
		}
		
		guard let sender = CampusUser(json: json["sender"])
			else
		{
			log.error("No sender in private message JSON")
			return nil
		}
		
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0) // Dates are in UTC on server
		
		guard let sentDateString = json["sent_date"].string, sentDate = formatter.dateFromString(sentDateString)
			else
		{
			log.error("No or malformed sent date in private message JSON")
			return nil
		}
		
		self.init(
			id: id,
			text: text,
			conversation: conversation,
			sender: sender,
			sentDate: sentDate)
	}
}