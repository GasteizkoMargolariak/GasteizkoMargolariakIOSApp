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

/**
 Extension of UICollectionViewCell for the main menu.
 */
class MenuCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var label: UILabel!
 
	@IBOutlet weak var bar: UIView!
	
	
	override var isHighlighted: Bool {
		willSet {
			onSelected(newValue)
		}
	}
	override var isSelected: Bool {
		willSet {
			onSelected(newValue)
		}
	}
	func onSelected(_ newValue: Bool) {

		guard selectedBackgroundView == nil else { return }
		if newValue == true {
			self.bar.backgroundColor = UIColor(red: 148/255, green: 209/255, blue: 255/255, alpha: 1)
			self.label.font = UIFont.boldSystemFont(ofSize: self.label.font.pointSize)
			self.label.textColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
		}
		else{
			self.bar.backgroundColor = UIColor(red: 90/255, green: 180/255, blue: 255/255, alpha: 1)
			self.label.font = UIFont.systemFont(ofSize: self.label.font.pointSize)
			self.label.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
		}
	}
}
