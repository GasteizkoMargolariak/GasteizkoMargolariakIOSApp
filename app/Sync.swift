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
	
	/**
	 Starts the sync process.
	*/
	init(){
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
		
		//Synchronously get data
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			guard error == nil else {
				print("error")
				return
			}
			guard let data = data else {
				print("Data is empty")
				return
			}
			
			print("Got the Sync JSON")
			
			var strData = String(data:data, encoding: String.Encoding.utf8)
			
			let dataIdx = strData?.indexOf(target: "{\"data\"")
			strData = strData!.subStr(start: dataIdx!, end: strData!.length - 1)
			
			//TODO: do something with versions
			
			//Get tables
			let dataActivity : [String] = self.getTable(data: strData!, table: "activity")
			let dataActivityComment : [String] = self.getTable(data: strData!, table: "activity_comment")
			let dataActivityImage : [String] = self.getTable(data: strData!, table: "activity_image")
			let dataActivityTag : [String] = self.getTable(data: strData!, table: "activity_tag")
			//let dataAlbum : [String] = self.getTable(data: strData!, table: "album")
			//let dataFestival : [String] = self.getTable(data: strData!, table: "festival")
			//let dataFestivalDay : [String] = self.getTable(data: strData!, table: "festival_day")
			//let dataFestivalEvent : [String] = self.getTable(data: strData!, table: "festival_event")
			//let dataFestivalEventImage : [String] = self.getTable(data: strData!, table: "festival_event_image")
			//let dataFestivalOffer : [String] = self.getTable(data: strData!, table: "festival_offer")
			//let dataPeople : [String] = self.getTable(data: strData!, table: "people")
			//let dataPhoto : [String] = self.getTable(data: strData!, table: "photo")
			//let dataPhotoAlbum : [String] = self.getTable(data: strData!, table: "photo_album")
			//let dataPhotoComment : [String] = self.getTable(data: strData!, table: "photo_comment")
			//let dataPlace : [String] = self.getTable(data: strData!, table: "place")
			//let dataPost : [String] = self.getTable(data: strData!, table: "post")
			//let dataPostComment : [String] = self.getTable(data: strData!, table: "post_comment")
			//let dataPostImage : [String] = self.getTable(data: strData!, table: "post_image")
			//let dataPostTag : [String] = self.getTable(data: strData!, table: "post_tag")
			//let dataSponsor : [String] = self.getTable(data: strData!, table: "sponsor")
			
			//One by one, save the received data
			self.saveTableActivity(entries : dataActivity)
			self.saveTableActivityComment(entries : dataActivityComment)
			self.saveTableActivityImage(entries : dataActivityImage)
			self.saveTableActivityTag(entries : dataActivityTag)
			
			//TODO: Tester, Debug only
			// Test if a entity has entries
			let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
			let fetchRequest: NSFetchRequest<Activity_comment> = Activity_comment.fetchRequest()
			
			do {
				//go get the results
				let searchResults = try context.fetch(fetchRequest)
				
				//I like to check the size of the returned results!
				print ("num of results = \(searchResults.count)")
				
				//You need to convert to NSManagedObject to use 'for' loops
				for trans in searchResults as [NSManagedObject] {
					//get the Key Value pairs (although there may be a better way to do that...
					print("\(trans.value(forKey: "id"))")
				}
			} catch {
				print("Error with request: \(error)")
			}
			//End tester
		}
		
		task.resume()

	}
	
	func getTable(data: String, table: String) -> [String]{
			//Does the table exists?
			if data.indexOf(target: table) == nil{
				print("No data in table \(table)")
				return [String]()
			}
			let iS : Int? = data.indexOf(target: table)
			var str = data.subStr(start: iS!, end: data.length - 1)
			let iE : Int? = str.indexOf(target: "}]}")!
			str = str.subStr(start: 0, end: iE!)
			str = str.subStr(start: table.length + 3,end: str.length - 1)
		
			//Separate the entries
			var entries : [String] = str.components(separatedBy: "},{")
		
			//Modify the first and the last one to remove bracers
			entries[0] = entries[0].subStr(start: 1, end: entries[0].length - 1)
			entries[entries.count - 1] = entries[entries.count - 1].subStr(start: 0, end: entries[entries.count - 1].length - 2)
		
			//Return the array
			return entries
	}
	
	func saveTableActivity(entries : [String]){
		
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
			print("Could not clean up Activity entity: \(error), \(error.userInfo)")
		} catch {
			
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
			//print("Price: \(price)")
			
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
				print("Could not store Activity with id \(id) \(error), \(error.userInfo)")
			} catch {
				
			}

		}
	}
	
	func saveTableActivityComment(entries : [String]){
		
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
			print("Could not clean up Activity_comment entity: \(error), \(error.userInfo)")
		} catch {
			
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
				print("Could not store Activity_comment with id \(id) \(error), \(error.userInfo)")
			} catch {
				
			}
			
		}
	}
	
	func saveTableActivityImage(entries : [String]){
		
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
			print("Could not clean up Activity_comment entity: \(error), \(error.userInfo)")
		} catch {
			
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
				print("Could not store Activity_image with id \(id) \(error), \(error.userInfo)")
			} catch {
				
			}
		}
	}
	
	func saveTableActivityTag(entries : [String]){
		
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
			print("Could not clean up Activity_tag entity: \(error), \(error.userInfo)")
		} catch {
			
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
				print("Could not store Activity_tag for activity: \(activity), tag: \(tag). Error: \(error), \(error.userInfo)")
			} catch {
				
			}
		}
	}
}
