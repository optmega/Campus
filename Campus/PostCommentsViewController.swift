//
//  PostCommentsViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 3/21/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class PostCommentsViewController: UIViewController
{
	private static let commentToPublicProfileSegueId = "commentToPublicProfile"
	
	var post: CampusGroupPost!
	var comments: [CampusComment]?
	{
		didSet
		{
			comments?.sortInPlace({$0.commentDate > $1.commentDate})
			tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
			activityIndicator.stopAnimating()
		}
	}
	
	// MARK: - Outlets
	
	@IBOutlet var profilePicture: UIImageView!
	@IBOutlet var usernameLabel: UILabel!
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var dateLabel: UILabel!
	@IBOutlet var textLabel: UILabel!
	
	@IBOutlet var tableView: UITableView!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
	// MARK: - Lifecycle
	
    override func viewDidLoad()
	{
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "MM/dd/yyyy hh:mma"
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = Constants.Values.TableViewRowHeight / 2
		
		usernameLabel.text = post.user.firstName + " " + post.user.lastName
		titleLabel.text = post.title
		dateLabel.text = dateFormatter.stringFromDate(post.postDate)
		textLabel.text = post.text
		
		post.user.getProfilePictureFromS3 { (image) -> () in
			if let image = image
			{
				self.profilePicture.image = image
			} else
			{
				self.profilePicture.image = UIImage(named: Constants.Values.NoPhotoImageName)
			}
		}
        super.viewDidLoad()
    }
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
	{
		if let segueId = segue.identifier,
			destVC = segue.destinationViewController as? PublicProfileViewController,
			sender = sender as? PostCommentCell
			where segueId == PostCommentsViewController.commentToPublicProfileSegueId
		{
			destVC.user = sender.comment.user
		}
	}
}

extension PostCommentsViewController: UITableViewDataSource
{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int
	{
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return comments?.count ?? 0
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let comment = comments![indexPath.row]
		let cell = tableView.dequeueReusableCellWithIdentifier(PostCommentCell.reuseId, forIndexPath: indexPath) as! PostCommentCell
		cell.comment = comment
		
		cell.usernameLabel.text = comment.user.firstName + " " + comment.user.lastName
		cell.commentTextLabel.text = comment.text
		
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "MM/dd/yyyy hh:mma"
		cell.commentDateLabel.text = dateFormatter.stringFromDate(comment.commentDate)
		
		comment.user.getProfilePictureFromS3 { (image) -> () in
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

extension PostCommentsViewController: UITextFieldDelegate
{
	func textFieldShouldReturn(textField: UITextField) -> Bool
	{
		if let text = textField.text where text != ""
		{
			CampusGroupPostRequest.commentOnPost(text,
				post: post,
				successHandler: { (comment) -> () in
					if self.comments != nil
					{
						self.comments!.append(comment)
					} else
					{
						self.comments = [comment]
					}
					textField.text = nil
				},
				failureHandler: { (error) -> () in
					self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
			})
		}
		
		return true
	}
}