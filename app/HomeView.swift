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
 Class to handle the home view.
 */
class HomeView: UIView {
	
	// Outlets
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var locationMessage: UILabel!
	@IBOutlet weak var lablancaImage: UIImageView!
	@IBOutlet weak var lablancaText: UILabel!
	
	//Each of the sections of the view.
	@IBOutlet weak var locationSection: UIView!
	@IBOutlet weak var lablancaSection: Section!
	@IBOutlet weak var futureActivitiesSection: Section!
	@IBOutlet weak var blogSection: Section!
	@IBOutlet weak var gallerySection: Section!
	@IBOutlet weak var pastActivitiesSection: Section!
	@IBOutlet weak var socialSection: Section!
	
	var moc: NSManagedObjectContext? = nil
	var delegate: AppDelegate? = nil
	var lang: String? = nil
	var locationTimer: Timer? = nil
	var controller: ViewController
	var storyboard: UIStoryboard
	
	
	/**
	Default constructor for the storyboard.
	:param: frame View frame.
	*/
	override init(frame: CGRect){
		self.storyboard = UIStoryboard(name: "Main", bundle: nil)
		self.controller = storyboard.instantiateViewController(withIdentifier: "GMViewController") as! ViewController
		super.init(frame: frame)
		
	}
	
	
	/**
	 Run when the view is started.
	*/
	required init?(coder aDecoder: NSCoder) {
		
		self.storyboard = UIStoryboard(name: "Main", bundle: nil)
		self.controller = storyboard.instantiateViewController(withIdentifier: "GMViewController") as! ViewController
		super.init(coder: aDecoder)
		
		//Load the contents of the HomeView.xib file.
		Bundle.main.loadNibNamed("HomeView", owner: self, options: nil)
		self.addSubview(container)
		container.frame = self.bounds
		
		//Set titles for each section
		futureActivitiesSection.setTitle(text: "Próximas actividades")
		blogSection.setTitle(text: "Últimos posts")
		gallerySection.setTitle(text: "Últimas fotos")
		pastActivitiesSection.setTitle(text: "Últimas actividades")
		socialSection.setTitle(text: "Síguenos")
		
		//Get info to populate sections
		self.moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		
		self.delegate = UIApplication.shared.delegate as! AppDelegate
		self.moc?.persistentStoreCoordinator = self.delegate?.persistentStoreCoordinator
		self.lang = getLanguage()
		
		
		// Populate section.
		populate()
		
		
		// Special case: Location
		// Set up once and start and periodically witha  timer.
		setUpLocation()
		Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(setUpLocation), userInfo: nil, repeats: true)
	}
	
	
	/**
	Sets all the sections up
	*/
	func populate(){
	
		//Populate sections
		setUpPastActivities(context: self.moc!, delegate: self.delegate!, lang: self.lang!, parent: self.pastActivitiesSection.getContentStack())
		setUpBlog(context: self.moc!, delegate: self.delegate!, lang: self.lang!, parent: self.blogSection.getContentStack())
		setUpFutureActivities(context: self.moc!, delegate: self.delegate!, lang: self.lang!, parent: self.futureActivitiesSection.getContentStack())
		setUpSocial(parent: self.socialSection.getContentStack())
		setUpGallery(context: self.moc!, delegate: self.delegate!, parent: self.gallerySection.getContentStack())
		setUpLablanca(context: self.moc!, delegate: self.delegate!, lang: self.lang!)
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
	
	
	/**
	Sets up the location section.
	If no location is reported, it hiddes the section.
	*/
	func setUpLocation(){
		// TODO: Also set up tap recognizer.
		let defaults = UserDefaults.standard
		if (defaults.value(forKey: "GMLocLat") != nil && defaults.value(forKey: "GMLocLon") != nil){
			let lat = defaults.value(forKey: "GMLocLat") as! Double
			let lon = defaults.value(forKey: "GMLocLon") as! Double
			let time = defaults.value(forKey: "GMLocTime") as! Date
			let cTime = Date()
			let minutes = Calendar.current.dateComponents([.minute], from: time, to: cTime).minute
			if (minutes! < 30){
				self.locationSection.isHidden = false
				
				// Set tap recognizer.
				let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (HomeView.openLocation (_:)))
				tapRecognizer.delegate = (UIApplication.shared.delegate as! AppDelegate).controller
				self.locationSection.addGestureRecognizer(tapRecognizer)
				
				let location = self.controller.getLocation()
				if location != nil {
					let d: Int = calculateDistance(lat1: location.latitude, lon1: location.longitude, lat2: lat, lon2: lon)
					
					if d <= 1000 {
						self.locationMessage.text = "¡Gasteizko Margolariak está por ahí! A \(d) metros de ti."
					}
					else{
						self.locationMessage.text = "¡Gasteizko Margolariak está por ahí! A \(Int(d/1000)) kilómetros de ti."
					}
				}
				else{
					self.locationMessage.text = "¡Gasteizko Margolariak está por ahí!"
				}
			}
			else{
				self.locationSection.isHidden = true
			}
		}
		else{
			self.locationSection.isHidden = true
		}
	}
	
	
	/**
	Sets up the La Blanca secction.
	Hiddes it if no current festivals.
	:param: context App context.
	:param: delegate App delegate.
	:param: lang Language code (two letter code, lowercase. Only 'es', 'en' and 'eu' supported).
	*/
	func setUpLablanca(context : NSManagedObjectContext, delegate: AppDelegate, lang: String){
		
		let defaults = UserDefaults.standard
		if (defaults.value(forKey: "festivals") != nil){
			let festivals = defaults.value(forKey: "festivals") as! Int
			if festivals == 1{
				
				// Set tap recognizer
				let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (HomeView.openLablanca (_:)))
				tapRecognizer.delegate = (UIApplication.shared.delegate as! AppDelegate).controller
				self.lablancaSection.addGestureRecognizer(tapRecognizer)
				
				// TODO: Get current year
				let year = 2017
				
				// Get info about festivals
				let fetchRequest: NSFetchRequest<Festival> = Festival.fetchRequest()
				fetchRequest.predicate = NSPredicate(format: "year = %i", year)
				
				do {
					
					// Get info from festivals
					let searchResults = try context.fetch(fetchRequest)
					
					if searchResults.count > 0 {
						let r = searchResults[0]
						
						// Set image and text
						self.lablancaText.text = (r.value(forKey: "text_\(lang)") as! String?)?.decode().stripHtml()
						let filename: String = r.value(forKey: "img") as! String
						if (filename == ""){
							// Hide the imageview
							self.lablancaImage.isHidden = true;
						}
						else{
							let path = "img/blog/thumb/\(filename)"
							self.lablancaImage.setImage(localPath: path, remotePath: "https://margolariak.com/\(path)")
						}
					}
					
				}
				catch {
					NSLog(":LABLANCA:ERROR: Error getting festivals info: \(error)")
				}
			}
			else{
				self.lablancaSection.isHidden = true
			}
		}
	}
	
	
	/**
	Sets up the future activities section.
	If none, it hiddes the section.
	:param: context App context.
	:param: delegate App delegate.
	:param: lang Language code (two letter code, lowercase. Only 'es', 'en' and 'eu' supported).
	:param: parent Stack view to load the rows in.
	*/
	func setUpFutureActivities(context : NSManagedObjectContext, delegate: AppDelegate, lang: String, parent : UIStackView){
		let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
		let sortDescriptors = [sortDescriptor]
		fetchRequest.sortDescriptors = sortDescriptors
		fetchRequest.predicate = NSPredicate(format: "date > %@", NSDate())
		fetchRequest.fetchLimit = 2
		
		do {
			let searchResults = try context.fetch(fetchRequest)
			
			var row : RowHomeFutureActivities
			var count = 0
			var id: Int
			var title: String
			var text: String
			var image: String
			
			if searchResults.count == 0{
				self.futureActivitiesSection.isHidden = true
			}
			else{
				for r in searchResults as [NSManagedObject] {
					count = count + 1
				
					//Create a new row
					row = RowHomeFutureActivities.init(s: "rowHomeFutureActivities\(count)", i: count)
					id = r.value(forKey: "id")! as! Int
					title = r.value(forKey: "title_\(lang)")! as! String
					text = r.value(forKey: "text_\(lang)")! as! String
					row.setTitle(text: title)
					row.setText(text: text)
					row.id = id
				
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
							row.setImage(filename: image)
						}
					}
					catch {
						NSLog(":HOME:ERROR: Error getting image for activity \(id): \(error)")
					}
				
					parent.addArrangedSubview(row)
				}
			}
		}
		catch {
			NSLog(":HOME:ERROR: Error loading future activities: \(error)")
		}
	}
	
	
	/**
	Sets up the blog section.
	:param: context App context.
	:param: delegate App delegate.
	:param: lang Language code (two letter code, lowercase. Only 'es', 'en' and 'eu' supported).
	:param: parent Stack view to load the rows in.
	*/
	func setUpBlog(context : NSManagedObjectContext, delegate: AppDelegate, lang: String, parent : UIStackView){
		
		let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "dtime", ascending: false)
		let sortDescriptors = [sortDescriptor]
		fetchRequest.sortDescriptors = sortDescriptors
		fetchRequest.fetchLimit = 2
		
		do {
			let searchResults = try context.fetch(fetchRequest)
			var row : RowHomeBlog
			var count = 0
			var id: Int
			var title: String
			var text: String
			var image: String
			
			for r in searchResults as [NSManagedObject] {
				count = count + 1
				
				//Create a new row
				row = RowHomeBlog.init(s: "rowHomeBlog\(count)", i: count)
				id = r.value(forKey: "id")! as! Int
				title = r.value(forKey: "title_\(lang)")! as! String
				text = r.value(forKey: "text_\(lang)")! as! String
				
				row.id = id
				row.setTitle(text: title)
				row.setText(text: text)
				
				// Get main image
				image = ""
				let imgFetchRequest: NSFetchRequest<Post_image> = Post_image.fetchRequest()
				let imgSortDescriptor = NSSortDescriptor(key: "idx", ascending: true)
				let imgSortDescriptors = [imgSortDescriptor]
				imgFetchRequest.sortDescriptors = imgSortDescriptors
				imgFetchRequest.predicate = NSPredicate(format: "post == %i", id)
				imgFetchRequest.fetchLimit = 1
				do{
					let imgSearchResults = try context.fetch(imgFetchRequest)
					for imgR in imgSearchResults as [NSManagedObject]{
						image = imgR.value(forKey: "image")! as! String
						row.setImage(filename: image)
					}
				} catch {
					NSLog(":HOME:ERROR: Error getting image for post \(id): \(error)")
				}
				
				parent.addArrangedSubview(row)
				
				let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(openPost(_:)))
				row.isUserInteractionEnabled = true
				row.addGestureRecognizer(tapRecognizer)
				
			}
		}
		catch {
			NSLog(":HOME:ERROR: Error loading the blog section: \(error)")
		}
	}
	
	
	/**
	Sets up the past activities section.
	:param: context App context.
	:param: delegate App delegate.
	:param: lang Language code (two letter code, lowercase. Only 'es', 'en' and 'eu' supported).
	:param: parent Stack view to load the rows in.
	*/
	func setUpPastActivities(context : NSManagedObjectContext, delegate: AppDelegate, lang: String, parent : UIStackView){
		
		let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
		let sortDescriptors = [sortDescriptor]
		fetchRequest.sortDescriptors = sortDescriptors
		fetchRequest.predicate = NSPredicate(format: "date <= %@", NSDate())
		fetchRequest.fetchLimit = 2
		
		do {
			let searchResults = try context.fetch(fetchRequest)
			
			var row : RowHomePastActivities
			var count = 0
			var id: Int
			var title: String
			var text: String
			var image: String
			
			for r in searchResults as [NSManagedObject] {
				count = count + 1
				
				//Create a new row
				row = RowHomePastActivities.init(s: "rowHomePastActivities\(count)", i: count)
				id = r.value(forKey: "id")! as! Int
				title = r.value(forKey: "title_\(lang)")! as! String
				text = r.value(forKey: "text_\(lang)")! as! String
				
				row.setTitle(text: title)
				row.setText(text: text)
				row.id = id
				
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
						row.setImage(filename: image)
					}
				}
				catch {
					NSLog(":HOME:ERROR: Error getting image for past activity \(id): \(error)")
				}
				parent.addArrangedSubview(row)
				
			}
		} catch {
			NSLog(":HOME:ERROR: Error loading past activities: \(error)")
		}
	}
	
	
	/**
	Sets up the future activities section.
	:param: context App context.
	:param: delegate App delegate.
	:param: parent Stack view to load the rows in.
	*/
	func setUpGallery(context : NSManagedObjectContext, delegate: AppDelegate,parent: UIStackView){
		
		// Create the row
		var row: RowHomeGallery
		row = RowHomeGallery.init(s: "rowHomeGallery", i: 0)
		parent.addArrangedSubview(row)
		
		// Set images
		let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "uploaded", ascending: false)
		let sortDescriptors = [sortDescriptor]
		fetchRequest.sortDescriptors = sortDescriptors
		fetchRequest.fetchLimit = 4
		
		do {
			let searchResults = try context.fetch(fetchRequest)
	
			var id: Int
			var image: String
			var i = 0
			for r in searchResults as [NSManagedObject] {
				
				image = r.value(forKey: "file")! as! String
				row.setImage(idx: i, filename: image)
				NSLog(":HOME:DEBUG: Photo \(i)")
				
				//TODO Set click listener
				i = i + 1
			}
		}
		catch{
			NSLog(":HOME:ERROR: Error setting gallery up: \(error)")
		}
	}
	
	
	/**
	Sets up the social section.
	:param: parent Stack view to load the rows in.
	*/
	func setUpSocial(parent : UIStackView){
		//Create a new row
		var row : RowHomeSocial
		row = RowHomeSocial.init(s: "rowHomeSocial", i: 0)
		parent.addArrangedSubview(row)
	}
	
	
	/**
	Converts degrees to radians.
	:params: degrees Angle in degrees.
	:return: Angle in radians.
	*/
	func degreesToRadians(degrees: Double) -> Double {
		return degrees * Double.pi / 180;
	}
	
	
	/**
	Calculates the distance between two coordinates.
	:param: lat1 Latitude of the first coordinate.
	:param: lon1 Longitude of the first coordinate.
	:param: lat2 Latitude of the second coordinate.
	:param: lon2 Longitude of the second coordinate.
	:return: Distance between the points, in meters.
	*/
	func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Int {
		let eRadius: Double = 6371
		
		let dLat: Double = degreesToRadians(degrees: lat2-lat1)
		let dLon: Double = degreesToRadians(degrees: lon2-lon1)
		
		let l1: Double = degreesToRadians(degrees: lat1)
		let l2: Double = degreesToRadians(degrees: lat2)
		
		let a: Double = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(l1) * cos(l2)
		let c: Double = 2 * atan2(sqrt(a), sqrt(1-a))
		let m: Double = eRadius * c * 1000
		return Int(m)
	}
	
	
	/**
	Opens a post.
	*/
	func openPost(_ sender:UITapGestureRecognizer? = nil){
		NSLog(":HOME:DEBUG: Getting delegate and showing post.")
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showPost(id: (sender?.view as! RowHomeBlog).id)
	}
	
	
	/**
	Opens the La Blanca section when tapping the section.
	*/
	func openLablanca(_ sender:UITapGestureRecognizer? = nil){
		NSLog(":HOME:DEBUG: Getting delegate opening the La Blanca section.")
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showComponent(selected: 2)
	}
	
	
	/**
	Opens the Location section when tapping the section.
	*/
	func openLocation(_ sender:UITapGestureRecognizer? = nil){
		NSLog(":HOME:DEBUG: Getting delegate opening the location section.")
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showComponent(selected: 1)
	}
}
