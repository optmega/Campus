//
//  GroupMembersViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/5/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class GroupMembersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
	static let storyboardId = "GroupMembersViewController"
	
	static let addMembersSegueId = "manageMembersToAddMembers"
	static let requestToPublicProfileSegueId = "manageRequestToPublicProfile"
	static let memberToPublicProfileSegueId = "manageMemberToPublicProfile"
	
	enum TableMode
	{
		case Requests
		case Admins
		case Members
	}
	
	// MARK: - Properties
	
	var group: CampusGroup!
	var viewAsAdmin: Bool = false
	
	private var tableMode = TableMode.Requests
	private var requests:	[CampusUser]?
	private var admins:		[CampusUser]?
	private var members:	[CampusUser]?
	
	// MARK: - Outlets
	
	@IBOutlet var tableView: UITableView!
	
	@IBOutlet var requestsButton: UIButton!
	@IBOutlet var adminsButton: UIButton!
	@IBOutlet var membersButton: UIButton!
	
	@IBOutlet var requestsIndicator: UIView!
	@IBOutlet var adminsIndicator: UIView!
	@IBOutlet var membersIndicator: UIView!
	
	@IBOutlet var addMembersButton: UIBarButtonItem!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	
	// MARK: - Actions
	
	@IBAction func requestsPressed(sender: UIButton)
	{
		requestsButton.setTitleColor(Constants.Colors.Purple, forState: .Normal)
		adminsButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		membersButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		
		requestsIndicator.hidden = false
		adminsIndicator.hidden = true
		membersIndicator.hidden = true
		
		tableMode = .Requests
		
		if requests == nil
		{
			activityIndicator.startAnimating()
			CampusGroupJoinRequestRequest.getJoinRequests(group,
				successHandler: { (users) -> () in
					self.activityIndicator.stopAnimating()
					
					self.requests = users
					self.tableView.reloadData()
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		} else
		{
			self.tableView.reloadData()
		}
	}
	
	@IBAction func adminsPressed(sender: UIButton)
	{
		requestsButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		adminsButton.setTitleColor(Constants.Colors.Purple, forState: .Normal)
		membersButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		
		requestsIndicator.hidden = true
		adminsIndicator.hidden = false
		membersIndicator.hidden = true
		
		tableMode = .Admins
		
		if admins == nil
		{
			activityIndicator.startAnimating()
			CampusGroupRequest.getAdmins(forGroup: group,
				successHandler: { (users) -> () in
					self.activityIndicator.stopAnimating()
					
					self.admins = users
					self.tableView.reloadData()
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		} else
		{
			self.tableView.reloadData()
		}
	}
	
	@IBAction func membersPressed(sender: UIButton)
	{
		requestsButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		adminsButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		membersButton.setTitleColor(Constants.Colors.Purple, forState: .Normal)
		
		requestsIndicator.hidden = true
		adminsIndicator.hidden = true
		membersIndicator.hidden = false
		
		tableMode = .Members
		
		if members == nil
		{
			activityIndicator.startAnimating()
			CampusGroupRequest.getMembers(forGroup: group,
				successHandler: { (users) -> () in
					self.activityIndicator.stopAnimating()
					
					self.members = users
					self.tableView.reloadData()
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		} else
		{
			self.tableView.reloadData()
		}
	}
	
	// MARK: - MemberRequestTableCell Actions
	
	func acceptMemberPressed(sender: UIButton)
	{
		activityIndicator.startAnimating()
		
		let user = requests![sender.tag]
		CampusGroupJoinRequestRequest.approveRequestForUser(user, group: group,
			successHandler: { () -> () in
				self.activityIndicator.stopAnimating()
				
				self.requests!.removeAtIndex(sender.tag)
				self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
	}
	
	func declineMemberPressed(sender: UIButton)
	{
		activityIndicator.startAnimating()
		
		let user = requests![sender.tag]
		CampusGroupJoinRequestRequest.declineRequestForUser(user, group: group,
			successHandler: { () -> () in
				self.activityIndicator.stopAnimating()
				
				self.requests!.removeAtIndex(sender.tag)
				self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
	}
	
	// MARK: - GroupMembersTableCell Actions
	
	func leaveGroup(sender: UIButton)
	{
		if let admins = self.admins
			where admins.count > 0
				&& admins.filter( { $0.id != CampusUser.currentUser.id } ).count == 0
		{
			let alertController = UIAlertController(title: "You are the last admin of the group", message: "Add another admin before leaving.", preferredStyle: .Alert)
			let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
			alertController.addAction(okAction)
			
			self.presentViewController(alertController, animated: true, completion: nil)
			
			return
		}
		
		activityIndicator.startAnimating()
		CampusGroupRequest.removeUser(CampusUser.currentUser,
			fromGroup: group,
			successHandler: { () -> () in
				self.activityIndicator.stopAnimating()
				
				if self.tableMode == .Admins // User was an admin and left
				{
					self.navigationController?.popViewControllerAnimated(true)
				} else
				{
					self.members = self.members?.filter { $0.id != CampusUser.currentUser.id }
					self.admins = self.admins?.filter { $0.id != CampusUser.currentUser.id }
					self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
				}
				
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
	}
	
	func promoteMember(sender: UIButton)
	{
		guard let user = members?[sender.tag]
			else
		{
			log.error("Promote member, but no member in members array?")
			return
		}
		
		activityIndicator.startAnimating()
		
		CampusGroupRequest.addUser(user, isAdmin: true, toGroup: group,
			successHandler: { () -> () in
				self.activityIndicator.stopAnimating()
				
				self.members = self.members?.filter { $0.id != user.id }
				
				if self.admins == nil
				{
					self.admins = [CampusUser]()
				}
				
				self.admins!.append(user)
				
				self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
	}
	
	func removeMember(sender: UIButton)
	{
		let user: CampusUser
		switch tableMode
		{
			case .Admins:
				guard let admin = admins?[sender.tag]
					else
				{
					log.error("Promote member, but no member in members array?")
					return
				}
			
				user = admin
			
			case .Members:
				guard let member = members?[sender.tag]
					else
				{
					log.error("Promote member, but no member in members array?")
					return
				}
				
				user = member
			
			default: return
		}
		
		activityIndicator.startAnimating()
		CampusGroupRequest.removeUser(user,
			fromGroup: group,
			successHandler: { () -> () in
				self.activityIndicator.stopAnimating()
				
				self.members = self.members?.filter { $0.id != user.id }
				self.admins = self.admins?.filter { $0.id != user.id }
				self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})

	}
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		tableView.rowHeight = Constants.Values.TableViewRowHeight

		if viewAsAdmin == true
		{
			tableMode = .Requests
			requestsPressed(requestsButton)
		} else
		{
			navigationItem.rightBarButtonItem = nil
			requestsButton.hidden = true
			tableMode = .Admins
			adminsPressed(adminsButton)
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
			destVC = segue.destinationViewController as? AddGroupMembersViewController
			where segueId == GroupMembersViewController.addMembersSegueId
		{
			destVC.group = group
		} else if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? PublicProfileViewController,
			sender = sender as? GroupMembersTableCell
			where segueId == GroupMembersViewController.memberToPublicProfileSegueId
		{
			destVC.user = sender.member
		} else if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? PublicProfileViewController,
			sender = sender as? MemberRequestTableCell
			where segueId == GroupMembersViewController.requestToPublicProfileSegueId
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
		switch tableMode
		{
			case .Requests:	return requests?.count ?? 0
			case .Admins:	return admins?.count ?? 0
			case .Members:	return members?.count ?? 0
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		switch tableMode
		{
			case .Requests:
				let cell = tableView.dequeueReusableCellWithIdentifier(MemberRequestTableCell.reuseId, forIndexPath: indexPath) as! MemberRequestTableCell
				let user = requests![indexPath.row]
				
				cell.memberName.text = user.firstName + " " + user.lastName
				
				cell.member = user
				
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
				
				cell.acceptButton.tag = indexPath.row
				cell.declineButton.tag = indexPath.row
				
				if cell.acceptButton.allTargets().isEmpty
				{
					cell.acceptButton.addTarget(self, action: #selector(GroupMembersViewController.acceptMemberPressed(_:)), forControlEvents: .TouchUpInside)
				}
				
				if cell.declineButton.allTargets().isEmpty
				{
					cell.declineButton.addTarget(self, action: #selector(GroupMembersViewController.declineMemberPressed(_:)), forControlEvents: .TouchUpInside)
				}
				
				cell.acceptButton.hidden = !viewAsAdmin
				cell.declineButton.hidden = !viewAsAdmin
				
				return cell
			
			case .Admins:
				let cell = tableView.dequeueReusableCellWithIdentifier(GroupMembersTableCell.reuseId, forIndexPath: indexPath) as! GroupMembersTableCell
				let user = admins![indexPath.row]
			
				cell.memberName.text = user.firstName + " " + user.lastName
				
				cell.member = user
				
				user.getProfilePictureFromS3(handler: { (image) -> () in
					if let image = image,
						visibleRows = tableView.indexPathsForVisibleRows where visibleRows.contains(indexPath)
					{
						cell.profilePicture.image = image
					} else
					{
						cell.profilePicture.image = UIImage(named: Constants.Values.NoPhotoImageName)
					}
				})
			
				if user.id == CampusUser.currentUser.id
				{
					cell.leaveGroupButton.hidden = false
					cell.promoteButton.hidden = true
					cell.removeButton.hidden = true
					
					cell.leaveGroupButton.tag = indexPath.row
					
					if cell.leaveGroupButton.allTargets().isEmpty
					{
						cell.leaveGroupButton.addTarget(self, action: #selector(GroupMembersViewController.leaveGroup(_:)), forControlEvents: .TouchUpInside)
					}
				} else
				{
					cell.leaveGroupButton.hidden = true
					cell.promoteButton.hidden = true
					cell.removeButton.hidden = !viewAsAdmin
					
					cell.removeButton.tag = indexPath.row
					
					if cell.removeButton.allTargets().isEmpty
					{
						cell.removeButton.addTarget(self, action: #selector(GroupMembersViewController.removeMember(_:)), forControlEvents: .TouchUpInside)
					}
				}
			
				return cell
			
			
			case .Members:
				let cell = tableView.dequeueReusableCellWithIdentifier(GroupMembersTableCell.reuseId, forIndexPath: indexPath) as! GroupMembersTableCell
				let user = members![indexPath.row]
				
				cell.memberName.text = user.firstName + " " + user.lastName
				
				cell.member = user
				
				user.getProfilePictureFromS3(handler: { (image) -> () in
					if let image = image,
						visibleRows = tableView.indexPathsForVisibleRows where visibleRows.contains(indexPath)
					{
						cell.profilePicture.image = image
					} else
					{
						cell.profilePicture.image = UIImage(named: Constants.Values.NoPhotoImageName)
					}
				})
				
				if user.id == CampusUser.currentUser.id
				{
					cell.leaveGroupButton.hidden = false
					cell.promoteButton.hidden = true
					cell.removeButton.hidden = true
					
					cell.leaveGroupButton.tag = indexPath.row
					
					if cell.leaveGroupButton.allTargets().isEmpty
					{
						cell.leaveGroupButton.addTarget(self, action: #selector(GroupMembersViewController.leaveGroup(_:)), forControlEvents: .TouchUpInside)
					}
				} else
				{
					cell.leaveGroupButton.hidden = true
					cell.promoteButton.hidden = !viewAsAdmin
					cell.removeButton.hidden = !viewAsAdmin
					
					cell.promoteButton.tag = indexPath.row
					cell.removeButton.tag = indexPath.row
					
					if cell.promoteButton.allTargets().isEmpty
					{
						cell.promoteButton.addTarget(self, action: #selector(GroupMembersViewController.promoteMember(_:)), forControlEvents: .TouchUpInside)
					}
					
					if cell.removeButton.allTargets().isEmpty
					{
						cell.removeButton.addTarget(self, action: #selector(GroupMembersViewController.removeMember(_:)), forControlEvents: .TouchUpInside)
					}
				}
			
				return cell
		}
	}
	
	
	// MARK: - UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		
	}
}
