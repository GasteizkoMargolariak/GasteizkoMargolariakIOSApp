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
	
	var cnt: NSManagedObjectContext
	
	/**
	 Starts the sync process.
	*/
	init(cnt: NSManagedObjectContext){
		self.cnt = cnt
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
			//let dataActivityComment : [String] = self.getTable(data: strData!, table: "activity_comment")
			//let dataActivityImage : [String] = self.getTable(data: strData!, table: "activity_image")
			//let dataActivityTag : [String] = self.getTable(data: strData!, table: "activity_tag")
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
			
			//TEST
			let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
			let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest()
			
			do {
				//go get the results
				let searchResults = try context.fetch(fetchRequest)
				
				//I like to check the size of the returned results!
				print ("num of results = \(searchResults.count)")
				
				//You need to convert to NSManagedObject to use 'for' loops
				for trans in searchResults as [NSManagedObject] {
					//get the Key Value pairs (although there may be a better way to do that...
					print("\(trans.value(forKey: "permalink"))")
				}
			} catch {
				print("Error with request: \(error)")
			}
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
		
		//let context = self.cnt //getContext()
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Activity", in: context)
		
		var transc: NSManagedObject
		
		//Delete all previous entries
		let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
		let request = NSBatchDeleteRequest(fetchRequest: fetch)
		do {
			try context.execute(request)
		} catch let error as NSError  {
			print("Could not clean up Activity table: \(error), \(error.userInfo)")
		} catch {
			
		}
		
		//Loop new entries
		for entry in entries{
			
			//Get id
			var str = entry
			let id : Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			//print("Id: \(id)")
			
			//Get permalink
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let permalink : String = str.subStr(start : str.indexOf(target : "\"permalink\":")! + 13, end : str.indexOf(target : ",\"")! - 2)
			//print("Permalink: \(permalink)")
			
			//Get date
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			dateFormatter.dateFormat = "yyyy-MM-dd"
			let date = dateFormatter.date(from : str.subStr(start : str.indexOf(target : "\"date\":")! + 8, end : str.indexOf(target : ",\"")! - 2))!
			//print("Date: \(date)")
			
			//Get city
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let city : String = str.subStr(start : str.indexOf(target : "\"city\":")! + 8, end : str.indexOf(target : ",\"")! - 2)
			//print("City: \(city)")
			
			//Get title_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_es : String = str.subStr(start : str.indexOf(target : "\"title_es\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			//print("Title (es): \(title_es)")
			
			//Get title_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_en : String = str.subStr(start : str.indexOf(target : "\"title_en\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			//print("Title (en): \(title_en)")
			
			//Get title_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_eu : String = str.subStr(start : str.indexOf(target : "\"title_eu\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			//print("Title (eu): \(title_eu)")
			
			//Get text_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_es : String = str.subStr(start : str.indexOf(target : "\"text_es\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			//print("Text (es): \(text_es)")
			
			//Get text_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_eu : String = str.subStr(start : str.indexOf(target : "\"text_eu\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			//print("Text (eu): \(text_eu)")
			
			//Get text_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_en : String = str.subStr(start : str.indexOf(target : "\"text_en\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			//print("Text (en): \(text_en)")
			
			//Get after_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			var after_es : String = str.subStr(start : str.indexOf(target : "\"after_es\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			if (after_es == "ul"){ //From "null"
				after_es = ""
			}
			//print("After (es): \(after_es)")
			
			//Get after_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			var after_en : String = str.subStr(start : str.indexOf(target : "\"after_en\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			if (after_en == "ul"){ //From "null"
				after_en = ""
			}
			//print("After (en): \(after_en)")
			
			//Get after_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			var after_eu : String = str.subStr(start : str.indexOf(target : "\"after_eu\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			if (after_eu == "ul"){  //From "null"
				after_eu = ""
			}
			//print("After (eu): \(after_eu)")
			
			//Get price
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let price : Int = Int(str.subStr(start : str.indexOf(target : "\"price\":")! + 9, end : str.indexOf(target : ",\"")! - 2))!
			//print("Price: \(price)")
			
			//Get inscription
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let inscription : Int = Int(str.subStr(start : str.indexOf(target : "\"inscription\":")! + 15, end : str.indexOf(target : ",\"")! - 2))!
			//print("Inscription: \(inscription)")
			
			//Get max_people
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let maxPeople : Int = Int(str.subStr(start : str.indexOf(target : "\"max_people\":")! + 14, end : str.indexOf(target : ",\"")! - 2))!
			//print("Max People: \(maxPeople)")
			
			//Get album
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let albumPre = str.subStr(start : str.indexOf(target : "\"album\":")! + 9, end : str.length - 2)
			var album = -1
			if (albumPre != "ul"){ //From "null"
				album = Int(albumPre)!
			}
			//print("Album: \(album)")
			
			//Skipping dtime
			//Skipping comments
			
			//TODO: Save CoreData
			transc = NSManagedObject(entity: entity!, insertInto: context)
			//set the entity values
			transc.setValue(id, forKey: "id")
			transc.setValue(permalink, forKey: "permalink")
			transc.setValue(date, forKey: "date")
			transc.setValue(city, forKey: "city")
			transc.setValue(title_es, forKey: "title_es")
			transc.setValue(title_en, forKey: "title_en")
			transc.setValue(title_eu, forKey: "title_eu")
			transc.setValue(text_es, forKey: "text_es")
			transc.setValue(text_en, forKey: "text_en")
			transc.setValue(text_eu, forKey: "text_eu")
			transc.setValue(after_es, forKey: "after_es")
			transc.setValue(after_en, forKey: "after_en")
			transc.setValue(after_eu, forKey: "after_eu")
			transc.setValue(price, forKey: "price")
			transc.setValue(inscription, forKey: "inscription")
			transc.setValue(maxPeople, forKey: "max_people")
			if (album != -1){
				transc.setValue(album, forKey: "album")
			}

			do {
				try context.save()
			} catch let error as NSError  {
				print("Could not store Activity with id \(id) \(error), \(error.userInfo)")
			} catch {
				
			}

		}
	}
}
