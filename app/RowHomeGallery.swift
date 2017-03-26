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
@IBDesignable class RowHomeGallery: UIView {
	
	//This view
	var v: UIView!
	
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var photo0: UIImageView!
	@IBOutlet weak var photo1: UIImageView!
	@IBOutlet weak var photo2: UIImageView!
	@IBOutlet weak var photo3: UIImageView!
	
	var photos: [UIImageView] = []
	
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
		v = self
		v.frame = bounds
		v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		v.translatesAutoresizingMaskIntoConstraints = true
		container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		container.translatesAutoresizingMaskIntoConstraints = true
		
		container.frame = v.bounds
		v.addSubview(container)
		
		photos = [photo0, photo1, photo2, photo3]
		

		
		//TODO Set click listeners
	}
	
	/**
	Default constructor for the interface builder
	*/
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	/**
	Changes the preview image.
	If null or empty, the igage is hidden.
	:param: path The new text.
	*/
	func setImage(idx: Int, filename: String){
		if (filename == ""){
			print("ROWHOMEGALLERY:LOG: No image.")
			//TODO hide the imageview
		}
		else{
			let path = "img/galeria/thumb/\(filename)"
			photos[idx].setImage(localPath: path, remotePath: "https://margolariak.com/\(path)")
		}
	}
	
}
