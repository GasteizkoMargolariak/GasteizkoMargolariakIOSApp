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
	@IBOutlet weak var locationSection: Section!
	@IBOutlet weak var lablancaSection: Section!
	@IBOutlet weak var futureActivitiesSection: Section!
	@IBOutlet weak var blogSection: Section!
	@IBOutlet weak var gallerySection: Section!
	@IBOutlet weak var pastActivitiesSection: Section!
	@IBOutlet weak var socialSection: Section!

	var lang: String? = nil
	var moc: NSManagedObjectContext? = nil
	var appDelegate: AppDelegate? = nil
	
	
	/**
	Run when the view is started.
	:param: frame Frame for the view.
	*/
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	
	/**
	Run when the view is started.
	:param: coder Application decoder.
	*/
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		
		// Load the contents of the HomeView.xib file.
		Bundle.main.loadNibNamed("HomeView", owner: self, options: nil)
		self.addSubview(container)
		container.frame = self.bounds
		

		// Set titles for each section
		locationSection.setTitle(text: "Encuentranos")
		lablancaSection.setTitle(text: "La Blanca")
		futureActivitiesSection.setTitle(text: "Proximas actividades")
		blogSection.setTitle(text: "Ultimos posts")
		gallerySection.setTitle(text: "Ultimas fotos")
		pastActivitiesSection.setTitle(text: "Ultimas actividades")
		socialSection.setTitle(text: "Siguenos")
		
		// Get info to populate sections
		self.moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		self.appDelegate = UIApplication.shared.delegate as! AppDelegate
		self.moc?.persistentStoreCoordinator = appDelegate?.persistentStoreCoordinator
		self.lang = getLanguage()
		
		// Populate sections
		self.populate()
		
		
		//Always at the end: update scrollview
		//var h: Int = 0
		//for view in scrollView.subviews {
		//	//contentRect = contentRect.union(view.frame);
		//	h = h + Int(view.frame.height) + 30 //Why 30?
		//	print("curh: \(h)")
		//}
		// TODO: Calculate at the end
		//self.scrollView.contentSize.height = 1300// CGFloat(h);
	}

	
	/**
	Triggers a reloading (or initial loading) of all sections.
	*/
	func populate(){
		
		NSLog(":HOME:DEBUG: Populating home view.")
		
		//Populate sections
		self.setUpPastActivities(context: self.moc!, delegate: appDelegate!, lang: self.lang!, parent: self.pastActivitiesSection.getContentStack())
		self.setUpBlog(context: self.moc!, delegate: self.appDelegate!, lang: self.lang!, parent: self.blogSection.getContentStack())
		self.setUpFutureActivities(context: self.moc!, delegate: self.appDelegate!, lang: self.lang!, parent: self.futureActivitiesSection.getContentStack())
		self.setUpSocial(parent: self.socialSection.getContentStack())
		self.setUpGallery(context: self.moc!, delegate: self.appDelegate!, parent: self.gallerySection.getContentStack())
		self.pastActivitiesSection.expandSection()
	}
	
	
	/**
	Retrieves the device language. The only available ones are Spanish, English and Basque.
	:return: Two letter language code (en, eu, es). If other, spanish will be selected.
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
	Sets the future activities section.
	Loads up to two future activities.
	:param: context Aplication context.
	:param: delegate Application delegate.
	:param: lang Device language. Two letter code. Accepts 'es', 'en' and 'eu'.
	:param: parent View where the rows will be loaded.
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
			NSLog(":HOME:DEBUG: Future activity count: \(searchResults.count)")
			
			var row : RowHomePastActivities
			var count = 0
			var id: Int
			var title: String
			var text: String
			var image: String
			
			for r in searchResults as [NSManagedObject] {
				count = count + 1
				
				//Create a new row
				row = RowHomePastActivities.init(s: "rowHomeFutureActivities\(count)", i: count)
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
						row.setImage(filename: image)
					}
				} catch {
					NSLog(":HOME:ERROR: Error getting image for futureactivity \(id): \(error)")
				}
				parent.addArrangedSubview(row)
				
			}
		} catch {
			NSLog(":HOME:ERROR: Error setting the future activities section up: \(error)")
		}
	}
	
	
	/**
	Sets the blog section.
	Loads up to two posts.
	:param: context Aplication context.
	:param: delegate Application delegate.
	:param: lang Device language. Two letter code. Accepts 'es', 'en' and 'eu'.
	:param: parent View where the rows will be loaded.
	*/
	func setUpBlog(context : NSManagedObjectContext, delegate: AppDelegate, lang: String, parent : UIStackView){
		
		let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "dtime", ascending: false)
		let sortDescriptors = [sortDescriptor]
		fetchRequest.sortDescriptors = sortDescriptors
		fetchRequest.fetchLimit = 2
		
		do {
			let searchResults = try context.fetch(fetchRequest)
			NSLog(":HOME:DEBUG: Post count: \(searchResults.count)")
			
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
		} catch {
			NSLog(":HOME:ERROR: Error setting the blog section up: \(error)")
		}
	}
	
	
	/**
	Sets the past activities section.
	Loads up to two past activities.
	:param: context Aplication context.
	:param: delegate Application delegate.
	:param: lang Device language. Two letter code. Accepts 'es', 'en' and 'eu'.
	:param: parent View where the rows will be loaded.
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
			NSLog(":HOME:LOG: Setting past activities up. Count: \(searchResults.count)")
			
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
				} catch {
					NSLog(":HOME:ERROR: Error getting image for past activity \(id): \(error)")
				}
				
				parent.addArrangedSubview(row)
				
			}
		} catch {
			NSLog(":HOME:ERROR: Error setting the past activities section up: \(error)")
		}
	}
	
	/**
	Sets the fgallery section.
	Loads up to four photos.
	:param: context Aplication context.
	:param: delegate Application delegate.
	:param: parent View where the rows will be loaded.
	*/
	func setUpGallery(context : NSManagedObjectContext, delegate: AppDelegate,parent: UIStackView){
		NSLog(":HOME:LOG: Setting gallery section up.")
		
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
			var image: String
			
			// Loop images
			var i = 0
			for r in searchResults as [NSManagedObject] {
				
				image = r.value(forKey: "file")! as! String
				row.setImage(idx: i, filename: image)
				
				//TODO Set click listener
				
				i = i + 1
			}
			
		}
		catch{
			NSLog(":HOME:ERROR: Error setting gallery up: \(error)")
		}
		
	}
	
	/**
	Sets the social section.
	:param: parent View where the rows will be loaded.
	*/
	func setUpSocial(parent : UIStackView){
		NSLog(":HOME:LOG: Setting soceial section up.")
		//Create a new row
		var row : RowHomeSocial
		row = RowHomeSocial.init(s: "rowHomeSocial", i: 0)
		parent.addArrangedSubview(row)
	}
	
	/**
	opens the blog section, showing a post.
	:param: sender: View calling the function.
	*/
	func openPost(_ sender:UITapGestureRecognizer? = nil){
		NSLog(":HOME:DEBUG: Getting delegate and showing post.")
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showPost(id: (sender?.view as! RowHomeBlog).id)
		NSLog(":HOME:DEBUG: Post should be shown.")
	}
}
