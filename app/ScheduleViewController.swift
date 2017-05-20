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
The controller of the schedule view.
*/
class ScheduleViewController: UIViewController, UIGestureRecognizerDelegate {

	// Outlets
	@IBOutlet weak var lbWindowTitle: UILabel!
	@IBOutlet weak var btPrev: UIButton!
	@IBOutlet weak var btNext: UIButton!
	@IBOutlet weak var lbDayNumber: UILabel!
	@IBOutlet weak var lbDayMonth: UILabel!
	@IBOutlet weak var lbDayName: UILabel!
	@IBOutlet weak var svScheduleList: UIStackView!
	@IBOutlet weak var lbToolbarTitle: UILabel!
	@IBOutlet weak var btToolbarButton: UIButton!
	
	var context: NSManagedObjectContext? = nil
	var lang: String? = nil
	var delegate: AppDelegate? = nil
	
	// Margolari schedule indicator
	var margolari: Bool = false

	// Day indicator
	var days: [NSDate] = [NSDate]()
	var selectedDay: Int = 0

	/**
	Gets the application context.
	:return: The application context.
	*/
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
		
		// Set titles
		if margolari == true{
			lbToolbarTitle.text = " Programa Margolari"
			lbWindowTitle.text = " Programa Margolari"
		}
		else{
			lbToolbarTitle.text = " Programa de Fiestas"
			lbWindowTitle.text = " Programa de Fiestas"
		}
		
		// Set back button action
		btToolbarButton.addTarget(self, action: #selector(self.back), for: .touchUpInside)
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
		
		self.context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		self.delegate = UIApplication.shared.delegate as! AppDelegate
		self.lang = getLanguage()
		self.context?.persistentStoreCoordinator = self.delegate?.persistentStoreCoordinator

		// Get days
		// TODO: Get current year
		let year = 2016
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		dateFormatter.locale = Locale.init(identifier: "en_GB")
		var dateString = "\(year)-01-01"
		let sDate = dateFormatter.date(from: dateString)
		dateString = "\(year)-12-31"
		let eDate = dateFormatter.date(from: dateString)
		let dayFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Festival_event")
		dayFetchRequest.propertiesToFetch = ["day"]
		if self.margolari == true{
			dayFetchRequest.predicate = NSPredicate(format: "(gm = %i) AND (start >= %@) AND (start <= %@)", argumentArray: [1, sDate, eDate])
		}
		else{
			dayFetchRequest.predicate = NSPredicate(format: "(gm = %i) AND (start >= %@) AND (start <= %@)", argumentArray: [0, sDate, eDate])
		}

		dayFetchRequest.returnsDistinctResults = true
		//dayFetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType

		do {
			let results = try self.context?.fetch(dayFetchRequest)
			
			for r in results as! [NSManagedObject] {
				let day: NSDate = r.value(forKey: "day") as! NSDate
				// Don't add duplicates
				if self.days.contains(day) == false{
					NSLog(":SCHEDULECONTROLLER:DEBUG: Day \(day)")
					self.days.append(day)
				}
			}

			/*let resultsDict = results as! [[String: String]]
			for r in resultsDict {
				//let dayStr: String = r.value(forKey: "day") as! String
				NSLog(":SCHEDULECONTROLLER:DEBUG: Day \(r["day"])")
				//self.days.append(r.value(forKey: "day") as! NSDate)
			}*/

		}
		catch let err as NSError {
			NSLog(":SCHEDULECONTROLLER:ERROR: Error getting day list: \(err)")
		}

		// Select the day to show initially.
		// TODO: Check if any day corresponds to the current date.
		self.selectedDay = 0

		// Set listenerts for the arrow buttons
		let tapRecognizerPrevDay = UITapGestureRecognizer(target: self, action: #selector(prevDay(_:)))
		self.btPrev.isUserInteractionEnabled = true
		self.btPrev.addGestureRecognizer(tapRecognizerPrevDay)
		let tapRecognizerNextDay = UITapGestureRecognizer(target: self, action: #selector(nextDay(_:)))
		self.btNext.isUserInteractionEnabled = true
		self.btNext.addGestureRecognizer(tapRecognizerNextDay)

	loadDay()

	}


	/**
	Populates the schedule list with tehe events of the currently selected days.
	Usually there is no need to call this function manually.
	*/
	func loadDay(){
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		dateFormatter.locale = Locale.init(identifier: "en_GB")
		
		// Clear list.
		for v in (self.svScheduleList?.subviews)!{
			v.removeFromSuperview()
		}
		
		// TODO: Set toolbar elements.
		if margolari == true{
			let dayFetchRequest: NSFetchRequest<Festival_day> = Festival_day.fetchRequest()
			dayFetchRequest.predicate = NSPredicate(format: "date = %@", argumentArray: [days[selectedDay]])
			var name: String = ""
			do {
				let daySearchResults = try self.context?.fetch(dayFetchRequest)
				for r in daySearchResults as! [NSManagedObject] {
					name = r.value(forKey: "name_\(lang!)") as! String
				}
				self.lbDayName.text = name
			}
			catch {
				NSLog(":SCHEDULECONTROLLER:ERROR: Error getting info about days: \(error)")
			}
		}
		else{
			self.lbDayName.text = ""
		}
		let dateString: String = dateFormatter.string(from: days[selectedDay] as Date)
		let nDay: String = dateString.subStr(start: 8, end: 9)
		let month: String = dateString.subStr(start: 5, end: 6)
		var nMonth: String = "Agosto" // TODO: Reference
		if month == "07"{
			nMonth = "Julio" // TODO: Reference
		}
		self.lbDayMonth.text = nMonth
		self.lbDayNumber.text = "\(Int(nDay)!)"
		
		// Enable or disable buttons
		if self.selectedDay <= 0{
			self.btPrev.alpha = 0.5
			self.btPrev.isUserInteractionEnabled = false
		}
		else{
			self.btPrev.alpha = 1
			self.btPrev.isUserInteractionEnabled = true
		}
		if self.selectedDay >= (days.count - 1){
			self.btNext.alpha = 0.5
			self.btNext.isUserInteractionEnabled = false
		}
		else{
			self.btNext.alpha = 1
			self.btNext.isUserInteractionEnabled = true
		}

		
		
		
		var rowcount = 0
		var row: RowSchedule
		var start: NSDate
		var title: String
		var text: String
		var locationId: Int
		var location: String

		let fetchRequest: NSFetchRequest<Festival_event> = Festival_event.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "start", ascending: true)
		let sortDescriptors = [sortDescriptor]
		fetchRequest.sortDescriptors = sortDescriptors
		
		if margolari == true{
			fetchRequest.predicate = NSPredicate(format: "(gm = %i) AND (day = %@)", argumentArray: [1, days[selectedDay]])
		}
		else{
			fetchRequest.predicate = NSPredicate(format: "(gm = %i) AND (day = %@)", argumentArray: [0, days[selectedDay]])
		}
				
		do {
			
			// Get the result
			let searchResults = try self.context?.fetch(fetchRequest)
			
			NSLog(":SCHEDULECONTROLLER:DEBUG: Total events: \(searchResults?.count)")
			
			for r in searchResults as! [NSManagedObject] {
				
				title = r.value(forKey: "title_\(lang!)") as! String
				if let tx = r.value(forKey: "description_\(lang!)"){
					text = r.value(forKey: "description_\(lang!)") as! String
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
					var locationSearchResults = try self.context?.fetch(locationFetchRequest)
					var locationR = locationSearchResults?[0]
					location = locationR?.value(forKey: "name_\(lang!)")! as! String
					
					row.setLocation(text: location)
				} catch {
					NSLog(":SCHEDULECONTROLLER:ERROR: Error getting location: \(error)")
				}
				
				svScheduleList.addArrangedSubview(row)
				
				rowcount = rowcount + 1
			}

			svScheduleList.setNeedsLayout()
			svScheduleList.layoutIfNeeded()

		} catch {
			NSLog(":SCHEDULECONTROLLER:ERROR: Error with request: \(error)")
		}

	}


	/**
	Shows the schedule of the next day
	:param: sender Event trigger.
	*/
	func nextDay(_ sender:UITapGestureRecognizer? = nil){
		changeDay(increment: 1)
	}


	/**
	Shows the schedule of the previous day.
	:param: sender Event trigger.
	*/
	func prevDay(_ sender:UITapGestureRecognizer? = nil){
    changeDay(increment: -1)
  }


	/**
	Changes the day by a fixed amount of days.
	Usualli called to move one step forward or backward.
	:param: increment Days to advance the schedule. Negative values to back it up.
	*/
	func changeDay(increment: Int){
		NSLog(":SCHEDULECONTROLLER:DEBUG: Change day increment: \(increment)")
		self.selectedDay = self.selectedDay + increment
		if self.selectedDay <= -1{
			self.selectedDay = 0
		}
		if self.selectedDay >= self.days.count{
			self.selectedDay = (self.days.count - 1)
		}
		loadDay()
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
