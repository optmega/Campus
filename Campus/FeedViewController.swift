//
//  FeedViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/4/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit
import ViewDeck
import FBAudienceNetwork

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
	private let openGroupFromPostSegueId = "openGroupFromPost"
	
	private enum FeedEntry
	{
		case GroupPost(post: CampusGroupPost)
		case FBNativeAd
//		case UserPost
	}
	
	enum FeedMode
	{
		case All
		case Followed
		case Admin
	}
	
	
	// MARK: - Properties
	
	private var fbNativeAdsManager: FBNativeAdsManager!
	private var fBNativeAdTableViewCellProvider: FBNativeAdTableViewCellProvider?
	
	private var followedGroupIds: [Int]?
	private var joinedGroupIds: [Int]?
	private var adminGroupIds: [Int]?
	
	private var allGroupPosts = [CampusGroupPost]()
	private var displayedGroupPosts = [CampusGroupPost]()
	
	private var lastPostId: Int?
	
	private var feedMode = FeedMode.All
	
	private var newPostsObserver: NSObjectProtocol? //Notification observation with block can be removed only with the object returned from addObserver...
	
	// MARK: - Outlets
	
	@IBOutlet var tableView: UITableView!
	
	@IBOutlet var allButton: UIButton!
	@IBOutlet var followingButton: UIButton!
	@IBOutlet var adminButton: UIButton!
	
	@IBOutlet var allIndicator: UIView!
	@IBOutlet var followingIndicator: UIView!
	@IBOutlet var adminIndicator: UIView!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	
	// MARK: - Actions
	
	@IBAction func allGroupsPressed(sender: UIButton)
	{
		allButton.setTitleColor(Constants.Colors.Purple, forState: .Normal)
		followingButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		adminButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		
		allIndicator.hidden = false
		followingIndicator.hidden = true
		adminIndicator.hidden = true
		
		feedMode = .All
		reloadData()
	}
	
	@IBAction func followedGroupsPressed(sender: UIButton)
	{
		allButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		followingButton.setTitleColor(Constants.Colors.Purple, forState: .Normal)
		adminButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		
		allIndicator.hidden = true
		followingIndicator.hidden = false
		adminIndicator.hidden = true
		
		feedMode = .Followed
		reloadData()
	}
	
	@IBAction func adminGroupsPressed(sender: AnyObject)
	{
		allButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		followingButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
		adminButton.setTitleColor(Constants.Colors.Purple, forState: .Normal)
		
		allIndicator.hidden = true
		followingIndicator.hidden = true
		adminIndicator.hidden = false
		
		feedMode = .Admin
		reloadData()
	}
	
	@IBAction func openMenuPressed(sender: UIBarButtonItem)
	{
		if let tabBarController = self.tabBarController
		{
			tabBarController.viewDeckController.toggleLeftView()
			if tabBarController.viewDeckController.isSideOpen(IIViewDeckSide.LeftSide)
			{
				navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu-close-icon"), style: .Plain, target: self, action: #selector(FeedViewController.openMenuPressed(_:)))
			} else
			{
				navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu-open-icon"), style: .Plain, target: self, action: #selector(FeedViewController.openMenuPressed(_:)))
			}
		}
	}
	
	func subscribe(sender: UIButton)
	{
		let post = displayedGroupPosts[sender.tag]
		
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
					subscribe(self.displayedGroupPosts[sender.tag], notificationInterval: nil)
				}
				alertController.addAction(okAction)
				
				self.presentViewController(alertController, animated: true, completion: nil)
			} else
			{
				let alertController = UIAlertController(title: "Do you want to receive a notification about this event?", message: nil, preferredStyle: .ActionSheet)
				let noAction = UIAlertAction(title: "No", style: .Default)  { (action) -> Void in
					subscribe(self.displayedGroupPosts[sender.tag], notificationInterval: nil)
				}

				
				let eventTime = UIAlertAction(title: "At event time", style: .Default) { (action) -> Void in
					subscribe(self.displayedGroupPosts[sender.tag], notificationInterval: 0)
				}
				
				let minutes15 = UIAlertAction(title: "15 minutes before", style: .Default) { (action) -> Void in
					subscribe(self.displayedGroupPosts[sender.tag], notificationInterval: 15)
				}
				
				let minutes30 = UIAlertAction(title: "30 minutes before", style: .Default) { (action) -> Void in
					subscribe(self.displayedGroupPosts[sender.tag], notificationInterval: 30)
				}
				
				let hours1 = UIAlertAction(title: "1 hour before", style: .Default) { (action) -> Void in
					subscribe(self.displayedGroupPosts[sender.tag], notificationInterval: 60)
				}
				
				let hours3 = UIAlertAction(title: "3 hours before", style: .Default) { (action) -> Void in
					subscribe(self.displayedGroupPosts[sender.tag], notificationInterval: 180)
				}
				
				let days1 = UIAlertAction(title: "1 day before", style: .Default) { (action) -> Void in
					subscribe(self.displayedGroupPosts[sender.tag], notificationInterval: 1440)
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
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
	
		fbNativeAdsManager = FBNativeAdsManager(placementID: Constants.Values.FacebookNativeAdPlacementId, forNumAdsRequested: 6)
		fbNativeAdsManager.delegate = self
		fbNativeAdsManager.loadAds()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		tableView.estimatedRowHeight = Constants.Values.TableViewRowHeight
		tableView.rowHeight = UITableViewAutomaticDimension;
		
		newPostsObserver = NSNotificationCenter.defaultCenter().addObserverForName(Constants.NotificationIds.NotificationNewGroupPost, object: nil, queue: nil) { (notification) -> Void in
			guard let newPost = notification.userInfo?["post"] as? CampusGroupPost
				else
			{
				log.error("No post in notification!")
				return
			}
			
			self.processNewPost(newPost)
		}
    }
	
	deinit
	{
		if let newPostsObserver = newPostsObserver
		{
			NSNotificationCenter.defaultCenter().removeObserver(newPostsObserver)
		}
	}

	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		activityIndicator.startAnimating()
		
		let userDetailGroup = dispatch_group_create()
		
		dispatch_group_enter(userDetailGroup)
		dispatch_group_enter(userDetailGroup)
		dispatch_group_enter(userDetailGroup)
		dispatch_group_enter(userDetailGroup)
		dispatch_group_enter(userDetailGroup)
		
		CampusUserRequests.getFollowedGroups(
			forUser: CampusUser.currentUser,
			success: { (groups) -> () in
				self.followedGroupIds = groups.map { $0.id }
				
				dispatch_group_leave(userDetailGroup)
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(userDetailGroup)
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
		
		CampusUserRequests.getJoinedGroups(
			forUser: CampusUser.currentUser,
			success: { (groups) -> () in
				self.joinedGroupIds = groups.map { $0.id }
				
				dispatch_group_leave(userDetailGroup)
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(userDetailGroup)
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
		
		CampusUserRequests.getAdministeredGroups(
			forUser: CampusUser.currentUser,
			success: { (groups) -> () in
				dispatch_group_leave(userDetailGroup)
				
				self.adminGroupIds = groups.map { $0.id }
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(userDetailGroup)
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
		
		CampusGroupPostRequest.getAllPostsForUser(
			sincePostId: lastPostId,
			successHandler: { (posts) -> () in
				self.allGroupPosts.insertContentsOf(posts.sort { $0.postDate > $1.postDate }, at: 0)
				self.lastPostId = self.allGroupPosts.first?.id
				
				dispatch_group_leave(userDetailGroup)
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(userDetailGroup)
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
		
		CampusUserRequests.getSubscribedEvents({ (posts) -> () in
				CampusUser.currentUser.subscribedPosts = posts
				dispatch_group_leave(userDetailGroup)
			},
			failureHandler: { (error) -> () in
				dispatch_group_leave(userDetailGroup)
				
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
		
		dispatch_group_notify(userDetailGroup, dispatch_get_main_queue()) {
			self.activityIndicator.stopAnimating()
			self.reloadData()
		}
		
		allGroupsPressed(allButton)
		
		self.navigationController?.navigationBarHidden = false
		
		if tabBarController!.viewDeckController.isSideOpen(IIViewDeckSide.LeftSide)
		{
			navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu-close-icon"), style: .Plain, target: self, action: #selector(FeedViewController.openMenuPressed(_:)))
		} else
		{
			navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu-open-icon"), style: .Plain, target: self, action: #selector(FeedViewController.openMenuPressed(_:)))
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
			cell = sender as? FeedPostTableCell,
			destVC = segue.destinationViewController as? GroupViewController
			where segueId == openGroupFromPostSegueId
		{
			destVC.group = cell.post.group
		} else
		{
			log.error("Segue with id \"\(segue.identifier)\" not handled")
		}
	}
	
	// MARK: - UITableViewDataSource
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		if let fBNativeAdTableViewCellProvider = fBNativeAdTableViewCellProvider where displayedGroupPosts.count > 0
		{
			let count = Int(fBNativeAdTableViewCellProvider.adjustCount(UInt(displayedGroupPosts.count), forStride: Constants.Values.FacebookNativeAdFrequency))
			return count
		} else
		{
			return displayedGroupPosts.count
		}
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		if let fBNativeAdTableViewCellProvider = fBNativeAdTableViewCellProvider
			where fBNativeAdTableViewCellProvider.isAdCellAtIndexPath(indexPath, forStride: Constants.Values.FacebookNativeAdFrequency)
		{
			let cell = tableView.dequeueReusableCellWithIdentifier(FeedAdTableCell.reuseId, forIndexPath: indexPath) as! FeedAdTableCell
			cell.parentViewController = self
			cell.nativeAd = FBNativeAd(placementID: Constants.Values.FacebookNativeAdPlacementId)
			cell.nativeAd.delegate = cell
			cell.nativeAd.loadAd()
					
			return cell
		} else // Fails either if fBNativeAdTableViewCellProvider is nil OR indexPath is not an ad
		{
			let indexPath2 = fBNativeAdTableViewCellProvider?.adjustNonAdCellIndexPath(indexPath, forStride: Constants.Values.FacebookNativeAdFrequency) ?? indexPath // If fb provider is not nil readjust the indexPath. Otherwise use the original
			
			
			let post = displayedGroupPosts[indexPath2.row]
			let cell = tableView.dequeueReusableCellWithIdentifier(FeedPostTableCell.reuseId, forIndexPath: indexPath2) as! FeedPostTableCell
			cell.post = post
			cell.tag = indexPath2.row
			
			cell.post.group.getGroupPictureFromS3 { (image) -> () in
				if let image = image
				{
					if cell.tag == indexPath2.row
					{
						cell.groupImage.image = image
					} else
					{
						log.info("Loaded image for not displayed cell at index \(indexPath2.row)")
					}
				} else
				{
					cell.groupImage.image = UIImage(named: Constants.Values.NoPhotoImageName)
				}
			}
			
			cell.groupName.text = post.group.name
			cell.postTitle.text = post.title
			cell.eventDate.text = post.eventDate?.shortLocalString()
			cell.postDate.text = post.postDate.shortLocalString()
			
			cell.bookmarkButton.hidden = post.eventDate == nil
			
			if cell.bookmarkButton.allTargets().count == 0
			{
				cell.bookmarkButton.addTarget(self, action: #selector(FeedViewController.subscribe(_:)), forControlEvents: .TouchUpInside)
			}
			cell.bookmarkButton.tag = indexPath2.row
			
			if let subscribedPosts = CampusUser.currentUser.subscribedPosts where subscribedPosts.map({ $0.id }).contains(post.id)
			{
				cell.bookmarkButton.setImage(UIImage(named: "bookmark-purple-icon"), forState: .Normal)
			} else
			{
				cell.bookmarkButton.setImage(UIImage(named: "bookmark-icon"), forState: .Normal)
			}
			
			return cell
		}
	}
	
	// MARK: - Private
	
	private func reloadData()
	{
		if let followedGroupIds = followedGroupIds, joinedGroupIds = joinedGroupIds, adminGroupIds = adminGroupIds
		{
			switch feedMode
			{
				case .All:
					displayedGroupPosts = allGroupPosts
				case .Followed:
					displayedGroupPosts = allGroupPosts.filter { followedGroupIds.contains($0.group.id) || joinedGroupIds.contains($0.group.id) }
				case .Admin:
					displayedGroupPosts = allGroupPosts.filter { adminGroupIds.contains($0.group.id) }
			}
		} else
		{
			displayedGroupPosts.removeAll()
		}
		
		tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
	}
	
	private func processNewPost(post: CampusGroupPost)
	{
		activityIndicator.startAnimating()
		CampusGroupPostRequest.getAllPostsForUser(
			sincePostId: lastPostId,
			successHandler: { (posts) -> () in
				self.allGroupPosts.insertContentsOf(posts.sort { $0.postDate > $1.postDate }, at: 0)
				self.lastPostId = self.allGroupPosts.first?.id
				self.reloadData()
				
				self.activityIndicator.stopAnimating()
			},
			failureHandler: { (error) -> () in
				log.error("Could not load last posts")
				self.activityIndicator.stopAnimating()
		})
	}
}

extension FeedViewController: FBNativeAdsManagerDelegate
{
	func nativeAdsLoaded()
	{
		fbNativeAdsManager.nextNativeAd()
		fBNativeAdTableViewCellProvider = FBNativeAdTableViewCellProvider(manager: fbNativeAdsManager, forType: FBNativeAdViewType.GenericHeight100)
//		tableView.reloadData()
	}
	
	func nativeAdsFailedToLoadWithError(error: NSError)
	{
		log.error("Native FB ads could not be loaded. Error: \(error.localizedDescription)")
	}
	
}