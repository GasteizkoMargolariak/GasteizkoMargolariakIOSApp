// Copyright (C) 2016 Inigo Valentin
//
// This file is part of the Gasteizko Margolariak IOS app.
//
// The Gasteizko Margolariak IOS app is free software: you can
// redistribute it and/or modify it under the terms of the
// GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your
// option) any later version.
//
// The Gasteizko Margolariak IOS app is distributed in the
// hope that it will be useful, but WITHOUT ANY WARRANTY;
// without even the implied warranty of MERCHANTABILITY or
// FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
// Public License for more details.
//
// You should have received a copy of the GNU General Public
// License along with the Gasteizko Margolariak IOS app.
// If not, see <http://www.gnu.org/licenses/>.

import UIKit
import CoreData

/**
The view controller of the app.
*/
class ScheduleViewController: UIViewController, UIGestureRecognizerDelegate {

	// Outlets
	@IBOutlet weak var btPrev: UIButton!
	@IBOutlet weak var btNext: UIButton!
	@IBOutlet weak var lbDayNumber: UILabel!
	@IBOutlet weak var lbDayMonth: UILabel!
	@IBOutlet weak var lbDayName: UILabel!
	@IBOutlet weak var svScheduleList: UIStackView!
	
	// Margolari schedule indicator
	var margolari: Bool = false
	
	// App delegate
	var delegate: AppDelegate?
	
	func getContext () -> NSManagedObjectContext {
		return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
	}
	
	/**
	Run when the app loads.
	*/
	override func viewDidLoad() {
		
		NSLog(":SCHEDULECONTROLLER:LOG: Init schedule.")
		
		super.viewDidLoad()
		self.loadSchedule(margolari: margolari)
		
		//TODO Title
		
		// TODO Set button action
		//barButton.addTarget(self, action: #selector(self.back), for: .touchUpInside)
	}
	
	/**
	Returns to the main view controller.
	*/
	func back() {
		NSLog(":SCHEDULECONTROLLER:DEBUG: Back")
		self.dismiss(animated: true, completion: nil)
	}
	
	
	/**
	Dispose of any resources that can be recreated.
	*/
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	/**
	Loads the schedule.
	*/
	public func loadSchedule(margolari: Bool){
		
		NSLog(":SCHEDULECONTROLLER:DEBUG: Loading schedule: Margolariak \(margolari)")
		
		var rowcount = 0
		var row: RowSchedule
		var start: NSDate
		var title: String
		var text: String
		var locationId: Int
		var location: String
		
		NSLog(":SCHEDULECONTROLLER:DEBUG: 1")
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let lang : String = getLanguage()
		NSLog(":SCHEDULECONTROLLER:DEBUG: 2")
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		let fetchRequest: NSFetchRequest<Festival_event> = Festival_event.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "start", ascending: false)
		let sortDescriptors = [sortDescriptor]
		NSLog(":SCHEDULECONTROLLER:DEBUG: 3")
		fetchRequest.sortDescriptors = sortDescriptors
		
		if margolari == true{
			fetchRequest.predicate = NSPredicate(format: "gm = %i", 1)
		}
		else{
			fetchRequest.predicate = NSPredicate(format: "gm = %i", 0)
		}
		
		// TODO: filter by date, not by number
		fetchRequest.fetchLimit = 20
		
		NSLog(":SCHEDULECONTROLLER:DEBUG: 4")
		
		do {
			
			// Get the result
			let searchResults = try context.fetch(fetchRequest)
			NSLog(":SCHEDULECONTROLLER:DEBUG: 5")
			
			NSLog(":SCHEDULECONTROLLER:DEBUG: Total events: \(searchResults.count)")
			
			for r in searchResults as [NSManagedObject] {
				
				title = r.value(forKey: "title_\(lang)") as! String
				if let tx = r.value(forKey: "description_\(lang)"){
					text = r.value(forKey: "description_\(lang)") as! String
				}
				else{
					text = ""
				}
				start = r.value(forKey: "start")! as! NSDate
				locationId = r.value(forKey: "place")! as! Int
				row = RowSchedule.init(s: "rowSchedule\(rowcount)", i: rowcount)
				
				row.setTitle(text: title)
				row.setText(text: text)
				row.setTime(dtime: start)
				
				// Get location info from Place entity
				let locationFetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
				locationFetchRequest.predicate = NSPredicate(format: "id == %i", locationId)
				locationFetchRequest.fetchLimit = 1
				do{
					var locationSearchResults = try context.fetch(locationFetchRequest)
					var locationR = locationSearchResults[0]
					location = locationR.value(forKey: "name_\(lang)")! as! String
					
					row.setLocation(text: location)
				} catch {
					NSLog(":SCHEDULECONTROLLER:ERROR: Error getting location: \(error)")
				}
				
				NSLog(":SCHEDULECONTROLLER:DEBUG: Adding row: height: \(row.frame.height)")
				svScheduleList.addArrangedSubview(row)
				//row.setNeedsLayout()
				//row.layoutIfNeeded()
				
				rowcount = rowcount + 1
			}

			svScheduleList.setNeedsLayout()
			svScheduleList.layoutIfNeeded()

		} catch {
			NSLog(":SCHEDULECONTROLLER:ERROR: Error with request: \(error)")
		}

	}
	
	/**
	Gets the device language.
	:return: Two letter language code of the device.
	*/
	func getLanguage() -> String{
		let pre = NSLocale.preferredLanguages[0].subStr(start: 0, end: 1)
		if(pre == "es" || pre == "en" || pre == "eu"){
			return pre
		}
		else{
			return "es"
		}
	}
	
}

