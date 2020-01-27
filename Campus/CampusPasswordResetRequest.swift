//
//  CampusPasswordResetRequest.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/14/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Alamofire

class CampusPasswordResetRequest: Request
{
	class func requestResetForEmail(
		email: String,
		successHandler success: (() -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let passwordResetEndpoint = CampusPasswordResetEndpoint.RequestReset(email: email)
		makeRequestToEndpoint(passwordResetEndpoint,
			withResponseHandler: { (_) -> () in
				success?()
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
}