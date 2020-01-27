//
//  GroupViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/5/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
	static private let editGroupSegueId = "groupToEditGroup"
	static private let newPostSegueId = "groupToNewPost"
	static private let userPublicProfileSegueId = "groupToUserPublicProfile"
	static private let groupToEventSegueId = "groupToEvent"
	static private let postToPostComments = "groupToPostComments"
	// MARK: - Properties
	
	var group: CampusGroup!
	
	private var groupPosts: [CampusGroupPost]?
	
	private var accessLevel: CampusGroup.UserAccessLevel?
	private var newPostNavbarButton: UIBarButtonItem?	//Used to show & hide the edit group item depending on the user's role
	private var firstDisplay = true							//Used to reload only when re-displaying screen
	
	private var newPostsObserver: NSObjectProtocol? //Notification observation with block can be removed only with the object returned from addObserver...
	private var lastPostId: Int?
	
	private var showCommentsForPostIds = [Int]()
	private var commentsForPostIds = [Int: [CampusComment]]()
	
	
	// MARK: - Outlets
	
	@IBOutlet var editGroupButton: UIBarButtonItem!
	
	@IBOutlet var groupImage: UIImageView!
	@IBOutlet var groupDescription: UILabel!
	
	@IBOutlet var groupTypeContainer: UIView!
	@IBOutlet var groupType: UILabel!
	
	@IBOutlet var recognizedGroupTypeContainer: UIView!
	@IBOutlet var recognizedGroupType: UILabel!
	
	@IBOutlet var presidentAndExecutivesHeading: UILabel!
	@IBOutlet var presidentLabel: UILabel!
	@IBOutlet var executiveLabel: UILabel!
	@IBOutlet var executive2Label: UILabel!
	@IBOutlet var executive3Label: UILabel!
	
	
	@IBOutlet var requestButton: UIButton!
	@IBOutlet var followButton: UIButton!
	
	@IBOutlet var tableView: UITableView!
	
	@IBOutlet var separatorHeights: [NSLayoutConstraint]!
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	// MARK: - Actions
	
	@IBAction func editGroupPressed(sender: UIBarButtonItem)
	{
	}
	
	@IBAction func requestPushed(sender: UIButton)
	{
		guard let accessLevel = accessLevel
			where accessLevel == .None || accessLevel == .Follower
			else
		{
			log.info("Access level not loaded yet or is already member/admin")
			return
		}
		
		activityIndicator.startAnimating()
		CampusGroupJoinRequestRequest.createJoinRequestForGroup(group,
			successHandler: { () -> () in
				self.activityIndicator.stopAnimating()
				
				self.requestButton.setTitle("Request sent", forState: .Normal)
				self.requestButton.enabled = false	
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})

	}
	
	@IBAction func followPushed(sender: UIButton)
	{
		guard let accessLevel = accessLevel
			else
		{
			log.info("Access level not loaded yet")
			return
		}
		
		guard accessLevel != .Admin && accessLevel != .Member
			else
		{
			log.info("Already admin or member")
			return
		}
		
		if accessLevel == .None
		{
			activityIndicator.startAnimating()
			CampusGroupRequest.follow(group,
				successHandler: { () -> () in
					self.activityIndicator.stopAnimating()
					
					self.followButton.setTitle("Followed", forState: .Normal)
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		} else if accessLevel == .Follower
		{
			activityIndicator.startAnimating()
			CampusGroupRequest.unfollow(group,
				successHandler: { () -> () in
					self.activityIndicator.stopAnimating()
					
					self.followButton.setTitle("Follow", forState: .Normal)
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		}
	}
	
	func deletePost(sender: UIButton)
	{
		let alertController = UIAlertController(title: "Delete post", message: "Are you sure that you want t odelete this post?", preferredStyle: .Alert)
		let okAction = UIAlertAction(title: "OK", style: .Destructive) { (ACTION) -> Void in
			self.activityIndicator.startAnimating()
			CampusGroupPostRequest.deletePost(self.groupPosts![sender.tag],
				successHandler: { () -> () in
					self.groupPosts!.removeAtIndex(sender.tag)
					self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
					
					self.activityIndicator.stopAnimating()
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
		alertController.addAction(okAction)
		alertController.addAction(cancelAction)
		
		self.presentViewController(alertController, animated: true, completion: nil)
	}
	
	func subscribe(sender: UIButton)
	{
		guard let post = groupPosts?[sender.tag]
			else
		{
			log.error("No posts in group??")
			return
		}
		
		guard let eventDate = post.eventDate
			else
		{
			log.error("Post is not an event")
			return
		}
		
		if let subscribedPosts = CampusUser.currentUser.subscribedPosts where subscribedPosts.map({ $0.id }).contains(post.id)
		{
			activityIndicator.startAnimating()
			CampusGroupPostRequest.unsubscribe(post,
				successHandler: { () -> () in
					CampusUser.currentUser.subscribedPosts! = CampusUser.currentUser.subscribedPosts!.filter { $0.id != post.id }
					sender.setImage(UIImage(named: "bookmark-icon"), forState: .Normal)
					
					self.activityIndicator.stopAnimating()
				},
				failureHandler: { (error) -> () in
					self.activityIndicator.stopAnimating()
					
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
			
		} else
		{
			activityIndicator.startAnimating()
			
			func subscribe(post: CampusGroupPost, notificationInterval: Int?)
			{
				CampusGroupPostRequest.subscribe(post,
					notificationInterval: notificationInterval,
					successHandler: { () -> () in
						CampusUser.currentUser.subscribedPosts!.append(post)
						sender.setImage(UIImage(named: "bookmark-purple-icon"), forState: .Normal)
						
						self.activityIndicator.stopAnimating()
					},
					failureHandler: { (error) -> () in
						self.activityIndicator.stopAnimating()
						
						self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
				})
			}
			
			if eventDate < NSDate()
			{
				let alertController = UIAlertController(title: "Event time is in the past", message: nil, preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
					subscribe(post, notificationInterval: nil)
				}
				alertController.addAction(okAction)
				
				self.presentViewController(alertController, animated: true, completion: nil)
			} else
			{
				let alertController = UIAlertController(title: "Do you want to receive a notification about this event?", message: nil, preferredStyle: .ActionSheet)
				let noAction = UIAlertAction(title: "No", style: .Default)  { (action) -> Void in
					subscribe(post, notificationInterval: nil)
				}
				
				
				let eventTime = UIAlertAction(title: "At event time", style: .Default) { (action) -> Void in
					subscribe(post, notificationInterval: 0)
				}
				
				let minutes15 = UIAlertAction(title: "15 minutes before", style: .Default) { (action) -> Void in
					subscribe(post, notificationInterval: 15)
				}
				
				let minutes30 = UIAlertAction(title: "30 minutes before", style: .Default) { (action) -> Void in
					subscribe(post, notificationInterval: 30)
				}
				
				let hours1 = UIAlertAction(title: "1 hour before", style: .Default) { (action) -> Void in
					subscribe(post, notificationInterval: 60)
				}
				
				let hours3 = UIAlertAction(title: "3 hours before", style: .Default) { (action) -> Void in
					subscribe(post, notificationInterval: 180)
				}
				
				let days1 = UIAlertAction(title: "1 day before", style: .Default) { (action) -> Void in
					subscribe(post, notificationInterval: 1440)
				}
				
				alertController.addAction(noAction)
				
				alertController.addAction(eventTime)
				alertController.addAction(minutes15)
				alertController.addAction(minutes30)
				alertController.addAction(hours1)
				alertController.addAction(hours3)
				alertController.addAction(days1)
				
				self.presentViewController(alertController, animated: true, completion: nil)
			}
		}

	}
	
	func likePost(sender: UIButton)
	{
		if let post = groupPosts?[sender.tag]
		{
			if post.likesUserIds.contains(CampusUser.currentUser.id)
			{
				CampusGroupPostRequest.unlikePost(post,
					successHandler: { (post) -> () in
						if let groupPosts = self.groupPosts
						{
							for (index, oldPost) in groupPosts.enumerate()
							{
								if oldPost.id == post.id
								{
									self.groupPosts![index] = post
									self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
									break
								}
							}
						}
					},
					failureHandler: { (error) -> () in
						self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
				})
			} else
			{
				CampusGroupPostRequest.likePost(post,
					successHandler: { (post) -> () in
						if let groupPosts = self.groupPosts
						{
							for (index, oldPost) in groupPosts.enumerate()
							{
								if oldPost.id == post.id
								{
									self.groupPosts![index] = post
									self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Fade)
									break
								}
							}

						}
					},
					failureHandler: { (error) -> () in
						self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
				})
			}
		}
	}
	
	func showComments(sender: UIButton)
	{
		let post = groupPosts![sender.tag]
		self .performSegueWithIdentifier(GroupViewController.postToPostComments, sender: post)
	}
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		guard group != nil
			else
		{
			fatalError("Trying to present nil group")
		}
		
		if let description = group.description
		{
			groupDescription.text = description
		} else
		{
			groupDescription.hidden = true
		}
		
		if let type = group.groupType?.rawValue
		{
			groupType.text = type
		} else
		{
			groupTypeContainer.hidden = true
		}
		
		if let recognizedType = group.recognizedGroupType?.rawValue
		{
			recognizedGroupType.text = recognizedType
		} else
		{
			recognizedGroupTypeContainer.hidden = true
		}
		
		if let president = group.president
		{
			presidentLabel.text = president
		} else
		{
			presidentLabel.hidden = true
		}
		
		if let executive = group.executive
		{
			executiveLabel.text = executive
		} else
		{
			executiveLabel.hidden = true
		}
		
		if let executive2 = group.executive2
		{
			executive2Label.text = executive2
		} else
		{
			executive2Label.hidden = true
		}
		
		if let executive3 = group.executive3
		{
			executive3Label.text = executive3
		} else
		{
			executive3Label.hidden = true
		}
		
		if group.president == nil && group.executive == nil && group.executive2 == nil && group.executive3 == nil
		{
			presidentAndExecutivesHeading.hidden = true
		}
		
		self.navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		self.navigationItem.title = group.name ?? "Group"
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = Constants.Values.TableViewRowHeight
		
		newPostNavbarButton = self.navigationItem.rightBarButtonItem
		self.navigationItem.rightBarButtonItem = nil
		
		for height in separatorHeights
		{
			height.constant = 0.5 //Minimum in IB is 1
		}
		
		activityIndicator.startAnimating()
		
		let activityGroup = dispatch_group_create() //Dispatch group to stop activity indicator after all requests have finished
		
		dispatch_group_enter(activityGroup)
		dispatch_group_enter(activityGroup)
		dispatch_group_enter(activityGroup)
		
		CampusGroupRequest.getAccessLevelForUser(CampusUser.currentUser,
			inGroup: group,
			successHandler: { (accessLevel) -> () in
				self.accessLevel = accessLevel
				switch accessLevel
				{
					case .Admin:
						self.requestButton.setTitle("You are an Admin", forState: .Normal)
						self.requestButton.enabled = false
						self.followButton.removeFromSuperview()
						if let editGroupNavbarButton = self.newPostNavbarButton
						{
							self.navigationItem.rightBarButtonItem = editGroupNavbarButton
						}
					
					case .Member:
						self.requestButton.setTitle("You are a Member", forState: .Normal)
						self.requestButton.enabled = false
						self.followButton.removeFromSuperview()
					
						if let editGroupNavbarButton = self.newPostNavbarButton
						{
							self.navigationItem.rightBarButtonItem = editGroupNavbarButton
						}
					
					case .Follower:
						self.followButton.setTitle("Followed", forState: .Normal)
					
					case .None: ()
				}
				
				dispatch_group_leave(activityGroup)
			}, failureHandler: { (error) -> () in
				dispatch_group_leave(activityGroup)
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
		
		CampusGroupJoinRequestRequest.getUserStatusForGroup(group,
			successHandler: { (status) -> () in
				switch status
				{
					case .Pending:
						self.requestButton.setTitle("Request Sent", forState: .Normal)
						self.requestButton.enabled = false
					
					default: ()
				}
				
				dispatch_group_leave(activityGroup)
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(activityGroup)
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})

		CampusGroupPostRequest.getPostsFromGroup(group,
			sincePostId: lastPostId,
			successHandler: { (posts) -> () in
				self.groupPosts = posts.sort { $0.postDate > $1.postDate }
				self.tableView.reloadData()
				
				self.lastPostId = self.groupPosts?.first?.id
				
				dispatch_group_leave(activityGroup)
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(activityGroup)
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
		
		dispatch_group_notify(activityGroup, dispatch_get_main_queue()) {
			self.activityIndicator.stopAnimating()
		}
		
		group.getGroupPictureFromS3 { (image) -> () in
			if let image = image
			{
				self.groupImage.image = image
				self.groupImage.contentMode = .ScaleAspectFill
			}
		}
    }
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		if firstDisplay //Reload only when re-displaying
		{
			firstDisplay = false
			return
		}
		
		let activityGroup = dispatch_group_create() //Dispatch group to stop activity indicator after all requests have finished
		
		dispatch_group_enter(activityGroup)
		dispatch_group_enter(activityGroup)
		
		self.activityIndicator.startAnimating()
		
		CampusGroupRequest.getGroupWithId(group.id,
			successHandler: { (group) -> () in
				self.group = group
				
				self.navigationItem.title = group.name ?? "Group"
				self.groupDescription.text = group.description
				
				dispatch_group_leave(activityGroup)
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(activityGroup)
		})
		
		CampusGroupPostRequest.getPostsFromGroup(group,
			sincePostId: lastPostId,
			successHandler: { (posts) -> () in
				if self.groupPosts == nil
				{
					self.groupPosts = [CampusGroupPost]()
				}
				self.groupPosts!.insertContentsOf(posts.sort { $0.postDate > $1.postDate }, at: 0)
				self.tableView.reloadData()
				
				self.lastPostId = self.groupPosts?.first?.id
				
				dispatch_group_leave(activityGroup)
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(activityGroup)
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
		
		dispatch_group_notify(activityGroup, dispatch_get_main_queue()) {
			self.activityIndicator.stopAnimating()
		}
		
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
	
	override func viewWillDisappear(animated: Bool)
	{
		super.viewWillDisappear(animated)
		if let newPostsObserver = newPostsObserver
		{
			NSNotificationCenter.defaultCenter().removeObserver(newPostsObserver)
		}
	}
	
	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		
		requestButton.layer.cornerRadius = requestButton.frame.size.height / 2
		followButton.layer.cornerRadius = followButton.frame.size.height / 2
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? CreateEditGroupViewController
			where segueId == GroupViewController.editGroupSegueId
		{
			destVC.group = self.group
		} else if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? NewGroupPostViewController
			where segueId == GroupViewController.newPostSegueId
		{
			destVC.group = self.group
			destVC.accessLevel = self.accessLevel
		} else if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? PublicProfileViewController,
			sender = sender as? GroupPostTableCell
			where segueId == GroupViewController.userPublicProfileSegueId
		{
			let indexPath = tableView.indexPathForCell(sender)!
			destVC.user = groupPosts![indexPath.row].user
		} else if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? EventViewController,
			sender = sender as? GroupPostTableCell
			where segueId == GroupViewController.groupToEventSegueId
		{
			let indexPath = tableView.indexPathForCell(sender)!
			destVC.post = groupPosts![indexPath.row]
		} else if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? PostCommentsViewController,
			sender = sender as? CampusGroupPost
			where segueId == GroupViewController.postToPostComments
		{
			destVC.post = sender
			
			CampusGroupPostRequest.getCommentsForPost(sender,
				successHandler: { (comments) -> () in
					destVC.comments = comments
				},
				failureHandler: { (error) -> () in
					destVC.activityIndicator.stopAnimating()
					destVC.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		}

	}
	
	
	// MARK: - UITableViewDataSource
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return groupPosts?.count ?? 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCellWithIdentifier(GroupPostTableCell.reuseId, forIndexPath: indexPath) as! GroupPostTableCell
		let post = groupPosts![indexPath.row]
		cell.groupPost = post
		
		if post.eventDate == nil
		{
			cell.bookmarkEvent.hidden = true
		} else
		{
			cell.bookmarkEvent.hidden = false
			if cell.bookmarkEvent.allTargets().count == 0
			{
				cell.bookmarkEvent.addTarget(self, action: #selector(GroupViewController.subscribe(_:)), forControlEvents: .TouchUpInside)
			}
			cell.bookmarkEvent.tag = indexPath.row
		}
		
		if let subscribedPosts = CampusUser.currentUser.subscribedPosts where subscribedPosts.map({ $0.id }).contains(post.id)
		{
			cell.bookmarkEvent.setImage(UIImage(named: "bookmark-purple-icon"), forState: .Normal)
		} else
		{
			cell.bookmarkEvent.setImage(UIImage(named: "bookmark-icon"), forState: .Normal)
		}
		
		if let accessLevel = accessLevel where accessLevel == .Admin
		{
			cell.deletePost.hidden = false
		} else if post.user.id == CampusUser.currentUser.id
		{
			cell.deletePost.hidden = false
		} else
		{
			cell.deletePost.hidden = true
		}
		
		if !cell.deletePost.hidden
		{
			if cell.deletePost.allTargets().count == 0
			{
				cell.deletePost.addTarget(self, action: #selector(GroupViewController.deletePost(_:)), forControlEvents: .TouchUpInside)
			}
			cell.deletePost.tag = indexPath.row
		}
		
		cell.title.text = post.title
		cell.date.text = post.postDate.shortLocalString()
		cell.postText.text = post.text
		
		var likesText = ""
		if post.likesUserIds.count > 0
		{
			if post.likesUserIds.count == 1
			{
				likesText = "\(post.likesUserIds.count) Like"
			} else
			{
				likesText = "\(post.likesUserIds.count) Likes"
			}
		}
		var commentsText = ""
		if post.commentIds.count > 0
		{
			if post.commentIds.count == 1
			{
				commentsText = "\(post.commentIds.count) Comment"
			} else
			{
				commentsText = "\(post.commentIds.count) Comments"
			}
		}
		var text = likesText
		
		if text != ""
		{
			if commentsText != ""
			{
				text += " and " + commentsText
			}
		} else
		{
			text = commentsText
		}
		
		if post.likesUserIds.contains(CampusUser.currentUser.id)
		{
			cell.likeButton.setTitle("Unlike", forState: .Normal)
		} else
		{
			cell.likeButton.setTitle("Like", forState: .Normal)
		}
		
		if cell.likeButton.allTargets().count == 0
		{
			cell.likeButton.addTarget(self, action: #selector(GroupViewController.likePost(_:)), forControlEvents: .TouchUpInside)
		}
		cell.likeButton.tag = indexPath.row

		if cell.commentButton.allTargets().count == 0
		{
			cell.commentButton.addTarget(self, action: #selector(GroupViewController.showComments(_:)), forControlEvents: .TouchUpInside)
		}
		cell.commentButton.tag = indexPath.row

		if cell.likesAndCommentsButton.allTargets().count == 0
		{
			cell.likesAndCommentsButton.addTarget(self, action: #selector(GroupViewController.showComments(_:)), forControlEvents: .TouchUpInside)
		}
		cell.likesAndCommentsButton.tag = indexPath.row
		
		if text == ""
		{
			cell.likesAndCommentsButton.hidden = true
		} else
		{
			cell.likesAndCommentsButton.hidden = false
			cell.likesAndCommentsButton.setTitle(text, forState: .Normal)
		}
		
		return cell
	}
	
	
	// MARK: - UITableViewDelegate
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		let post = groupPosts![indexPath.row]
		if post.eventDate == nil
		{
			self.performSegueWithIdentifier(GroupViewController.userPublicProfileSegueId, sender: tableView.cellForRowAtIndexPath(indexPath))
		} else
		{
			self.performSegueWithIdentifier(GroupViewController.groupToEventSegueId, sender: tableView.cellForRowAtIndexPath(indexPath))
		}
	}
	
	// MARK: - Private
	
	private func processNewPost(post: CampusGroupPost)
	{
		CampusGroupPostRequest.getPostsFromGroup(group,
			sincePostId: lastPostId,
			successHandler: { (posts) -> () in
				if self.groupPosts == nil
				{
					self.groupPosts = [CampusGroupPost]()
				}
				self.groupPosts!.insertContentsOf(posts.sort { $0.postDate > $1.postDate }, at: 0)
				
				self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
				
				self.lastPostId = self.groupPosts?.first?.id
				
			},
			failureHandler: { (error) -> () in
				log.error("Could not get latest posts for group.id \(self.group.id)")
		})
	}

}
