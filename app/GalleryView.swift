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
Class to handle the gallery view.
*/
class GalleryView: UIView {
	
	// Outlets
	@IBOutlet var container: UIView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var section: Section!
	
	// App delegate
	var delegate: AppDelegate? = nil
	
	// Section row list
	var rows: Array<RowGallery> = []
	
	
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
		
		//Load the contents of the HomeView.xib file.
		Bundle.main.loadNibNamed("GalleryView", owner: self, options: nil)
		self.addSubview(container)
		container.frame = self.bounds
		section.setTitle(text: "Gallery")
		let parent = section.getContentStack()
		
		// Get viewController from StoryBoard
		let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let controller = storyboard.instantiateViewController(withIdentifier: "GMViewController") as! ViewController
		
		// Show albums
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		self.delegate = appDelegate
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		let fetchRequest: NSFetchRequest<Album> = Album.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
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
		}
		catch {
			NSLog(":GALLERY:ERROR: Error with request: \(error)")
		}
				
		self.setUpRowsTapRecognizers()
	}
	
	
	/**
	Opens an album.
	*/
	@objc func openAlbum(_ sender:UITapGestureRecognizer? = nil){
		let id = (sender?.view as! RowGallery).id
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showAlbum(id: id)
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
	Handles the click events to open albums.
	*/
	func setUpRowsTapRecognizers(){
		for row in self.rows{
			let tapRecognizer = UITapGestureRecognizer(target: row, action: #selector(openAlbum(_:)))
			row.isUserInteractionEnabled = true
			container.addGestureRecognizer(tapRecognizer)
		}
	}
}
