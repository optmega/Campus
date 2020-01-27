//
//  FollowingViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 3/17/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class FollowingViewController: UIViewController, UITableViewDataSource
{
	static let storyboardId = "FollowingViewController"
	
	static private let friendPublicProfileSegueId = "friendsToPublicProfile"
	
	// MARK: - Outlets
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()

		tableView.rowHeight = Constants.Values.TableViewRowHeight
		
		if CampusUser.currentUser.followedUsers == nil
		{
			activityIndicator.startAnimating()
			CampusUserRequests.getFollowedUsers(
				{ (users) -> () in
					CampusUser.currentUser.followedUsers = users
					self.tableView.reloadData()
					self.activityIndicator.stopAnimating()
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		}
		
        // Do any additional setup after loading the view.
    }

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? PublicProfileViewController,
			sender = sender as? GroupMembersTableCell
			where segueId == FollowingViewController.friendPublicProfileSegueId
		{
			destVC.user = sender.member
		}
	}
    

    // MARK: - UITableViewDataSource
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return CampusUser.currentUser.followedUsers?.count ?? 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		guard let user = CampusUser.currentUser.followedUsers?[indexPath.row]
			else
		{
			log.error("Followed users is nil??")
			return UITableViewCell()
		}
		
		let cell = tableView.dequeueReusableCellWithIdentifier(GroupMembersTableCell.reuseId, forIndexPath: indexPath) as! GroupMembersTableCell
		cell.member = user
		
		cell.memberName.text = user.firstName + " " + user.lastName
		
		user.getProfilePictureFromS3(handler: { (image) -> () in
			if let visibleRows = tableView.indexPathsForVisibleRows where visibleRows.contains(indexPath)
			{
				if let image = image
				{
					cell.profilePicture.image = image
				} else if image == nil
				{
					cell.profilePicture.image = UIImage(named: Constants.Values.NoPhotoImageName)
				}
			}
		})
		
		return cell
	}
}
