//
//  CampusGroup+JSON.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/5/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import SwiftyJSON

extension CampusGroup
{
	convenience init?(json: JSON)
	{
		guard let id = json["id"].int
			else
		{
			log.error("No id in group JSON")
			return nil
		}
		
		guard let name = json["name"].string
			else
		{
			log.error("No name in group JSON")
			return nil
		}
		
		guard let school = CampusSchool(json: json["school"])
			else
		{
			log.error("No school in group JSON")
			return nil
		}
		
		self.init()
		
		self.id = id
		self.name = name
		self.description = json["description"].string
		self.school = school
		
		if let groupPicturePath = json["group_picture_path"].string
		{
			self.groupPicturePath = groupPicturePath
		}
		
		let formatter = NSDateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		if let lastPostDateString = json["last_post_date"].string, lastPostDate = formatter.dateFromString(lastPostDateString)
		{
			self.lastPostDate = lastPostDate
		}

		
		if let groupTypeString = json["group_type"].string, groupType = GroupType(rawValue: groupTypeString)
		{
			self.groupType = groupType
		}
		
		if let recognizedTypeString = json["recognized_group_type"].string, recognizedType = SchoolRecognizedGroupType(rawValue: recognizedTypeString)
		{
			self.recognizedGroupType = recognizedType
		}
		
		self.president = json["president"].string
		self.executive = json["executive"].string
		self.executive2 = json["executive2"].string
		self.executive3 = json["executive3"].string
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = Constants.Values.BackendTimestampsFormat
		
		if let createdAtString = json["created_at"].string, createdAt = dateFormatter.dateFromString(createdAtString)
		{
			self.createdAt = createdAt
		}
		
		if let updatedAtString = json["updated_at"].string, updatedAt = dateFormatter.dateFromString(updatedAtString)
		{
			self.updatedAt = updatedAt
		}
	}
}