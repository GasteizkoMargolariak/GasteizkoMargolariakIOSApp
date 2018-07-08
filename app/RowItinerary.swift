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
import UIKit

/**
Extension of UIView to be formatted an activity itinerary.
*/
@IBDesignable class RowItinerary: UIView {

	
	// Outlets
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var lbTime: UILabel!
	@IBOutlet weak var lbTitle: UILabel!
	@IBOutlet weak var lbText: UILabel!
	@IBOutlet weak var lbLocation: UILabel!
	
	var id: Int = -1
	var type: String = ""
	
	/**
	Default constructor
	*/
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	
	/**
	Loads the view from the xib with the same name as the class.
	*/
	private func loadViewFromNib() {
		let bundle = Bundle(for: Swift.type(of: self))
		let nib = UINib(nibName: String(describing: Swift.type(of: self)), bundle: bundle)
		nib.instantiate(withOwner: self, options: nil)
	}
	
	
	/**
	Default constructor.
	:param: s Custom identifier
	:param: i Custom identifier
	*/
	init(s: String, i: Int) {
		super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		loadViewFromNib()
		self.frame = self.bounds
		self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.translatesAutoresizingMaskIntoConstraints = true
		
		container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		container.translatesAutoresizingMaskIntoConstraints = true
		
		container.frame = self.bounds
		self.addSubview(container)
		
		// Set tap recognizer
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (RowItinerary.openItinerary(_:)))
		tapRecognizer.delegate = (UIApplication.shared.delegate as! AppDelegate).controller
		self.addGestureRecognizer(tapRecognizer)
	}
	
	
	/**
	Default constructor for the interface builder
	*/
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	
	/**
	Sets the time of the event.
	:param: str String with the time to set.
	*/
	func setStart(str: String){
		self.lbTime.text = str
	}
	
	
	/**
	Sets the time of the event.
	:param: hours Hour of the event start.
	:param: minutes Minutes of the event start.
	*/
	func setStart(hours: Int, minutes: Int){
		var strMinutes: String = ""
		if "\(minutes)".length == 1{
			strMinutes = "0\(minutes)"
		}
		else{
			strMinutes = "\(minutes)"
		}
		self.lbTime.text = "\(hours):\(strMinutes)"
	}
	
	
	/**
	Sets the time of the event.
	:param: dtime Datetime of the event start.
	*/
	func setStart(time: NSDate){
		let calendar = Calendar.current
		let hours = calendar.component(.hour, from: time as Date)
		let minutes = calendar.component(.minute, from: time as Date)
		var strMinutes: String = ""
		if "\(minutes)".length == 1{
			strMinutes = "0\(minutes)"
		}
		else{
			strMinutes = "\(minutes)"
		}
		self.lbTime.text = "\(hours):\(strMinutes)"
	}
	
	
	/**
	Sets the title of the event.
	:param: text The title of the event.
	*/
	func setTitle(text: String){
		self.lbTitle.text = text.decode().stripHtml()
	}
	
	
	/**
	Sets the location of the event.
	:param: text The location of the event.
	*/
	func setLocation(text: String){
		self.lbLocation.text = text.decode().stripHtml()
	}
	
	
	/**
	Sets the description of the event. Decodes HTML.
	:param: text The new text.
	*/
	func setText(text: String){
		self.lbText.text = text.decode().stripHtml()
	}
	
	func setPlace(place: String, address: String){
		self.lbLocation.text = place.decode().stripHtml()
	}
	
	
	/**
	Opens an event dialog.
	*/
	@objc func openItinerary(_ sender:UITapGestureRecognizer? = nil){
		// TODO implement openItinerary.
		NSLog(":ROWITINERARY:DEBUG: Open Itinerary")
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.futureActivityController?.showItinerary(id: self.id)
	}
}
