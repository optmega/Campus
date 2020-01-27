//
//  FindGroupsAndPeopleViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/7/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class FindGroupsAndPeopleViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate
{
	private static let showGroupSegueId = "findToShowGroup"
	private static let manageMembersSegueId = "findGroupsToManageMembers"
	private static let userToPublicProfileSegueId = "findUserToPublicProfile"
	
	// MARK: - Properties
	var groups = [CampusGroup]()
	var users = [CampusUser]()
	
	
	// MARK: - Outlets
	
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var tableView: UITableView!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	
	// MARK: - Actions
	
	func viewMembers(sender: UIButton)
	{
		if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: sender.tag, inSection: 1)) as? MyGroupsGroupTableCell
		{
			self.performSegueWithIdentifier(FindGroupsAndPeopleViewController.manageMembersSegueId, sender: cell)
		}
	}
	
	// MARK: - Lifecycle

    override func viewDidLoad()
	{
        super.viewDidLoad()
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		tableView.rowHeight = Constants.Values.TableViewRowHeight
    }

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
    }
	
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? GroupViewController,
			cell = sender as? MyGroupsGroupTableCell,
			cellIndexPath = tableView.indexPathForCell(cell)
			where segueId == FindGroupsAndPeopleViewController.showGroupSegueId
		{
			destVC.group = groups[cellIndexPath.row]
		} else if let segueId = segue.identifier,
			sender = sender as? MyGroupsGroupTableCell,
			destVC = segue.destinationViewController as? GroupMembersViewController
			where segueId == FindGroupsAndPeopleViewController.manageMembersSegueId
		{
			destVC.group = sender.group
			destVC.viewAsAdmin = false
		} else if let segueId = segue.identifier,
			sender = sender as? GroupMembersTableCell,
			destVC = segue.destinationViewController as? PublicProfileViewController
			where segueId == FindGroupsAndPeopleViewController.userToPublicProfileSegueId
		{
			destVC.user = sender.member
		}

    }

	// MARK: - UITableViewDataSource
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 2
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		switch section
		{
			case 0: return users.count
			case 1: return groups.count
				
			default: return 0
		}
	}
	
	// TODO: Code copied from MyGroupsViewController - Refactor in a common place
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		switch indexPath.section
		{
			case 0:
				let cell = tableView.dequeueReusableCellWithIdentifier(GroupMembersTableCell.reuseId, forIndexPath: indexPath) as! GroupMembersTableCell
				let user = users[indexPath.row]
				cell.member = user
				cell.memberName.text = user.firstName + " " + user.lastName
			
				user.getProfilePictureFromS3(handler: { (image) -> () in
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
				})
			
				return cell
			
			case 1:
				let cell = tableView.dequeueReusableCellWithIdentifier(MyGroupsGroupTableCell.reuseId, forIndexPath: indexPath) as! MyGroupsGroupTableCell
				let group = groups[indexPath.row]
				cell.group = group
				
				cell.groupName.text = group.name
				
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
					let formatter = NSDateFormatter()
					formatter.dateStyle = .ShortStyle
					formatter.timeStyle = .NoStyle
					
					cell.lastUpdated.text = "Last Update: \(formatter.stringFromDate(lastPostdate))"
				} else
				{
					cell.lastUpdated.text = nil
				}
				
				cell.manageMembersButton.tag = indexPath.row
				
				if cell.manageMembersButton.allTargets().isEmpty
				{
					cell.manageMembersButton.addTarget(self, action: #selector(FindGroupsAndPeopleViewController.viewMembers(_:)), forControlEvents: .TouchUpInside)
				}
				
				return cell

				
			default: return UITableViewCell()
		}
	}
	
	
	// MARK: - UITableViewDelegate
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
	{
		switch section
		{
			case 0: return users.count > 0 ? "Users" : nil
			case 1: return groups.count > 0 ? "Groups" : nil
			
			default: return nil
		}
	}
	
	
	// MARK: - UISearchBarDelegate
	
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
	{
		if searchText == ""
		{
			self.groups.removeAll()
			self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(0...1)), withRowAnimation: .Fade)
			return
		}
		
		CampusGroupRequest.searchGroupsWithName(
			searchText,
			successHandler: { (groups, searchString) -> () in
				if searchText == searchString
				{
					self.groups = groups
					self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(0...1)), withRowAnimation: .Fade)
				}
			},
			failureHandler: { (error) -> () in
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
		
		CampusUserRequests.searchUsersByName(searchText,
			success: { (users) -> () in
				self.users = users
				self.tableView.reloadSections(NSIndexSet(indexesInRange: NSRange(0...1)), withRowAnimation: .Fade)
			},
			failureHandler: { (error) -> () in
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
	}
	
}
