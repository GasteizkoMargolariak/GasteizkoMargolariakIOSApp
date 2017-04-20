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
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
	
	var delegate: AppDelegate?
	
	//The menu collection.
	var sectionCollection: UICollectionView!
	
	// Need to save the sync segue.
	var syncSegue: UIStoryboardSegue?

	//Each of the sections of the app.
	@IBOutlet var containerViewGallery: GalleryView!
	@IBOutlet var containerViewBlog: BlogView!
	@IBOutlet var containerViewActivities: UIView!
	@IBOutlet var containerViewLablanca: LablancaView!
	@IBOutlet var containerViewLocation: UIView!
	@IBOutlet var containerViewHome: HomeView!
	
	var passId: Int = -1
	
	//required init() {
	//	delegate = UIApplication.shared.delegate as! AppDelegate
	//	super.init()
	//}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	func getContext () -> NSManagedObjectContext {
		//let appDelegate = UIApplication.shared.delegate as! AppDelegate
		//return appDelegate.persistentContainer.viewContext
		return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
	}
	
	func showPost(id: Int){
		print("CONTROLLER:DEBUG: Showing Post \(id)")
		self.passId = id
		performSegue(withIdentifier: "SeguePost", sender: nil)
	}
	
	func showAlbum(id: Int){
		NSLog(":CONTROLLER:DEBUG: Showing album \(id)")
		self.passId = id
		performSegue(withIdentifier: "SegueAlbum", sender: nil)
	}
	
	func initialSync(showScreen: Bool){
		if showScreen == true{
			NSLog(":CONTROLLER:DEBUG: Showing initial sync screen.")
			performSegue(withIdentifier: "SegueSync", sender: nil)
			Sync(synchronous: true)
		}
		else{
			NSLog(":CONTROLLER:DEBUG: Hidding initial sync screen.")
			syncSegue?.destination.dismiss(animated: true, completion: nil)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		NSLog(":CONTROLLER:DEBUG: preparing for segue '\(segue.identifier)' with id \(self.passId)")
		if segue.identifier == "SeguePost"{
			(segue.destination as! PostViewController).id = passId
		}
		if segue.identifier == "SegueAlbum"{
			(segue.destination as! AlbumViewController).id = passId
		}
		if segue.identifier == "SegueSync"{
			self.syncSegue = segue
		}
	}
	
	/**
	 Run when the app loads.
	*/
	override func viewDidLoad() {
				
		//Hide all sections, except for the first one
		self.containerViewLocation.alpha = 0
		self.containerViewLablanca.alpha = 0
		self.containerViewActivities.alpha = 0
		self.containerViewBlog.alpha = 0
		self.containerViewGallery.alpha = 0
		
		
		//self.containerViewBlog.isHidden = true
				
		NSLog(":CONTROLLER:LOG: viewDidLoad()")
		NSLog(":CONTROLLER:DEBUG: Skyp sync")
		//Sync()
		
		
		
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		
		//self.containerViewBlog.setController(controller: self as ViewController)
		
		delegate = UIApplication.shared.delegate as! AppDelegate
		delegate?.controller = self
		
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Try to read user id
		//let defaults = UserDefaults.standard
		//let uid: String? = defaults.string(forKey: "userId")
		
		//NSLog(":CONTROLLER:DEBUG: userId \(uid)")
		
		//if uid! == nil{
		if UserDefaults.standard.object(forKey: "userId") == nil{
			let newUid = "123456789123"
			let defaults = UserDefaults.standard
			defaults.set(newUid, forKey: "userId")
			initialSync(showScreen: true)
		}
		
		
		
		// TODO: Only if neccessary
		
	}

	/**
	 Dispose of any resources that can be recreated.
	*/
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	//Menu items.
	let reuseIdentifier = "cell"
	var selected = 0
	var items = ["Home", "Location", "La Blanca", "Actividades", "Blog", "Gallery"]
	
	// MARK: - UICollectionViewDataSource protocol
	
	//Tell the collection view how many cells to make
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.items.count
	}
	
	//Make a cell for each section
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
				
		//Get a reference to our storyboard cell
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MenuCollectionViewCell
		
		//Set text
		cell.label.text = self.items[indexPath.item]
		
		//Mark the first cell as selected...
		if indexPath.item == selected{
			cell.bar.backgroundColor = UIColor(red: 90/255, green: 180/255, blue: 255/255, alpha: 1)
			cell.label.font = UIFont.boldSystemFont(ofSize: cell.label.font.pointSize)
		}
			
		//... and the others as unselected
		else{
			cell.bar.backgroundColor = UIColor(red: 148/255, green: 209/255, blue: 255/255, alpha: 1)
			cell.label.font = UIFont.systemFont(ofSize: cell.label.font.pointSize)
		}
		
		return cell
	}
	
	// MARK: - UICollectionViewDelegate protocol
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		sectionCollection = collectionView
		showComponent(selected: indexPath.item)
	}
	
	@IBAction func showComponent(selected: Int) {
		//Activate label
		var i = 0
		for cell in sectionCollection.visibleCells as! [MenuCollectionViewCell]{ //TODO: Not only visibles!
			if i == selected + 1{
				cell.bar.backgroundColor = UIColor(red: 90/255, green: 180/255, blue: 255/255, alpha: 1)
				cell.label.font = UIFont.boldSystemFont(ofSize: cell.label.font.pointSize)
			}
			else{
				cell.bar.backgroundColor = UIColor(red: 148/255, green: 209/255, blue: 255/255, alpha: 1)
				cell.label.font = UIFont.systemFont(ofSize: cell.label.font.pointSize)
				
			}
			i = i + 1
		}
		
		//Show the view
		if selected == 0 {
			UIView.animate(withDuration: 0.5, animations: {
				self.containerViewHome.alpha = 1
				self.containerViewLocation.alpha = 0
				self.containerViewLablanca.alpha = 0
				self.containerViewActivities.alpha = 0
				self.containerViewBlog.alpha = 0
				self.containerViewGallery.alpha = 0
			})
		}
		else if selected == 1 {
			UIView.animate(withDuration: 0.5, animations: {
				self.containerViewHome.alpha = 0
				self.containerViewLocation.alpha = 1
				self.containerViewLablanca.alpha = 0
				self.containerViewActivities.alpha = 0
				self.containerViewBlog.alpha = 0
				self.containerViewGallery.alpha = 0
			})
		}
		else if selected == 2 {
			UIView.animate(withDuration: 0.5, animations: {
				self.containerViewHome.alpha = 0
				self.containerViewLocation.alpha = 0
				self.containerViewLablanca.alpha = 1
				self.containerViewActivities.alpha = 0
				self.containerViewBlog.alpha = 0
				self.containerViewGallery.alpha = 0
			})
		}
		else if selected == 3 {
			UIView.animate(withDuration: 0.5, animations: {
				self.containerViewHome.alpha = 0
				self.containerViewLocation.alpha = 0
				self.containerViewLablanca.alpha = 0
				self.containerViewActivities.alpha = 1
				self.containerViewBlog.alpha = 0
				self.containerViewGallery.alpha = 0
			})
		}
		else if selected == 4 {
			UIView.animate(withDuration: 0.5, animations: {
				self.containerViewHome.alpha = 0
				self.containerViewLocation.alpha = 0
				self.containerViewLablanca.alpha = 0
				self.containerViewActivities.alpha = 0
				self.containerViewBlog.alpha = 1
				self.containerViewGallery.alpha = 0
			})
		}
		else if selected == 5 {
			UIView.animate(withDuration: 0.5, animations: {
				self.containerViewHome.alpha = 0
				self.containerViewLocation.alpha = 0
				self.containerViewLablanca.alpha = 0
				self.containerViewActivities.alpha = 0
				self.containerViewBlog.alpha = 0
				self.containerViewGallery.alpha = 1
			})
		}
		
	}


}

