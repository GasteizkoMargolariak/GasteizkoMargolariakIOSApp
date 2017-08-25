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

import Foundation
import CoreData
import UIKit

/**
Class to handle server sync.
*/
class Sync{

	var initial: Bool = false

	/**
	Starts the sync process.
	Always asynchronously.
	*/
	init(){
		let url = buildUrl();
		sync(url: url)
	}

	/**
	Starts the sync process, synchronously or asynchronously.
	:param: synchronous True for synchronous sync, false for asynchronously
	*/
	init(synchronous: Bool){
		if synchronous == true{
			NSLog(":SYNC:LOG: Synchronous sync started.")
			self.initial = true
		}
		let url = buildUrl();
		sync(url: url)
	}

	/**
	Builds the URL to perform the sync against.
	:returns: The URL.
	*/
	func buildUrl() -> URL{
		
		// Get user ID
		let defaults = UserDefaults.standard
		var uId: String = "unknown"
		if defaults.value(forKey: "userId") != nil{
			uId = defaults.value(forKey: "userId") as! String
		}

		// Get versions
		var strVersions = ""
		do{
			let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
			let fetchRequest: NSFetchRequest<Version> = Version.fetchRequest()
			let searchResults = try context.fetch(fetchRequest)
			var s: String = ""
			var v: Int = 0
			for r in searchResults {
				s = r.value(forKey: "section")! as! String
				v = r.value(forKey: "version")! as! Int
				strVersions = strVersions + "&\(s)=\(v)"
			}
		}
		catch let error as NSError{
			NSLog(":SYNC:ERROR: Error getting stored versions: \(error)")
		}

		// Build URL
		// TODO: Change host for production
		
		var urlStr: String = ""
		
		if initial{
			urlStr = "http://192.168.1.101/API/v3/fastsync.php?client=com.margolariak.app&user=\(uId)\(strVersions)"
		}
		else{
			urlStr = "http://192.168.1.101/API/v3/sync.php?client=com.margolariak.app&user=\(uId)\(strVersions)"
		}
		let url = URL(string: urlStr)

		
		NSLog(":SYNC:LOG: URL built: \(String(describing: url))")
		return url!
	}

	/**
	Performs an asynchronous sync.
	It fetches the info from the server and stores as Core Data
	:param: url The url to sync.
	*/
	func sync(url: URL){
		
		NSLog(":SYNC:LOG: Sync started.")
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.syncController?.nowSyncing = true

		//Synchronously get data
		let task = URLSession.shared.dataTask(with: url) { dat, response, error in
			guard error == nil else {
				NSLog(":SYNC:ERROR: Unknown error.")
				return
			}
			guard let rawData = dat else {
				NSLog(":SYNC:ERROR: Data is empty.")
				return
			}
			
			var data = String(data:rawData, encoding: String.Encoding.utf8)

			NSLog(":SYNC:LOG: Data received.")

			// Loop tables and save them to core data
			var table: String;
			var content: String;
			while (data?.indexOf(target: "}]") != nil){
				table = data!.subStr(start: 3, end: data!.indexOf(target: "\":")! - 1)
				content = data!.subStr(start: table.length + 5, end: (data?.indexOf(target: "}]"))! + 1)

				if table == "settings"{ // Special case
					self.saveSettings(content: content)
				}
				else if table == "version"{ // Special case
					self.saveVersion(content: content)
				}
				else{
					self.saveTable(table: table, content: content)
				}

				data = data?.subStr(start: (data?.indexOf(target: "}]"))! + 1, end: (data?.length)! - 1)
			}

			// If it's the initial sync, hide the segue
			if self.initial == true{
				NSLog(":SYNC:LOG: Finishing synchronous sync.")
				let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
				delegate.syncController?.nowSyncing = false
			}
		}

		task.resume()
	}


	/**
	Saves the data in the table.
	:param: table Name of the table
	:param: content JSON string containing the rows of the table.
	*/
	func saveTable(table: String, content: String){
		
		NSLog(":SYNC:LOG: Saving table \(table)")
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
		dateFormatter.timeZone = TimeZone.ReferenceType.local

		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator

		let entity =  NSEntityDescription.entity(forEntityName: table.capitalize(), in: context)

		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: table.capitalize())
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError {
			NSLog(":SYNC:ERROR: Could not clean up \(table.capitalize()) entity: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up \(table.capitalize()) entity.")
		}
		

		//Loop rows
		var data: String = content
		var row: String
		var column: String
		var value: String
		var tuple: String
		var query: NSManagedObject
		
		
		while data.indexOf(target: "}") != nil{
			row = data.subStr(start: data.indexOf(target: "{")! + 1, end: data.indexOf(target: "}")! - 1)
			row = "\(row),\""
			
			query = NSManagedObject(entity: entity!, insertInto: context)
			
			while row.indexOf(target: ",\"") != nil{
				tuple = row.subStr(start: 0, end: row.indexOf(target: ",\"")! - 1)
				
				column = tuple.subStr(start: tuple.indexOf(target: "\"")! + 1, end: tuple.indexOf(target: "\":")! - 1)
				
				if column.length + 4 >= tuple.length - 2{
					value = "ul"
				}
				else{
					value = tuple.subStr(start: column.length + 4, end: tuple.length - 2)
				}
				
				if value != "ul"{ // 'ul' rom 'null' or empty. If it is, just do nothing.
					if entity?.attributesByName[column]?.attributeType == .stringAttributeType{
						query.setValue(value, forKey: column)
					}
					else if entity?.attributesByName[column]?.attributeType == .integer16AttributeType || entity?.attributesByName[column]?.attributeType == .integer32AttributeType || entity?.attributesByName[column]?.attributeType == .integer64AttributeType{
						query.setValue(Int(value), forKey: column)
					}
					else if entity?.attributesByName[column]?.attributeType == .booleanAttributeType{
						if Int(value) == 1{
							query.setValue(true, forKey: column)
						}
						else if Int(value) == 0{
							query.setValue(false, forKey: column)
						}
					}
					else if entity?.attributesByName[column]?.attributeType == .dateAttributeType{
						if value.length < 11{
							value = "\(value) 00:00:00"
						}
						query.setValue(dateFormatter.date(from: value)!, forKey: column)
					}
					else{ //Regular string
						
					}
					
					// Special case: "festivl_event_citiy" and "festival_event_gm" have a special column: "day"
					if (table == "festival_event_city" || table == "festival_event_gm") && (column == "start" || (column == "end" && value != "ul")) {
						
						dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
						dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.ISO8601)! as Calendar
						dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
						dateFormatter.timeZone = NSTimeZone.local
						let timeString = value//"\(value.subStr(start: 0, end: 19))"
						let dayString = "\(value.subStr(start: 0, end: 10)) 00:00:00"
						var day = dateFormatter.date(from: dayString)!
						let start = dateFormatter.date(from: timeString)!
						
						// If on the first hours of the next day...
						let calendar = Calendar.current
						let hours = calendar.component(.hour, from: start )
						
						// ... the event belongs to the previous day.
						if hours < 6{
							day = Calendar.current.date(byAdding: .day, value: -1, to: day)!
						}
						query.setValue(day, forKey: "day")
						
					}
					
					
					
				}
				
				
				let start: Int = row.indexOf(target: ",\"")! + 2
				let end: Int = row.length
				if (start == end){
					row = ""
				}
				else{
					row = row.subStr(start: row.indexOf(target: ",\"")! + 1, end: row.length - 1)
				}
				
			}
			
			do{
				// Save the setting
				try context.save()
			}
			catch let error as NSError {
				NSLog(":SYNC:ERROR: Could not save a row for table \(table.capitalize()): \(error), \(error.userInfo).")
			}
			
			data = data.subStr(start: data.indexOf(target: "}")! + 1, end: data.length - 1)
		}
	}


	/**
	Saves the received settings.
	:param: content JSON string containing the rows of the table.
	*/
	func saveSettings(content: String){
		
		NSLog(":SYNC:LOG: Saving settings")
		
		var row: String
		var tuple: String
		var column: String
		var value: String
		var name: String = "dummy"

		let defaults = UserDefaults.standard

		//Loop rows
		var data: String = content
		
		
		while (data.indexOf(target: "}") != nil){
			row = data.subStr(start: data.indexOf(target: "{")! + 1, end: data.indexOf(target: "}")! - 1)
			row = "\(row),\""
			
			while (row.indexOf(target: ",\"") != nil){
				tuple = row.subStr(start: 0, end: row.indexOf(target: ",\"")! - 1)
				
				column = tuple.subStr(start: 1, end: tuple.indexOf(target: "\":")! - 1)
				value = tuple.subStr(start: column.length + 4, end: tuple.length - 2)
				
				if (column == "name"){
					name = value
				}
				else if (column == "value"){
					defaults.set(value, forKey: name)
				}
				
				
				let start: Int = row.indexOf(target: ",\"")! + 2
				let end: Int = row.length
				if (start == end){
					row = ""
				}
				else{
					row = row.subStr(start: row.indexOf(target: ",\"")! + 2, end: row.length - 1)
				}
				
			}
			data = data.subStr(start: data.indexOf(target: "}")! + 1, end: data.length - 1)
		}
	}


	/**
	Saves the new versions of the tables
	:param: content: JSON string.
	*/
	func saveVersion(content: String){
		NSLog(":SYNC:LOG: Saving versions")
		
		var data: String = content
		var row: String
		var section: String = "dummy"
		var version: String = "0"
		var column: String
		var tuple: String
		var value: String
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		let entity =  NSEntityDescription.entity(forEntityName: "Version", in: context)
		
		//Loop rows
		var query: NSManagedObject
		
		while (data.indexOf(target: "}") != nil){
			row = data.subStr(start: data.indexOf(target: "{")! + 1, end: data.indexOf(target: "}")! - 1)
			row = "\(row),\""
			
			while (row.indexOf(target: ",\"") != nil){
				tuple = row.subStr(start: 0, end: row.indexOf(target: ",\"")! - 1)
				
				column = tuple.subStr(start: 1, end: tuple.indexOf(target: "\":")! - 1)
				value = tuple.subStr(start: column.length + 4, end: tuple.length - 2)
				if column == "section"{
					section = value
				}
				else if column == "version"{
					version = value
					
					// Check if version is already in database.
					context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
					let fetchRequest: NSFetchRequest<Version> = Version.fetchRequest()
					fetchRequest.predicate = NSPredicate(format: "section = %@", section)
					do {
						let searchResults = try context.fetch(fetchRequest)
						if searchResults.count > 0{
							let v = searchResults[0]
							v.setValue(Int(version), forKey: "version")
						}
						else{
							query = NSManagedObject(entity: entity!, insertInto: context)
							query.setValue(section, forKey: "section")
							query.setValue(Int(version), forKey: "version")
						}
						
						// Save the setting
						try context.save()
					}
					catch let error as NSError  {
						NSLog(":SYNC:ERROR: Could not store a version: \(error), \(error.userInfo).")
					}
					catch {
						NSLog(":SYNC:ERROR: Could not store a version.")
					}
					
				}
				
				let start: Int = row.indexOf(target: ",\"")! + 2
				let end: Int = row.length
				if (start == end){
					row = ""
				}
				else{
					row = row.subStr(start: row.indexOf(target: ",\"")! + 1, end: row.length - 1)
				}
				
			}
			data = data.subStr(start: data.indexOf(target: "}")! + 1, end: data.length - 1)
		}
		
	}
}
