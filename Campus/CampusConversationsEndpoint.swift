//
//  CampusConversationsEndpoint.swift
//  Campus
//
//  Created by Ivan Dilchovski on 3/18/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import Alamofire

enum CampusConversationsEndpoint: Endpoint
{
	case CreateConversation(conversation: CampusConversation)
	case UpdateConversation(conversation: CampusConversation)
	case GetConversation(id: Int)
	case GetConversations
	
	case AddParticipants(conversation: CampusConversation, users: [CampusUser])
	case ConversationWithParticipants(users: [CampusUser])
	
	case CreateMessage(text: String, conversation: CampusConversation)
	case GetMessagesInConversation(conversation: CampusConversation, sinceMessageId: Int?)
	case GetUnreadCountInConversation(conversation: CampusConversation)
	
	case GetTotalUnreadCount
	
	var path : String
	{
		switch self
		{
			case .CreateConversation:								return "/conversations"
			case .UpdateConversation(let conversation):				return "/conversations/\(conversation.id)"
			case .GetConversation(let id):							return "/conversations/\(id)"
			case .GetConversations:									return "/conversations"
			
			case .AddParticipants(let conversation, _):				return "/conversations/\(conversation.id)/add_participants"
			case .ConversationWithParticipants:						return "/conversations/conversation_with_participants"
			
			case .CreateMessage(_, let conversation):				return "/conversations/\(conversation.id)/create_message"
			case .GetMessagesInConversation(let conversation, let sinceMessageId):
				if let sinceMessageId = sinceMessageId
				{
					return "/conversations/\(conversation.id)/messages/since_message/\(sinceMessageId)"
				} else
				{
					return "/conversations/\(conversation.id)/messages"
				}
			case .GetUnreadCountInConversation(let conversation):	return "/conversations/\(conversation.id)/unread_count"
			
			case .GetTotalUnreadCount:								return "/conversations/total_unread"
		}
	}
	
	var method: Alamofire.Method
	{
		switch self
		{
			case .CreateConversation:			return .POST
			case .UpdateConversation:			return .PUT
			case .GetConversation:				return .GET
			case .GetConversations:				return .GET
			
			case .AddParticipants:				return .POST
			case .ConversationWithParticipants:	return .GET
			
			case .CreateMessage:				return .POST
			case .GetMessagesInConversation:	return .GET
			case .GetUnreadCountInConversation:	return .GET
			case .GetTotalUnreadCount:			return .GET
		}
	}
	
	var parameters: [String : AnyObject]?
	{
		switch self
		{
			case .CreateConversation(let conversation):
				var parameters = [String : AnyObject]()
				parameters["conversation"] = [String : AnyObject]() //Gurantee at least an empty dic for :conversation key
				
				if let title = conversation.title
				{
					parameters = ["conversation" :	["title" : title]]
				}
				
				parameters["participants"] = conversation.participants.map({ $0.id })
			
				return parameters
			
			case .UpdateConversation(let conversation):
				var parameters = [String : AnyObject]()
				parameters["conversation"] = [String : AnyObject]() //Gurantee at least an empty dic for :conversation key
				
				if let title = conversation.title
				{
					parameters = ["conversation" :	["title" : title]]
				} else
				{
					parameters = ["conversation" :	["title" : ""]]
				}
				
				return parameters
			
			case .AddParticipants(_, let users): return ["participants" : users.map {$0.id }]
			case .ConversationWithParticipants(let users): return ["participant_ids" : users.map { $0.id }]
			
			case .CreateMessage(let text, _): return ["private_message" : ["text" : text]]
			
			default: return nil
		}
	}
	
	var encoding: Alamofire.ParameterEncoding
	{
		switch self
		{
			case .ConversationWithParticipants: return .URLEncodedInURL
			default: return .JSON
		}
	}
	
	var headers: [String : String]?
	{
		var headers = [String : String]()
		
		switch self
		{
			default:
				headers["Accept"] = "application/json"
		}
		
		switch self
		{
			default:
				if let (email, token) = authTokenAndMail
				{
					let authHeader = "Token token=\"\(token)\", email=\"\(email)\""
					headers["Authorization"] = authHeader
				}
		}
		
		return headers
	}
}