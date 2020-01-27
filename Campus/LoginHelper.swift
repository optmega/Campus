//
//  LoginHelper.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/9/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

import Locksmith
import Alamofire

class LoginHelper
{
	private static let keychainCampusAccount = "CampusApp"
	private static let keychainEmailKey = "email"
	private static let keychainTokenKey = "token"
	
	class func loginWithKeychain(successHandler success: ((user: CampusUser) -> ())?, failureHandler failure: ((error: RequestError) -> ())?)
	{
		if let (email, token) = LoginHelper.getEmailAndTokenFromKeychain()
		{
			CampusSessionRequest.verifyToken(token, email: email,
				successHandler: { (user) -> () in
					success?(user: user)
					CampusUser.currentUser = user
					CampusUser.currentUserAuthToken = token
				},
				failureHandler: { (requestError) -> () in
					failure?(error: requestError)
			})
		} else
		{
			failure?(error: RequestError.StatusCode(statusCode: 401, message: nil))
		}
		
	}
	
	class func loginWithEmail(email: String, password: String, rememberMe: Bool, successHandler success: ((user: CampusUser) -> ())?, failureHandler failure: ((error: RequestError) -> ())?)
	{
		CampusSessionRequest.login(
			email: email,
			password: password,
			successHandler: { (user) -> () in
				if let token = user.authToken
				{
					CampusUser.currentUserAuthToken = token
					do
					{
						if rememberMe
						{
							if var loginData = Locksmith.loadDataForUserAccount(keychainCampusAccount)
							{
								loginData[keychainTokenKey] = token
								loginData[keychainEmailKey] = email
								try Locksmith.updateData(loginData, forUserAccount: keychainCampusAccount)
							} else
							{
								var loginData = [String : AnyObject]()
								loginData[keychainTokenKey] = token
								loginData[keychainEmailKey] = email
								
								try Locksmith.saveData(loginData, forUserAccount: keychainCampusAccount)
							}
						} else
						{
							try Locksmith.deleteDataForUserAccount(keychainCampusAccount) // Delete to be sure there is no old data in the keychain.
						}
					} catch let error as LocksmithError
					{
						log.error("Error while storing auth token to keychain: \(error.rawValue)")
					} catch
					{
						log.error("Unknown error while storing auth token to keychain")
					}
				}
				success?(user: user)
			},
			failureHandler: { (requestError) -> () in
				failure?(error: requestError)
		})
	}
	
	class func logout()
	{
		CampusSessionRequest.logout(
			successHandler: { () -> () in
				log.info("Logout from surver success")
			},
			failureHandler: { (error) -> () in
				log.error("Could not logout from surver")
		})
		
		CampusUser.currentUser = CampusUser()
		CampusUser.currentUserAuthToken = nil
		
		do
		{
			try Locksmith.deleteDataForUserAccount(keychainCampusAccount)
		} catch let error as LocksmithError
		{
			log.error("Error while deleteing account data from keychain \(error.rawValue)")
		} catch
		{
			log.error("Unknown error while deleteing account data from keychain")
		}
	}
	
	class func getEmailAndTokenFromKeychain() -> (email: String, token: String)?
	{
		if let loginData = Locksmith.loadDataForUserAccount(keychainCampusAccount), token = loginData[keychainTokenKey] as? String, email = loginData[keychainEmailKey] as? String
		{
			return (email, token)
		} else
		{
			return nil
		}
	}
}