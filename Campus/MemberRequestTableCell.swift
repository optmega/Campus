//
//  MemberRequestTableCell.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/5/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class MemberRequestTableCell: UITableViewCell
{
	static let reuseId = "memberRequestCell"
	
	var member: CampusUser!
	
	@IBOutlet var memberName: UILabel!
	@IBOutlet var profilePicture: UIImageView!
	
	@IBOutlet var acceptButton: UIButton!
	@IBOutlet var declineButton: UIButton!
	
	override func awakeFromNib()
	{
		profilePicture.clipsToBounds = true
	}
	
	override func layoutSubviews()
	{
		super.layoutSubviews()
		
		acceptButton.layer.cornerRadius = acceptButton.frame.size.height / 2
		declineButton.layer.cornerRadius = declineButton.frame.size.height / 2
	}
}
