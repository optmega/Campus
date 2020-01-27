//
//  GroupMembersTableCell.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/13/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class GroupMembersTableCell: UITableViewCell
{
	static let reuseId = "groupMemberCell"
	
	var member: CampusUser!
	
	@IBOutlet var profilePicture: UIImageView!
	@IBOutlet var memberName: UILabel!
	
	@IBOutlet var leaveGroupButton: UIButton!
	@IBOutlet var promoteButton: UIButton!
	@IBOutlet var removeButton: UIButton!
	
	override func awakeFromNib()
	{
		profilePicture.clipsToBounds = true
	}
	
	override func layoutSubviews()
	{
		super.layoutSubviews()
		
		leaveGroupButton?.layer.cornerRadius = leaveGroupButton.frame.size.height / 2
		promoteButton?.layer.cornerRadius = promoteButton.frame.size.height / 2
		removeButton?.layer.cornerRadius = removeButton.frame.size.height / 2
	}
}
