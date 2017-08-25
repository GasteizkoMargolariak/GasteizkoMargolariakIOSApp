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
import MapKit

/**
The view controller of the app.
*/
class EventController: UIViewController, UIGestureRecognizerDelegate {

	@IBOutlet weak var eventTitle: UITextView!
	@IBOutlet weak var eventText: UILabel!
	@IBOutlet weak var eventTime: UILabel!
	@IBOutlet weak var eventLocation: UILabel!
	@IBOutlet weak var eventMap: MKMapView!
	@IBOutlet weak var btClose: UIButton!
	@IBOutlet weak var eventAddress: UILabel!
	
	var id: Int = -1
	var passId: Int = -1
	var delegate: AppDelegate?
	
	
	/**
	Gets the application context.
	:return: The application context.
	*/
	func getContext () -> NSManagedObjectContext {
		return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
	}
	
	
	/**
	Run when the app loads. Sets everything up.
	*/
	override func viewDidLoad() {
		
		//let mapTemplate: String = "http://tile.openstreetmap.org/{z}/{x}/{y}.png";
		//let mapOverlay: MKTileOverlay = MKTileOverlay.initWithURLTemplate(mapTemplate)
		//overlay.canReplaceMapContent = YES
		//self.eventMap addOverlay(overlay level:MKOverlayLevelAboveLabels];         // (4)
		
		// TODO: Pas this
		let margolari: Bool = true
		
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		if (margolari == true){
			
			let fetchRequest: NSFetchRequest<Festival_event_gm> = Festival_event_gm.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "id = %i", id)
			do {
				// Get the result
				let searchResults = try context.fetch(fetchRequest)
			
				var name: String = ""
				var text: String = ""
				var start: NSDate
				var placeId: Int = -1
				var place: [Any]
				var placeName: String = ""
				var placeAddress: String = ""
				var lat: Double = 0.0
				var lon: Double = 0.0
				if searchResults.count > 0{
					let r = searchResults[0]
				
					name = r.value(forKey: "title_\(lang)")! as! String
					if r.value(forKey: "description_\(lang)") != nil{
						text = r.value(forKey: "description_\(lang)")! as! String
					}
					start = r.value(forKey: "start")! as! NSDate
					placeId = r.value(forKey: "place")! as! Int
					place = getPlace(place: placeId, lang: getLanguage(), context: context)
					placeName = place[0] as! String
					placeAddress = place[1] as! String
					lat = place[2] as! Double
					lon = place[3] as! Double
				
					// Set labels
					eventTitle.text = " \(name.decode().stripHtml())"
					if text.length > 0{
						eventText.text = " \(text.decode().stripHtml())"
					}
					else{
						self.eventText.isHidden = true
					}
					self.eventTime.text = formatTime(date: start)
					self.eventLocation.text = placeName.decode().stripHtml()
					if placeAddress.length == 0 || placeAddress == placeName{
						self.eventAddress.isHidden = true
					}
					else{
						self.eventAddress.text = placeAddress.decode().stripHtml()
					}
				}
				
				// Set up map
				let template = "http://tile.openstreetmap.org/{z}/{x}/{y}.png"
				let carte_indice = MKTileOverlay(urlTemplate:template)
				carte_indice.isGeometryFlipped = true
				carte_indice.canReplaceMapContent = false
				self.eventMap.add(carte_indice)
				
				// Set marker
				let annotation = MKPointAnnotation()
				annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
				self.eventMap.addAnnotation(annotation)
				
				
				// Center map
				let center = CLLocation(latitude: lat, longitude: lon)
				let radius: CLLocationDistance = 1000
				let coordinateRegion = MKCoordinateRegionMakeWithDistance(center.coordinate,
				                                                          radius, radius)
				self.eventMap.setRegion(coordinateRegion, animated: true)
				
			}
			catch {
				NSLog(":EVENT:ERROR: Error getting info from event \(id): \(error)")
			}
		} // if margolari == true
		
		super.viewDidLoad()
		
		// Set button action
		self.btClose.addTarget(self, action: #selector(self.back), for: .touchUpInside)
	}
	
	
	/**
	Dismisses the controller.
	*/
	func back() {
		self.dismiss(animated: true, completion: nil)
	}
	
	
	/**
	Dispose of any resources that can be recreated.
	*/
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	/**
	Extracts the time from a date to a string.
	:param: text The date.
	:return: Time, in string format.
	*/
	func formatTime(date: NSDate) -> String{

		let calendar = Calendar.current
		let hour: Int = calendar.component(.hour, from: date as Date)
		let minute: Int = calendar.component(.minute, from: date as Date)
		
		var strTime = ""
		if minute <= 9{
			strTime = "\(hour):0\(minute)"
		}
		else{
			strTime = "\(hour):\(minute)"
		}
		
		return strTime
	}
	
	
	/**
	Gets info about a place in the device language.
	:param: place Place id.
	:param: lang Device language (only 'es', 'en', or 'eu').
	:param: context Application context.
	:return: String array. 0-index item contains the place name. The 1-index one contains the address.
	*/
	func getPlace(place: Int, lang: String, context: NSManagedObjectContext) -> [Any]{
		var placeName: String = ""
		var placeAddress: String = ""
		var lat: Double = 0.0
		var lon: Double = 0.0
		let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "id = %i", place)
		do {
			let searchResults = try context.fetch(fetchRequest)
			if (searchResults.count > 0){
				let r: NSManagedObject = searchResults[0]
				placeName = r.value(forKey: "name_\(lang)")! as! String
				placeAddress = r.value(forKey: "address_\(lang)")! as! String
				lat = r.value(forKey: "lat")! as! Double
				lon = r.value(forKey: "lon")! as! Double
			}
			else{
				placeName = " "
				placeAddress =  " "
				lat = 42.8507807
				lon = -2.8394378
			}
		}
		catch{
			NSLog(":FUTUREACTIVITY:ERROR: Error getting infor about place \(place): \(error)")
		}
		return [placeName, placeAddress, lat, lon]
	}
	
	
	func eventMapV(eventMap: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer!
	{
		
		if overlay is MKTileOverlay
		{
			var renderer = MKTileOverlayRenderer(overlay:overlay)
			
			renderer.alpha = 0.8
			
			return renderer
		}
		return nil
	}
	
	
	/**
	Gets the device language. The only recognized languages are Spanish, English and Basque.
	If the device has another language, Spanish will be selected by default.
	:return: Two-letter language code.
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

