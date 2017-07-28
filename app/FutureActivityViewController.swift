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
Controller to show a future activity.
*/
class FutureActivityViewController: UIViewController, UIGestureRecognizerDelegate {
	
	@IBOutlet weak var barButton: UIButton!
	@IBOutlet weak var barTitle: UILabel!
	@IBOutlet weak var activityTitle: UILabel!
	@IBOutlet weak var activityImage: UIImageView!
	@IBOutlet weak var activityText: UILabel!
	@IBOutlet weak var activityDate: UILabel!
	@IBOutlet weak var itineraryContainer: UIView!
	@IBOutlet weak var itineraryList: UIStackView!
	@IBOutlet weak var activityPrice: UILabel!
	
	// Activity id
	var id: Int = -1
	
	var delegate: AppDelegate?
	
	var passId: Int = -1
	
	
	/**
	Get the app context.
	:return: The app context.
	*/
	func getContext () -> NSManagedObjectContext {
		return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
	}
	
	
	/**
	Run when the app loads.
	*/
	override func viewDidLoad() {
		super.viewDidLoad()
		self.loadActivity(id: id)
		// Set button action
		barButton.addTarget(self, action: #selector(self.back), for: .touchUpInside)
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
	Loads the selected post.
	:param: id Post id.
	*/
	public func loadActivity(id: Int){
		
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		appDelegate.futureActivityController = self
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "id = %i", id)
		
		do {
			let searchResults = try context.fetch(fetchRequest)
			var count = 0
			var sTitle: String
			var sText: String
			var image: String
			var date: NSDate
			var price: Int
			
			for r in searchResults as [NSManagedObject] {
				count = count + 1
				sTitle = r.value(forKey: "title_\(lang)")! as! String
				sText = r.value(forKey: "text_\(lang)")! as! String
				date = r.value(forKey: "date")! as! NSDate
				price = r.value(forKey: "price")! as! Int
				activityTitle.text = "  \(sTitle.decode().stripHtml())"
				activityText.text = sText.decode().stripHtml()
				activityDate.text = formatDate(date: date, lang: lang)
				activityPrice.text = "Precio: \(price) €"
				
				// Get main image
				image = ""
				let imgFetchRequest: NSFetchRequest<Activity_image> = Activity_image.fetchRequest()
				let imgSortDescriptor = NSSortDescriptor(key: "idx", ascending: true)
				let imgSortDescriptors = [imgSortDescriptor]
				imgFetchRequest.sortDescriptors = imgSortDescriptors
				imgFetchRequest.predicate = NSPredicate(format: "activity == %i", id)
				imgFetchRequest.fetchLimit = 1
				do{
					let imgSearchResults = try context.fetch(imgFetchRequest)
					for imgR in imgSearchResults as [NSManagedObject]{
						image = imgR.value(forKey: "image")! as! String
						let path = "img/actividades/preview/\(image)"
						self.activityImage.setImage(localPath: path, remotePath: "https://margolariak.com/\(path)")
					}
				}
				catch {
					NSLog(":FUTUREACTIVITYCONTROLLER:ERROR: Error getting image for past activity \(id): \(error)")
				}
				
				// Get itinerary
				let itiFetchRequest: NSFetchRequest<Activity_itinerary> = Activity_itinerary.fetchRequest()
				let itiSortDescriptor = NSSortDescriptor(key: "start", ascending: true)
				let itiSortDescriptors = [itiSortDescriptor]
				itiFetchRequest.sortDescriptors = itiSortDescriptors
				itiFetchRequest.predicate = NSPredicate(format: "activity == %i", id)
				do {
					let itiSearchResults = try context.fetch(itiFetchRequest)
					if itiSearchResults.count == 0{
						self.itineraryContainer.isHidden = true
					}
					else{
					
						var row: RowItinerary
						var count = 0
						var itiId: Int
						var itiTitle: String
						var itiText: String
						var itiPlace: Int
						var itiStart: NSDate
						var place: [String]
					
						for r in itiSearchResults {
							count = count + 1
						
							// Create a new row
							row = RowItinerary.init(s: "rowItinerary\(count)", i: count)
							itiId = r.value(forKey: "id")! as! Int
							itiTitle = r.value(forKey: "name_\(lang)")! as! String
							if r.value(forKey: "description_\(lang)") != nil{
								itiText = r.value(forKey: "description_\(lang)")! as! String
							}
							else{
								itiText = ""
							}
							itiStart = r.value(forKey: "start")! as! NSDate
							itiPlace = r.value(forKey: "place")! as! Int
							place = getPlace(place: itiPlace, lang: lang, context: context)
														
							row.setTitle(text: itiTitle)
							row.setText(text: itiText)
							row.setStart(str: formatTime(date: itiStart))
							row.setPlace(place: place[0], address: place[1])
							row.id = id
						
							self.itineraryList?.addArrangedSubview(row)
						}
						self.itineraryList?.setNeedsLayout()
						self.itineraryList?.layoutIfNeeded()
						
					}
				}
				catch {
					NSLog(":FUTUREACTIVITY:ERROR: Error getting itinerary: \(error)")
				}
			}
		} catch {
			NSLog(":FUTUREACTIVITYCONTROLLER:ERROR: Error loading past activity: \(error)")
		}
	}
	
	
	/**
	Formats a date to the desired language.
	:param: text The date.
	:param: lang Device language (only 'es', 'en', or 'eu').
	*/
	func formatDate(date: NSDate, lang: String) -> String{
		
		let months_es = ["0index", "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"]
		let months_en = ["0index", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
		let months_eu = ["0index", "urtarrilaren", "otsailaren", "martxoaren", "abrilaren", "maiatzaren", "ekainaren", "ustailaren", "abustuaren", "irailaren", "urriaren", "azaroaren", "abenduaren"]
		let days_es = ["0index", "Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sábado", "Domingo"]
		let days_en = ["0index", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
		let days_eu = ["0index", "Astelehena", "Asteartea", "Asteazkena", "Osteguna", "Ostirala", "Larumbata", "Igandea"]
		
		let calendar = Calendar.current
		let day = calendar.component(.day, from: date as Date)
		let month = calendar.component(.month, from: date as Date)
		let weekday = calendar.component(.weekday, from: date as Date)
		var strDate = ""
		
		switch lang{
		case "en":
			
			var dayNum = ""
			switch day{
			case 1:
				dayNum = "1th"
				break
			case 2:
				dayNum = "2nd"
				break;
			case 3:
				dayNum = "3rd"
				break;
			default:
				dayNum = "\(weekday)th"
			}
			
			strDate = "\(days_en[weekday]), \(months_en[month]) \(dayNum)"
			break
		case "eu":
			strDate = "\(days_eu[weekday]) \(months_eu[month]) \(day)an"
			break
		default:
			strDate = "\(days_es[weekday]) \(day) de \(months_es[month])"
		}
		
		return strDate
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
	func getPlace(place: Int, lang: String, context: NSManagedObjectContext) -> [String]{
		var placeName = ""
		var placeAddress = ""
		let fetchRequest: NSFetchRequest<Place> = Place.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "id = %i", place)
		do {
			let searchResults = try context.fetch(fetchRequest)
			let r: NSManagedObject = searchResults[0]
			placeName = r.value(forKey: "name_\(lang)")! as! String
			placeAddress = r.value(forKey: "address_\(lang)")! as! String
		}
		catch{
			NSLog(":FUTUREACTIVITY:ERROR: Error getting infor about place \(place): \(error)")
		}
		return [placeName, placeAddress]
	}
	
	
	/**
	Shows an itinerary dialog.
	:param: id The itinerary id.
	*/
	func showItinerary(id: Int){
		self.passId = id
		// TODO
		NSLog(":FUTUREACTIVITY:TODO: Implement segue")
		//performSegue(withIdentifier: "SegueItinerary", sender: nil)
	}
	
	
	/**
	Run before performing a segue.
	Assigns id if neccessary.
	:param: segue The segue to perform.
	:sender: The calling view.
	*/
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "SegueItinerary"{
			(segue.destination as! EventController).id = passId
		}
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

