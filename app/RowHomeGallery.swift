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
	
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var photo0: UIImageView!
	@IBOutlet weak var photo1: UIImageView!
	@IBOutlet weak var photo2: UIImageView!
	@IBOutlet weak var photo3: UIImageView!
	
	var photos: [UIImageView] = []
	
	var photoIds: [Int] = [-1, -1, -1, -1]
	var albumIds: [Int] = [-1, -1, -1, -1]
	
	
	/**
	Default constructor
	*/
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	
	/**
	Loads the view in the xib file with the same name.
	*/
	private func loadViewFromNib() {
		let bundle = Bundle(for: type(of: self))
		let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
		nib.instantiate(withOwner: self, options: nil)
	}
	
	
	/**
	Default constructor.
	:param: s Custom identifier
	:param: i Custom identifier
	*/
	init(s: String, i: Int) {
		super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		loadViewFromNib()
		
		self.frame = self.bounds
		self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.translatesAutoresizingMaskIntoConstraints = true
		self.container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.container.translatesAutoresizingMaskIntoConstraints = true
		self.container.frame = self.bounds
		self.addSubview(container)
		
		self.photos = [photo0, photo1, photo2, photo3]
		

		//TODO Set click listeners
	}
	
	
	/**
	Open the first photo in the photo viewer.
	*/
	func openFirstPhoto(_ sender:UITapGestureRecognizer? = nil){
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showPhoto(album: self.albumIds[0], photo: self.photoIds[0])
	}
	
	
	/**
	Open the second photo in the photo viewer.
	*/
	func openSecondPhoto(_ sender:UITapGestureRecognizer? = nil){
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showPhoto(album: self.albumIds[1], photo: self.photoIds[1])
	}
	
	
	/**
	Open the third photo in the photo viewer.
	*/
	func openThirdPhoto(_ sender:UITapGestureRecognizer? = nil){
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showPhoto(album: self.albumIds[2], photo: self.photoIds[2])
	}
	
	
	/**
	Open the fourth photo in the photo viewer.
	*/
	func openFourthPhoto(_ sender:UITapGestureRecognizer? = nil){
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showPhoto(album: self.albumIds[3], photo: self.photoIds[3])
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
			// Hide the imageview
			self.photos[idx].isHidden = true
		}
		else{
			let path = "img/galeria/thumb/\(filename)"
			photos[idx].setImage(localPath: path, remotePath: "https://margolariak.com/\(path)")
			
			// Set tap recognizer
			switch idx{
				case 0:
					let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (RowHomeGallery.openFirstPhoto(_:)))
					tapRecognizer.delegate = (UIApplication.shared.delegate as! AppDelegate).controller
					self.photos[idx].isUserInteractionEnabled = true
					self.photos[idx].addGestureRecognizer(tapRecognizer)
					break;
				case 1:
					let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (RowHomeGallery.openSecondPhoto(_:)))
					tapRecognizer.delegate = (UIApplication.shared.delegate as! AppDelegate).controller
					self.photos[idx].isUserInteractionEnabled = true
					self.photos[idx].addGestureRecognizer(tapRecognizer)
					break;
				case 2:
					let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (RowHomeGallery.openThirdPhoto(_:)))
					tapRecognizer.delegate = (UIApplication.shared.delegate as! AppDelegate).controller
					self.photos[idx].isUserInteractionEnabled = true
					self.photos[idx].addGestureRecognizer(tapRecognizer)
					break;
				case 3:
					let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (RowHomeGallery.openFourthPhoto(_:)))
					tapRecognizer.delegate = (UIApplication.shared.delegate as! AppDelegate).controller
					self.photos[idx].isUserInteractionEnabled = true
					self.photos[idx].addGestureRecognizer(tapRecognizer)
					break;
				default:
					NSLog(":ROWHOMEGALLERY:ERROR: Trying to set tap recognizer for invalid photo index \(idx).")
			}
		}
	}
	
}
