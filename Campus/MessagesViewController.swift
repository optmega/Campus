//
//  MessagesViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/6/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

import ViewDeck
import RKNotificationHub

// TODO: Chat abstraction model

class MessagesViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource
{
	private let messagesToConversationSegueId = "messagesToConversation"
	private let messagesNewConversationSegueId = "messagesNewConversationToConversation"
	
	// MARK: - Properties
	var newMessageRecipients: [CampusUser]?
	var conversations: [CampusConversation]?
	
	private var newMessagesObserver: NSObjectProtocol? //Notification observation with block can be removed only with the object returned from addObserver...
	private var notificationHubs = [UIView : RKNotificationHub]() // Notification hubs keyed to attached views
	private var conversationIdsWithNewMessages = [Int : Int]() //Ids of conversations with pending new messages and new message count
	
	// MARK: - Outlets
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	// MARK: - Actions

	@IBAction func openMenuPressed(sender: UIBarButtonItem)
	{
		if let tabBarController = self.tabBarController
		{	
			tabBarController.viewDeckController.toggleLeftView()
			if tabBarController.viewDeckController.isSideOpen(IIViewDeckSide.LeftSide)
			{
				navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu-close-icon"), style: .Plain, target: self, action: #selector(MessagesViewController.openMenuPressed(_:)))
			} else
			{
				navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu-open-icon"), style: .Plain, target: self, action: #selector(MessagesViewController.openMenuPressed(_:)))
			}
		}
	}
	
	@IBAction func pickRecipientsForNewMessage(sender: UIStoryboardSegue)
	{
		if let recipients = newMessageRecipients
		{
			let participants = recipients + [CampusUser.currentUser]
			CampusConversationsRequest.getConversationWithParticipants(participants,
				successHandler: { (conversation) -> () in
					if let conversation = conversation
					{
						self.performSegueWithIdentifier(self.messagesNewConversationSegueId, sender: conversation)
					} else
					{
						let conversation = CampusConversation(id: -1, title: nil, participants: participants)
						self.performSegueWithIdentifier(self.messagesNewConversationSegueId, sender: conversation)
					}
				},
				failureHandler: { (error) -> () in
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
			
		}
	}
	
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		tableView.rowHeight = Constants.Values.TableViewRowHeight
		
		newMessagesObserver = NSNotificationCenter.defaultCenter().addObserverForName(Constants.NotificationIds.NotificationNewPrivateMessage, object: nil, queue: nil) { (notification) -> Void in
			guard let newMessage = notification.userInfo?["message"] as? CampusPrivateMessage
				else
			{
				log.error("No message in notification!")
				return
			}
			
			self.processNewMessage(newMessage)
		}
    }
	
	deinit
	{
		if let newMessagesObserver = newMessagesObserver
		{
			NSNotificationCenter.defaultCenter().removeObserver(newMessagesObserver)
		}
	}
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		if tabBarController!.viewDeckController.isSideOpen(IIViewDeckSide.LeftSide)
		{
			navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu-close-icon"), style: .Plain, target: self, action: #selector(MessagesViewController.openMenuPressed(_:)))
		} else
		{
			navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu-open-icon"), style: .Plain, target: self, action: #selector(MessagesViewController.openMenuPressed(_:)))
		}
		
		activityIndicator.startAnimating()
		conversationIdsWithNewMessages.removeAll()
		
		CampusConversationsRequest.getConversations(
			successHandler: { (conversations) -> () in
				let conversations = conversations.sort {
					guard let firstDate = $0.lastMessageDate
						else
					{
						return true
					}
					
					guard let secondDate = $1.lastMessageDate
						else
					{
						return false
					}
					
					return firstDate > secondDate
				}
				
				for (index, conversation) in conversations.enumerate()
				{
					CampusConversationsRequest.getUnreadCountInConversation(conversation,
						successHandler: { (count) -> () in
							self.conversationIdsWithNewMessages[conversation.id] = count
							self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .None)
						},
						failureHandler: { (error) -> () in
							
					})
				}
				
				self.conversations = conversations
				self.tableView.reloadData()
				
				self.activityIndicator.stopAnimating()
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
	}
	
	override func viewWillDisappear(animated: Bool)
	{
		super.viewWillDisappear(animated)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? ConversationViewController,
			sender = sender as? CampusConversation
			where segueId == messagesNewConversationSegueId
		{
			destVC.conversation = sender

		} else if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? ConversationViewController,
			sender = sender as? MessagesConversationTableCell
			where segueId == messagesToConversationSegueId
		{
			destVC.conversation = sender.conversation
			
			if let unreadCount = conversationIdsWithNewMessages[sender.conversation.id]
			{
				UIApplication.sharedApplication().applicationIconBadgeNumber -= unreadCount
				conversationIdsWithNewMessages[sender.conversation.id] = nil
				
				if let countString = self.tabBarController?.viewControllers?[0].tabBarItem.badgeValue, count = Int(countString)
				{
					if count - unreadCount > 0
					{
						self.self.tabBarController?.viewControllers?[0].tabBarItem.badgeValue = "\(count - unreadCount)"
					} else
					{
						self.self.tabBarController?.viewControllers?[0].tabBarItem.badgeValue = nil
					}
				}
			}
		}
	}
	
	// MARK: - UITableViewDataSource
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return conversations?.count ?? 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCellWithIdentifier(MessagesConversationTableCell.reuseId, forIndexPath: indexPath) as! MessagesConversationTableCell
		cell.deleteConversationButton.hidden = true
		cell.lastMessageText.text = nil
		cell.lastMessageDate.text = nil
		cell.title.text = nil
		cell.thumbnail.image = UIImage(named: Constants.Values.NoPhotoImageName)
		
		let conversation = conversations![indexPath.row]
		cell.conversation = conversation
		
		if let title = conversation.title
		{
			cell.title.text = title
		} else
		{
			var title = ""
			for user in conversation.participants
			{
				title += user.firstName + " " + user.lastName
				title += ", "
			}
			title = title.substringToIndex(title.endIndex.predecessor().predecessor()) // Trim last ", "
			cell.title.text = title
		}
		
		let participants = conversation.participants.filter({ $0.id != CampusUser.currentUser.id })
		if participants.count == 1
		{
			participants[0].getProfilePictureFromS3(handler: { (image) -> () in
				if let image = image
				{
					if let visibleRows = tableView.indexPathsForVisibleRows
						where visibleRows.contains(indexPath)
					{
						cell.thumbnail.image = image
					}
				} else
				{
					cell.thumbnail.image = UIImage(named: Constants.Values.NoPhotoImageName)
				}
			})
		}
		
		let formatter = NSDateFormatter()
		
		if let lastMessageDate = conversation.lastMessageDate
		{
			if lastMessageDate.isToday()
			{
				formatter.dateFormat = "hh:mm a"
			} else
			{
				formatter.dateStyle = .ShortStyle
				formatter.timeStyle = .NoStyle
			}
		
			cell.lastMessageDate.text = formatter.stringFromDate(lastMessageDate)
		}
		
		if let unreadMessages = conversationIdsWithNewMessages[conversation.id] // Put a badge if unread messages
		{
			if notificationHubs[cell.badgeView] == nil
			{
				notificationHubs[cell.badgeView] = RKNotificationHub(view: cell.badgeView)
				notificationHubs[cell.badgeView]?.scaleCircleSizeBy(0.66)
			}
			
			notificationHubs[cell.badgeView]?.count = UInt(unreadMessages)
		} else
		{
			notificationHubs[cell.badgeView]?.count = 0
		}
		
		return cell
	}
	
	
	// MARK: - Private
	
	// Put a badge and increase badge number for unread messages
	private func processNewMessage(newMessage: CampusPrivateMessage)
	{
		if let conversations = conversations
		{
			if conversationIdsWithNewMessages[newMessage.conversation.id] != nil
			{
				conversationIdsWithNewMessages[newMessage.conversation.id]? += 1
			} else
			{
				conversationIdsWithNewMessages[newMessage.conversation.id] = 1
			}
		
			if conversations.filter({ $0.id == newMessage.conversation.id }).count == 0
			{
				self.conversations!.append(newMessage.conversation)
				self.conversations = self.conversations!.sort {
					guard let firstDate = $0.lastMessageDate
						else
					{
						return true
					}
					
					guard let secondDate = $1.lastMessageDate
						else
					{
						return false
					}
					
					return firstDate > secondDate
				}
			}
			
			self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
		} else
		{
			conversations = [newMessage.conversation]
			tableView.reloadData()
			
			return
		}
	}
}
