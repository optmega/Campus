//
//  IndentedTextField.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/5/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

///	UITextField with the text identated from both ends settable identation
class IndentedTextField : UITextField
{
	var horizontalPadding: CGFloat? = nil
	
	override func textRectForBounds(bounds: CGRect) -> CGRect
	{
		if let horizontalPadding = horizontalPadding
		{
			return CGRectMake(bounds.origin.x + horizontalPadding, bounds.origin.y, bounds.size.width - horizontalPadding * 2, bounds.size.height)
		} else
		{
			return super.textRectForBounds(bounds)
		}
	}
	
	override func editingRectForBounds(bounds: CGRect) -> CGRect
	{
		return textRectForBounds(bounds)
	}
}