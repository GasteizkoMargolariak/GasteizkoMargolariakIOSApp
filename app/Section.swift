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
class Section: UIView {
	
	//The container.
	@IBOutlet weak var container: UIView!
	
	//The section title.
	@IBOutlet weak var title: UITextView!
	
	//The content of the section.
	@IBOutlet weak var content: UIStackView!
	
	
	
	/**
	 Run when the section is loaded.
	*/
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		//Load the contents of the Section.xib file.
		Bundle.main.loadNibNamed("Section", owner: self, options: nil)
		self.addSubview(container)
		container.frame = self.bounds
	}
	
	func getContentStack() -> UIStackView {
		return content
	}
	
	/**
	 Chancges the title of the section.
	 :param: title The new title.
	*/
	func setTitle(text: String){
		title.text = text
	}
	
	func expandSection(){
		print("Bounds: \(self.bounds)")
		print("Frame: \(self.frame)")
		print("Subviews: \(self.subviews)")
		sizeToFit()
	}
	
	func addEntry(view : UIView){
		let lbl = UILabel()
		lbl.text = "ABBA"
		content.addSubview(lbl)
	}
	
	func resizeToFitSubviews() {
		var width: CGFloat = 0
		var height: CGFloat = 0
		for someView in self.subviews {
			let aView = someView
			let newWidth = aView.frame.origin.x + aView.frame.width
			let newHeight = aView.frame.origin.y + aView.frame.height
			width = max(width, newWidth)
			height = max(height, newHeight)
		}
		
		frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: width, height: height)
	}
}
