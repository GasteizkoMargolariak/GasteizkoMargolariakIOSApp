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
	
	
	//@IBOutlet weak var barTitle: UILabel!
	//@IBOutlet weak var barButton: UIButton!
	//@IBOutlet weak var postText: UILabel!
	//@IBOutlet weak var postTitle: UILabel!
	//@IBOutlet weak var postImage: UIImageView!
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
	var passPhotoId: Int = -1
	var passAlbumId: Int = -1
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
		NSLog(":PHOTOCONTROLLER:DEBUG: viewDidLoad")
		
		super.viewDidLoad()
		self.loadPhoto(id: photoId)
		
		// TODO populate photo array
		
		// Set button action
		// TODO barButton.addTarget(self, action: #selector(self.back), for: .touchUpInside)
	}
	
	
	/**
	Dismisses the controller.
	*/
	func back() {
		NSLog(":PHOTOCONTROLLER:DEBUG: Back")
		self.dismiss(animated: true, completion: nil)
	}
	
	
	/**
	Dispose of any resources that can be recreated.
	*/
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
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
			
			for r in searchResults as [NSManagedObject] {
				
				sTitle = r.value(forKey: "title_\(lang)")! as! String
				// TODO photoTitle.text = "  \(sTitle.decode().stripHtml())"
				// TODO date
				
				// TODO set photo
				
				/*
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
						if image == ""{
							self.postImage.isHidden = true
						}
						else{
							let path = "img/actividades/thumb/\(image)"
							self.postImage.setImage(localPath: path, remotePath: "https://margolariak.com/\(path)")
						}
					}
				} catch {
					NSLog(":POST:ERROR: Error getting image for post \(id): \(error)")
				}*/
				
			}
		} catch {
			NSLog(":PHOTO:ERROR: Error setting up photo \(id): \(error)")
		}
	}
	
	
	// TODO Buttons
	
	
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

