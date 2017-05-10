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
Extension of UIView to be formatted as sections.
*/
@IBDesignable class RowSchedule: UIView {

	
	// Outlets
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var lbTime: UILabel!
	@IBOutlet weak var lbTitle: UILabel!
	@IBOutlet weak var lbText: UILabel!
	@IBOutlet weak var lbLocation: UILabel!
	
	/**
	Default constructor
	*/
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func loadViewFromNib() {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
		nib.instantiate(withOwner: self, options: nil).first as! UIView
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
		/*print("ROW_BLOG:DEBUG: set tap recognizer")
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (self.openPost (_:)))
		tapRecognizer.delegate = (UIApplication.shared.delegate as! AppDelegate).controller
		addGestureRecognizer(tapRecognizer)*/
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
	func setTime(str: String){
		self.lbTime.text = str
	}
	
	/**
	Sets the time of the event.
	:param: hours Hour of the event start.
	:param: minutes Minutes of the event start.
	*/
	func setTime(hours: Int, minutes: Int){
		self.lbTime.text = "\(hours):\(minutes)"
	}
	
	/**
	Sets the time of the event.
	:param: dtime Datetime of the event start.
	*/
	func setTime(dtime: NSDate){
		let dateformatter = DateFormatter()
		let calendar = Calendar.current
		let hours = calendar.component(.hour, from: dtime as Date)
		let minutes = calendar.component(.minute, from: dtime as Date)
		self.lbTime.text = "\(hours):\(minutes)"
	}
	
	/**
	Sets the title of the event.
	:param: text The title of the event.
	*/
	func setTitle(text: String){
		self.lbTitle.text = text
	}
	
	/**
	Sets the location of the event.
	:param: text The location of the event.
	*/
	func setLocation(text: String){
		self.lbLocation.text = text
	}
	
	/**
	Sets the description of the event. Decodes HTML.
	:param: text The new text.
	*/
	func setText(text: String){
		self.lbText.text = text.stripHtml()
	}
	
	/**
	Opens an event dialog.
	*/
	func openEvent(_ sender:UITapGestureRecognizer? = nil){
		print("ROW_BLOG:DEBUG: openpost")
	}
}
