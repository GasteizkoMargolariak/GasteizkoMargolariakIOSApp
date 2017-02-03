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
@IBDesignable class RowHomePastActivities: UIView {
	
	//This view
	var v: UIView!
	
	//The container.
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var entry: UIView!
	
	
	//The activity title.
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var descrip: UILabel!
	
	
	
	
	//The acvtivity text.
	
	
	
	
	/**
	Run when the section is loaded.
	*/
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func loadViewFromNib() -> UIView {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
		let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
		
		return nibView
	}
	
	init(s: String, i: Int) {
		//self.s = s
		//self.i = i
		super.init(frame: CGRect(x: 20, y: 100, width: 200, height: 450))
		print("Constructor: Custom")
		//self.bounds = CGRect(x: 00, y: 0, width: 200, height: 150)
		//v = loadViewFromNib()
		loadViewFromNib()
		v = self
		v.frame = bounds
		v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		v.translatesAutoresizingMaskIntoConstraints = true
		v.backgroundColor = UIColor.green
			//Bundle.main.loadNibNamed("RowHomePastActivities", owner: self, options: nil)
		//self.addSubview(container)
		//container.frame = CGRect(x: 20, y: 100, width: 100, height: 150)
		//container.frame = CGRect(x: 20, y: 0, width: 100, height: 150)
		container.backgroundColor = UIColor.green
		container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		container.translatesAutoresizingMaskIntoConstraints = true
		self.backgroundColor = UIColor.red
		self.borderColor = UIColor.blue
		self.borderWidth = 3
		//container.bounds = self.bounds//CGRect(x: 20, y: 100, width: 10, height: 10)
		//title.frame = self.bounds
		
		print("bounds")
		//title.frame = container.bounds//CGRect(x: 30, y: 150, width: 80, height: 100)
		//title.frame = CGRect(x: 0, y: 0, width: 50, height: 15)
		//title.bounds = CGRect(x: 0, y: 0, width: 50, height: 15)
		//title.bounds = CGRec
		container.frame = v.frame
		//container.frame = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.width, height: self.bounds.height)
		v.addSubview(container)
		title.frame = self.bounds
		container.addSubview(title)
		//container.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
		
		let lbl = UILabel()
		lbl.text = "ABBA2"
		lbl.frame = v.bounds
		//view.addEntry(view: row)
		v.addSubview(lbl)
		
		
	}
	
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	func setBounds(rect: CGRect){
		container.bounds = rect
	}
	
	/**
	Changes the title of the activity.
	:param: text The new title.
	*/
	func setTitle(text: String){
		print("Setting title: \(text)")
		//title.text = text
		//descrip.text = text
	}
	
	/**
	Changes the description of the activity.
	:param: text The new text.
	*/
	func setText(text: String){
		descrip.text = text
	}
	
	/**
	Changes the image of the activity.
	If null or empty, the igage is hidden.
	:param: path The new text.
	*/
	func setImage(path: String){
		//TODO
	}
	
	
	
	
	/*var view:UIView!
	
	func setup() {
		view = loadViewFromNib()
		view.frame = bounds
		view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeightaddSubview(view)
	}
	
	func loadViewFromNib() -> UIView {
		let bundle = Bundle(for:type(of: self))
		let nib = UINib(nibName: "RowHomePastActivities", bundle: bundle)
		let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
		
		return view
	}*/
}
