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
import UserNotifications


/**
Class to fetch notifications from the server.
*/
class Notifications{
	
	/**
	Starts the sync process.
	Always asynchronously.
	*/
	init(){
		let url = buildUrl();
		notification(url: url)
	}
	
	
	/**
	Builds the URL to perform the sync against.
	:returns: The URL.
	*/
	func buildUrl() -> URL{
		
		let url = URL(string: "https://margolariak.com/API/v1/notifications.php")
		return url!
	}
	
	
	/**
	Performs an asynchronous request.
	It fetches the info from the server and stores as Core Data
	:param: url The url to sync.
	*/
	func notification(url: URL){
		
		NSLog(":NOTIFICATION:LOG: Notification fetch started.")
		
		//Synchronously get data
		let task = URLSession.shared.dataTask(with: url) { data, response, error in
			guard error == nil else {
				NSLog(":NOTIFICATION:ERROR: Unknown error.")
				return
			}
			guard let data = data else {
				NSLog(":NOTIFICATION:ERROR: Data is empty.")
				return
			}
			
			let strData: String = String(data:data, encoding: String.Encoding.utf8)!
			if strData.length > 0{
				NSLog(":NOTIFICATION:LOG: Notifications received.")
				let dataNotification: [String] = self.getData(data: strData)
				self.saveNotifications(entries: dataNotification)
			}
			
		}
		
		task.resume()
	}
	
	
	/**
	Extracts notifications from the raw data received.
	:param: param Received data in JSON format.
	:return: Array of strings containing the notifications.
	*/
	func getData(data: String) -> [String]{
		
		//Separate the entries
		var entries : [String] = data.components(separatedBy: "},{")
		
		//Modify the first and the last one to remove bracers
		entries[0] = entries[0].subStr(start: 1, end: entries[0].length - 1)
		entries[entries.count - 1] = entries[entries.count - 1].subStr(start: 0, end: entries[entries.count - 1].length - 2)
		
		
		//Return the array
		return entries
	}
	
	
	/**
	Saves the data in the table.
	:param: entries Array of strings containing the rows of the table, in JSON format.
	*/
	func saveNotifications(entries : [String]){
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone.ReferenceType.local
		
		//Set up context
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		let entity =  NSEntityDescription.entity(forEntityName: "Notification", in: context)
		
		var row: NSManagedObject
		
		//Loop new entries
		for entry in entries{
			
			//Get id
			var str = entry
			let id: Int = Int(str.subStr(start : str.indexOf(target : "\"id\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get title_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_es: String = str.subStr(start : str.indexOf(target : "\"title_es\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			
			//Get title_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_en: String = str.subStr(start : str.indexOf(target : "\"title_en\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			
			//Get title_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let title_eu: String = str.subStr(start : str.indexOf(target : "\"title_eu\":")! + 12, end : str.indexOf(target : ",\"")! - 2)
			
			//Get text_es
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_es: String = str.subStr(start : str.indexOf(target : "\"text_es\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			
			//Get text_en
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_en: String = str.subStr(start : str.indexOf(target : "\"text_en\":")! + 11, end : str.indexOf(target : ",\"")! - 2)
			
			//Get text_eu
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let text_eu: String = str.subStr(start : str.indexOf(target : "\"text_eu\":")! + 11, end: str.indexOf(target : ",\"")! - 2)
			
			//Get dtime
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
			let dtime = dateFormatter.date(from : str.subStr(start : str.indexOf(target : "\"dtime\":")! + 9, end : str.indexOf(target : ",\"")! - 2))!
			
			//Get GM
			str = str.subStr(start : str.indexOf(target : ",\"")! + 1, end : str.length - 1)
			let gm: Int = Int(str.subStr(start : str.indexOf(target : "\"gm\":")! + 6, end : str.indexOf(target : ",\"")! - 2))!
			
			// Not getting seen
			
			// Save & show
			let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "id == %i", id)
			fetchRequest.fetchLimit = 1
			do{
				let searchResults = try context.fetch(fetchRequest)
				if (searchResults.count == 0){
					row = NSManagedObject(entity: entity!, insertInto: context)
					row.setValue(id, forKey: "id")
					row.setValue(title_es, forKey: "title_es")
					row.setValue(title_en, forKey: "title_en")
					row.setValue(title_eu, forKey: "title_eu")
					row.setValue(text_es, forKey: "text_es")
					row.setValue(text_en, forKey: "text_en")
					row.setValue(text_eu, forKey: "text_eu")
					row.setValue(dtime, forKey: "dtime")
					row.setValue(gm, forKey: "gm")
					do {
						try context.save()
						
						if #available(iOS 10.0, *) {
							let content = UNMutableNotificationContent()
							
							let lang = getLanguage()
							switch lang{
								case "en":
									content.title = title_en
									content.body = text_en
									break;
								case "eu":
									content.title = title_eu
									content.body = text_eu
									break;
								default:
									content.title = title_es
									content.body = text_es
							}
							content.sound = UNNotificationSound.default()
							let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
							let request = UNNotificationRequest.init(identifier: "Not\(id)", content: content, trigger: trigger)
							
							// Schedule the notification.
							let center = UNUserNotificationCenter.current()
							center.add(request) {
								(error) in
								NSLog(":NOTIFICATION:ERROR: Error showing notification \(String(describing: error))")
							}
						}
						else {
							NSLog(":NOTIFICATION:ERROR: Can't send notifications in iOS versions lower than 10. Not showing notification \(id)")
						}
						
					}
					catch let error as NSError  {
						NSLog(":NOTIFICATION:ERROR: Could not save notification with id \(id): \(error), \(error.userInfo).")
					}
					catch {
						NSLog(":NOTIFICATION:ERROR: Could not save notification with id \(id).")
					}
				}
			}
			catch {
				NSLog(":NOTIFICATION:ERROR: Error getting notifications: \(error)")
			}
		}
	}

	/**
	Gets the device language. The only recognized languages are Spanish, English and Basque.
	If the device has another language, Spanish will be selected by default.
	:return: Two-letter language code.}
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
