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
import CoreLocation

/**
  The view controller of the app.
 */
class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
	
	var delegate: AppDelegate?
	
	//The menu collection.
	var sectionCollection: UICollectionView!

	//Each of the sections of the app.
	@IBOutlet var containerViewGallery: GalleryView!
	@IBOutlet var containerViewBlog: BlogView!
	@IBOutlet var containerViewActivities: ActivitiesView!
	@IBOutlet var containerViewLablanca: LablancaView!
	@IBOutlet var containerViewLocation: LocationView!
	@IBOutlet var containerViewHome: HomeView!
	
	//Menu items.
	let reuseIdentifier = "cell"
	var selected = 0
	var items = ["Inicio", "Localización", "La Blanca", "Actividades", "Blog", "Galería"]
	
	// Passed id to perform segues.
	var passId: Int = -1
	var passAlbum: Int = -1
	
	// Location-related variables.
	var locationManager = CLLocationManager()
	var didFindMyLocation = false
	var locationTimer: Timer? = nil
	
	
	/**
	Controller initializer.
	:param: coder Coder.
	*/
	required init?(coder aDecoder: NSCoder) {
		NSLog(":CONTROLLER:DEBUG: Init.")
		super.init(coder: aDecoder)
		
	}
	
	/**
	Gets the device-reported location.
	*/
	func getLocation() -> CLLocationCoordinate2D {
		return (locationManager.location?.coordinate)!
	}
	
	
	/**
	Retrieves the application context.
	:return: The application context.
	*/
	func getContext () -> NSManagedObjectContext {
		//let appDelegate = UIApplication.shared.delegate as! AppDelegate
		//return appDelegate.persistentContainer.viewContext
		return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
	}
	
	
	/**
	Shows a post.
	:param: id The post id.
	*/
	func showPost(id: Int){
		self.passId = id
		performSegue(withIdentifier: "SeguePost", sender: nil)
	}
	
	
	/**
	Shows a past activity.
	:param: id The activity id.
	*/
	func showPastActivity(id: Int){
		self.passId = id
		performSegue(withIdentifier: "SeguePastActivity", sender: nil)
	}
	
	
	/**
	Shows a future activity.
	:param: id The activity id.
	*/
	func showFutureActivity(id: Int){
		self.passId = id
		performSegue(withIdentifier: "SegueFutureActivity", sender: nil)
	}
	
	
	/**
	Shows an album.
	:param: id The album id.
	*/
	func showAlbum(id: Int){
		self.passId = id
		performSegue(withIdentifier: "SegueAlbum", sender: nil)
	}
	
	
	/**
	Shows a photo.
	:param: id The album id.
	*/
	func showPhoto(album: Int, photo: Int){
		self.passAlbum = album
		self.passId = photo
		performSegue(withIdentifier: "SeguePhoto", sender: nil)
	}
	
	
	/**
	Shows a schedule.
	:param: margolari True for the margolari schedule, false for the city one.
	*/
	func showSchedule(margolari: Bool){
		if margolari == true{
			self.passId = 1
		}
		else{
			self.passId = 0
		}
		performSegue(withIdentifier: "SegueSchedule", sender: nil)
	}
	
	
	/**
	Run before performing a segue.
	Assigns id if neccessary.
	:param: segue The segue to perform.
	:sender: The calling view.
	*/
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "SeguePost"{
			(segue.destination as! PostViewController).id = passId
		}
		if segue.identifier == "SegueAlbum"{
			(segue.destination as! AlbumViewController).id = passId
		}
		if segue.identifier == "SeguePhoto"{
			(segue.destination as! PhotoViewController).photoId = passId
			(segue.destination as! PhotoViewController).albumId = passAlbum
		}
		if segue.identifier == "SegueSchedule"{
			if passId == 1{
				(segue.destination as! ScheduleViewController).margolari = true
			}
			else{
				(segue.destination as! ScheduleViewController).margolari = false
			}
		}
		if segue.identifier == "SeguePastActivity"{
			(segue.destination as! PastActivityViewController).id = passId
		}
		if segue.identifier == "SegueFutureActivity"{
			(segue.destination as! FutureActivityViewController).id = passId
		}
	}
	
	
	/**
	Run when the app loads.
	*/
	override func viewDidLoad() {
		
		// Ask for location permissions.
		locationManager.delegate = self
		locationManager.requestWhenInUseAuthorization()
		
		//Hide all sections, except for the first one
		self.containerViewLocation.alpha = 0
		self.containerViewLablanca.alpha = 0
		self.containerViewActivities.alpha = 0
		self.containerViewBlog.alpha = 0
		self.containerViewGallery.alpha = 0
		
		// Start the location schedule
		fetchLocation()
		self.locationTimer = Timer.scheduledTimer(timeInterval: 90, target: self, selector: #selector(fetchLocation), userInfo: nil, repeats: true)
		
		self.delegate = UIApplication.shared.delegate as? AppDelegate
		self.delegate?.controller = self
		
		super.viewDidLoad()
		
	}
	
	/**
	Asynchronously gets a location report from the server.
	*/
	func fetchLocation(){
		FetchLocation()
	}
	
	
	/**
	Generates a random string to be used as a user identifier.
	:param: length The length of the generated string.
	:return: A random alphanumeric string with the indicated length.
	*/
	func randomString(length: Int) -> String {
		
		let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		let len = UInt32(letters.length)
		
		var randomString = ""
		
		for _ in 0 ..< length {
			let rand = arc4random_uniform(len)
			var nextChar = letters.character(at: Int(rand))
			randomString += NSString(characters: &nextChar, length: 1) as String
		}
		
		return randomString
	}
	
	
	/**
	Dispose of any resources that can be recreated.
	*/
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	
	// MARK: - UICollectionViewDataSource protocol
	
	
	/**
	Sets a collection of menu items.
	:param: numberOfItemsInSection The number of entries of the menu.
	:return: The number of entries of the menu.
	*/
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.items.count
	}
	
	
	/**
	Sets up the menu bar.
	:param: cellForItemAt indexPath One cell of the menu.
	*/
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		//Get a reference to our storyboard cell
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MenuCollectionViewCell
		
		//Set text
		cell.label.text = self.items[indexPath.item]
		
		// Mark the first one as selected.
		if indexPath.item == 0{
			cell.isSelected = true
		}
		
		return cell
	}
	
	// MARK: - UICollectionViewDelegate protocol
	
	
	/**
	Inits items in the menu bar.
	:paramm: didSelectItemAt item index
	*/
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		sectionCollection = collectionView
		showComponent(selected: indexPath.item)
	}
	
	
	/**
	Caled when an item of the menu bar is selected.
	:param: selected Index of the selected item.
	*/
	@IBAction func showComponent(selected: Int) {
	
		// Reverts the style of the first tab.
		if selected != 0{
			if self.sectionCollection != nil{
				self.sectionCollection.visibleCells[0].isSelected = false
			}
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

