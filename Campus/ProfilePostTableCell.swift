//
//  ProfilePostsTableCell.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/5/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class ProfilePostTableCell: UITableViewCell
{
	static let reuseId = "profilePostCell"
	
	@IBOutlet var title: UILabel!
	@IBOutlet var date: UILabel!
	@IBOutlet var postText: UILabel!
	@IBOutlet var subscribeButton: UIButton!
}
