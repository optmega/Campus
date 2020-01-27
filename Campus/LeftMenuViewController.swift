//
//  LeftMenuViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/4/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class LeftMenuViewController: UIViewController
{
	@IBAction func myGroupsPressed(sender: UIButton)
	{
		let myGroupsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("MyGroupsViewController")
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		if let navController = delegate.rootTabController.selectedViewController as? UINavigationController
		{
			navController.pushViewController(myGroupsController, animated: true)
		}
		
		self.viewDeckController.toggleLeftView()
	}
	
	@IBAction func createGroupPressed(sender: UIButton)
	{
		let createGroupController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CreateGroupViewController")
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		if let navController = delegate.rootTabController.selectedViewController as? UINavigationController
		{
			navController.pushViewController(createGroupController, animated: true)
		}
		
		self.viewDeckController.toggleLeftView()
	}
	
	@IBAction func editProfilePressed(sender: UIButton)
	{
		let editProfileController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(ProfileEditAboutViewController.storyboardId)
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		if let navController = delegate.rootTabController.selectedViewController as? UINavigationController
		{
			navController.pushViewController(editProfileController, animated: true)
		}
		
		self.viewDeckController.toggleLeftView()
	}
	
	@IBAction func friendsPressed(sender: UIButton)
	{
		let friendsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(FollowingViewController.storyboardId)
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		if let navController = delegate.rootTabController.selectedViewController as? UINavigationController
		{
			navController.pushViewController(friendsController, animated: true)
		}
		
		self.viewDeckController.toggleLeftView()

	}
	
	@IBAction func signOutPressed(sender: UIButton)
	{
		LoginHelper.logout()
		
		let loginNavController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoginNavigationController")
		let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
		
		self.viewDeckController.toggleLeftView()
		
		delegate.window?.rootViewController = loginNavController
		
	}
	
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		

    }

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
