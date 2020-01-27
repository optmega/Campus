//
//  MyGroupsViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/5/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

import RKNotificationHub

class MyGroupsViewController: UIViewController, UITableViewDataSource
{
	static let storyboardId = "MyGroupsViewController"
	
	private static let manageMembersSegueId = "myGroupsToManageMembers"
	private static let viewGroupSegueId = "myGroupsToGroup"
	private static let editGroupSegueId = "myGroupsToEditGroup"
	
	enum SelectedGroups
	{
		case Administered
		case Joined
		case Followed
	}
	
	// MARK: - Properties
	
	private var selectedGroups = SelectedGroups.Administered
	
	private var administeredGroups: [CampusGroup]?
	private var joinedGroups: [CampusGroup]?
	private var followedGroups: [CampusGroup]?
	
	private var firstDisplay = true //Used to reload only when re-displaying screen
	
	private var newPostsObserver: NSObjectProtocol? //Notification observation with block can be removed only with the object returned from addObserver...
	private var notificationHubs = [UIView : RKNotificationHub]() // Notification hubs keyed to attached views
	private var groupIdsWithNewPosts = [Int : Int]() //Ids of groups with pending new posts and post count
	
	
	// MARK: - Outlets
	
	@IBOutlet var tableView: UITableView!
	
	@IBOutlet var adminButton: UIButton!
	@IBOutlet var memberButton: UIButton!
	@IBOutlet var followingButton: UIButton!
	
	@IBOutlet var adminIndicator: UIView!
	@IBOutlet var memberIndicator: UIView!
	@IBOutlet var followingIndicator: UIView!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	
	// MARK: - Actions
	@IBAction func adminPressed(sender: UIButton)
	{
		adminButton.setTitleColor(Constants.Colors.Purple, forState: .Normal)
		memberButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		followingButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		
		adminIndicator.hidden = false
		memberIndicator.hidden = true
		followingIndicator.hidden = true
		
		selectedGroups = .Administered
		
		if administeredGroups != nil
		{
			tableView.reloadData()
		} else
		{
			activityIndicator.startAnimating()
			CampusUserRequests.getAdministeredGroups(
				forUser: CampusUser.currentUser,
				success: { (groups) -> () in
					self.activityIndicator.stopAnimating()
					
					for (index, group) in groups.enumerate()
					{
						CampusGroupPostRequest.getGroupPostsUnreadCount(group,
							successHandler: { (count) -> () in
								self.groupIdsWithNewPosts[group.id] = count
								if self.selectedGroups == .Administered
								{
									self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
								}
							},
							failureHandler: nil)
					}
					
					self.administeredGroups = groups
					self.tableView.reloadData()
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		}
	}
	
	@IBAction func memberPressed(sender: UIButton)
	{
		adminButton.setTitleColor(Constants.Colors.Purple, forState: .Normal)
		memberButton.setTitleColor(Constants.Colors.Purple, forState: .Normal)
		followingButton.setTitleColor(Constants.Colors.Purple, forState: .Normal)
		
		adminIndicator.hidden = true
		memberIndicator.hidden = false
		followingIndicator.hidden = true
		
		selectedGroups = .Joined
		
		if joinedGroups != nil
		{
			tableView.reloadData()
		} else
		{
			activityIndicator.startAnimating()
			CampusUserRequests.getJoinedGroups(
				forUser: CampusUser.currentUser,
				success: { (groups) -> () in
					self.activityIndicator.stopAnimating()
					self.joinedGroups = groups
					
					for (index, group) in groups.enumerate()
					{
						CampusGroupPostRequest.getGroupPostsUnreadCount(group,
							successHandler: { (count) -> () in
								self.groupIdsWithNewPosts[group.id] = count
								if self.selectedGroups == .Joined
								{
									self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
								}
							},
							failureHandler: nil)
					}
					
					self.tableView.reloadData()
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		}
	}
	
	@IBAction func followingPressed(sender: UIButton)
	{
		adminButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		memberButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		followingButton.setTitleColor(Constants.Colors.Purple, forState: .Normal)
		
		adminIndicator.hidden = true
		memberIndicator.hidden = true
		followingIndicator.hidden = false
		
		
		selectedGroups = .Followed
		
		if followedGroups != nil
		{
			tableView.reloadData()
		} else
		{
			activityIndicator.startAnimating()
			CampusUserRequests.getFollowedGroups(
				forUser: CampusUser.currentUser,
				success: { (groups) -> () in
					self.activityIndicator.stopAnimating()
					self.followedGroups = groups
					
					for (index, group) in groups.enumerate()
					{
						CampusGroupPostRequest.getGroupPostsUnreadCount(group,
							successHandler: { (count) -> () in
								self.groupIdsWithNewPosts[group.id] = count
								if self.selectedGroups == .Followed
								{
									self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
								}
							},
							failureHandler: nil)
					}
					
					self.tableView.reloadData()
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		}
	}
	
	func manageMembers(sender: UIButton)
	{
		if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as? MyGroupsGroupTableCell
		{
			self.performSegueWithIdentifier(MyGroupsViewController.manageMembersSegueId, sender: cell)
		}
	}
	
	func editGroup(sender: UIButton)
	{
		if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as? MyGroupsGroupTableCell
		{
			self.performSegueWithIdentifier(MyGroupsViewController.editGroupSegueId, sender: cell)
		}
	}
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen

		tableView.rowHeight = Constants.Values.TableViewRowHeight
        adminPressed(UIButton())
		
		newPostsObserver = NSNotificationCenter.defaultCenter().addObserverForName(Constants.NotificationIds.NotificationNewGroupPost, object: nil, queue: nil) { (notification) -> Void in
			guard let post = notification.userInfo?["post"] as? CampusGroupPost
				else
			{
				log.error("No post in notification!")
				return
			}
			
			self.processNewPost(post)
		}
    }
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		tableView.rowHeight = Constants.Values.TableViewRowHeight
		
		if firstDisplay //Reload only when re-displaying
		{
			firstDisplay = false
			return
		}
		
		switch selectedGroups
		{
			case .Administered:
				adminPressed(UIButton())
			case .Joined:
				memberPressed(UIButton())
			case .Followed:
				followingPressed(UIButton())
		}
	}

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier,
			sender = sender as? MyGroupsGroupTableCell,
			destVC = segue.destinationViewController as? GroupMembersViewController
			where segueId == MyGroupsViewController.manageMembersSegueId
		{
			destVC.group = sender.group
			destVC.viewAsAdmin = selectedGroups == .Administered
		} else if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? GroupViewController,
			cell = sender as? MyGroupsGroupTableCell,
			cellIndexPath = tableView.indexPathForCell(cell)
			where segueId == MyGroupsViewController.viewGroupSegueId
		{
			let group: CampusGroup
			
			switch selectedGroups
			{
				case .Administered:
					group = administeredGroups![cellIndexPath.row]
				case .Joined:
					group = joinedGroups![cellIndexPath.row]
				case .Followed:
					group = followedGroups![cellIndexPath.row]
			}
			
			destVC.group = group
			
			groupIdsWithNewPosts[group.id] = nil
			if let hub = notificationHubs[cell.badgeView]
			{
				UIApplication.sharedApplication().applicationIconBadgeNumber -= Int(hub.count)
			}
			notificationHubs[cell.badgeView]?.count = 0
		}else if let segueId = segue.identifier,
			sender = sender as? MyGroupsGroupTableCell,
			destVC = segue.destinationViewController as? CreateEditGroupViewController
			where segueId == MyGroupsViewController.editGroupSegueId

		{
			destVC.group = sender.group
		} else
		{
			log.error("Failed to handle segue \(segue.identifier)")
		}
	}
	
	
	// MARK: - UITableViewDataSource
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		switch selectedGroups
		{
			case .Administered:
				return administeredGroups?.count ?? 0
			case .Joined:
				return joinedGroups?.count ?? 0
			case .Followed:
				return followedGroups?.count ?? 0
		}
	}
	
	
	// TODO: Code copied to FindGroupViewController - Refactor in a common place
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let group: CampusGroup
		switch selectedGroups
		{
			case .Administered:
				group = administeredGroups![indexPath.row]
			case .Joined:
				group = joinedGroups![indexPath.row]
			case .Followed:
				group = followedGroups![indexPath.row]
		}
		
		let cell = tableView.dequeueReusableCellWithIdentifier(MyGroupsGroupTableCell.reuseId, forIndexPath: indexPath) as! MyGroupsGroupTableCell
		cell.group = group
		
		let formatter = NSDateFormatter()
		formatter.dateStyle = .ShortStyle
		formatter.timeStyle = .NoStyle
		
		group.getGroupPictureFromS3 { (image) -> () in
			if let image = image,
				visibleRows = tableView.indexPathsForVisibleRows where visibleRows.contains(indexPath)
			{
				cell.groupImage.image = image
			} else
			{
				cell.groupImage.image = UIImage(named: Constants.Values.NoPhotoImageName)
			}
		}
		
		if let lastPostdate = group.lastPostDate
		{
			cell.lastUpdated.text = "Last Update: \(formatter.stringFromDate(lastPostdate))"
		} else
		{
			cell.lastUpdated.text = nil
		}
		
		cell.groupName.text = group.name
		
		cell.manageMembersButton.tag = indexPath.row
		cell.editGroupButton.tag = indexPath.row
		
		if cell.manageMembersButton.allTargets().isEmpty
		{
			cell.manageMembersButton.addTarget(self, action: #selector(MyGroupsViewController.manageMembers(_:)), forControlEvents: .TouchUpInside)
		}
		
		if cell.editGroupButton.allTargets().isEmpty
		{
			cell.editGroupButton.addTarget(self, action: #selector(MyGroupsViewController.editGroup(_:)), forControlEvents: .TouchUpInside)
		}
		
		if selectedGroups == .Administered
		{
			cell.editGroupButton.hidden = false
		} else
		{
			cell.editGroupButton.hidden = true
		}
		
		if let unreadPosts = groupIdsWithNewPosts[cell.group.id] // Put a badge if unread messages
		{
			if notificationHubs[cell.badgeView] == nil
			{
				notificationHubs[cell.badgeView] = RKNotificationHub(view: cell.badgeView)
				notificationHubs[cell.badgeView]?.scaleCircleSizeBy(0.66)
			}
			
			notificationHubs[cell.badgeView]?.count = UInt(unreadPosts)
		} else
		{
			notificationHubs[cell.badgeView]?.count = 0
		}
		
		return cell
	}
	
	
	// MARK: - Private
	
	private func processNewPost(post: CampusGroupPost)
	{
		CampusGroupPostRequest.getGroupPostsUnreadCount(post.group,
			successHandler: { (count) -> () in
				self.groupIdsWithNewPosts[post.group.id] = count
				self.tableView.reloadData()
			},
			failureHandler: { (error) -> () in
				log.error("Could not get unread count for group.id \(post.group.id) posts")
		})
	}
}
