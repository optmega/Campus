//
//  UIImage+ScaleImage.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/12/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation

extension UIImage
{
	func scaledToSize(size: CGSize) -> UIImage
	{
		var scaledImageRect = CGRectZero
  
		let aspectWidth = size.width / self.size.width;
		let aspectHeight = size.height / self.size.height;
		let aspectRatio = min(aspectWidth, aspectHeight)
		
		scaledImageRect.size.width = self.size.width * aspectRatio
		scaledImageRect.size.height = self.size.height * aspectRatio
		
		UIGraphicsBeginImageContextWithOptions(scaledImageRect.size, false, 0 )
		self.drawInRect(scaledImageRect)
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
  
		return scaledImage
	}
}