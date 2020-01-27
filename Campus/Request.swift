//
//  CampusRequest.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

protocol Request
{
	static func makeRequestToEndpoint(endpoint: Endpoint,
		withJSONResponseHandler jsonResponseHandler:  ((json: JSON) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?)
	
	static func makeRequestToEndpoint(endpoint: Endpoint,
		withResponseHandler responseHandler:  ((NSHTTPURLResponse) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?)
}

extension Request
{
	static func makeRequestToEndpoint(endpoint: Endpoint,
		withJSONResponseHandler jsonResponseHandler:  ((json: JSON) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?)
	{
		Alamofire.request(endpoint.method, endpoint.baseURL + endpoint.path, parameters: endpoint.parameters, encoding: endpoint.encoding, headers: endpoint.headers).responseString(completionHandler: { (response) -> Void in
//			print(" ")
//			log.info(String(reflecting: response))
//			print(" ")
		}).responseJSON { (response) -> Void in
			if let error = response.result.error
			{
				if error.domain == NSURLErrorDomain && error.code == -1004
				{
					log.error("No network connection")
					failure?(requestError: .NoConnection)
				} else
				{
					log.error("Error sending request to server: \(error.localizedDescription)")
					failure?(requestError: .Other(error.localizedDescription))
				}
			} else
			{
				if let value: AnyObject = response.result.value, statusCode = response.response?.statusCode
				{
					let json = JSON(value)
					
					guard json.error == nil
						else
					{
						log.error("Unprocessable JSON response: \(json.error!.description)")
						failure?(requestError: .BadResponseFormat("Unprocessable JSON response: \(json.error!.description)"))
						
						return
					}
					
					if let status = json["status"].string where status == "success"
					{
						if statusCode >= 200 && statusCode <= 299 //Only possible way for success
						{
							log.info("Request for \(endpoint.path) success")
							jsonResponseHandler?(json: json["data"])
						} else
						{
							log.error("Success status in JSON, but status code != 2xx !") // JSON object claims success, but the status code is wrong?
							jsonResponseHandler?(json: json["data"])
						}
					} else if let status = json["status"].string where status == "error"
					{
						var errorString = ""
						for (_, error): (String, JSON) in json["errors"]
						{
							errorString += "\(error["title"].stringValue)\n"
						}
						
						log.error("JSON error status. Status Code \(statusCode). JSON Error Message \(errorString)")
						failure?(requestError: .StatusCode(statusCode: statusCode, message: errorString))
					} else if json["status"].string == nil
					{
						log.error("No status in JSON")
						failure?(requestError: .BadResponseFormat("No status in JSON"))
					}
				} else
				{
					if let statusCode = response.response?.statusCode
					{
						log.error("Status code \(statusCode) with nil response")
						failure?(requestError: .StatusCode(statusCode: statusCode, message: "Nil response"))
					} else
					{
						log.error("No response value and no status code")
						failure?(requestError: .BadResponseFormat("No response value and no status code"))
					}
				}
			}
		}
	}
	
	static func makeRequestToEndpoint(endpoint: Endpoint,
		withResponseHandler responseHandler:  ((NSHTTPURLResponse) -> ())?,
		failureHandler failure: ((requestError: RequestError) -> ())?)
	{
		Alamofire.request(endpoint.method, endpoint.baseURL + endpoint.path, parameters: endpoint.parameters, encoding: endpoint.encoding, headers: endpoint.headers).responseString(completionHandler: { (response) -> Void in
//			print(" ")
//			log.info(String(reflecting: response))
//			print(" ")
		}).response { (request, response, data, error) -> Void in
			if let error = error
			{
				if error.domain == NSURLErrorDomain && error.code == -1004
				{
					log.error("No network connection")
					failure?(requestError: .NoConnection)
				} else
				{
					log.error("Error with request to server: \(error.localizedDescription)")
					failure?(requestError: .Other(error.localizedDescription))
				}
			} else if let response = response
			{
				print(" ")
				log.verbose(String(reflecting: response))
				print(" ")
				
				if response.statusCode >= 200 && response.statusCode <= 299
				{
					log.info("Request success")
					responseHandler?(response)
				} else
				{
					log.error("Bad status code \(response.statusCode)")
					failure?(requestError: RequestError.StatusCode(statusCode: response.statusCode, message: "Status code != 2xx"))
				}
			} else
			{
				log.error("No response from server")
				failure?(requestError: .Other("No response from server"))
			}
		}
	}
	
	private static func parseErrorJSON(errorJson: JSON)
	{
		
	}
}