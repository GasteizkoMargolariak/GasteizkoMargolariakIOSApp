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
class ActivitiesView: UIView {
	
	@IBOutlet var container: ActivitiesView!
	@IBOutlet weak var futureSection: Section!
	@IBOutlet weak var pastSection: Section!

	var delegate: AppDelegate? = nil
	
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	/**
	Run when the view is started.
	*/
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		
		NSLog(":ACTIVITIES:DEBUG: init.")
		
		//Load the contents of the HomeView.xib file.
		Bundle.main.loadNibNamed("ActivitiesView", owner: self, options: nil)
		self.addSubview(container)
		container.frame = self.bounds
		futureSection.setTitle(text: "Próximas actividades")
		pastSection.setTitle(text: "Últimas actividades")
		let futureParent = futureSection.getContentStack()
		let pastParent = pastSection.getContentStack()
		
		// Get viewController from StoryBoard
		let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "GMViewController") as! ViewController
		
		
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		self.delegate = appDelegate
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		// Show future activities
		var fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest()
		var sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
		var sortDescriptors = [sortDescriptor]
		fetchRequest.sortDescriptors = sortDescriptors
		fetchRequest.predicate = NSPredicate(format: "date > %@", NSDate())
		
		do {
			let searchResults = try context.fetch(fetchRequest)
			NSLog(":ACTIVITIES:DEBUG: Total future activities: \(searchResults.count)")
			if searchResults.count == 0{
				NSLog(":ACTIVITIES:DEBUG: No future activities: \(searchResults.count)")
				let row: RowLabel = RowLabel.init(s: "rowFutureActivity0", i: 0)
				row.setText(text: "No hay actividades planeadas proximamente. Pronto organizaremos algo!")
				futureParent.addArrangedSubview(row)
			}
			else{

			
				var row : RowFutureActivity
				var count = 0
				var id: Int
				var title: String
				var text: String
				var image: String
				var city: String
				var price: Int
				var date: NSDate
			
				for r in searchResults as [NSManagedObject] {
					count = count + 1
					NSLog(":ACTIVITIES:DEBUG: Activity perm: \(r.value(forKey: "permalink"))")
				
					// Create a new row
					row = RowFutureActivity.init(s: "rowFutureActivity\(count)", i: count)
					id = r.value(forKey: "id")! as! Int
					title = r.value(forKey: "title_\(lang)")! as! String
					text = r.value(forKey: "text_\(lang)")! as! String
					city = r.value(forKey: "city")! as! String
					price = r.value(forKey: "price")! as! Int
					date = r.value(forKey: "date")! as! NSDate
					row.setTitle(text: title)
					row.setText(text: text)
					row.setPrice(price: price)
					row.setCity(text: city)
					row.setDate(date: date, lang: lang)
				
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
							NSLog(":ACTIVITIES:DEBUG: Image: \(image)")
							row.setImage(filename: image)
						}
					} catch {
						NSLog(":ACTIVITIES:ERROR: Error getting image for activity \(id): \(error)")
					}
				
					futureParent.addArrangedSubview(row)
					row.setNeedsLayout()
					row.layoutIfNeeded()
				
					// TODO: Do this on the row didLoad method
					// Set tap recognizer
					//let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(openActivity(_:)))
					//row.isUserInteractionEnabled = true
					//row.addGestureRecognizer(tapRecognizer)
				
				
				
				}
			}
		} catch {
			NSLog(":ACTIVITIES:ERROR: Error with request: \(error)")
		}
		
		
		
		// Show past activities
		fetchRequest = Activity.fetchRequest()
		sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
		sortDescriptors = [sortDescriptor]
		fetchRequest.sortDescriptors = sortDescriptors
		fetchRequest.predicate = NSPredicate(format: "date < %@", NSDate())
		
		do {
			let searchResults = try context.fetch(fetchRequest)
			NSLog(":ACTIVITIES:DEBUG: Total past activities: \(searchResults.count)")
			
			var row : RowPastActivity
			var count = 0
			var id: Int
			var title: String
			var text: String
			var image: String
			
			for r in searchResults as [NSManagedObject] {
				count = count + 1
				NSLog(":ACTIVITIES:DEBUG: Activity perm: \(r.value(forKey: "permalink"))")
				
				// Create a new row
				row = RowPastActivity.init(s: "rowPastActivity\(count)", i: count)
				id = r.value(forKey: "id")! as! Int
				title = r.value(forKey: "title_\(lang)")! as! String
				text = r.value(forKey: "text_\(lang)")! as! String
				row.setTitle(text: title)
				row.setText(text: text)
				
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
						NSLog(":ACTIVITIES:DEBUG: Image: \(image)")
						row.setImage(filename: image)
					}
				} catch {
					NSLog(":ACTIVITIES:ERROR: Error getting image for activity \(id): \(error)")
				}
				
				NSLog(":ACTIVITIES:DEBUG: Row height: \(row.frame.height)")
				
				pastParent.addArrangedSubview(row)
				row.setNeedsLayout()
				row.layoutIfNeeded()
				
				// TODO: Do this on the row didLoad method
				// Set tap recognizer
				//let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(openActivity(_:)))
				//row.isUserInteractionEnabled = true
				//row.addGestureRecognizer(tapRecognizer)
				
				
				
			}
		} catch {
			NSLog(":ACTIVITIES:ERROR: Error with request: \(error)")
		}
		NSLog(":ACTIVITIES:DEBUG: Finished loading ActivitiesView")
	}
	
	/*func openActivity(){//(_ sender:UITapGestureRecognizer? = nil){
		NSLog(":ACTIVITIES:DEBUG: getting delegate and showing activity.")
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showActivity(id: 4)
		NSLog(":ACTIVITIES:DEBUG: Activity should be shown.")
	}
	
	func openActivity(_ sender:UITapGestureRecognizer? = nil){
		NSLog(":ACTIVITIES:DEBUG: getting delegate and showing activity.")
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showActivity(id: 4)
		NSLog(":ACTIVITIES:DEBUG: Activity should be shown.")
	}*/
	
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
