//
//  CampusSchoolRequest.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/8/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

class CampusSchoolRequest: Request
{
	static func getSchools(successHandler success: ((schools: [CampusSchool]) -> ())?, failureHandler failure: ((error: RequestError) -> ())?)
	{
		makeRequestToEndpoint(CampusSchoolEndpoint.GetSchools,
			withJSONResponseHandler: { (json) -> () in
				var schools = [CampusSchool]()

				let schoolsJson = json["schools"]
				
				if let jsonError = schoolsJson.error
				{
					failure?(error: RequestError.BadResponseFormat("Error parsing schools from JSON \(jsonError.localizedDescription)"))
				} else
				{
					for (_, json) in schoolsJson
					{
						guard let school = CampusSchool(json: json)
							else
						{
							continue
						}
						
						schools.append(school)
					}
					
					success?(schools: schools)
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
}