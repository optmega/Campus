//
//  FeedAdTableCell.swift
//  Campus
//
//  Created by Ivan Dilchovski on 5/5/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit
import FBAudienceNetwork

class FeedAdTableCell: UITableViewCell
{
	static let reuseId = "feedAdCell"
	
	var nativeAd: FBNativeAd!
	var parentViewController: UIViewController!
	
	@IBOutlet var nativeAdView: UIView!
	
}

extension FeedAdTableCell: FBNativeAdDelegate
{
	func nativeAdDidLoad(nativeAd: FBNativeAd)
	{
		for view in nativeAdView.subviews
		{
			view.removeFromSuperview()
		}
		
		let nativeView = FBNativeAdView(nativeAd: nativeAd, withType: FBNativeAdViewType.GenericHeight120)
		nativeView.translatesAutoresizingMaskIntoConstraints = false
		nativeAd.registerViewForInteraction(nativeView, withViewController: parentViewController)
		nativeAdView.addSubview(nativeView)
		
		nativeAdView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[ad]|", options: [], metrics: nil, views: ["ad" : nativeView]))
		nativeAdView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[ad]|", options: [], metrics: nil, views: ["ad" : nativeView]))

	}
}

