//
//  PublicProfileViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 3/12/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class PublicProfileViewController: UIViewController
{
	static private let toGroupSegueId = "publicProfileToGroup"
	// MARK: - Properties
	var user: CampusUser!
	
	private var administeredGroups: [CampusGroup]?
	private var joinedGroups: [CampusGroup]?
	private var followedGroups: [CampusGroup]?
	
	// MARK: - Outlets
	@IBOutlet weak var followButton: UIBarButtonItem!
	
	@IBOutlet var profilePicture: UIImageView!
	@IBOutlet var bio: UILabel!
	@IBOutlet var major: UILabel!
	@IBOutlet var dreamJob: UILabel!
	@IBOutlet var hobbies: UILabel!
	@IBOutlet var favouriteQuote: UILabel!
	@IBOutlet var birthday: UILabel!

	@IBOutlet var sendMessageButton: UIButton!
	
	@IBOutlet var groupsTableView: UITableView!
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	// MARK: - Outlets
	
	@IBAction func followPressed(sender: UIBarButtonItem)
	{
		activityIndicator.startAnimating()
		CampusUserRequests.followUser(user,
			successHandler: { (users) -> () in
				CampusUser.currentUser.followedUsers = users
				self.followButton.enabled = false
				self.activityIndicator.stopAnimating()
				
				let alertController = UIAlertController(title: "You are now following this user", message: nil, preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alertController.addAction(okAction)
				
				self.presentViewController(alertController, animated: true, completion: nil)
			}, failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
	}
	
	@IBAction func sendMessagePressed(sender: UIButton)
	{
		CampusConversationsRequest.getConversationWithParticipants([user],
			successHandler: { (conversation) -> () in
				let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
				delegate.rootTabController.selectedIndex = 0
				
				let conversationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(ConversationViewController.storyboardId) as! ConversationViewController
				if let conversation = conversation
				{
					conversationController.conversation = conversation
				} else
				{
					conversationController.conversation = CampusConversation(id: -1, title: nil, participants: [self.user, CampusUser.currentUser])
				}
				
				(delegate.rootTabController.selectedViewController as? UINavigationController)?.popToRootViewControllerAnimated(false)
				(delegate.rootTabController.selectedViewController as? UINavigationController)?.pushViewController(conversationController, animated: false)
			},
			failureHandler: { (error) -> () in
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
	}
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		followButton.enabled = false
		if user.id != CampusUser.currentUser.id
		{
			if let followedUsers = CampusUser.currentUser.followedUsers
			{
				if followedUsers.filter({ $0.id == user.id }).count == 0
				{
					followButton.enabled = true
				}
			} else
			{
				activityIndicator.startAnimating()
				CampusUserRequests.getFollowedUsers(
					{ (users) -> () in
						CampusUser.currentUser.followedUsers = users
						if users.filter({ $0.id == self.user.id }).count == 0
						{
							self.followButton.enabled = true
						}
						self.activityIndicator.stopAnimating()
					}, failureHandler: { (error) -> () in
						self.activityIndicator.stopAnimating()
						self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
				})
			}
		}
		
		groupsTableView.rowHeight = Constants.Values.TableViewRowHeight
		
		navigationItem.title = user.firstName + " " + user.lastName
		bio.text = user.bio
		major.text = user.major
		dreamJob.text = user.dreamJob
		hobbies.text = user.hobbies
		favouriteQuote.text = user.favouriteQuote
		
		if let birthdayDate = user.birthday
		{
			let formatter = NSDateFormatter()
			formatter.dateStyle = .ShortStyle
			formatter.timeStyle = .NoStyle
			
			birthday.text = formatter.stringFromDate(birthdayDate)
		}
		
		user.getProfilePictureFromS3(handler: { (image) -> () in
			if let image = image
			{
				self.profilePicture.image = image
			} else
			{
				self.profilePicture.image = UIImage(named: Constants.Values.NoPhotoImageName)
			}
		})
		
		getUserGroups()
    }
	
	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		
		sendMessageButton.layer.cornerRadius = sendMessageButton.frame.height / 2
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier,
			cell = sender as? MyGroupsGroupTableCell,
			destVC = segue.destinationViewController as? GroupViewController
			where segueId == PublicProfileViewController.toGroupSegueId
		{
			destVC.group = cell.group
		}
	}
	
	
	// MARK: - Private
	
	private func getUserGroups()
	{
		let group = dispatch_group_create()
		dispatch_group_enter(group)
		dispatch_group_enter(group)
		dispatch_group_enter(group)
		
		CampusUserRequests.getAdministeredGroups(
			forUser: user,
			success: { (groups) -> () in
				self.administeredGroups = groups
				
				dispatch_group_leave(group)
			},
			failureHandler: { (error) -> () in
				log.error("Could not get groups administered by user")
				dispatch_group_leave(group)
		})
		
		CampusUserRequests.getJoinedGroups(
			forUser: user,
			success: { (groups) -> () in
				self.joinedGroups = groups
				
				dispatch_group_leave(group)
			},
			failureHandler: { (error) -> () in
				log.error("Could not get groups joined by user")
				dispatch_group_leave(group)
		})
		
		CampusUserRequests.getFollowedGroups(
			forUser: user,
			success: { (groups) -> () in
				self.followedGroups = groups
				
				dispatch_group_leave(group)
			},
			failureHandler: { (error) -> () in
				log.error("Could not get groups followed by user")
				dispatch_group_leave(group)
		})
		
		dispatch_group_notify(group, dispatch_get_main_queue()) { () -> Void in
			self.groupsTableView.reloadData()
		}
	}
}

extension PublicProfileViewController: UITableViewDataSource, UITableViewDelegate
{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 3
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
	{
		switch section
		{
			case 0: return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? "Administered Groups" : nil
			case 1: return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? "Joined Groups" : nil
			case 2: return self.tableView(tableView, numberOfRowsInSection: section) > 0 ? "Followed Groups" : nil
				
			default: return ""
		}
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		switch section
		{
			case 0: return administeredGroups?.count ?? 0
			case 1: return joinedGroups?.count ?? 0
			case 2: return followedGroups?.count ?? 0
			
			default: return 0
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCellWithIdentifier(MyGroupsGroupTableCell.reuseId, forIndexPath: indexPath) as! MyGroupsGroupTableCell
		let group: CampusGroup?
		switch indexPath.section
		{
			case 0: group = administeredGroups?[indexPath.row]
			case 1: group = joinedGroups?[indexPath.row]
			case 2: group = followedGroups?[indexPath.row]
			
			default: group = CampusGroup()
		}
		
		if let group = group
		{
			cell.group = group
			cell.groupName.text = group.name
			group.getGroupPictureFromS3(handler: { (image) -> () in
				if let image = image
				{
					if let visibleRows = tableView.indexPathsForVisibleRows
						where visibleRows.contains(indexPath)
					{
						cell.groupImage.image = image
					}
				} else
				{
					cell.groupImage.image = UIImage(named: Constants.Values.NoPhotoImageName)
				}
			})
		}
		
		return cell
	}
}