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
class BlogView: UIView {
	
	//The main scroll view.
	@IBOutlet weak var scrollView: UIScrollView!
	
	//The container of the view.
	@IBOutlet var container: UIView!
	
	//Each of the sections of the view.
	@IBOutlet weak var section: Section!
	
	
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	/**
	Run when the view is started.
	*/
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		
		//Load the contents of the HomeView.xib file.
		Bundle.main.loadNibNamed("BlogView", owner: self, options: nil)
		self.addSubview(container)
		container.frame = self.bounds
		section.setTitle(text: "Blog")
		let parent = section.getContentStack()
		
		// Show posts
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "dtime", ascending: false)
		let sortDescriptors = [sortDescriptor]
		fetchRequest.sortDescriptors = sortDescriptors
		
		do {
			//go get the results
			let searchResults = try context.fetch(fetchRequest)
			
			//I like to check the size of the returned results!
			print ("Post: \(searchResults.count)")
			
			var row : RowBlog
			var count = 0
			var id: Int
			var title: String
			var text: String
			var image: String
			
			//You need to convert to NSManagedObject to use 'for' loops
			for r in searchResults as [NSManagedObject] {
				count = count + 1
				//get the Key Value pairs (although there may be a better way to do that...
				print("Perm: \(r.value(forKey: "permalink"))")
				
				
				//Create a new row
				row = RowBlog.init(s: "rowBlog\(count)", i: count)
				id = r.value(forKey: "id")! as! Int
				title = r.value(forKey: "title_\(lang)")! as! String
				text = r.value(forKey: "text_\(lang)")! as! String
				print(title)
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
						print ("IMAGE: \(image)")
						row.setImage(filename: image)
					}
				} catch {
					print("Error getting image for post \(id): \(error)")
				}
				
				print("Row height: \(row.frame.height)")
				
				parent.addArrangedSubview(row)
				
			}
		} catch {
			print("Error with request: \(error)")
		}
		
		//Always at the end: update scrollview
		var h: Int = 0
		for view in scrollView.subviews {
			//contentRect = contentRect.union(view.frame);
			h = h + Int(view.frame.height) + 30 //Why 30?
			print("Blog curh: \(h)")
		}
		// TODO: Calculate at the end
		self.scrollView.contentSize.height = 2500//CGFloat(h);
		
		// The view controller
		//var viewController: ViewController  = self.window?.rootViewController as! ViewController
		
		
		let viewController = UIApplication.topViewController() as! ViewController
		
		viewController.showPost(id: 4)
		
		
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
