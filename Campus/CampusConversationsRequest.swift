//
//  CampusConversationsRequest.swift
//  Campus
//
//  Created by Ivan Dilchovski on 3/18/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Alamofire

class CampusConversationsRequest: Request
{
	class func createConversation(
		conversation: CampusConversation,
		successHandler success: ((conversation: CampusConversation) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusConversationsEndpoint.CreateConversation(conversation: conversation)
		makeRequestToEndpoint(endpoint,
			withJSONResponseHandler: { (json) -> () in
				if let conversation = CampusConversation(json: json["conversation"])
				{
					success?(conversation: conversation)
				}  else
				{
					log.error("Could not get conversation from JSON response")
					failure?(error: RequestError.BadResponseFormat("Could not get conversation from JSON response"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func updateConversation(
		conversation: CampusConversation,
		successHandler success: ((conversation: CampusConversation) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusConversationsEndpoint.UpdateConversation(conversation: conversation)
		makeRequestToEndpoint(endpoint,
			withJSONResponseHandler: { (json) -> () in
				if let conversation = CampusConversation(json: json["conversation"])
				{
					success?(conversation: conversation)
				}  else
				{
					log.error("Could not get conversation from JSON response")
					failure?(error: RequestError.BadResponseFormat("Could not get conversation from JSON response"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func getConversation(
		id id: Int,
		successHandler success: ((conversation: CampusConversation) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusConversationsEndpoint.GetConversation(id: id)
		makeRequestToEndpoint(endpoint,
			withJSONResponseHandler: { (json) -> () in
				if let conversation = CampusConversation(json: json["conversation"])
				{
					success?(conversation: conversation)
				}  else
				{
					log.error("Could not get conversation from JSON response")
					failure?(error: RequestError.BadResponseFormat("Could not get conversation from JSON response"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func getConversations(
		successHandler success: ((conversations: [CampusConversation]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusConversationsEndpoint.GetConversations
		makeRequestToEndpoint(endpoint,
			withJSONResponseHandler: { (json) -> () in
				if let jsonConversations = json["conversations"].array
				{
					var conversations = [CampusConversation]()
					for conversationJson in jsonConversations
					{
						if let conversation = CampusConversation(json: conversationJson)
						{
							conversations.append(conversation)
						}
					}
					
					success?(conversations: conversations)
				} else
				{
					log.error("No groups array in JSON")
					failure?(error: RequestError.BadResponseFormat("No groups array in JSON"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func createMessageWithText(
		text: String,
		inConversation conversation: CampusConversation,
		successHandler success: ((message: CampusPrivateMessage) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusConversationsEndpoint.CreateMessage(text: text, conversation: conversation)
		makeRequestToEndpoint(endpoint,
			withJSONResponseHandler: { (json) -> () in
				if let message = CampusPrivateMessage(json: json["private_message"])
				{
					success?(message: message)
				} else
				{
					log.error("Could not parse private message response")
					failure?(error: RequestError.BadResponseFormat("Could not parse private message response"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	
	
	class func addParticipants(
		participants: [CampusUser],
		toConversation conversation: CampusConversation,
		successHandler success: ((conversation: CampusConversation) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusConversationsEndpoint.AddParticipants(conversation: conversation, users: participants)
		makeRequestToEndpoint(endpoint,
			withJSONResponseHandler: { (json) -> () in
				if let conversation = CampusConversation(json: json["conversation"])
				{
					success?(conversation: conversation)
				}  else
				{
					log.error("Could not get conversation from JSON response")
					failure?(error: RequestError.BadResponseFormat("Could not get conversation from JSON response"))
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func getConversationWithParticipants(
		participants: [CampusUser],
		successHandler success: ((conversation: CampusConversation?) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusConversationsEndpoint.ConversationWithParticipants(users: participants)
		makeRequestToEndpoint(endpoint,
			withJSONResponseHandler: { (json) -> () in
				if let conversation = CampusConversation(json: json["conversation"])
				{
					success?(conversation: conversation)
				}  else
				{
					success?(conversation: nil)
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func getMessagesInConversation(
		conversation: CampusConversation,
		sinceMessageId: Int?,
		successHandler success: ((messages: [CampusPrivateMessage]) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusConversationsEndpoint.GetMessagesInConversation(conversation: conversation, sinceMessageId: sinceMessageId)
		makeRequestToEndpoint(endpoint,
			withJSONResponseHandler: { (json) -> () in
				if let jsonMessages = json["private_messages"].array
				{
					var messages = [CampusPrivateMessage]()
					
					for messageJson in jsonMessages
					{
						if let message = CampusPrivateMessage(json: messageJson)
						{
							messages.append(message)
						}
					}
					
					success?(messages: messages)
				} else
				{
					log.error("No private messages array in JSON")
					failure?(error: RequestError.BadResponseFormat("No private messages array in JSON"))
				}

			},
			failureHandler: { (requestError) -> () in
				failure?(error:requestError)
		})
	}
	
	class func getUnreadCountInConversation(
		conversation: CampusConversation,
		successHandler success: ((count: Int) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusConversationsEndpoint.GetUnreadCountInConversation(conversation: conversation)
		makeRequestToEndpoint(endpoint,
			withJSONResponseHandler: { (json) -> () in
				if let count = json["count"].int
				{
					success?(count: count)
				} else
				{
					log.error("No count in JSON")
					failure?(error: RequestError.BadResponseFormat("No count in JSON"))
					
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)	
		})
	}
	
	class func getTotalUnreadCount(
		successHandler success: ((count: Int) -> ())?,
		failureHandler failure: ((error: RequestError) -> ())?)
	{
		let endpoint = CampusConversationsEndpoint.GetTotalUnreadCount
		makeRequestToEndpoint(endpoint,
			withJSONResponseHandler: { (json) -> () in
				if let count = json["count"].int
				{
					success?(count: count)
				} else
				{
					log.error("No count in JSON")
					failure?(error: RequestError.BadResponseFormat("No count in JSON"))
					
				}
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
}