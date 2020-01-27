//
//  AddGroupMemmbersViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/6/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

// Naive implementation - fetches all users. If 5000 users? Fetch some and load more when scrolling
// Search also naive - search on server and load result
class AddGroupMembersViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate
{
	static let storyboardId = "AddGroupMembersViewController"
	
	// MARK: - Properties
	var group: CampusGroup!
	
	private var users = [CampusUser]()
	private var filteredUsers = [CampusUser]()
	private var members = [CampusUser]()
	
	// MARK: - Outlets
	
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var tableView: UITableView!

	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	// MARK: - Actions
	
	func addMemberPressed(sender: UIButton)
	{
		if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as? AddGroupMemberTableCell,
			user = cell.user
		{
			activityIndicator.startAnimating()
			CampusGroupRequest.addUser(user, isAdmin: false, toGroup: group,
				successHandler: { () -> () in
					self.activityIndicator.stopAnimating()
					
					UIView.animateWithDuration(Constants.Values.AnimationDurationShort) { () -> Void in
						cell.addMemberButton.enabled = false
						cell.addMemberButton.backgroundColor = UIColor.lightGrayColor()
					}
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		}
	}
	
	func addAdminPressed(sender: UIButton)
	{
		if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 0)) as? AddGroupMemberTableCell,
			user = cell.user
		{
			activityIndicator.startAnimating()
			CampusGroupRequest.addUser(user, isAdmin: true, toGroup: group,
				successHandler: { () -> () in
					self.activityIndicator.stopAnimating()
					
					self.users.removeAtIndex(sender.tag)
					
					self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		}
	}
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		searchBar.delegate = self
		tableView.dataSource = self
		tableView.delegate = self
		
		tableView.rowHeight = Constants.Values.TableViewRowHeight
		
		activityIndicator.startAnimating()
		
		let getUsersDispatchGroup = dispatch_group_create() // Use a dispatch group to schedule a call to reload data once all handlers have returned, as they are async
		
		dispatch_group_enter(getUsersDispatchGroup)
		dispatch_group_enter(getUsersDispatchGroup)
		
		CampusGroupRequest.getMembers(
			forGroup: group,
			successHandler: { (users) -> () in
				self.users += users
				self.filteredUsers += users
				self.members = users
				dispatch_group_leave(getUsersDispatchGroup)
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(getUsersDispatchGroup)
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
		
		CampusGroupRequest.getNonMembers(
			forGroup: group,
			successHandler: { (users) -> () in
				self.users += users
				self.filteredUsers += users
				
				dispatch_group_leave(getUsersDispatchGroup)
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(getUsersDispatchGroup)
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
		
		dispatch_group_notify(getUsersDispatchGroup, dispatch_get_main_queue()) {
			self.activityIndicator.stopAnimating()
			
			self.users.sortInPlace { "\($0.firstName) \($0.lastName)" < "\($1.firstName) \($1.lastName)" }
			self.tableView.reloadData()
		}
    }
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return filteredUsers.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCellWithIdentifier(AddGroupMemberTableCell.reuseId, forIndexPath: indexPath) as! AddGroupMemberTableCell
		let user = filteredUsers[indexPath.row]
		
		user.getProfilePictureFromS3 { (image) -> () in
			if let image = image,
				visibleRows = tableView.indexPathsForVisibleRows where visibleRows.contains(indexPath)
			{
				cell.memberImage.image = image
			} else
			{
				cell.memberImage.image = UIImage(named: Constants.Values.NoPhotoImageName)
			}
		}
		
		if members.contains(user)
		{
			cell.addMemberButton.enabled = false
			cell.addMemberButton.backgroundColor = UIColor.lightGrayColor()
		} else
		{
			cell.addMemberButton.enabled = true
			cell.addMemberButton.backgroundColor = Constants.Colors.Purple
		}
		
		cell.user = user
		cell.memberName.text = "\(user.firstName) \(user.lastName)"
		
		cell.addMemberButton.tag = indexPath.row
		cell.addAdminButton.tag = indexPath.row
		
		if cell.addMemberButton.allTargets().isEmpty
		{
			cell.addMemberButton.addTarget(self, action: #selector(AddGroupMembersViewController.addMemberPressed(_:)), forControlEvents: .TouchUpInside)
		}
		
		if cell.addAdminButton.allTargets().isEmpty
		{
			cell.addAdminButton.addTarget(self, action: #selector(AddGroupMembersViewController.addAdminPressed(_:)), forControlEvents: .TouchUpInside)
		}
		
		return cell
	}
	
	// MARK: - UISearchBarDelegate
	
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
	{
		
		self.filteredUsers = users.filter { searchText == "" || ($0.firstName.lowercaseString.rangeOfString(searchText.lowercaseString) != nil) || ($0.lastName.lowercaseString.rangeOfString(searchText.lowercaseString) != nil) }
		tableView.reloadData()
	}
}
