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
class AlbumViewController: UIViewController, UIGestureRecognizerDelegate {
	
	@IBOutlet weak var barButton: UIButton!
	@IBOutlet weak var barTitle: UILabel!
	@IBOutlet weak var albumTitle: UILabel!
	@IBOutlet weak var albumContainer: UIStackView!

	// Album ID
	var id: Int = -1
	
	// App delegate
	var delegate: AppDelegate?
	
	// Id received from segue.
	var passId: Int = -1
	
	func getContext () -> NSManagedObjectContext {
		return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
	}
	
	/**
	Run when the app loads.
	*/
	override func viewDidLoad() {
		
		NSLog(":GALLERYCONTROLLER:LOG: Init album.")
		
		super.viewDidLoad()
		self.loadAlbum(id: id)
		
		// Set button action
		barButton.addTarget(self, action: #selector(self.back), for: .touchUpInside)
	}
	
	/**
	Returns to the main view controller.
	*/
	func back() {
		NSLog(":GALLERYCONTROLLER:DEBUG: Back")
		self.dismiss(animated: true, completion: nil)
	}
	
	
	/**
	Dispose of any resources that can be recreated.
	*/
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	/**
	Loads the photos of the album
	*/
	public func loadAlbum(id: Int){
		
		NSLog(":GALLERYCONTROLLER:DEBUG: Loading post \(id)")
		
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		/*let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "id = %i", id)
		
		do {
			//go get the results
			let searchResults = try context.fetch(fetchRequest)
			
			var count = 0
			var sTitle: String
			var sText: String
			var image: String
			
			//You need to convert to NSManagedObject to use 'for' loops
			for r in searchResults as [NSManagedObject] {
				count = count + 1
				
				sTitle = r.value(forKey: "title_\(lang)")! as! String
				sText = r.value(forKey: "text_\(lang)")! as! String
				postTitle.text = "  \(sTitle)"
				postText.text = sText.stripHtml()
				
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
						print ("POST:LOG: Image: \(image)")
						//TODO set image
						//row.setImage(filename: image)
					}
				} catch {
					print("POST:ERROR: Error getting image for post \(id): \(error)")
				}
				
			}
		} catch {
			print("POST:ERROR: Error with request: \(error)")
		}
		*/
		
		//Always at the end: update scrollview
		// TODOs
		//var h: Int = 0
		//for view in scrollView.subviews {
		//contentRect = contentRect.union(view.frame);
		//	h = h + Int(view.frame.height) + 30 //Why 30?
		//}
		//print("POST:DEBUG: Height: \(h)")
		// TODO: Calculate at the end
		//self.scrollView.contentSize.height = 4500//CGFloat(h);
		
	}
	
	/**
	Gets the device language.
	:return: Two letter language code of the device.
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

