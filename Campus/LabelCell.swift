//
//  LabelCell.swift
//  Campus
//
//  Created by Ivan Dilchovski on 3/18/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class LabelCell: UICollectionViewCell
{
	static let reuseId = "LabelCell"
	
	@IBOutlet weak var label: UILabel!
	
	override func awakeFromNib()
	{
		label.layer.cornerRadius = 5
		label.layer.masksToBounds = true
	}
}
