	//
//  CampusGroup+S3Picture.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/15/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import AWSS3

extension CampusGroup
{
	func uploadGroupPictureToS3FromLocalURL(
		pictureURL: NSURL,
		uuid: String,
		successHandler: (() -> ())?,
		errorHandler: ((error: NSError) -> ())?)
	{
		let transferManager = AWSS3TransferManager.defaultS3TransferManager()
		let pictureUploadRequest = AWSS3TransferManagerUploadRequest()
		
		pictureUploadRequest.bucket = Constants.Values.S3BucketName
		pictureUploadRequest.key =  "group_pictures/\(uuid).jpg"
		pictureUploadRequest.body = pictureURL
		
		let task = transferManager.upload(pictureUploadRequest)
		task.continueWithBlock { (task) -> AnyObject! in
			if let error = task.error
			{
				log.error("Error: \(error)")
				dispatch_async(dispatch_get_main_queue()) {
					errorHandler?(error: error)
				}
			} else
			{
				dispatch_async(dispatch_get_main_queue()) {
					successHandler?()
				}
				
				log.info("Upload successful")
			}
			
			return nil
		}
		
	}

	func getGroupPictureFromS3(handler handler:((image: UIImage?) -> ())?)
	{
		guard let groupPicturePath = self.groupPicturePath
			else
		{
			handler?(image: nil)
			return
		}
		
		if let image = groupPictureFromCache(groupPicturePath)
		{
			handler?(image: image)
			return
		}
		
		guard task == nil
			else
		{
			log.info("Already downloading profile picture")
			return
		}
		
		let cachedURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent(groupPicturePath)
		
		let pictureS3DownloadRequest = AWSS3TransferManagerDownloadRequest()
		pictureS3DownloadRequest.bucket = Constants.Values.S3BucketName
		pictureS3DownloadRequest.key = groupPicturePath
		pictureS3DownloadRequest.downloadingFileURL = cachedURL;
		
		let transferManager = AWSS3TransferManager.defaultS3TransferManager()
		task = transferManager.download(pictureS3DownloadRequest)
		task!.continueWithBlock { (task) -> AnyObject? in
			self.task = nil
			if task.error != nil {
				log.error("Error: \(task.error)")
				dispatch_async(dispatch_get_main_queue()) { () -> Void in
					handler?(image: nil)
				}
			} else {
				log.info("Download to \(cachedURL) successful")
				if let image = self.groupPictureFromCache(groupPicturePath)
				{
					dispatch_async(dispatch_get_main_queue()) { () -> Void in
						handler?(image: image)
					}
				} else
				{
					dispatch_async(dispatch_get_main_queue()) { () -> Void in
						handler?(image: nil)
					}
				}
			}
			
			return nil
		}
	}
	
	func deleteGroupPictureFromS3()
	{
		guard let groupPicturePath = groupPicturePath
			else
		{
			return
		}
		
		let s3 = AWSS3.defaultS3()
		let deleteRequest = AWSS3DeleteObjectRequest()
		deleteRequest.bucket = Constants.Values.S3BucketName
		deleteRequest.key = groupPicturePath
		
		s3.deleteObject(deleteRequest).continueWithBlock { (task) -> AnyObject? in
			if let error = task.error
			{
				log.error("Error: \(error)")
			}
			
			return nil
		}
	}
	
	private func groupPictureFromCache(groupPicturePath: String) -> UIImage?
	{
		let cachedURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent(groupPicturePath)
		
		guard let imageData = NSData(contentsOfURL: cachedURL)
			else
		{
			log.info("Group picture not in cache")
			
			return nil
		}
		
		guard let image = UIImage(data: imageData)
			else
		{
			log.error("Data is not an image")
			
			return nil
		}
		
		return image
	}
}