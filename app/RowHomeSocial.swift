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
@IBDesignable class RowHomeSocial: UIView {
	
	//This view
	var v: UIView!
	
	//The container.
	@IBOutlet weak var container: UIView!
	
	//The container.
	@IBOutlet weak var entry: UIView!
	
	
	/**
	Default constructor
	*/
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func loadViewFromNib() {
		print("LOADING NIB...")
		let bundle = Bundle(for: type(of: self))
		print("GOT BUNDLE...")
		let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
		print("NIB CREATED")
		nib.instantiate(withOwner: self, options: nil).first as! UIView
		print("NIB INSTANTIATED")
	}
	
	/**
	Default constructor.
	:param: s Custom identifier
	:param: i Custom identifier
	*/
	init(s: String, i: Int) {
		super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		print("CREATING...")
		loadViewFromNib()
		print("NIB LOADED...")
		v = self
		v.frame = bounds
		v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		v.translatesAutoresizingMaskIntoConstraints = true
		print("STUFF DONE")
		container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		container.translatesAutoresizingMaskIntoConstraints = true
		
		container.frame = v.bounds
		print("CONTAINER STUFF DONE")
		v.addSubview(container)
		print("END CONSTRUCTOR")
	}
	
	/**
	Default constructor for the interface builder
	*/
	override init(frame: CGRect){
		super.init(frame: frame)
	}
}
