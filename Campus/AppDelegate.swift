//
//  AppDelegate.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/3/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

import Alamofire
import SwiftyJSON
import XCGLogger
import IQKeyboardManagerSwift

import FBSDKCoreKit

let log: XCGLogger = {
	let log = XCGLogger.defaultInstance()
	log.setup(.Debug, showThreadName: true, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLogLevel: .Debug)
	
	let dateFormatter = NSDateFormatter()
	dateFormatter.dateFormat = "MM/dd/yyyy hh:mma"
	dateFormatter.locale = NSLocale.currentLocale()
	log.dateFormatter = dateFormatter
	
	return log
}()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{

	var window: UIWindow?
	var rootTabController: UITabBarController!

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
	{
		// FB
		FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
		
		// Push
		let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
		application.registerUserNotificationSettings(settings)
		UIApplication.sharedApplication().registerForRemoteNotifications()
		
		// Appearance
		UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
		
		UINavigationBar.appearance().barTintColor = Constants.Colors.Purple
		UINavigationBar.appearance().translucent = false
		UINavigationBar.appearance().tintColor = UIColor.whiteColor()
		UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
		
		UINavigationBar.appearance().backIndicatorImage = UIImage(named: "BackIcon")
		UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "BackIcon")
		
		UITabBar.appearance().tintColor = UIColor.whiteColor()
		UITabBar.appearance().backgroundImage =  UIImage.imageWithColor(UIColor(red: 0.270, green: 0.270, blue: 0.270, alpha: 1),
			size: CGSizeMake(4, 4)).resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0))

		UITabBar.appearance().selectionIndicatorImage = UIImage.imageWithColor(UIColor(red: 0.301, green: 0.129, blue: 0.439, alpha: 1),
			size: CGSizeMake(4, 49)).resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0),
				resizingMode: UIImageResizingMode.Tile)
		
		if UIScreen.mainScreen().nativeBounds.height > 1000
		{
			Constants.Values.TableViewRowHeight = (UIScreen.mainScreen().nativeBounds.height / UIScreen.mainScreen().nativeScale) / 7 //7 rows per screen (not taking into account nav & tab bars!
		} else
		{
			Constants.Values.TableViewRowHeight = (UIScreen.mainScreen().nativeBounds.height / UIScreen.mainScreen().nativeScale) / 5 //5 rows per screen (not taking into account nav & tab bars!
		}
		
		rootTabController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
		rootTabController.selectedIndex = 1
		
		IQKeyboardManager.sharedManager().enable = true
		
		#if (arch(i386) || arch(x86_64)) && os(iOS)
			IQKeyboardManager.sharedManager().enable = false //Disable view offset for keyboard on simulator
		#endif
		
		//The unauthenticated identity in this pool should only be allowed to PutObject in the profile_pictures folder of the bucket
		//TODO: Proper authentication via temporary credentials via backend and AWS Cognito
		let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .EUWest1, identityPoolId: "eu-west-1:f2fb2c0a-b3ba-432d-9acb-a3ba5fc834fa")
		let configuration = AWSServiceConfiguration(region: .EUWest1, credentialsProvider: credentialsProvider)
		AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
		
		// Make sure path exist
		let cachedProfilePicturesURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("profile_pictures")
		try! NSFileManager.defaultManager().createDirectoryAtURL(cachedProfilePicturesURL, withIntermediateDirectories: true, attributes: nil)
		
		let cachedGroupPicturesURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent("group_pictures")
		try! NSFileManager.defaultManager().createDirectoryAtURL(cachedGroupPicturesURL, withIntermediateDirectories: true, attributes: nil)
		
		return true
	}
	
	func applicationWillResignActive(application: UIApplication)
	{
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication)
	{
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication)
	{
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication)
	{
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication)
	{
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}

	
	// MARK: - Push Notifications
	
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void)
	{		
		if let privateMessage = userInfo["private_message"] where CampusUser.currentUser.id != -1
		{
			let pmJson = JSON(privateMessage)
			completionHandler(.NewData)
			CampusPrivateMessage.buildFromJson(pmJson) { (pm) -> () in
					if let message = pm
					{
						if message.conversation.participants.map({$0.id}).contains(CampusUser.currentUser.id)
						{
							let notification = NSNotification(name: Constants.NotificationIds.NotificationNewPrivateMessage, object: nil, userInfo: ["message" : message])
							NSNotificationCenter.defaultCenter().postNotification(notification)
						}
					} else
					{
						log.error("Could not parse private message from push payload")
						completionHandler(.NoData)
					}
			}
		} else if let groupPost = userInfo["group_post"] where CampusUser.currentUser.id >= 0
		{
			let postJson = JSON(groupPost)
			CampusGroupPost.fetchFromJSON(postJson) { (post) -> () in
				completionHandler(.NewData)
				if let post = post
				{
					let notification = NSNotification(name: Constants.NotificationIds.NotificationNewGroupPost, object: nil, userInfo: ["post" : post])
					NSNotificationCenter.defaultCenter().postNotification(notification)
				}
			}
		} else
		{
			completionHandler(.NoData)
		}
		
	}
	
	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData)
	{
		let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
		var tokenString = ""
		for i in 0..<deviceToken.length {
			tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
		}
		
		Settings.Device.pushToken = tokenString
		
		log.info("Device token \(Settings.Device.pushToken)")
	}
	
	func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
		log.error("Failed to register for remote")
	}

}

