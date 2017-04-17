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
class LablancaView: UIView {

	@IBOutlet var container: UIView!			// Top container of the view.
	@IBOutlet weak var nfWindow: UIView!		// The section to show when no festivals.
	@IBOutlet weak var fWindow: UIView!			// The window to show while the festivals.
	@IBOutlet weak var fTitle: UILabel!			// The title of the year festivals.
	@IBOutlet weak var fImage: UIImageView!		// The festivals image
	@IBOutlet weak var fText: UILabel!			// The festivals description.
	@IBOutlet weak var fBtSchedule: UIButton!	// Button to show the city schedule.
	@IBOutlet weak var fBtGMSchedule: UIButton!	// Button to show the Margolari schedule
	@IBOutlet weak var fOfferList: UIStackView!	// Stack view to hold the offer list.
	@IBOutlet weak var fDayList: UIStackView!	// Stack view to hold the single days price list.
	
	
	
	// App delegate
	var delegate: AppDelegate? = nil
	
	// Section row list
	//var rows: Array<RowGallery> = []
	
	/**
	Run when the view is started.
	*/
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	/**
	Run when the view is started.
	*/
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		
		NSLog(":LABLANCA:LOG: Init lablanca section.")

		Bundle.main.loadNibNamed("LablancaView", owner: self, options: nil)
		self.addSubview(container)
		container.frame = self.bounds
		//section.setTitle(text: "Gallery")
		//let parent = section.getContentStack()
		
		// Get viewController from StoryBoard
		let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "GMViewController") as! ViewController
		
		// Read settings and show the required sections
		let defaults = UserDefaults.standard
		let festivals: Int = 1 //TODO defaults.integer(forKey: "festivals")
		
		if festivals == 1{
			showFestivals()
		}
		else{
			showNoFestivals()
		}
		
		// Show albums
		/*let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		self.delegate = appDelegate
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		let fetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "time", ascending: false)
		let sortDescriptors = [sortDescriptor]
		fetchRequest.sortDescriptors = sortDescriptors
		
		do {
			//Get the results
			let searchResults = try context.fetch(fetchRequest)
			
			var row : RowGallery
			var count = 0
			var id: Int
			var title: String
			for r in searchResults as [NSManagedObject] {
				count = count + 1
				
				//Create a new row
				row = RowGallery.init(s: "rowGallery\(count)", i: count)
				id = r.value(forKey: "id")! as! Int
				
				title = r.value(forKey: "title_\(lang)")! as! String
				row.id = id
				row.setTitle(text: title)
				
				// Get 4 random images from the album
				let imgFetchRequest: NSFetchRequest<Photo_album> = Photo_album.fetchRequest()
				// TODO Order random
				//let imgSortDescriptor = NSSortDescriptor(key: "time", ascending: true)
				//let imgSortDescriptors = [imgSortDescriptor]
				//simgFetchRequest.sortDescriptors = imgSortDescriptors
				imgFetchRequest.predicate = NSPredicate(format: "album == %i", id)
				imgFetchRequest.fetchLimit = 4
				do{
					let imgSearchResults = try context.fetch(imgFetchRequest)
					
					// Loop images
					var imageIdx = 0
					for imgR in imgSearchResults as [NSManagedObject]{
						
						let imageId = imgR.value(forKey: "photo")! as! Int
						
						// For each image, I need a new query to fetch from photo entity.
						let singleImgFetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
						singleImgFetchRequest.predicate = NSPredicate(format: "id == %i", imageId)
						singleImgFetchRequest.fetchLimit = 4
						do{
							let singleImgSearchResults = try context.fetch(singleImgFetchRequest)
							
							// Loop image
							for sImgR in singleImgSearchResults as [NSManagedObject]{
								
								let image = sImgR.value(forKey: "file")! as! String
								row.setImage(idx: imageIdx, filename: image)
							}
							imageIdx = imageIdx + 1
						}
						catch {
							NSLog(":GALLERY:ERROR: Error getting image from photo entity: \(error)")
						}
					}
				} catch {
					NSLog(":GALLERY:ERROR: Error getting image for album \(id): \(error)")
				}
				
				parent.addArrangedSubview(row)
				
				// Add to the rows array
				self.rows.append(row)
				
				
				
			}
		} catch {
			NSLog(":GALLERY:ERROR: Error with request: \(error)")
		}
		
		//Always at the end: update scrollview
		var h: Int = 0
		for view in scrollView.subviews {
			//contentRect = contentRect.union(view.frame);
			h = h + Int(view.frame.height) + 30 //Why 30?
		}
		// TODO: Calculate at the end
		self.scrollView.contentSize.height = 2500//CGFloat(h);
		
		self.setUpRowsTapRecognizers()
		NSLog(":GALLERY:LOG: Finished loading gallery section.")*/
	}
	
	func showFestivals(){
		NSLog(":LABLANCA:LOG: Showing festivals section.")
		self.nfWindow.isHidden = true
		
		// TODO: Get current year
		let year = 2016
		
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		// Get info about festivals
		let fetchRequest: NSFetchRequest<Festival> = Festival.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "year = %i", year)
		
		do {
			
			// Get info from festivals
			let searchResults = try context.fetch(fetchRequest)
			let r = searchResults[0]
			
			// Set description
			self.fText.text = r.value(forKey: "text_\(lang)") as! String?

		} catch {
			NSLog(":LABLANCA:ERROR: Error getting festivals info: \(error)")
		}
		
		// Get info about the day prices.
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		dateFormatter.locale = Locale.init(identifier: "en_GB")
		
		// First date of year
		var dateString = "\(year)-01-01"
		let sDate = dateFormatter.date(from: dateString)
		
		// Last date of year
		dateString = "\(year)-12-31"
		let eDate = dateFormatter.date(from: dateString)
		
		// Get days
		let dayFetchRequest: NSFetchRequest<Festival_day> = Festival_day.fetchRequest()
		dayFetchRequest.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", argumentArray: [sDate, eDate])
		
		do {
			
			// Get info from festivals
			let daySearchResults = try context.fetch(dayFetchRequest)
			
			for day in daySearchResults as [NSManagedObject]{
				let date: NSDate = day.value(forKey: "date")! as! NSDate
				let name: String = day.value(forKey: "name_\(lang)")! as! String
				let price: Int = day.value(forKey: "price")! as! Int
				NSLog(":LABLANCA:DEBUG: Day \(name): \(price)")
				//row.setImage(filename: image)
			}
			
		} catch {
			NSLog(":LABLANCA:ERROR: Error getting festival days info: \(error)")
		}
		
		
		
	}
	
	func showNoFestivals(){
		NSLog(":LABLANCA:LOG: Showing no festivals section.")
		self.fWindow.isHidden = true
		// Nothing else to be done.
	}
	
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
