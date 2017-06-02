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
import GoogleMaps
/**
Class to handle the home view.
*/
class LocationView: UIView {
	
	@IBOutlet var container: UIView!
	@IBOutlet weak var map: GMSMapView!
	
	var didFindMyLocation = false
	
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	
	/**
	Run when the view is started.
	*/
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		
		// Load the contents of the HomeView.xib file.
		Bundle.main.loadNibNamed("LocationView", owner: self, options: nil)
		self.addSubview(self.container)
		self.container.frame = self.bounds
		
		// Set map up
		map.isMyLocationEnabled = true
		//map.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.new, context: nil)
		let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: 42.846399, longitude: -2.673365, zoom: 12.0)
		map.camera = camera
	}
	
	
	/**
	I am not sure what does this do...
	*/
	func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status == CLAuthorizationStatus.authorizedWhenInUse {
			map.isMyLocationEnabled = true
		}
	}
	
	/*func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutableRawPointer) {
		if !didFindMyLocation {
			let myLocation: CLLocation = change[NSKeyValueChangeNewKey] as CLLocation
			map.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 10.0)
			map.settings.myLocationButton = true
			
			didFindMyLocation = true
		}
	}
	*/
}
