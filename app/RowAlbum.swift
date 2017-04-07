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
@IBDesignable class RowAlbum: UIView {
	
	// Outlets
	
	@IBOutlet weak var photo0: UIImageView!
	@IBOutlet weak var photo1: UIImageView!
	
	
	// This view
	var v: UIView!
	
	// Array with the imageviews
	var preview: [UIImageView] = []

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
		NSLog(":ROWALBUM:DEBUG: Init \(s), \(i)")
		
		super.init(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
		loadViewFromNib()
		v = self
		self.frame = bself.ounds
		self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.translatesAutoresizingMaskIntoConstraints = true
		
		//Populate review array
		preview = [photo0, photo1]
		
		// Set tap recognizers
		// TODO
		//let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (RowAlbum.openPhoto(_:)))
		//tapRecognizer.delegate = (UIApplication.shared.delegate as! AppDelegate).controller
		//self.addGestureRecognizer(tapRecognizer)
	}
	
	/**
	Default constructor for the interface builder
	*/
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	func openPhoto(_ sender:UITapGestureRecognizer? = nil){
		NSLog(":ROWALBUM:DEBUG: Getting delegate and showing photo.")
		// TODO
		//let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		//delegate.controller?.showAlbum(id: self.id)
	}
	
	/**
	Changes the preview image of the photos.
	If null or empty, the igage is hidden.
	:param: idx Id of the image in the row. 0 for left, 1 for right.
	:param: filename Filename of the image.
	*/
	func setImage(idx: Int, filename: String){
		if (filename == ""){
			NSLog(":ROWALBUM:DEBUG: No image for album \(self.id) at index \(idx).")
			preview[idx].isHidden = true
			//TODO hide the imageview
		}
		else{
			NSLog(":ROWALBUM:DEBUG: Set image \(filename) for at index \(idx).")
			let path = "img/galeria/thumb/\(filename)"
			preview[idx].setImage(localPath: path, remotePath: "https://margolariak.com/\(path)")
		}
	}
	
}
