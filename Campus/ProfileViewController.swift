//
//  ProfileViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/5/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

import ViewDeck

class ProfileViewController: UIViewController, UITableViewDataSource
{
	private let editProfileSegueId = "editProfile"
	
	@IBOutlet var largeProfileImageView: UIImageView!
	@IBOutlet var profileImageView: UIImageView!

	@IBOutlet var tableView: UITableView!
	
	@IBAction func openMenuPressed(sender: UIBarButtonItem)
	{
		if let tabBarController = self.tabBarController
		{
			tabBarController.viewDeckController.toggleLeftView()
			if tabBarController.viewDeckController.isSideOpen(IIViewDeckSide.LeftSide)
			{
				navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu-close-icon"), style: .Plain, target: self, action: #selector(ProfileViewController.openMenuPressed(_:)))
			} else
			{
				navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu-open-icon"), style: .Plain, target: self, action: #selector(ProfileViewController.openMenuPressed(_:)))
			}
		}
	}
	
	func unsubscribe(sender: UIButton)
	{
		let post = CampusUser.currentUser.subscribedPosts![sender.tag]
		CampusGroupPostRequest.unsubscribe(post,
			successHandler: { () -> () in
				CampusUser.currentUser.subscribedPosts! = CampusUser.currentUser.subscribedPosts!.filter { $0.id != post.id }
				self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
			},
			failureHandler: { (error) -> () in
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})

	}
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		tableView.rowHeight = Constants.Values.TableViewRowHeight
		
		profileImageView.clipsToBounds = true

		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "MenuIcon"), style: .Plain, target: self.viewDeckController, action: #selector(IIViewDeckController.toggleLeftView))
    }

	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		CampusUser.currentUser.getProfilePictureFromS3 { (image) -> () in
			if let image = image
			{
				self.profileImageView.image = image
				self.largeProfileImageView.image = image
			}
		}
		
		tableView.rowHeight = Constants.Values.TableViewRowHeight
		tableView.reloadData()
		
		if tabBarController!.viewDeckController.isSideOpen(IIViewDeckSide.LeftSide)
		{
			navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu-close-icon"), style: .Plain, target: self, action: #selector(ProfileViewController.openMenuPressed(_:)))
		} else
		{
			navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu-open-icon"), style: .Plain, target: self, action: #selector(ProfileViewController.openMenuPressed(_:)))
		}
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier where segueId == editProfileSegueId
		{
			
		}
	}
	
	// MARK: - UITableViewDataSource
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return CampusUser.currentUser.subscribedPosts?.count ?? 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCellWithIdentifier(ProfilePostTableCell.reuseId, forIndexPath: indexPath) as! ProfilePostTableCell
		let post = CampusUser.currentUser.subscribedPosts![indexPath.row]
		
		cell.title.text = post.title
		cell.postText.text = post.text
		cell.date.text = post.postDate.shortLocalString()

		if cell.subscribeButton.allTargets().count == 0
		{
			cell.subscribeButton.addTarget(self, action: #selector(ProfileViewController.unsubscribe(_:)), forControlEvents: .TouchUpInside)
		}
		cell.subscribeButton.tag = indexPath.row
		
		
		return cell
	}
}
