//
//  CampusUser+JSON.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/4/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import SwiftyJSON

extension CampusUser
{
	convenience init?(json: JSON)
	{
		guard let id = json["id"].int
			else
		{
			log.error("No id in user JSON")
			return nil
		}
		
		guard let email = json["email"].string
			else
		{
			log.error("No email in user JSON")
			return nil
		}
		
		guard let school = CampusSchool(json: json["school"])
			else
		{
			log.error("No school in group JSON")
			return nil
		}
		
		self.init()
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = Constants.Values.BackendTimestampsFormat
		
		self.id = id
		self.email = email
		self.authToken = json["token"].string
		self.firstName = json["firstname"].stringValue
		self.lastName = json["lastname"].stringValue
		self.about = json["about"].stringValue
		
		self.major = json["major"].string
		self.bio = json["bio"].string
		self.dreamJob = json["dream_job"].string
		self.hobbies = json["hobbies"].string
		self.favouriteQuote = json["favourite_quote"].string
		if let birthdayString = json["birthday"].string
		{
			self.birthday = dateFormatter.dateFromString(birthdayString)
		}
		
		if let profilePicturePath = json["profile_picture_path"].string
		{
			self.profilePicturePath = profilePicturePath
			getProfilePictureFromS3(handler: nil)
		}
		
		self.firstLogin = json["first_login"].boolValue
		
		self.school = school
		
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