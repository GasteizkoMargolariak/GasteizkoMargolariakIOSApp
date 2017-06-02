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
@IBDesignable class RowGallery: UIView {
	
	// Outlets
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var photo0: UIImageView!
	@IBOutlet weak var photo1: UIImageView!
	@IBOutlet weak var photo2: UIImageView!
	@IBOutlet weak var photo3: UIImageView!
	
	// Array with the imageviews
	var preview: [UIImageView] = []
	
	// Album ID
	var id = -1
	
	
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
		nib.instantiate(withOwner: self, options: nil).first
	}
	
	
	/**
	Default constructor.
	:param: s Custom identifier
	:param: i Custom identifier
	*/
	init(s: String, i: Int) {
		
		super.init(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
		loadViewFromNib()
		self.frame = self.bounds
		self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.translatesAutoresizingMaskIntoConstraints = true
		
		self.container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.container.translatesAutoresizingMaskIntoConstraints = true
		
		self.container.frame = self.bounds
		self.addSubview(self.container)
		
		//Populate review array
		self.preview = [photo0, photo1, photo2, photo3]
		
		// Set tap recognizer
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (RowGallery.openAlbum (_:)))
		tapRecognizer.delegate = (UIApplication.shared.delegate as! AppDelegate).controller
		self.addGestureRecognizer(tapRecognizer)
	}
	
	
	/**
	Default constructor for the interface builder
	*/
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	
	/**
	Opens an album.
	*/
	func openAlbum(_ sender:UITapGestureRecognizer? = nil){
		NSLog(":ROW_GALLERY:DEBUG: Getting delegate and showing album \(self.id).")
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showAlbum(id: self.id)
	}
	
	
	/**
	Changes the title of the album. Decodes HTML.
	:param: text The new title.
	*/
	func setTitle(text: String){
		self.title.text = "  \(text.decode().stripHtml())"
	}
	
	
	/**
	Changes the preview image of the album.
	If null or empty, the igage is hidden.
	:param: path The new text.
	*/
	func setImage(idx: Int, filename: String){
		if (filename == ""){
			NSLog(":ROWGALLERY:DEBUG: No image for album \(self.id) at index \(idx).")
			self.preview[idx].isHidden = true
		}
		else{
			let path = "img/galeria/thumb/\(filename)"
			self.preview[idx].setImage(localPath: path, remotePath: "https://margolariak.com/\(path)")
		}
	}
	
}
