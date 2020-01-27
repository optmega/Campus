//
//  EventViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 3/20/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class EventViewController: UIViewController
{
	static private let subscribersToPublicProfileSegueId = "subscribersToPublicProfile"
	
	var post: CampusGroupPost!
	
	private var followers: [CampusUser]?
	
	@IBOutlet var tableView: UITableView!
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		tableView.rowHeight = Constants.Values.TableViewRowHeight
		navigationItem.title = post.title
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		CampusGroupPostRequest.getSubscribers(post,
			successHandler: { (users) -> () in
				self.followers = users
				self.tableView.reloadData()
			},
			failureHandler: { (error) -> () in
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
    }
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier,
			cell = sender as? GroupMembersTableCell,
			destVC = segue.destinationViewController as? PublicProfileViewController
			where segueId == EventViewController.subscribersToPublicProfileSegueId
		{
			destVC.user = cell.member
		}
	}
}

extension EventViewController: UITableViewDataSource
{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return followers?.count ?? 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let follower = followers![indexPath.row]
		let cell = tableView.dequeueReusableCellWithIdentifier(GroupMembersTableCell.reuseId, forIndexPath: indexPath) as! GroupMembersTableCell
		cell.memberName.text = follower.firstName + " " + follower.lastName
		cell.member = follower
		
		follower.getProfilePictureFromS3 { (image) -> () in
			if let image = image
			{
				if let visibleRows = tableView.indexPathsForVisibleRows
					where visibleRows.contains(indexPath)
				{
					cell.profilePicture.image = image
				}
			} else
			{
				cell.profilePicture.image = UIImage(named: Constants.Values.NoPhotoImageName)
			}
		}
		
		return cell
	}
}