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
	
	//This view
	var v: UIView!
	
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var photo0: UIImageView!
	@IBOutlet weak var photo1: UIImageView!
	@IBOutlet weak var photo2: UIImageView!
	@IBOutlet weak var photo3: UIImageView!
	
	//Array with the imageviews
	var preview: [UIImageView] = []
	
	var id = -1
	
	
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
		print("ROWGALLERY:DEBUG: Init \(s), \(i)")
		
		super.init(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
		loadViewFromNib()
		v = self
		v.frame = bounds
		v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		v.translatesAutoresizingMaskIntoConstraints = true
		
		container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		container.translatesAutoresizingMaskIntoConstraints = true
		
		container.frame = v.bounds
		v.addSubview(container)
		
		//Populate review array
		//print("ROWGALLERY:DEBUG: Populating preview array")
		preview = [photo0, photo1, photo2, photo3]
		
		// Set tap recognizer
		print("ROW_GALLERY:DEBUG: Row \(id) frame h \(self.frame.height) w \(self.frame.width)")
		print("ROW_GALLERY:DEBUG: set tap recognizer")
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (RowGallery.openAlbum (_:)))
		tapRecognizer.delegate = (UIApplication.shared.delegate as! AppDelegate).controller
		self.addGestureRecognizer(tapRecognizer)
	}
	
	//override func viewDidLoad() {
	//	print("ROW_GALLERY:DEBUG: LAYOUT Row \(id) frame h \(self.frame.height) w \(self.frame.width)")
	//}
	
	/**
	Default constructor for the interface builder
	*/
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	func openAlbum(_ sender:UITapGestureRecognizer? = nil){
		print("ROW_GALLERY:DEBUG: getting delegate and showing album.")
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		//id = (sender?.view as! RowGallery).id
		delegate.controller?.showAlbum(id: self.id)
		print("ROW_GALLERY:DEBUG: Album should be shown.")
	}
	
	/**
	Changes the title of the album. Decodes HTML.
	:param: text The new title.
	*/
	func setTitle(text: String){
		title.text = "  \(text.stripHtml())"
	}
	
	/**
	Changes the preview image of the album.
	If null or empty, the igage is hidden.
	:param: path The new text.
	*/
	func setImage(idx: Int, filename: String){
		if (filename == ""){
			print("ROWGALLERY:LOG: No image.")
			//TODO hide the imageview
		}
		else{
			print("Set image \(filename)")
			let path = "img/galeria/thumb/\(filename)"
			preview[idx].setImage(localPath: path, remotePath: "https://margolariak.com/\(path)")
		}
	}
	
}
