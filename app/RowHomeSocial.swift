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

	//The container.
	@IBOutlet weak var container: UIView!
	
	//The container.
	@IBOutlet weak var entry: UIView!
	
	//The buttons
	@IBOutlet weak var btnPhone: UIImageView!
	@IBOutlet weak var btnMail: UIImageView!
	@IBOutlet weak var btnFacebook: UIImageView!
	@IBOutlet weak var btnTwitter: UIImageView!
	@IBOutlet weak var btnGoogle: UIImageView!
	@IBOutlet weak var btnYoutube: UIImageView!
	@IBOutlet weak var btnInstagram: UIImageView!
	
	
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
		
		// Set buttons up
		let phoneTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapPhone))
		btnPhone.isUserInteractionEnabled = true
		btnPhone.addGestureRecognizer(phoneTapRecognizer)
		let mailTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMail))
		btnMail.isUserInteractionEnabled = true
		btnMail.addGestureRecognizer(mailTapRecognizer)
		let facebookTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapFacebook))
		btnFacebook.isUserInteractionEnabled = true
		btnFacebook.addGestureRecognizer(facebookTapRecognizer)
		let twitterTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapTwitter))
		btnTwitter.isUserInteractionEnabled = true
		btnTwitter.addGestureRecognizer(twitterTapRecognizer)
		let googleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapGoogle))
		btnGoogle.isUserInteractionEnabled = true
		btnGoogle.addGestureRecognizer(googleTapRecognizer)
		let youtubeTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapYoutube))
		btnYoutube.isUserInteractionEnabled = true
		btnYoutube.addGestureRecognizer(youtubeTapRecognizer)
		let instagramTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapInstagram))
		btnInstagram.isUserInteractionEnabled = true
		btnInstagram.addGestureRecognizer(instagramTapRecognizer)
	}
	
	/**
	Default constructor for the interface builder
	:param: frame View frame.
	*/
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	
	/**
	Called when the phone button is tapped.
	*/
	func didTapPhone() {
		UIApplication.shared.openURL(NSURL(string: "tel://+34637140371")! as URL)
	}
	
	
	/**
	Called when the mail button is tapped.
	*/
	func didTapMail() {
		UIApplication.shared.openURL(NSURL(string: "mailto:gasteizkomargolariak@gmail.com")! as URL)
	}
	
	
	/**
	Called when the Facebook button is tapped.
	*/
	func didTapFacebook() {
		UIApplication.shared.openURL(NSURL(string: "http://facebook.com/gmargolariak")! as URL)
	}
	
	
	/**
	Called when the Twitter button is tapped.
	*/
	func didTapTwitter() {
		UIApplication.shared.openURL(NSURL(string: "http://twitter.com/gmargolariak")! as URL)
	}
	
	
	/**
	Called when the G+ button is tapped.
	*/
	func didTapGoogle() {
		UIApplication.shared.openURL(NSURL(string: "https://plus.google.com/106661466029005469492")! as URL)
	}
	
	
	/**
	Called when the Youtube button is tapped.
	*/
	func didTapYoutube() {
		UIApplication.shared.openURL(NSURL(string: "https://www.youtube.com/user/GasteizkoMargolariak")! as URL)
	}
	
	
	/**
	Called when the Instagram button is tapped.
	*/
	func didTapInstagram() {
		UIApplication.shared.openURL(NSURL(string: "https://instagram.com/gmargolariak/")! as URL)
	}
	
	
}
