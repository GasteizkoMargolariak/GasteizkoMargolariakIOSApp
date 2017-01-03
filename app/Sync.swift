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
			let dataAlbum : [String] = self.getTable(data: strData!, table: "album")
			let dataFestival : [String] = self.getTable(data: strData!, table: "festival")
			let dataFestivalDay : [String] = self.getTable(data: strData!, table: "festival_day")
			let dataFestivalEvent : [String] = self.getTable(data: strData!, table: "festival_event")
			let dataFestivalEventImage : [String] = self.getTable(data: strData!, table: "festival_event_image")
			let dataFestivalOffer : [String] = self.getTable(data: strData!, table: "festival_offer")
			let dataPeople : [String] = self.getTable(data: strData!, table: "people")
			let dataPhoto : [String] = self.getTable(data: strData!, table: "photo")
			let dataPhotoAlbum : [String] = self.getTable(data: strData!, table: "photo_album")
			let dataPhotoComment : [String] = self.getTable(data: strData!, table: "photo_comment")
			let dataPlace : [String] = self.getTable(data: strData!, table: "place")
			let dataPost : [String] = self.getTable(data: strData!, table: "post")
			let dataPostComment : [String] = self.getTable(data: strData!, table: "post_comment")
			let dataPostImage : [String] = self.getTable(data: strData!, table: "post_image")
			let dataPostTag : [String] = self.getTable(data: strData!, table: "post_tag")
			let dataSponsor : [String] = self.getTable(data: strData!, table: "sponsor")
			
			//One by one, save the received data
			//self.saveActivities(dataActivity)
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
	
}
