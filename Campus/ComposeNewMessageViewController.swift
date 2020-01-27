//
//  ComposeNewMessageViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 3/15/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class ComposeNewMessageViewController: UIViewController
{
	static private let toMessagesSegueId = "recipientsToMessages"
	static private let toConversationSegueId = "recipientsToConversation"
	// MARK: - Properties
	
	var addingToNewConversation = true //Adding to a new conversation or to an existing
	
	var existingParticipants: [CampusUser]? // When adding to conversation
	
	private var friends = [CampusUser]()
	private var filteredFriends = [CampusUser]()
	private var otherUsers = [CampusUser]()
	
	private var recipients = [CampusUser]()
	{
		didSet
		{
			doneButton.enabled = recipients.count > 0
		}
	}
	
	private var userSearchController: UISearchController = ({
		let controller = UISearchController(searchResultsController: nil)
		controller.hidesNavigationBarDuringPresentation = false
		controller.dimsBackgroundDuringPresentation = false
		controller.searchBar.searchBarStyle = .Minimal
		controller.searchBar.sizeToFit()
		return controller
	})()
	
	// MARK: - Outlets
	
	@IBOutlet var doneButton: UIBarButtonItem!
	@IBOutlet var searchBar: UISearchBar!
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var tableView: UITableView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	// MARK: - Actions
	
	@IBAction func cancelPressed(sender: UIBarButtonItem)
	{
		self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func donePressed(sender: UIBarButtonItem)
	{
		if addingToNewConversation
		{
			self.performSegueWithIdentifier(ComposeNewMessageViewController.toMessagesSegueId, sender: self)
		} else
		{
			self.performSegueWithIdentifier(ComposeNewMessageViewController.toConversationSegueId, sender: self)
		}
	}
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		doneButton.enabled = recipients.count > 0
		
		searchBar.delegate = self
		tableView.rowHeight = Constants.Values.TableViewRowHeight
		let flow = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
		flow.estimatedItemSize = CGSizeMake(100, 30)
		
		activityIndicator.startAnimating()
		CampusUserRequests.getFollowedUsers({ (users) -> () in
			
			// Filter out already added users
			self.friends = users.filter { (user) -> Bool in
					if let existingParticipants = self.existingParticipants?.map({ $0.id })
					{
						return !existingParticipants.contains(user.id)
					}
					
					return true
				}
			
				self.filteredFriends = self.friends
				self.tableView.reloadData()
				self.activityIndicator.stopAnimating()
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
		
    }

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? MessagesViewController
			where segueId == ComposeNewMessageViewController.toMessagesSegueId
		{
			destVC.newMessageRecipients = recipients
		} else if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? ConversationViewController
			where segueId == ComposeNewMessageViewController.toConversationSegueId
		{
			destVC.newMessageRecipients = recipients
		}
	}

}

extension ComposeNewMessageViewController: UITableViewDataSource, UITableViewDelegate
{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 2
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		switch section
		{
			case 0: return filteredFriends.count
			case 1: return otherUsers.count
			
			default: return 0
		}
	}
	
	func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
	{
		switch section
		{
			case 0: return (filteredFriends.count > 0) ? "Friends" : nil
			case 1: return (otherUsers.count > 0) ? "More Users" : nil
			
			default: return nil
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCellWithIdentifier(GroupMembersTableCell.reuseId, forIndexPath: indexPath) as! GroupMembersTableCell
		if indexPath.section == 0
		{
			let user = filteredFriends[indexPath.row]
			cell.memberName.text = user.firstName + " " + user.lastName
		} else if indexPath.section == 1
		{
			let user = otherUsers[indexPath.row]
			cell.memberName.text = user.firstName + " " + user.lastName
		}
		
		return cell
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		switch indexPath.section
		{
			case 0:
				if !recipients.contains(filteredFriends[indexPath.row])
				{
					recipients.append(filteredFriends[indexPath.row])
				}
			
			case 1:
				if !recipients.contains(otherUsers[indexPath.row])
				{
					recipients.append(otherUsers[indexPath.row])
				}
			default: ()
		}
		
		collectionView.reloadData()
		
	}
}

extension ComposeNewMessageViewController: UICollectionViewDataSource, UICollectionViewDelegate
{
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
	{
		return recipients.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
	{
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(LabelCell.reuseId, forIndexPath: indexPath) as! LabelCell
		let user = recipients[indexPath.row]
		
		cell.label.text = user.firstName + " " + user.lastName
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		recipients.removeAtIndex(indexPath.row)
		collectionView.reloadData()
	}
}

extension ComposeNewMessageViewController: UISearchBarDelegate
{
	func searchBarSearchButtonClicked(searchBar: UISearchBar)
	{
		guard let text = searchBar.text where text != ""
			else
		{
			return
		}
		
		searchBar.resignFirstResponder()
		activityIndicator.startAnimating()
		
		filteredFriends = friends.filter({ (user) -> Bool in
			let name = user.firstName + " " + user.lastName
			return name.lowercaseString.containsString(text.lowercaseString)
		})
		
		CampusUserRequests.searchUsersByName(text,
			success: { (users) -> () in
				self.otherUsers = users.filter { (user) -> Bool in
					if let existingParticipants = self.existingParticipants?.map({ $0.id })
					{
						return !existingParticipants.contains(user.id)
					}
					
					return true
				}
				self.tableView.reloadData()
				
				self.activityIndicator.stopAnimating()
			},
			failureHandler: { (error) -> () in
				self.tableView.reloadData()
				self.activityIndicator.stopAnimating()
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
	}
	
	// Hide the keyboard when search cleared (including from the X)
	func searchBar(searchBar: UISearchBar, textDidChange searchText: String)
	{
		if searchText == ""
		{
			filteredFriends = friends
			searchBar.performSelector(#selector(UIResponder.resignFirstResponder), withObject: nil, afterDelay: 0.1) //Needs a delay, because the searchbar is not yet the first responder
			tableView.reloadData()
		} else
		{
			guard let text = searchBar.text where text != ""
				else
			{
				return
			}
			
			
			filteredFriends = friends.filter({ (user) -> Bool in
				let name = user.firstName + " " + user.lastName
				return name.lowercaseString.containsString(text.lowercaseString)
			})
			
			CampusUserRequests.searchUsersByName(text,
				success: { (users) -> () in
					self.otherUsers = users.filter { (user) -> Bool in
						if let existingParticipants = self.existingParticipants?.map({ $0.id })
						{
							return !existingParticipants.contains(user.id)
						}
						
						return true
					}
					self.tableView.reloadData()
					
				},
				failureHandler: { (error) -> () in
					self.tableView.reloadData()
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})

		}
	}

}