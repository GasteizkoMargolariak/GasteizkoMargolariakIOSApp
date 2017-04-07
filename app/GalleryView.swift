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
class GalleryView: UIView {
	
	@IBOutlet var container: UIView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var section: Section!
	var delegate: AppDelegate? = nil
	
	var idToOpen = -1
	
	// Row list
	var rows: Array<RowGallery> = []
	
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	func getRows() -> Array<RowGallery>{
		return rows
	}
	
	/**
	Run when the view is started.
	*/
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		
		print("GALLERY:DEBUG: init.")
		
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
		let sortDescriptor = NSSortDescriptor(key: "time", ascending: false)
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
				
				// Set tap recognizer
				//let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(openAlbum(_:)))
				//tapRecognizer.delegate = (UIApplication.shared.delegate as! AppDelegate).controller
				//row.isUserInteractionEnabled = true
				//row.addGestureRecognizer(tapRecognizer)
				
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
							print("GALLERY:ERROR: Error getting image from photo entity: \(error)")
						}
					}
				} catch {
					print("GALLERY:ERROR: Error getting image for post \(id): \(error)")
				}
				
				row.backgroundColor = UIColor.red
				parent.addArrangedSubview(row)
				//row.setNeedsLayout()
				//row.layoutIfNeeded()
				
				// Add to the rows array
				rows.append(row)
				
				// TODO: Do this on the row didLoad method
				// Set tap recognizer
				let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(openAlbum(_:)))
				row.isUserInteractionEnabled = true
				row.addGestureRecognizer(tapRecognizer)
				
				
				
			}
		} catch {
			print("GALLERY:ERROR: Error with request: \(error)")
		}
		
		//Always at the end: update scrollview
		var h: Int = 0
		for view in scrollView.subviews {
			//contentRect = contentRect.union(view.frame);
			h = h + Int(view.frame.height) + 30 //Why 30?
		}
		// TODO: Calculate at the end
		self.scrollView.contentSize.height = 2500//CGFloat(h);
		
		// The view controller
		//var viewController: ViewController  = self.window?.rootViewController as! ViewController
		
		
		//let viewController = UIApplication.topViewController() as! ViewController
		
		//viewController.showPost(id: 4)
		
		//print("BLOG:DEBUG: Show post on load.")
		//self.delegate?.controller?.showPost(id: 4)
		
		//controller.showPost(id: 4)
		
		
		
		
		print("GALLERY:DEBUG: Finished loading GalleryView")
		//let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(openAlbum(_:)))
		//row.isUserInteractionEnabled = true
		//container.addGestureRecognizer(tapRecognizer)
		self.setUpRowsTapRecognizers()
	}
	
	func openAlbum(_ sender:UITapGestureRecognizer? = nil){
		print("GALLERY:DEBUG: getting delegate and showing album.")
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		let id = (sender?.view as! RowGallery).id
		delegate.controller?.showAlbum(id: id)
		print("GALLERY:DEBUG: Album should be shown.")
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
	
	func setUpRowsTapRecognizers(){
		print("GALLERY:DEBUG: Setting up tap recognizers")
		for row in rows{
			let tapRecognizer = UITapGestureRecognizer(target: row, action: #selector(openAlbum(_:)))
			row.isUserInteractionEnabled = true
			container.addGestureRecognizer(tapRecognizer)
		}
	}
}
