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
	
	//Each of the sections of the view.
	@IBOutlet weak var locationSection: Section!
	@IBOutlet weak var lablancaSection: Section!
	@IBOutlet weak var futureActivitiesSection: Section!
	@IBOutlet weak var blogSection: Section!
	@IBOutlet weak var gallerySection: Section!
	@IBOutlet weak var pastActivitiesSection: Section!
	@IBOutlet weak var socialSection: Section!
	
	var moc: NSManagedObjectContext? = nil
	var delegate: AppDelegate? = nil
	var lang: String? = nil
	
	override init(frame: CGRect){
		super.init(frame: frame)
		
	}
	
	/**
	 Run when the view is started.
	*/
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		
		//Load the contents of the HomeView.xib file.
		Bundle.main.loadNibNamed("HomeView", owner: self, options: nil)
		self.addSubview(container)
		container.frame = self.bounds
		

		
		//Set titles for each section
		locationSection.setTitle(text: "Encuentranos")
		lablancaSection.setTitle(text: "La Blanca")
		futureActivitiesSection.setTitle(text: "Proximas actividades")
		blogSection.setTitle(text: "Ultimos posts")
		gallerySection.setTitle(text: "Ultimas fotos")
		pastActivitiesSection.setTitle(text: "Ultimas actividades")
		socialSection.setTitle(text: "Siguenos")
		
		//Get info to populate sections
		self.moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		
		self.delegate = UIApplication.shared.delegate as! AppDelegate
		self.moc?.persistentStoreCoordinator = self.delegate?.persistentStoreCoordinator
		self.lang = getLanguage()
		
		populate()
		
		/*//Always at the end: update scrollview
		var h: Int = 0
		for view in scrollView.subviews {

			//contentRect = contentRect.union(view.frame);
			h = h + Int(view.frame.height) + 30 //Why 30?

		}
		// TODO: Calculate at the end
		self.scrollView.contentSize.height = 1300// CGFloat(h);*/
	}
	
	func populate(){
	
		//Populate sections
		setUpPastActivities(context: self.moc!, delegate: self.delegate!, lang: self.lang!, parent: self.pastActivitiesSection.getContentStack())
		setUpBlog(context: self.moc!, delegate: self.delegate!, lang: self.lang!, parent: self.blogSection.getContentStack())
		setUpFutureActivities(context: self.moc!, delegate: self.delegate!, lang: self.lang!, parent: self.futureActivitiesSection.getContentStack())
		setUpSocial(parent: self.socialSection.getContentStack())
		setUpGallery(context: self.moc!, delegate: self.delegate!, parent: self.gallerySection.getContentStack())
		
		
		//pastActivitiesSection.expandSection()

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
	Sets up the future activities section.
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
		} catch {
			NSLog(":HOME:ERROR: Error loading future activities: \(error)")
		}
	}
	
	
	/**
	Sets up the blog section.
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
	Opens a post.
	*/
	func openPost(_ sender:UITapGestureRecognizer? = nil){
		NSLog(":HOME:DEBUG: Getting delegate and showing post.")
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showPost(id: (sender?.view as! RowHomeBlog).id)
	}
}
