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
Extension of UIView to be formatted as a row on the blog section of the home view.
*/
@IBDesignable class RowHomeBlog: UIView {

	// Outlets.
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var entry: UIView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var descrip: UILabel!
	@IBOutlet weak var image: UIImageView!
	
	// Post ID.
	var id: Int!
	
	
	/**
	Default constructor.
	:param: coder Coder.
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
		self.frame = self.bounds
		self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.translatesAutoresizingMaskIntoConstraints = true
		self.container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.container.translatesAutoresizingMaskIntoConstraints = true
		
		self.container.frame = self.bounds
		self.addSubview(self.container)
		
		// Set tap recognizer
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (RowHomeBlog.openPost (_:)))
		tapRecognizer.delegate = (UIApplication.shared.delegate as! AppDelegate).controller
		self.addGestureRecognizer(tapRecognizer)
	}
	
	
	/**
	Default constructor for the interface builder.
	:param: frame View frame.
	*/
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	
	/**
	Changes the title of the post. Decodes HTML.
	:param: text The new title.
	*/
	func setTitle(text: String){
		self.title.text = text.decode().stripHtml()
	}
	
	
	/**
	Changes the text of the post. Decodes HTML.
	:param: text The new text.
	*/
	func setText(text: String){
		self.descrip.text = text.decode().stripHtml()
	}
	
	
	/**
	Changes the image of the post.
	If null or empty, the igage is hidden.
	:param: path The new text.
	*/
	func setImage(filename: String){
		if (filename == ""){
			// Hide the imageview
			self.image.isHidden = true;
		}
		else{
			let path = "img/blog/thumb/\(filename)"
			self.image.setImage(localPath: path, remotePath: "https://margolariak.com/\(path)")
		}
	}
	
	
	/**
	Opens a post in a controller.
	*/
	func openPost(_ sender:UITapGestureRecognizer? = nil){
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showPost(id: self.id)
	}
}
