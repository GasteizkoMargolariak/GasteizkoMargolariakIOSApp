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
Class to handle the location view.
*/
class LocationView: UIView {
	
	@IBOutlet var container: UIView!
	@IBOutlet weak var map: GMSMapView!
	@IBOutlet weak var lbTitle: UILabel!
	@IBOutlet weak var lbDistance: UILabel!
	@IBOutlet weak var lbNo: UILabel!
	
	var controller: ViewController
	var storyboard: UIStoryboard
	
	var didFindMyLocation = false
	
	var locationTimer: Timer? = nil
	

	/**
	Default constructor for the interface builder.
	:param: frame View frame.
	*/
	override init(frame: CGRect){
		
		// Set controller
		self.storyboard = UIStoryboard(name: "Main", bundle: nil)
		self.controller = storyboard.instantiateViewController(withIdentifier: "GMViewController") as! ViewController
		
		super.init(frame: frame)
	}
	
	
	/**
	Run when the view is started.
	*/
	required init?(coder aDecoder: NSCoder) {
		
		// Set controller
		self.storyboard = UIStoryboard(name: "Main", bundle: nil)
		self.controller = storyboard.instantiateViewController(withIdentifier: "GMViewController") as! ViewController
		
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
		
		// Schedule location fetches
		getNewLocation()
		Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(getNewLocation), userInfo: nil, repeats: true)
	}
	
	
	/**
	Enables the user location dot in the map, checking for permission.
	:param: manager Location manager used to get the location.
	:param: didChangeAuthorizationStatus status Permission status
	*/
	func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status == CLAuthorizationStatus.authorizedWhenInUse {
			map.isMyLocationEnabled = true
		}
	}
	
	
	/**
	Get new user location and recalculates distance to GM .
	*/
	func getNewLocation(){
		let defaults = UserDefaults.standard
		if (defaults.value(forKey: "GMLocLat") != nil && defaults.value(forKey: "GMLocLon") != nil){
			let lat = defaults.value(forKey: "GMLocLat") as! Double
			let lon = defaults.value(forKey: "GMLocLon") as! Double
			let time = defaults.value(forKey: "GMLocTime") as! Date
			let cTime = Date()
			let minutes = Calendar.current.dateComponents([.minute], from: time, to: cTime).minute
			if (minutes! < 30){
				self.map.isHidden = false
				self.lbTitle.isHidden = false
				self.lbDistance.isHidden = false
				self.lbNo.isHidden = true
				let marker = GMSMarker()
				marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
				marker.title = "Gasteizko Margolariak"
				//marker.snippet = "Australia"
				marker.map = self.map
			
				let location = self.controller.getLocation()
				if location != nil {
					let d: Int = calculateDistance(lat1: location.latitude, lon1: location.longitude, lat2: lat, lon2: lon)
				
					if d <= 1000 {
						self.lbDistance.text = "A \(d) metros de ti."
					}
					else{
						self.lbDistance.text = "A \(Int(d/1000)) kilómetros de ti."
					}
				}
			}
			else{
				self.map.isHidden = true
				self.lbTitle.isHidden = true
				self.lbDistance.isHidden = true
				self.lbNo.isHidden = false
			}
		}
	}


	/**
	Converts degrees to radians.
	:param: degrees Angle in degrees.
	:return: Angle in radiands.
	*/
	func degreesToRadians(degrees: Double) -> Double {
		return degrees * Double.pi / 180;
	}


	/**
	Calculates the distance, in integer meters, between two coordinates.
	:param: lat1 Latitude component of the first point.
	:param: lon1 Longitude component of the first point.
	:param: lat2 Latitude component of the second point.
	:param: lon2 Longitude component of the second point.
	:return: Distance, in integer meters, between the points.
	*/
	func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Int {
		let eRadius: Double = 6371

		let dLat: Double = degreesToRadians(degrees: lat2-lat1)
		let dLon: Double = degreesToRadians(degrees: lon2-lon1)

		let l1: Double = degreesToRadians(degrees: lat1)
		let l2: Double = degreesToRadians(degrees: lat2)

		let a: Double = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(l1) * cos(l2)
		let c: Double = 2 * atan2(sqrt(a), sqrt(1-a))
		let m: Double = eRadius * c * 1000
		return Int(m)
	}
	
	/*
	// TODO: Whato does this do?
	func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutableRawPointer) {
		if !didFindMyLocation {
			let myLocation: CLLocation = change[NSKeyValueChangeNewKey] as CLLocation
			map.camera = GMSCameraPosition.camera(withTarget: myLocation.coordinate, zoom: 10.0)
			map.settings.myLocationButton = true
			
			didFindMyLocation = true
		}
	}
	*/
}
