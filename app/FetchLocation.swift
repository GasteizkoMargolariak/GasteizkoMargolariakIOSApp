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
Class to handle Gasteizko Margolariak location updates.
*/
class FetchLocation{
	
	
	/**
	Default constructor.
	*/
	init(){
		fetch()
	}
	
	
	/**
	Fetches location reports form the server in the background.
	*/
	func fetch(){
		NSLog(":LOCATION:LOG: Fetching location...")
		
		// TODO Change for production
		//let url = URL(string: "https://margolariak.com/API/V1/location.php")
		let url = URL(string: "http://192.168.1.101/API/V3/location.php")
		
		let task = URLSession.shared.dataTask(with: url!) { data, response, error in
			if error != nil {
				NSLog(":LOCATION:ERROR: Unknown error getting location: \(error.debugDescription)")
			}
			var status = 204
			if (response != nil){
				status = (response as! HTTPURLResponse).statusCode
			}
			
			if status == 200{
			
				guard let data = data else {
					return
				}

				var strData = String(data: data, encoding: String.Encoding.utf8)
			
				// Get fields
				let lat: Double = Double(strData!.subStr(start : strData!.indexOf(target : "\"lat\":")! + 7, end : strData!.indexOf(target : ",\"")! - 2))!
			
			
				strData = strData?.subStr(start : (strData?.indexOf(target : ",\"")!)! + 1, end : (strData?.length)! - 1)
				let lon: Double = Double(strData!.subStr(start : strData!.indexOf(target : "\"lon\":")! + 7, end : strData!.indexOf(target : ",\"")! - 2))!
			
				strData = strData?.subStr(start : (strData?.indexOf(target : ",\"")!)! + 1, end : (strData?.length)! - 1)
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
				let dtime = dateFormatter.date(from : (strData?.subStr(start : (strData?.indexOf(target : "\"dtime\":")!)! + 9, end : (strData?.length)! - 4))!)!
			
				let defaults = UserDefaults.standard
				defaults.set(lat, forKey: "GMLocLat")
				defaults.set(lon, forKey: "GMLocLon")
				defaults.set(dtime, forKey: "GMLocTime")
			
				NSLog(":LOCATION:LOG: Got location at \(lat), \(lon) at \(dtime)")
			}
		}
		task.resume()
	}
}
