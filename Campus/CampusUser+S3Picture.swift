//
//  CampusUser+S3Picture.swift
//  Campus
//
//  Created by Ivan Dilchovski on 2/12/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import Foundation
import AWSS3

extension CampusUser
{
	func uploadProfilePictureToS3FromLocalURL(
		pictureURL: NSURL,
		uuid: String,
		successHandler: (() -> ())?,
		errorHandler: ((error: NSError) -> ())?)
	{
		let transferManager = AWSS3TransferManager.defaultS3TransferManager()
		let pictureUploadRequest = AWSS3TransferManagerUploadRequest()

		pictureUploadRequest.bucket = Constants.Values.S3BucketName
		pictureUploadRequest.key =  "profile_pictures/\(uuid).jpg"
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
	
	func getProfilePictureFromS3(handler handler:((image: UIImage?) -> ())?)
	{
		guard let profilePicturePath = self.profilePicturePath
			else
		{
			handler?(image: nil)
			return
		}
		
		if let image = profilePictureFromCache(profilePicturePath)
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
		
		let cachedURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent(profilePicturePath)
		
		let pictureS3DownloadRequest = AWSS3TransferManagerDownloadRequest()
		pictureS3DownloadRequest.bucket = Constants.Values.S3BucketName
		pictureS3DownloadRequest.key = profilePicturePath
		pictureS3DownloadRequest.downloadingFileURL = cachedURL;
		
		let transferManager = AWSS3TransferManager.defaultS3TransferManager()
		task = transferManager.download(pictureS3DownloadRequest)
		task!.continueWithBlock { (task) -> AnyObject? in
			self.task = nil
			if task.error != nil {
				log.error("Error with picture \(profilePicturePath): \(task.error)")
				if let image = self.profilePictureFromCache(profilePicturePath)
				{
					handler?(image: image)
				} else
				{
					handler?(image: nil)
				}
			} else {
				log.info("Download to \(cachedURL) successful")
				if let image = self.profilePictureFromCache(profilePicturePath)
				{
					handler?(image: image)
				} else
				{
					handler?(image: nil)
				}
			}

			return nil
		}
	}
	
	func deleteProfilePictureFromS3()
	{
		guard let profilePicturePath = profilePicturePath
			else
		{
			return
		}
		
		let s3 = AWSS3.defaultS3()
		let deleteRequest = AWSS3DeleteObjectRequest()
		deleteRequest.bucket = Constants.Values.S3BucketName
		deleteRequest.key = profilePicturePath
		
		s3.deleteObject(deleteRequest).continueWithBlock { (task) -> AnyObject? in
			if let error = task.error
			{
				log.error("Error: \(error)")
			} else
			{
				log.info("Delete successful")
			}
			
			return nil
		}
	}
	
	private func profilePictureFromCache(profilePicturePath: String) -> UIImage?
	{
		let cachedURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0].URLByAppendingPathComponent(profilePicturePath)
		
		guard let imageData = NSData(contentsOfURL: cachedURL)
			else
		{
			log.info("Profile picture not in cache")
			
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