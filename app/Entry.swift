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
class Entry: UIView {
	
	//The content of the section.
	@IBOutlet weak var entry: UIView!
	
	/**
	Run when the section is loaded.
	*/
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		//Load the contents of the Entry.xib file.
		Bundle.main.loadNibNamed("Entry", owner: self, options: nil)
		self.addSubview(entry)
		entry.frame = self.bounds
	}
	
	/**
	Chancges the title of the section.
	:param: title The new title.
	*/
	//func setTitle(text: String){
	//	title.text = text
	//}
}
