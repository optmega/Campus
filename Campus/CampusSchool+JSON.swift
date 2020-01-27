//
//  CampusSchool+JSON.swift
//  Campus
//
//  Created by Ivan Dilchovski on 3/8/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import SwiftyJSON

extension CampusSchool
{
	convenience init?(json: JSON)
	{
		guard let id = json["id"].int
			else
		{
			log.error("No id in school JSON")
			return nil
		}
		
		guard let name = json["name"].string
			else
		{
			log.error("No name in school JSON")
			return nil
		}
		
		guard let emailDomain = json["email_domain"].string
			else
		{
			log.error("No email domain in school JSON")
			return nil
		}
		
		self.init(id: id, name: name, emailDomain: emailDomain)
	}
}
