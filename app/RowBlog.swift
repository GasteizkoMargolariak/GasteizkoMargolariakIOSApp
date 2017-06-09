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
@IBDesignable class RowBlog: UIView {
	
	//The container.
	@IBOutlet weak var container: UIView!
	
	//The entry
	@IBOutlet weak var entry: UIView!

	//The post title.
	@IBOutlet weak var title: UILabel!
	
	//The post description.
	@IBOutlet weak var descrip: UILabel!

	//The post image.
	@IBOutlet weak var image: UIImageView!
	
	
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
		nib.instantiate(withOwner: self, options: nil).first
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
		/*print("ROW_BLOG:DEBUG: set tap recognizer")
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (self.openPost (_:)))
		tapRecognizer.delegate = (UIApplication.shared.delegate as! AppDelegate).controller
		addGestureRecognizer(tapRecognizer)*/
	}
	
	
	/**
	Default constructor for the interface builder
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
	Changes the description of the post. Decodes HTML.
	:param: text The new text.
	*/
	func setText(text: String){
		self.descrip.text = text.decode()
	}
	
	
	/**
	Changes the image of the post.
	If null or empty, the igage is hidden.
	:param: path The new text.
	*/
	func setImage(filename: String){
		if (filename == ""){
			// Hide the imageview
			self.image.isHidden = true
		}
		else{
			let path = "img/blog/thumb/\(filename)"
			self.image.setImage(localPath: path, remotePath: "https://margolariak.com/\(path)")
		}
	}
	
	
	/**
	Opens a post.
	*/
	func openPost(_ sender:UITapGestureRecognizer? = nil){
		// TODO implement openPost.
		NSLog(":ROW_BLOG:DEBUG: openpost")
	}
}
