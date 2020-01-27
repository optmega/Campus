//
//  Constants.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/3/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

struct Constants
{
	struct URLStrings
	{
//		static let CampusServer = "http://192.168.1.54:3000"
//		static let CampusServer = "http://localhost:3000"
		static let CampusServer = "https://campus-backend.herokuapp.com"
	}
	
	struct Values
	{
		static var TableViewRowHeight = (UIScreen.mainScreen().nativeBounds.height / UIScreen.mainScreen().nativeScale) / 7 //7 rows per screen (not taking into account nav & tab bars!
		static let FieldsBorderWidth: CGFloat = 1.0
		
		static let AnimationDurationShort = 0.25
		static let AnimationDurationMedium = 0.5
		static let AnimationDurationLong = 1
		
		static let ProfilePictureSize = CGSize(width: 256, height: 256)
		
		static let S3BucketName = "campusstorage"
		
		static let BackendDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
		static let BackendTimestampsFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
		
		static let NoPhotoImageName = "no-foto-icon"
		
		static let PlatformString	= "ios"
		
		static let ComplexFetchTimeout = 15 // Timeout when having to fetch inner objects (etc. PrivateMessage -> Sender & Receiver)
		
		static let FacebookNativeAdPlacementId = "709465759194281_709466719194185"
		static let FacebookNativeAdFrequency: UInt = 5
	}
	
	struct Strings
	{
		static let EnterMessagePlaceholder = "Enter your message"
		static let ShortDescriptionPlaceholder = "Short description"
	}
	
	struct Colors
	{
		static let Purple = UIColor(red: 0.301, green: 0.129, blue: 0.439, alpha: 1)
		static let DarkPurple = UIColor(red: 0.196, green: 0.082, blue: 0.290, alpha: 1)
		static let BrightPurple = UIColor(red: 0.525, green: 0.223, blue: 0.768, alpha: 1)
		
		static let DefaultTextFieldBorderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
	}
	
	struct NotificationIds
	{
		static let NotificationNewPrivateMessage = "NotificationNewPrivateMessage"
		static let NotificationNewGroupPost	= "NotificationNewGroupPost"
	}
}
