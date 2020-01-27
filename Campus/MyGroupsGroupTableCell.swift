//
//  MyGroupsGroupTableCell.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/5/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class MyGroupsGroupTableCell: UITableViewCell
{
	static let reuseId = "myGroupsCell"
	
	var group: CampusGroup!
	
	@IBOutlet var groupImage: UIImageView!
	@IBOutlet var badgeView: UIView!
	@IBOutlet var groupName: UILabel!
	@IBOutlet var lastUpdated: UILabel!
	@IBOutlet var manageMembersButton: UIButton!
	@IBOutlet var editGroupButton: UIButton!
	
	override func awakeFromNib()
	{
		groupImage.clipsToBounds = true
	}
}
