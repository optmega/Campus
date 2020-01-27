//
//  Group.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/6/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

// TODO: Some sort of caching for group objects for basic things like name, description, picture 

class CampusGroup
{
	enum UserAccessLevel: String
	{
		case None		= "none"
		case Follower	= "follower"
		case Member		= "member"
		case Admin		= "admin"
	}
	
	enum JoinRequestStatus: String
	{
		case None		= "none"
		case Pending	= "pending"
		case Approved	= "approved"
		case Declined	= "declined"
	}
	
	enum GroupType: String
	{
		case SchoolRecognized = "School Recognized"
		case InterestGroup = "Interests Group"
		case Other = "Other"
		
		static let All = [SchoolRecognized, InterestGroup, Other]
	}
	
	enum SchoolRecognizedGroupType: String
	{
		case GreekOrganization = "Greek Organization"
		case ClubSport = "Club Sport"
		case VarietySport = "Variety Sport"
		case AcademicOrganization = "Academic Organization"
		case Other = "Other"
		
		static let All = [GreekOrganization, ClubSport, VarietySport, AcademicOrganization, Other]
	}
	
	var id:						Int				= -1
	var name:					String?			= nil
	var description:			String?			= nil
	var groupPicturePath:		String?			= nil
	
	var groupType:				GroupType?		= nil
	var recognizedGroupType:	SchoolRecognizedGroupType?	= nil
	
	var president:				String?			= nil
	var executive:				String?			= nil
	var executive2:				String?			= nil
	var executive3:				String?			= nil
	
	var lastPostDate:			NSDate?			= nil
	
	var createdAt:				NSDate?			= nil
	var updatedAt:				NSDate?			= nil
	
	var school:					CampusSchool?	= nil
	
	var task: AWSTask?						= nil // Can't declare stored properties in extensions :(
}