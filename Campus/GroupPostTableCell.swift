//
//  GroupPostTableCell.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/5/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class GroupPostTableCell: UITableViewCell
{
	static let reuseId = "groupPostCell"
	
	var groupPost: CampusGroupPost!
	
	@IBOutlet var title: UILabel!
	@IBOutlet var date: UILabel!
	@IBOutlet var postText: UILabel!
	
	@IBOutlet var deletePost: UIButton!
	@IBOutlet var bookmarkEvent: UIButton!
	
	@IBOutlet var likeButton: UIButton!
	@IBOutlet var commentButton: UIButton!
	@IBOutlet var likesAndCommentsButton: UIButton!
	
	@IBOutlet var commentsStack: UIStackView!
	@IBOutlet var commentTextField: UITextField!
	
	@IBOutlet var cellHeightConstraint: NSLayoutConstraint!
	
	override func awakeFromNib()
	{
		cellHeightConstraint.constant = Constants.Values.TableViewRowHeight
		
		likeButton.layer.cornerRadius = likeButton.frame.size.height / 2
		commentButton.layer.cornerRadius = commentButton.frame.size.height / 2
		
	}
}
