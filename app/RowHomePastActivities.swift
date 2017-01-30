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
	
	//The container.
	
	
	//The activity title.
	@IBOutlet weak var title: UILabel!
	
	
	
	//The acvtivity text.
	@IBOutlet weak var descrip: UILabel!
	
	
	@IBOutlet weak var container: UIView!
	
	/**
	Run when the section is loaded.
	*/
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	init(s: String, i: Int) {
		//self.s = s
		//self.i = i
		super.init(frame: CGRect(x: 00, y: 0, width: 100, height: 150))
		Bundle.main.loadNibNamed("RowHomePastActivities", owner: self, options: nil)
		self.addSubview(container)
		container.frame = CGRect(x: 20, y: 100, width: 100, height: 150)
		//container.bounds = self.bounds//CGRect(x: 20, y: 100, width: 10, height: 10)
		//title.frame = self.bounds
		container.addSubview(title)
		title.frame = CGRect(x: 30, y: 150, width: 80, height: 100)
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
		title.text = text
		descrip.text = text
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
