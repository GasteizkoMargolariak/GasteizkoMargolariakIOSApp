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
		let url = URL(string: "https://margolariak.com/API/v1/sync.php?client=com.margolariak.app")
		//TODO add parameters
		return url!
	}
	
	/**
	Performs an asynchronous sync.
	It fethes the info from the server and stores as Core Data
	:param: url The url to sync.
	*/
	func sync(url: URL){
		
		NSLog(":SYNC:LOG: Sync started.")
		
		//Synchronously get data
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			guard error == nil else {
				NSLog(":SYNC:ERROR: Unknown error.")
				return
			}
			guard let data = data else {
				NSLog(":SYNC:ERROR: Data is empty.")
				return
			}
			
			NSLog(":SYNC:LOG: Data received.")
			
			var strData = String(data:data, encoding: String.Encoding.utf8)
			
			let dataIdx = strData?.indexOf(target: "{\"data\"")
			strData = strData!.subStr(start: dataIdx!, end: strData!.length - 1)
			
			//TODO: do something with versions
			
			//Get tables
			let dataActivity : [String] = self.getTable(data: strData!, table: "activity")
			let dataActivityComment : [String] = self.getTable(data: strData!, table: "activity_comment")
			let dataActivityImage : [String] = self.getTable(data: strData!, table: "activity_image")
			let dataActivityTag : [String] = self.getTable(data: strData!, table: "activity_tag")
			let dataActivityItinerary : [String] = self.getTable(data: strData!, table: "activity_itinerary")
			let dataAlbum : [String] = self.getTable(data: strData!, table: "album")
			let dataFestival : [String] = self.getTable(data: strData!, table: "festival")
			let dataFestivalDay : [String] = self.getTable(data: strData!, table: "festival_day")
			let dataFestivalEvent : [String] = self.getTable(data: strData!, table: "festival_event")
			//let dataFestivalEventImage : [String] = self.getTable(data: strData!, table: "festival_event_image")
			let dataFestivalOffer : [String] = self.getTable(data: strData!, table: "festival_offer")
			let dataPeople : [String] = self.getTable(data: strData!, table: "people")
			let dataPhoto : [String] = self.getTable(data: strData!, table: "photo")
			let dataPhotoAlbum : [String] = self.getTable(data: strData!, table: "photo_album")
			//let dataPhotoComment : [String] = self.getTable(data: strData!, table: "photo_comment")
			let dataPlace : [String] = self.getTable(data: strData!, table: "place")
			let dataPost : [String] = self.getTable(data: strData!, table: "post")
			let dataPostComment : [String] = self.getTable(data: strData!, table: "post_comment")
			let dataPostImage : [String] = self.getTable(data: strData!, table: "post_image")
			let dataPostTag : [String] = self.getTable(data: strData!, table: "post_tag")
			let dataSponsor : [String] = self.getTable(data: strData!, table: "sponsor")
			let dataSettings: [String] = self.getTable(data: strData!, table: "settings")
			
			//One by one, save the received data
			self.saveTableActivity(entries : dataActivity)
			self.saveTableActivityComment(entries : dataActivityComment)
			self.saveTableActivityImage(entries : dataActivityImage)
			self.saveTableActivityTag(entries : dataActivityTag)
			self.saveTableActivityItinerary(entries : dataActivityItinerary)
			
			self.saveTablePost(entries: dataPost)
			self.saveTablePostComment(entries: dataPostComment)
			self.saveTablePostImage(entries: dataPostImage)
			self.saveTablePostTag(entries: dataPostTag)
			
			self.saveTablePlace(entries: dataPlace)
			self.saveTablePeople(entries: dataPeople)
			
			self.saveTableAlbum(entries: dataAlbum)
			self.saveTablePhoto(entries: dataPhoto)
			self.saveTablePhotoAlbum(entries: dataPhotoAlbum)
			
			self.saveTableFestival(entries: dataFestival)
			self.saveTableFestivalDay(entries: dataFestivalDay)
			self.saveTableFestivalOffer(entries: dataFestivalOffer)
			self.saveTableFestivalEvent(entries: dataFestivalEvent)
			
			self.saveTableSponsor(entries: dataSponsor)
			
			self.saveSettings(entries: dataSettings)
			
			
			//DEBUG: Tester, Debug only
			// Test if a entity has entries
			/*let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
			let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()  //Entity to debug
			
			do {
				//go get the results
				let searchResults = try context.fetch(fetchRequest)
				
				NSLog(":SYNC:DEBUG: Num of results = \(searchResults.count).")
				for r in searchResults as [NSManagedObject] {
					NSLog(":SYNC:DEBUG: id: \(r.value(forKey: "id")).")
				}
			} catch {
				NSLog(":SYNC:DEBUG: Error with request: \(error).")
			}*/
			//End tester
			
			// If it's the initial sync, hide the segue
			if self.initial == true{
				NSLog(":SYNC:LOG: Finishing synchronous sync.")
				let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
				delegate.controller?.initialSync(showScreen: false)
				
			}
		}
		
		task.resume()
		
	}
	
	/**
	Extracts table rows from the raw data received.
	:param: param Received data in JSON format.
	:param: table The name of the table to look for.
	:return: Array of strings containing the rows of the table, in JSON format.
	*/
	func getTable(data: String, table: String) -> [String]{
		//Does the table exists?
		if data.indexOf(target: "\"\(table)\":[") == nil{
			NSLog(":SYNC:LOG: Empty table: \(table).")
			return [String]()
		}
		let iS : Int? = data.indexOf(target: "\"\(table)\":[")
		var str = data.subStr(start: iS!, end: data.length - 1)
		let iE : Int? = str.indexOf(target: "}]}")!
		str = str.subStr(start: 0, end: iE!)
		str = str.subStr(start: table.length + 3,end: str.length - 1)
		
		//Separate the entries
		var entries : [String] = str.components(separatedBy: "},{")
		
		//Modify the first and the last one to remove bracers
		entries[0] = entries[0].subStr(start: 1, end: entries[0].length - 1)
		entries[entries.count - 1] = entries[entries.count - 1].subStr(start: 0, end: entries[entries.count - 1].length - 2)
		
		NSLog(":SYNC:LOG: Table \(table) has \(entries.count) rows.")
		
		//Return the array
		return entries
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTablePlace(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Place.")
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Place", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Places entity: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Places entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			//Get id
			var str = entry
			let id : Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get name_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_es : String = str.subStr(start : str.indexOf(target : "\"name_es\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			
			//Get name_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_en : String = str.subStr(start : str.indexOf(target : "\"name_en\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			
			//Get name_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_eu : String = str.subStr(start : str.indexOf(target : "\"name_eu\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			
			//Get address_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let address_es : String = str.subStr(start : str.indexOf(target : "\"address_es\":")! + 14, end : str.indexOf(target : ",\"")! - 2)
			
			//Get address_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let address_en : String = str.subStr(start : str.indexOf(target : "\"address_en\":")! + 14, end : str.indexOf(target : ",\"")! - 2)
			
			//Get address_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let address_eu : String = str.subStr(start : str.indexOf(target : "\"address_eu\":")! + 14, end : str.indexOf(target : ",\"")! - 2)
			
			//Get cp
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let cp : String = str.subStr(start : str.indexOf(target : "\"cp\":")! + 6, end : str.indexOf(target : ",\"")! - 2)
			
			//Get lat
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let lat : Float = Float(str.subStr(start : str.indexOf(target : "\"lat\":")! + 7, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get lon
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let lon : Float = Float(str.subStr(start : str.indexOf(target : "\"lon\":")! + 7, end : str.length - 2))!
			
			//Save CoreData
			row = NSManagedObject(entity: entity!, insertInto: context)
			row.setValue(id, forKey: "id")
			row.setValue(name_es, forKey: "name_es")
			row.setValue(name_en, forKey: "name_en")
			row.setValue(name_eu, forKey: "name_eu")
			row.setValue(address_es, forKey: "address_es")
			row.setValue(address_en, forKey: "address_en")
			row.setValue(address_eu, forKey: "address_eu")
			row.setValue(cp, forKey: "cp")
			row.setValue(lat, forKey: "lat")
			row.setValue(lon, forKey: "lon")
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Place with id \(id): \(error), \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Place with id \(id).")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTablePeople(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table People.")
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "People", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "People")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up People entity: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up People entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			row = NSManagedObject(entity: entity!, insertInto: context)
			
			//Get id
			var str = entry
			let id: Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(id, forKey: "id")
			
			//Get name_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_es: String = str.subStr(start : str.indexOf(target : "\"name_es\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_es, forKey: "name_es")
			
			//Get name_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_en: String = str.subStr(start : str.indexOf(target : "\"name_en\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_en, forKey: "name_en")
			
			//Get name_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_eu : String = str.subStr(start : str.indexOf(target : "\"name_eu\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_eu, forKey: "name_eu")
			
			//Get link
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let link : String = str.subStr(start : str.indexOf(target : "\"link\":")! + 8, end : str.length - 2)
			row.setValue(link, forKey: "link")
			
			//Save CoreData
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Place with id \(id): \(error), \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Place with id \(id).")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTablePost(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Post.")
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone.ReferenceType.local
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Post", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Post entity: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Post entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			//Get id
			var str = entry
			let id : Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get permalink
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let permalink : String = str.subStr(start : str.indexOf(target : "\"permalink\":")! + 13, end : str.indexOf(target : ",\"")! - 2)
			
			//Get title_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_es : String = str.subStr(start : str.indexOf(target : "\"title_es\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			
			//Get title_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_en : String = str.subStr(start : str.indexOf(target : "\"title_en\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			
			//Get title_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_eu : String = str.subStr(start : str.indexOf(target : "\"title_eu\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			
			//Get text_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_es : String = str.subStr(start : str.indexOf(target : "\"text_es\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			
			//Get text_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_en : String = str.subStr(start : str.indexOf(target : "\"text_en\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			
			//Get text_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_eu : String = str.subStr(start : str.indexOf(target : "\"text_eu\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			
			//Get comments
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let comments : Int = Int(str.subStr(start : str.indexOf(target : "\"comments\":")! + 12, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get username
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let username : String = str.subStr(start : str.indexOf(target : "\"username\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			
			//Get dtime
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let dtime = dateFormatter.date(from : str.subStr(start : str.indexOf(target : "\"dtime\":")! + 9, end : str.length - 2))!
			
			//Save CoreData
			row = NSManagedObject(entity: entity!, insertInto: context)
			//set the entity values
			row.setValue(id, forKey: "id")
			row.setValue(permalink, forKey: "permalink")
			row.setValue(dtime, forKey: "dtime")
			row.setValue(username, forKey: "username")
			row.setValue(comments, forKey: "comments")
			row.setValue(title_es, forKey: "title_es")
			row.setValue(title_en, forKey: "title_en")
			row.setValue(title_eu, forKey: "title_eu")
			row.setValue(text_es, forKey: "text_es")
			row.setValue(text_en, forKey: "text_en")
			row.setValue(text_eu, forKey: "text_eu")
			
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Post with id \(id): \(error), \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Post with id \(id).")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTablePostComment(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Post_comment.")
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone.ReferenceType.local
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Post_comment", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Post_comment")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Post_comment entity: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Post_comment entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			//Get id
			var str = entry
			let id : Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get activity
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let post : String = str.subStr(start : str.indexOf(target : "\"post\":")! + 8, end : str.indexOf(target : ",\"")! - 2)
			
			//Get text
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text : String = str.subStr(start : str.indexOf(target : "\"text\":")! + 8, end : str.indexOf(target : ",\"")! - 2)
			
			//Get dtime
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			dateFormatter.dateFormat = "yyyy-MM-dd"
			let dtime = dateFormatter.date(from : str.subStr(start : str.indexOf(target : "\"dtime\":")! + 9, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get username
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let username : String = str.subStr(start : str.indexOf(target : "\"username\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			
			//Get lang
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let lang : String = str.subStr(start : str.indexOf(target : "\"lang\":")! + 8, end : str.length - 1)
			
			//Save CoreData
			row = NSManagedObject(entity: entity!, insertInto: context)
			row.setValue(id, forKey: "id")
			row.setValue(post, forKey: "post")
			row.setValue(text, forKey: "text")
			row.setValue(dtime, forKey: "dtime")
			row.setValue(username, forKey: "username")
			row.setValue(lang, forKey: "lang")
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Activity_comment with id \(id): \(error), \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Activity_comment with id \(id).")
			}
			
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTablePostImage(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Post_image.")
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Post_image", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Post_image")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Post_comment entity: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Post_comment entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			//Get id
			var str = entry
			let id : Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get activity
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let post : Int = Int(str.subStr(start : str.indexOf(target : "\"post\":")! + 8, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get image
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let image : String = str.subStr(start : str.indexOf(target : "\"image\":")! + 9, end : str.indexOf(target : ",\"")! - 2)
			
			//Get idx
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let idx : Int = Int(str.subStr(start : str.indexOf(target : "\"idx\":")! + 7, end : str.length - 2))!
			
			//Save CoreData
			row = NSManagedObject(entity: entity!, insertInto: context)
			row.setValue(id, forKey: "id")
			row.setValue(post, forKey: "post")
			row.setValue(image, forKey: "image")
			row.setValue(idx, forKey: "idx")
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Post_image with id \(id): \(error), \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Post_image with id \(id).")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTablePostTag(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Post_tag.")
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Post_tag", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Post_tag")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Post_tag entity: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Post_tag entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			//Get activity
			var str = entry
			let post : Int = Int(str.subStr(start : str.indexOf(target : "\"post\":")! + 8, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get tag
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let tag : String = str.subStr(start : str.indexOf(target : "\"tag\":")! + 7, end : str.length - 1)
			
			//Save CoreData
			row = NSManagedObject(entity: entity!, insertInto: context)
			row.setValue(post, forKey: "post")
			row.setValue(tag, forKey: "tag")
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Post_tag for post: \(post), tag: \(tag): \(error), \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Post_tag for post: \(post), tag: \(tag).")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTableActivity(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Activity.")
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone.ReferenceType.local
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Activity", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Activity entity: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Activity entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			//Get id
			var str = entry
			let id : Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get permalink
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let permalink : String = str.subStr(start : str.indexOf(target : "\"permalink\":")! + 13, end : str.indexOf(target : ",\"")! - 2)
			
			//Get date
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			dateFormatter.dateFormat = "yyyy-MM-dd"
			let date = dateFormatter.date(from : str.subStr(start : str.indexOf(target : "\"date\":")! + 8, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get city
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let city : String = str.subStr(start : str.indexOf(target : "\"city\":")! + 8, end : str.indexOf(target : ",\"")! - 2)
			
			//Get title_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_es : String = str.subStr(start : str.indexOf(target : "\"title_es\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			
			//Get title_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_en : String = str.subStr(start : str.indexOf(target : "\"title_en\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			
			//Get title_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_eu : String = str.subStr(start : str.indexOf(target : "\"title_eu\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			
			//Get text_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_es : String = str.subStr(start : str.indexOf(target : "\"text_es\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			
			//Get text_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_eu : String = str.subStr(start : str.indexOf(target : "\"text_eu\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			
			//Get text_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_en : String = str.subStr(start : str.indexOf(target : "\"text_en\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			
			//Get after_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			var after_es : String = str.subStr(start : str.indexOf(target : "\"after_es\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			if (after_es == "ul"){ //From "null"
				after_es = ""
			}
			
			//Get after_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			var after_en : String = str.subStr(start : str.indexOf(target : "\"after_en\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			if (after_en == "ul"){ //From "null"
				after_en = ""
			}
			
			//Get after_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			var after_eu : String = str.subStr(start : str.indexOf(target : "\"after_eu\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			if (after_eu == "ul"){  //From "null"
				after_eu = ""
			}
			
			//Get price
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let price : Int = Int(str.subStr(start : str.indexOf(target : "\"price\":")! + 9, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get inscription
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let inscription : Int = Int(str.subStr(start : str.indexOf(target : "\"inscription\":")! + 15, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get max_people
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let maxPeoplePre : String = str.subStr(start : str.indexOf(target : "\"max_people\":")! + 14, end : str.indexOf(target : ",")! - 2)
			var maxPeople = -1
			if (maxPeoplePre != "ul"){ //From "null"
				maxPeople = Int(maxPeoplePre)!
			}
			
			//Get album
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let albumPre = str.subStr(start : str.indexOf(target : "\"album\":")! + 9, end : str.length - 2)
			var album = -1
			if (albumPre != "ul"){ //From "null"
				album = Int(albumPre)!
			}
			
			//Skipping dtime
			//Skipping comments
			
			//Save CoreData
			row = NSManagedObject(entity: entity!, insertInto: context)
			//set the entity values
			row.setValue(id, forKey: "id")
			row.setValue(permalink, forKey: "permalink")
			row.setValue(date, forKey: "date")
			row.setValue(city, forKey: "city")
			row.setValue(title_es, forKey: "title_es")
			row.setValue(title_en, forKey: "title_en")
			row.setValue(title_eu, forKey: "title_eu")
			row.setValue(text_es, forKey: "text_es")
			row.setValue(text_en, forKey: "text_en")
			row.setValue(text_eu, forKey: "text_eu")
			row.setValue(after_es, forKey: "after_es")
			row.setValue(after_en, forKey: "after_en")
			row.setValue(after_eu, forKey: "after_eu")
			row.setValue(price, forKey: "price")
			row.setValue(inscription, forKey: "inscription")
			row.setValue(maxPeople, forKey: "max_people")
			if (album != -1){
				row.setValue(album, forKey: "album")
			}
			
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Activity with id \(id): \(error), \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Activity with id \(id).")
			}
			
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTableActivityComment(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Activity_comment.")
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone.ReferenceType.local
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Activity_comment", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity_comment")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Activity_comment entity: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Activity_comment entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			//Get id
			var str = entry
			let id : Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get activity
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let activity : String = str.subStr(start : str.indexOf(target : "\"activity\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			
			//Get text
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text : String = str.subStr(start : str.indexOf(target : "\"text\":")! + 8, end : str.indexOf(target : ",\"")! - 2)
			
			//Get dtime
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			dateFormatter.dateFormat = "yyyy-MM-dd"
			let dtime = dateFormatter.date(from : str.subStr(start : str.indexOf(target : "\"dtime\":")! + 9, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get username
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let username : String = str.subStr(start : str.indexOf(target : "\"username\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			
			//Get lang
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let lang : String = str.subStr(start : str.indexOf(target : "\"lang\":")! + 8, end : str.length - 1)
			
			//Save CoreData
			row = NSManagedObject(entity: entity!, insertInto: context)
			row.setValue(id, forKey: "id")
			row.setValue(activity, forKey: "activity")
			row.setValue(text, forKey: "text")
			row.setValue(dtime, forKey: "dtime")
			row.setValue(username, forKey: "username")
			row.setValue(lang, forKey: "lang")
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Activity_comment with id \(id): \(error), \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Activity_comment with id \(id).")
			}
			
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTableActivityImage(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Activity_image.")
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Activity_image", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity_image")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Activity_comment entity: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Activity_comment entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			//Get id
			var str = entry
			let id : Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get activity
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let activity : Int = Int(str.subStr(start : str.indexOf(target : "\"activity\":")! + 12, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get image
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let image : String = str.subStr(start : str.indexOf(target : "\"image\":")! + 9, end : str.indexOf(target : ",\"")! - 2)
			
			//Get idx
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let idx : Int = Int(str.subStr(start : str.indexOf(target : "\"idx\":")! + 7, end : str.length - 2))!
			
			//Save CoreData
			row = NSManagedObject(entity: entity!, insertInto: context)
			row.setValue(id, forKey: "id")
			row.setValue(activity, forKey: "activity")
			row.setValue(image, forKey: "image")
			row.setValue(idx, forKey: "idx")
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Activity_image with id \(id): \(error), \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Activity_image with id \(id).")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTableActivityTag(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Activity_tag.")
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Activity_tag", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity_tag")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Activity_tag entity: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Activity_tag entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			//Get activity
			var str = entry
			let activity : Int = Int(str.subStr(start : str.indexOf(target : "\"activity\":")! + 12, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get tag
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let tag : String = str.subStr(start : str.indexOf(target : "\"tag\":")! + 7, end : str.length - 1)
			
			//Save CoreData
			row = NSManagedObject(entity: entity!, insertInto: context)
			row.setValue(activity, forKey: "activity")
			row.setValue(tag, forKey: "tag")
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Activity_tag for activity \(activity), tag: \(tag): Error: \(error), \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Activity_tag for activity \(activity), tag: \(tag).")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	//CHECK: New (and probably better format than the others.)
	func saveTableActivityItinerary(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Activity_itinerary.")
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone.ReferenceType.local
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Activity_itinerary", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity_itinerary")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Activity_itinerary entity: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Activity_itinerary entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			row = NSManagedObject(entity: entity!, insertInto: context)
			
			//Get id
			var str = entry
			let id : Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(id, forKey: "id")
			
			//Get activity
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let activity : Int = Int(str.subStr(start : str.indexOf(target : "\"activity\":")! + 12, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(activity, forKey: "activity")
			
			//Get name_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_es : String = str.subStr(start : str.indexOf(target : "\"name_es\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_es, forKey: "name_es")
			
			//Get name_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_en : String = str.subStr(start : str.indexOf(target : "\"name_en\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_en, forKey: "name_en")
			
			//Get name_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_eu : String = str.subStr(start : str.indexOf(target : "\"name_eu\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_eu, forKey: "name_eu")
			
			//Get description_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_es : String = str.subStr(start : str.indexOf(target : "\"description_es\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_es != "ul"){ //From "null"
				row.setValue(description_es, forKey: "description_es")
			}
			
			//Get description_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_en : String = str.subStr(start : str.indexOf(target : "\"description_en\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_en != "ul"){ //From "null"
				row.setValue(description_en, forKey: "description_en")
			}
			
			//Get description_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_eu : String = str.subStr(start : str.indexOf(target : "\"description_eu\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_eu != "ul"){ //From "null"
				row.setValue(description_eu, forKey: "description_eu")
			}
			
			//Get start
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let start = dateFormatter.date(from: str.subStr(start : str.indexOf(target : "\"start\":")! + 9, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(start, forKey: "start")

			//Get end
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let end = str.subStr(start : str.indexOf(target : "\"end\":")! + 7, end : str.indexOf(target : ",\"")! - 2)
			if (end != "ul"){ //From "null"
				row.setValue(dateFormatter.date(from: end), forKey: "end")
			}
			
			//Get place
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let place : Int = Int(str.subStr(start : str.indexOf(target : "\"place\":")! + 9, end : str.length - 2))!
			row.setValue(place, forKey: "place")
			
			//Save CoreData
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Activity_itinerary with id \(id): \(error), \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Activity_itinerary with id \(id).")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTableAlbum(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Album.")
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Album", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Album: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Album entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			row = NSManagedObject(entity: entity!, insertInto: context)
			
			//Get id
			var str = entry
			let id : Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(id, forKey: "id")
			
			//Get permalink
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let permalink : String = str.subStr(start : str.indexOf(target : "\"permalink\":")! + 13, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(permalink, forKey: "permalink")
			
			//Get title_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_es : String = str.subStr(start : str.indexOf(target : "\"title_es\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(title_es, forKey: "title_es")
			
			//Get title_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_en : String = str.subStr(start : str.indexOf(target : "\"title_en\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(title_en, forKey: "title_en")
			
			//Get title_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_eu : String = str.subStr(start : str.indexOf(target : "\"title_eu\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(title_eu, forKey: "title_eu")
			
			//Get description_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_es : String = str.subStr(start : str.indexOf(target : "\"description_es\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_es != "ul"){ //From "null"
				row.setValue(description_es, forKey: "description_es")
			}
			
			//Get description_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_en : String = str.subStr(start : str.indexOf(target : "\"description_en\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_en != "ul"){ //From "null"
				row.setValue(description_en, forKey: "description_en")
			}
			
			//Get description_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_eu : String = str.subStr(start : str.indexOf(target : "\"description_eu\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_eu != "ul"){ //From "null"
				row.setValue(description_eu, forKey: "description_eu")
			}
			
			//Get open
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let open : Int = Int(str.subStr(start : str.indexOf(target : "\"open\":")! + 8, end : str.length - 2))!
			row.setValue(open, forKey: "open")
			
			//Save CoreData
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Album with id \(id): \(error), \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Album with id \(id).")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTablePhoto(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Photo.")
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone.ReferenceType.local
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Photo", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Photo: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Photo entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			row = NSManagedObject(entity: entity!, insertInto: context)
			
			//Get id
			var str = entry
			let id : Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(id, forKey: "id")
			
			//Get file
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let file : String = str.subStr(start : str.indexOf(target : "\"file\":")! + 8, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(file, forKey: "file")
			
			//Get permalink
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let permalink : String = str.subStr(start : str.indexOf(target : "\"permalink\":")! + 13, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(permalink, forKey: "permalink")
			
			//Get title_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_es : String = str.subStr(start : str.indexOf(target : "\"title_es\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(title_es, forKey: "title_es")
			
			//Get title_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_en : String = str.subStr(start : str.indexOf(target : "\"title_en\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(title_en, forKey: "title_en")
			
			//Get title_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_eu : String = str.subStr(start : str.indexOf(target : "\"title_eu\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(title_eu, forKey: "title_eu")
			
			//Get description_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_es : String = str.subStr(start : str.indexOf(target : "\"description_es\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_es != "ul"){ //From "null"
				row.setValue(description_es, forKey: "description_es")
			}
			
			//Get description_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_en : String = str.subStr(start : str.indexOf(target : "\"description_en\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_en != "ul"){ //From "null"
				row.setValue(description_en, forKey: "description_en")
			}
			
			//Get description_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_eu : String = str.subStr(start : str.indexOf(target : "\"description_eu\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_eu != "ul"){ //From "null"
				row.setValue(description_eu, forKey: "description_eu")
			}
			
			//Get uploaded
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let uploaded = dateFormatter.date(from: str.subStr(start : str.indexOf(target : "\"uploaded\":")! + 12, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(uploaded, forKey: "uploaded")
			
			//TODO: Ignoting place
			//TODO: Ignoring width
			//TODO: Ignoring height
			//TODO: Ignoring size
			//TODO: Ignoring username
			
			//Save CoreData
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Photo with id \(id): \(error), \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Photo with id \(id).")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTablePhotoAlbum(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Photo_album.")
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone.ReferenceType.local
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Photo_album", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo_album")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Photo_album: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Photo_album entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			row = NSManagedObject(entity: entity!, insertInto: context)
			
			//Get photo
			var str = entry
			let photo : Int = Int(str.subStr(start : str.indexOf(target : "\"photo\":")! + 9, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(photo, forKey: "photo")
			
			//Get album
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let album : Int = Int(str.subStr(start : str.indexOf(target : "\"album\":")! + 9, end : str.length - 2))!
			row.setValue(album, forKey: "album")
			
			//Save CoreData
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Photo_album entry \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Photo_album entry.")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTableFestival(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Festival.")
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Festival", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Festival")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Festival: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Festival entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			row = NSManagedObject(entity: entity!, insertInto: context)
			
			//Get id
			var str = entry
			let id: Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(id, forKey: "id")
			
			//Get year
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let file: Int = Int(str.subStr(start : str.indexOf(target : "\"year\":")! + 8, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(file, forKey: "year")
			
			//Get text_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_es: String = str.subStr(start : str.indexOf(target : "\"text_es\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(text_es, forKey: "text_es")
			
			//Get text_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_en: String = str.subStr(start : str.indexOf(target : "\"text_en\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(text_en, forKey: "text_en")
			
			//Get text_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_eu: String = str.subStr(start : str.indexOf(target : "\"text_eu\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(text_eu, forKey: "text_eu")
			
			//Get summary_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let summary_es: String = str.subStr(start : str.indexOf(target : "\"summary_es\":")! + 14, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(summary_es, forKey: "summary_es")
			
			//Get summary_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let summary_en: String = str.subStr(start : str.indexOf(target : "\"summary_en\":")! + 14, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(summary_en, forKey: "summary_en")
			
			//Get summary_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let summary_eu: String = str.subStr(start : str.indexOf(target : "\"summary_eu\":")! + 14, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(summary_eu, forKey: "summary_eu")
			
			//Get img
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let img: String = str.subStr(start : str.indexOf(target : "\"img\":")! + 7, end : str.length - 2)
			row.setValue(img, forKey: "img")
			
			//Save CoreData
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Festival entry \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Festival entry.")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTableFestivalDay(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table FestivalDay.")
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone.ReferenceType.local
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Festival_day", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Festival_day")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Festival_day: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Festival_day entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			row = NSManagedObject(entity: entity!, insertInto: context)
			
			//Get id
			var str = entry
			let id: Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(id, forKey: "id")
			
			//Get date
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			dateFormatter.dateFormat = "yyyy-MM-dd"
			let date = dateFormatter.date(from: str.subStr(start : str.indexOf(target : "\"date\":")! + 8, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(date, forKey: "date")
			
			//Get name_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_es: String = str.subStr(start : str.indexOf(target : "\"name_es\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_es, forKey: "name_es")
			
			//Get name_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_en: String = str.subStr(start : str.indexOf(target : "\"name_en\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_en, forKey: "name_en")
			
			//Get name_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_eu: String = str.subStr(start : str.indexOf(target : "\"name_eu\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_eu, forKey: "name_eu")
			
			//Get price
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let price: Int = Int(str.subStr(start : str.indexOf(target : "\"price\":")! + 9, end : str.length - 2))!
			row.setValue(price, forKey: "price")
			
			//Save CoreData
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Festival_day entry \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Festival_day entry.")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTableFestivalOffer(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table FestivalOffer.")
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Festival_offer", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Festival_offer")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Festival_offer: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Festival_offer entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			row = NSManagedObject(entity: entity!, insertInto: context)
			
			// Get id
			var str = entry
			let id: Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(id, forKey: "id")
			
			// Get year
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let year: Int = Int(str.subStr(start : str.indexOf(target : "\"year\":")! + 8, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(year, forKey: "year")
			
			// Get name_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_es: String = str.subStr(start : str.indexOf(target : "\"name_es\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_es, forKey: "name_es")
			
			// Get name_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_en: String = str.subStr(start : str.indexOf(target : "\"name_en\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_en, forKey: "name_en")
			
			// Get name_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_eu: String = str.subStr(start : str.indexOf(target : "\"name_eu\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_eu, forKey: "name_eu")
			
			// Get description_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_es : String = str.subStr(start : str.indexOf(target : "\"description_es\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_es != "ul"){ //From "null"
				row.setValue(description_es, forKey: "description_es")
			}
			
			// Get description_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_en : String = str.subStr(start : str.indexOf(target : "\"description_en\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_en != "ul"){ //From "null"
				row.setValue(description_en, forKey: "description_en")
			}
			
			// Get description_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_eu : String = str.subStr(start : str.indexOf(target : "\"description_eu\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_eu != "ul"){ //From "null"
				row.setValue(description_eu, forKey: "description_eu")
			}
			
			// Get days
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let days: Int = Int(str.subStr(start : str.indexOf(target : "\"days\":")! + 8, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(days, forKey: "days")
			
			//Get price
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let price: Int = Int(str.subStr(start : str.indexOf(target : "\"price\":")! + 9, end : str.length - 2))!
			row.setValue(price, forKey: "price")
			
			//Save CoreData
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Festival_offer entry \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Festival_offer entry.")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTableFestivalEvent(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table FestivalEvent.")
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone.ReferenceType.local
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Festival_event", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Festival_event")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Festival_event: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Festival_event entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			row = NSManagedObject(entity: entity!, insertInto: context)
			
			//Get id
			var str = entry
			let id: Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(id, forKey: "id")
			
			//Get gm
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let gm: Int = Int(str.subStr(start : str.indexOf(target : "\"gm\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(gm, forKey: "gm")
			
			//Get title_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_es : String = str.subStr(start : str.indexOf(target : "\"title_es\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(title_es, forKey: "title_es")
			
			//Get title_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_en : String = str.subStr(start : str.indexOf(target : "\"title_en\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(title_en, forKey: "title_en")
			
			//Get title_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_eu : String = str.subStr(start : str.indexOf(target : "\"title_eu\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(title_eu, forKey: "title_eu")
			
			//Get description_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_es : String = str.subStr(start : str.indexOf(target : "\"description_es\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_es != "ul"){ //From "null"
				row.setValue(description_es, forKey: "description_es")
			}
			
			//Get description_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_en : String = str.subStr(start : str.indexOf(target : "\"description_en\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_en != "ul"){ //From "null"
				row.setValue(description_en, forKey: "description_en")
			}
			
			//Get description_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let description_eu : String = str.subStr(start : str.indexOf(target : "\"description_eu\":")! + 18, end : str.indexOf(target : ",\"")! - 2)
			if (description_eu != "ul"){ //From "null"
				row.setValue(description_eu, forKey: "description_eu")
			}
			
			//Get host
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let strHost: String = str.subStr(start : str.indexOf(target : "\"host\":")! + 8, end : str.indexOf(target : ",\"")! - 2)
			if (strHost != "ul"){ //From "null"
				let host: Int = Int(strHost)!
				row.setValue(host, forKey: "host")
			}
			
			//Get place
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let place: Int = Int(str.subStr(start : str.indexOf(target : "\"place\":")! + 9, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(place, forKey: "place")
			
			//Get start
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let start = dateFormatter.date(from: str.subStr(start : str.indexOf(target : "\"start\":")! + 9, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(start, forKey: "start")

			// Get day
			// Special item, not in the sync content
			dateFormatter.dateFormat = "yyyy-MM-dd"
			var day = dateFormatter.date(from: str.subStr(start : str.indexOf(target : "\"start\":")! + 9, end : str.indexOf(target : ",\"")! - 11))!
			// If on the first hours of the next day...
			let calendar = Calendar.current
			let hours = calendar.component(.hour, from: day as! Date)
			// ... the event belongs to the previous day.
			if hours < 6{
				day = Calendar.current.date(byAdding: .day, value: -1, to: day)!	
			}
			row.setValue(day, forKey: "day")

			
			//Get end
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let strEnd: String =  str.subStr(start : str.indexOf(target : "\"end\":")! + 7, end : str.length - 2)
			if (strEnd != "ul"){ //From "null"
				let end = dateFormatter.date(from: strEnd)!
				row.setValue(end, forKey: "end")
			}
			
			//Save CoreData
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Festival_event entry \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Festival_event entry.")
			}
		}
	}
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveTableSponsor(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving table Sponsor.")
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Sponsor", in: context)
		
		var row: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Sponsor")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			NSLog(":SYNC:ERROR: Could not clean up Sponsor: \(error), \(error.userInfo).")
		} catch {
			NSLog(":SYNC:ERROR: Could not clean up Sponsor entity.")
		}
		
		//Loop new entries
		for entry in entries{
			
			row = NSManagedObject(entity: entity!, insertInto: context)
			
			//Get id
			var str = entry
			let id: Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			row.setValue(id, forKey: "id")
			
			// Get name_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_es: String = str.subStr(start : str.indexOf(target : "\"name_es\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_es, forKey: "name_es")
			
			// Get name_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_en: String = str.subStr(start : str.indexOf(target : "\"name_en\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_en, forKey: "name_en")
			
			// Get name_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let name_eu: String = str.subStr(start : str.indexOf(target : "\"name_eu\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(name_eu, forKey: "name_eu")
			
			// Get text_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_es: String = str.subStr(start : str.indexOf(target : "\"text_es\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(text_es, forKey: "text_es")
			
			// Get text_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_en: String = str.subStr(start : str.indexOf(target : "\"text_en\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(text_en, forKey: "text_en")
			
			// Get text_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_eu: String = str.subStr(start : str.indexOf(target : "\"text_eu\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			row.setValue(text_eu, forKey: "text_eu")
			
			// Get image
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let image: String = str.subStr(start : str.indexOf(target : "\"image\":")! + 9, end : str.indexOf(target : ",\"")! - 2)
			if (image != "ul"){ //From "null"
				row.setValue(image, forKey: "image")
			}
			
			// Get address_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let address_es: String = str.subStr(start : str.indexOf(target : "\"address_es\":")! + 14, end : str.indexOf(target : ",\"")! - 2)
			if (address_es != "ul"){ //From "null"
				row.setValue(address_es, forKey: "address_es")
			}
			
			// Get address_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let address_en: String = str.subStr(start : str.indexOf(target : "\"address_en\":")! + 14, end : str.indexOf(target : ",\"")! - 2)
			if (address_en != "ul"){ //From "null"
				row.setValue(address_en, forKey: "address_en")
			}
			
			// Get address_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let address_eu: String = str.subStr(start : str.indexOf(target : "\"address_eu\":")! + 14, end : str.indexOf(target : ",\"")! - 2)
			if (address_eu != "ul"){ //From "null"
				row.setValue(address_eu, forKey: "address_eu")
			}
			
			//Get link
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let link: String = str.subStr(start : str.indexOf(target : "\"link\":")! + 8, end : str.indexOf(target : ",\"")! - 2)
			if (link != "ul"){ //From "null"
				row.setValue(link, forKey: "link")
			}
			
			//Get lat
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let strLat: String = str.subStr(start : str.indexOf(target : "\"lat\":")! + 7, end : str.indexOf(target : ",\"")! - 2)
			if (strLat != "ul"){ //From "null"
				let lat: Float = Float(str.subStr(start : str.indexOf(target : "\"lat\":")! + 7, end : str.indexOf(target : ",\"")! - 2))!
				row.setValue(lat, forKey: "lat")
			}
			
			//Get lon
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let strLon: String = str.subStr(start : str.indexOf(target : "\"lon\":")! + 7, end : str.length - 2)
			if (strLon != "ul"){ //From "null"
				let lon: Float = Float(str.subStr(start : str.indexOf(target : "\"lon\":")! + 7, end : str.length - 2))!
				row.setValue(lon, forKey: "lon")
			}
			
			//Save CoreData
			do {
				try context.save()
			} catch let error as NSError  {
				NSLog(":SYNC:ERROR: Could not store Sponsor entry \(error.userInfo).")
			} catch {
				NSLog(":SYNC:ERROR: Could not store Sponsor entry.")
			}
		}
	}
	
	/**
	Saves the received settings.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveSettings(entries : [String]){
		
		NSLog(":SYNC:LOG: Saving settings.")
		let defaults = UserDefaults.standard
		
		// Loop new entries
		for entry in entries{
			
			// Get setting name
			var str = entry
			let name: String = str.subStr(start : str.indexOf(target : "\"name\":")! + 8, end : str.indexOf(target : ",\"")! - 2)
			
			// Get setting value
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let value: Int = Int(str.subStr(start : str.indexOf(target : "\"value\":")! + 9, end : str.length - 2))!
			
			// Save only the needed settings
			if ["festivals", "comments", "photos"].contains(name){
				NSLog(":SYNC:LOG: Setting \(name) \(value)")
				defaults.set(value, forKey: name)
			}

		}
	}
}
