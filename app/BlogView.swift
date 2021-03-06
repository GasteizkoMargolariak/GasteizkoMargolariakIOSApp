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
Class to handle the blog view.
*/
class BlogView: UIView {
	
	
	// Outlets
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet var container: UIView!
	@IBOutlet weak var section: Section!
	
	var delegate: AppDelegate? = nil
	var postList: UIStackView? = nil
	var storyboard: UIStoryboard? = nil
	var controller: ViewController? = nil
	var context: NSManagedObjectContext? = nil;
	var lang: String? = nil
	

	/**
	Default constructor for the interface builder.
	*/
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	
	/**
	Run when the view is started.
	*/
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		
		// Load the contents of the HomeView.xib file.
		Bundle.main.loadNibNamed("BlogView", owner: self, options: nil)
		self.addSubview(self.container)
		self.container.frame = self.bounds
		self.section.setTitle(text: "Blog")
		self.postList = self.section.getContentStack()
		
		// Get viewController from StoryBoard
		self.storyboard = UIStoryboard(name: "Main", bundle: nil)
		self.controller = storyboard?.instantiateViewController(withIdentifier: "GMViewController") as! ViewController
		self.context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		self.delegate = UIApplication.shared.delegate as? AppDelegate
		self.lang = getLanguage()
		self.context?.persistentStoreCoordinator = delegate?.persistentStoreCoordinator
		
		populate()
	}
	
	
	/**
	Actually populates the section.
	*/
	func populate(){
		let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "dtime", ascending: false)
		let sortDescriptors = [sortDescriptor]
		fetchRequest.sortDescriptors = sortDescriptors
		
		do {
			// Clear the list
			for v in (self.postList?.subviews)!{
				v.removeFromSuperview()
			}
			
			// Get the results
			let searchResults = try self.context?.fetch(fetchRequest)
			
			var count: Int = 0
			var row : RowBlog
			var id: Int
			var title: String
			var text: String
			var image: String
			
			for r in searchResults! {
								
				//Create a new row
				row = RowBlog.init(s: "rowBlog\(count)", i: count)
				id = r.value(forKey: "id")! as! Int
				title = r.value(forKey: "title_\(lang!)")! as! String
				text = r.value(forKey: "text_\(lang!)")! as! String
				row.setTitle(text: title)
				row.setText(text: text)
				row.id = id
				
				// Get main image
				image = ""
				let imgFetchRequest: NSFetchRequest<Post_image> = Post_image.fetchRequest()
				let imgSortDescriptor = NSSortDescriptor(key: "idx", ascending: true)
				let imgSortDescriptors = [imgSortDescriptor]
				imgFetchRequest.sortDescriptors = imgSortDescriptors
				imgFetchRequest.predicate = NSPredicate(format: "post == %i", id)
				imgFetchRequest.fetchLimit = 1
				do{
					let imgSearchResults = try context?.fetch(imgFetchRequest)
					for imgR in imgSearchResults!{
						image = imgR.value(forKey: "image")! as! String
						row.setImage(filename: image)
					}
				} catch {
					NSLog(":BLOG:ERROR: Error getting image for post \(id): \(error)")
				}
				
				
				self.postList?.addArrangedSubview(row)
				count = count + 1
			}

			// Trigger a layout update
			postList?.setNeedsLayout()
			postList?.layoutIfNeeded()

		} catch {
			NSLog(":BLOG:ERROR: Error with request: \(error)")
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
