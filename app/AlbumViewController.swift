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
	@IBOutlet weak var albumView: UIView!

	// Album ID
	var id: Int = -1
	
	// App delegate
	var delegate: AppDelegate?
	
	// Id received from segue.
	var passId: Int = -1
	var passAlbum: Int = -1
	
	
	/**
	Gets the app context.
	:return: Application context.
	*/
	func getContext () -> NSManagedObjectContext {
		return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
	}
	
	
	/**
	Run when the app loads.
	*/
	override func viewDidLoad() {
		
		super.viewDidLoad()
		self.loadAlbum(id: id)
		
		// Set button action
		barButton.addTarget(self, action: #selector(self.back), for: .touchUpInside)
		
		// Set this controller in the delegate
		self.delegate = UIApplication.shared.delegate as? AppDelegate
		self.delegate?.albumController = self
		
		// Get album title
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		let fetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "id = %i", id)
		do {
			let results = try context.fetch(fetchRequest)
			let r = results[0]
			let title: String = r.value(forKey: "title_\(lang)")! as! String
			self.albumTitle.text = " \(title.decode().stripHtml())"
		}
		catch {
			NSLog(":GALLERYCONTROLLER:ERROR: Error getting album info: \(error)")
		}
	}
	
	
	/**
	Returns to the main view controller.
	*/
	func back() {
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
		
		var row : RowAlbum
		
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		let fetchRequest: NSFetchRequest<Photo_album> = Photo_album.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "album = %i", id)
		
		var rowcount = 0
		
		do {
			
			// Get the photo list
			let searchResults = try context.fetch(fetchRequest)
			var image: String
			
			for i in (0..<searchResults.count) where i % 2 == 0 {
				
				var r = searchResults[i]
				var photoId = r.value(forKey: "photo")! as! Int
				var leftId: Int = -1
				var rightId: Int = -1
				
				row = RowAlbum.init(s: "rowAlbum\(i)", i: i)
				row.id = id
				
				// Get photo info from Photo entity
				let imgFetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
				let imgSortDescriptor = NSSortDescriptor(key: "uploaded", ascending: true)
				let imgSortDescriptors = [imgSortDescriptor]
				imgFetchRequest.sortDescriptors = imgSortDescriptors
				imgFetchRequest.predicate = NSPredicate(format: "id == %i", photoId)
				imgFetchRequest.fetchLimit = 1
				do{
					var imgSearchResults = try context.fetch(imgFetchRequest)
					var imgR = imgSearchResults[0]
					image = imgR.value(forKey: "file")! as! String
					leftId = imgR.value(forKey: "id")! as! Int
					NSLog(":GALLERYCONTROLLER:LOG: Image Row \(i) left: \(image)")
					row.setImage(idx: 0, filename: image)
					if i + 1 < searchResults.count {
						r = searchResults[i + 1]
						photoId = r.value(forKey: "photo")! as! Int
						
						imgFetchRequest.predicate = NSPredicate(format: "id == %i", photoId)
						imgSearchResults = try context.fetch(imgFetchRequest)
						
						
						imgR = imgSearchResults[0]
						image = imgR.value(forKey: "file")! as! String
						rightId = imgR.value(forKey: "id")! as! Int
						NSLog(":GALLERYCONTROLLER:LOG: Image Row \(i) right: \(image)")
						row.setImage(idx: 1, filename: image)
					}
					else{
						NSLog(":GALLERYCONTROLLER:LOG: Image Row \(i) right: none")
					}
					//TODO create row, add images (L+R), add row to container.
					//row.setImage(filename: image)
				} catch {
					NSLog(":GALLERYCONTROLLER:ERROR: Error getting image for post \(id): \(error)")
				}
				
				row.setIds(left: leftId, right: rightId)
				albumContainer.addArrangedSubview(row)
				
				rowcount = rowcount + 1
			}
		}
		catch {
			NSLog(":GALLERYCONTROLLER:ERROR: Error with request: \(error)")
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
	
	
	/**
	Run before performing a segue.
	Assigns id if neccessary.
	:param: segue The segue to perform.
	:sender: The calling view.
	*/
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		NSLog(":GALLERYCONTROLLER:DEBUG: Preparing for segue '\(String(describing: segue.identifier))' with id \(self.passId)")
		if segue.identifier == "SeguePhotoAlbum"{
			(segue.destination as! PhotoViewController).albumId = passAlbum
			(segue.destination as! PhotoViewController).photoId = passId
		}
	}
	
	
	/**
	Shows a photo.
	:param: id The album id.
	*/
	func showPhoto(album: Int, photo: Int){
		NSLog(":ALBUMCONTROLLER:DEBUG: Showing photo \(photo) of album \(album)")
		// TODO: Set thoese variables and the prepare method
		self.passAlbum = album
		self.passId = photo
		performSegue(withIdentifier: "SeguePhotoAlbum", sender: nil)
		NSLog(":ALBUMCONTROLLER:DEBUG: PHOTO should be shown")
	}
	
}

