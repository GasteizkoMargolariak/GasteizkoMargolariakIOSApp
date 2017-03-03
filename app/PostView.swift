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
Class to handle the post view.
*/
class PostView: UIView {
	
	//The main scroll view.
	@IBOutlet weak var scrollView: UIScrollView!
	
	@IBOutlet weak var title: UILabel!
	
	@IBOutlet weak var image: UIImageView!
	
	@IBOutlet weak var text: UILabel!
	
	@IBOutlet weak var imageExtra: UIStackView!
	
	@IBOutlet weak var date: UILabel!
	
	@IBOutlet weak var commentCount: UILabel!
	
	@IBOutlet weak var commentList: UIStackView!
	
	@IBOutlet weak var commentUser: UITextField!
	
	@IBOutlet weak var commentContent: UITextView!
	
	
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
		//self.addSubview(container)
		//container.frame = self.bounds
		
		
	}
	
	func loadPost(id : Int){
	
		// Show posts
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "post == %i", id)
		
		do {
			//go get the results
			let searchResults = try context.fetch(fetchRequest)
			
			//I like to check the size of the returned results!
			print ("Post: \(searchResults.count)")
			
			var count = 0
			var sTitle: String
			var sText: String
			var image: String
			
			//You need to convert to NSManagedObject to use 'for' loops
			for r in searchResults as [NSManagedObject] {
				count = count + 1
				//get the Key Value pairs (although there may be a better way to do that...
				print("Perm: \(r.value(forKey: "permalink"))")
				
				
				sTitle = r.value(forKey: "title_\(lang)")! as! String
				sText = r.value(forKey: "text_\(lang)")! as! String
				title.text = sTitle
				text.text = sText
				
				// Get main image
				image = ""
				let imgFetchRequest: NSFetchRequest<Post_image> = Post_image.fetchRequest()
				let imgSortDescriptor = NSSortDescriptor(key: "idx", ascending: true)
				let imgSortDescriptors = [imgSortDescriptor]
				imgFetchRequest.sortDescriptors = imgSortDescriptors
				imgFetchRequest.predicate = NSPredicate(format: "post == %i", id)
				imgFetchRequest.fetchLimit = 1
				//TODO get more images
				do{
					let imgSearchResults = try context.fetch(imgFetchRequest)
					for imgR in imgSearchResults as [NSManagedObject]{
						image = imgR.value(forKey: "image")! as! String
						print ("IMAGE: \(image)")
						//TODO set image
						//row.setImage(filename: image)
					}
				} catch {
					print("Error getting image for post \(id): \(error)")
				}
				
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
