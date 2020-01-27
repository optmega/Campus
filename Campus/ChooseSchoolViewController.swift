//
//  ChooseSchoolViewController.swift
//  Campus
//
//  Created by Ivan Dilchovski on 1/3/16.
//  Copyright © 2016 Ivan Dilchovski. All rights reserved.
//

import UIKit

class ChooseSchoolViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate
{
	private var schools = [CampusSchool]()
	
	@IBOutlet var schoolPicker: UIPickerView!
	@IBOutlet var nextButton: UIButton!
	
	@IBOutlet var activityIndicator: UIActivityIndicatorView!
	
    override func viewDidLoad()
	{
        super.viewDidLoad()
		
		self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil) //Removes the title from the back button on the next screen
		
		nextButton.clipsToBounds = true
		nextButton.enabled = false
		
		schools.append(CampusSchool(id: -1, name: "Select your school", emailDomain: ""))
		
		activityIndicator.startAnimating()
		CampusSchoolRequest.getSchools(
			successHandler: { (schools: [CampusSchool]) -> () in
				self.schools += schools
				self.schoolPicker.reloadAllComponents()
				
				self.activityIndicator.stopAnimating()
			},
			failureHandler: { (error) -> () in
				self.activityIndicator.stopAnimating()
				
				self.nextButton.enabled = false
				self.presentViewController(error.getGenericAlert(), animated: true, completion: nil)
		})
		
		CampusUser.currentUser = CampusUser()
    }
	
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		
		self.navigationController?.navigationBarHidden = false
	}
	
	override func viewDidLayoutSubviews()
	{
		super.viewDidLayoutSubviews()
		
		nextButton.layer.cornerRadius = nextButton.frame.size.height / 2
		
	}

    override func didReceiveMemoryWarning()
	{
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
	{
		return 1
	}
	
	func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
	{
		return schools.count
	}
	
	func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
	{
		return schools[row].name
	}
	
	func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
		return NSAttributedString(string: schools[row].name, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
	}
	
	func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
	{
		if row > 0
		{
			let school = schools[row]
			CampusUser.currentUser.school = CampusSchool(id: school.id, name: school.name, emailDomain: school.emailDomain)
			nextButton.enabled = true
		} else
		{
			nextButton.enabled = false
		}
	}
}
