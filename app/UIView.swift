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
 Extension of UIView that adds some options at the interface
 builder.
 */
@IBDesignable extension UIView {
	
	//Border color.
	@IBInspectable var borderColor:UIColor? {
		set {
			layer.borderColor = newValue!.cgColor
		}
		get {
			if let color = layer.borderColor {
				return UIColor(cgColor:color)
			}
			else {
				return nil
			}
		}
	}
	
	//Border width.
	@IBInspectable var borderWidth:CGFloat {
		set {
			layer.borderWidth = newValue
		}
		get {
			return layer.borderWidth
		}
	}
	@IBInspectable var cornerRadius:CGFloat {
		set {
			layer.cornerRadius = newValue
			clipsToBounds = newValue > 0
		}
		get {
			return layer.cornerRadius
		}
	}
	
	var parentViewController: ViewController? {
		var parentResponder: UIResponder? = self
		var i = 0
		while parentResponder != nil {
			print("UIVIEW:DEBUG: parentViewController level \(i)")
			parentResponder = parentResponder!.next
			if let viewController = parentResponder as? ViewController {
				print("UIVIEW:DEBUG: parentViewController found  controller.")
				return viewController
			}
		}
		print("UIVIEW:DEBUG: parentViewController no controller found.")
		return nil
	}
	
}
