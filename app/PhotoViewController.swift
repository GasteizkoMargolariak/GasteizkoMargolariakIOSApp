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
The view controller of the app.
*/
class PhotoViewController: UIViewController, UIGestureRecognizerDelegate {

	@IBOutlet weak var barButton: UIButton!
	@IBOutlet weak var barTitle: UILabel!
	@IBOutlet weak var photoTitle: UILabel!
	@IBOutlet weak var photoImage: UIImageView!
	@IBOutlet weak var photoDate: UILabel!
	@IBOutlet weak var btPrev: UIButton!
	@IBOutlet weak var btNext: UIButton!
	
	var albumId: Int = -1
	var photoId: Int = -1
	var photoIds: [Int] = []
	var photoIdx: Int = 0
	var passPhotoId: Int = -1
	var passAlbumId: Int = -1
	var albumTitle: String = ""
	var delegate: AppDelegate?
	
	
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
		
		// Populate photo array.
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		let fetchRequest: NSFetchRequest<Photo_album> = Photo_album.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "album = %i", albumId)
		do {
			let searchResults = try context.fetch(fetchRequest)
			
			var id: Int
			var i = 0
			
			for r in searchResults as [NSManagedObject] {
				
				id = r.value(forKey: "photo")! as! Int
				photoIds.append(id)
				if id == photoId{
					photoIdx = i
				}
				i = i + 1
			}
			
			// Get album title
			let albumFetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
			albumFetchRequest.predicate = NSPredicate(format: "id = %i", albumId)
			do {
				let results = try context.fetch(albumFetchRequest)
				let r = results[0]
				self.albumTitle = r.value(forKey: "title_\(lang)")! as! String
			}
			catch {
				NSLog(":GALLERYCONTROLLER:ERROR: Error getting album info: \(error)")
			}
			
		} catch {
			NSLog(":PHOTO:ERROR: Error getting infor from album \(albumId): \(error)")
		}
		
		// Set up buttons
		let tapRecognizerNext = UITapGestureRecognizer(target: self, action: #selector(nextPhoto(_:)))
		btNext.isUserInteractionEnabled = true
		btNext.addGestureRecognizer(tapRecognizerNext)
		let tapRecognizerPrev = UITapGestureRecognizer(target: self, action: #selector(prevPhoto(_:)))
		btPrev.isUserInteractionEnabled = true
		btPrev.addGestureRecognizer(tapRecognizerPrev)
		
		super.viewDidLoad()
		self.loadPhoto(id: photoId)
		
		// Set button action
		self.barButton.addTarget(self, action: #selector(self.back), for: .touchUpInside)
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
	Opens the next photo.
	*/
	func nextPhoto(_ sender:UITapGestureRecognizer? = nil){
		photoIdx = photoIdx + 1
		loadPhoto(id: photoIds[photoIdx])
	}
	
	
	/**
	Opens the previous photo.
	*/
	func prevPhoto(_ sender:UITapGestureRecognizer? = nil){
		photoIdx = photoIdx - 1
		loadPhoto(id: photoIds[photoIdx])
	}
	
	
	/**
	Loads a photo in the viewer.
	:param: id
	*/
	public func loadPhoto(id: Int){
		
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "id = %i", id)
		
		do {
			let searchResults = try context.fetch(fetchRequest)
			
			var sTitle: String
			var sText: String
			var image: String
			var date: NSDate
			
			for r in searchResults as [NSManagedObject] {
				
				sTitle = r.value(forKey: "title_\(lang)")! as! String
				if sTitle == "" || sTitle == "ul" {
					sTitle = self.albumTitle
				}
				self.photoTitle.text = "  \(sTitle.decode().stripHtml())"
				
				// Enable or disable buttons
				if photoIdx == 0{
					self.btPrev.isEnabled = false
					self.btPrev.alpha = 0.5
				}
				else{
					self.btPrev.isEnabled = true
					self.btPrev.alpha = 1
				}
				if photoIdx == photoIds.count - 1{
					self.btNext.isEnabled = false
					self.btNext.alpha = 0.5
				}
				else{
					self.btNext.isEnabled = true
					self.btNext.alpha = 1
				}
				
				// Get image
				image = ""
				let imgFetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
				imgFetchRequest.predicate = NSPredicate(format: "id == %i", id)
				do{
					let imgSearchResults = try context.fetch(imgFetchRequest)
					let r: NSManagedObject = imgSearchResults[0]
					image = r.value(forKey: "file")! as! String
					date = r.value(forKey: "uploaded")! as! NSDate
					let path = "img/galeria/preview/\(image)"
					// TODO: Every time, set placeholder image
					self.photoImage.setImage(localPath: path, remotePath: "https://margolariak.com/\(path)")
					self.photoDate.text = formatDate(date: date, lang: lang)
				}
				catch {
					NSLog(":PHOTO:ERROR: Error getting image for post \(id): \(error)")
				}
				
			}
		} catch {
			NSLog(":PHOTO:ERROR: Error setting up photo \(id): \(error)")
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
		let year = calendar.component(.year, from: date as Date)
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
			
			strDate = "\(days_en[weekday]), \(months_en[month]) \(dayNum), \(year)"
			break
		case "eu":
			strDate = "\(year)ko \(days_eu[weekday]) \(months_eu[month]) \(day)an"
			break
		default:
			strDate = "\(days_es[weekday]) \(day) de \(months_es[month]) de \(year)"
		}
		
		return strDate
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

