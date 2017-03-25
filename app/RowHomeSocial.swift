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
	
	//The buttons
	@IBOutlet weak var btnPhone: UIImageView!
	@IBOutlet weak var btnMail: UIImageView!
	@IBOutlet weak var btnWhatsapp: UIImageView!
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
		loadViewFromNib()
		v = self
		v.frame = bounds
		v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		v.translatesAutoresizingMaskIntoConstraints = true
		container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		container.translatesAutoresizingMaskIntoConstraints = true
		
		container.frame = v.bounds
		v.addSubview(container)
		
		// Set buttons up
		let phoneTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapPhone))
		btnPhone.isUserInteractionEnabled = true
		btnPhone.addGestureRecognizer(phoneTapRecognizer)
		let mailTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMail))
		btnMail.isUserInteractionEnabled = true
		btnMail.addGestureRecognizer(mailTapRecognizer)
		let whatsappTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapWhatsapp))
		btnWhatsapp.isUserInteractionEnabled = true
		btnWhatsapp.addGestureRecognizer(whatsappTapRecognizer)
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
	*/
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	func didTapPhone() {
		UIApplication.shared.openURL(NSURL(string: "tel://+34637140371") as! URL)
	}
	
	func didTapMail() {
		UIApplication.shared.openURL(NSURL(string: "mailto:gasteizkomargolariak@gmail.com") as! URL)
	}
	
	func didTapWhatsapp() {
		//As of today, imposible
		//UIApplication.shared.openURL(NSURL(string: "+34637140371") as! URL)
	}
	
	func didTapFacebook() {
		UIApplication.shared.openURL(NSURL(string: "http://facebook.com/gmargolariak") as! URL)
	}
	
	func didTapTwitter() {
		UIApplication.shared.openURL(NSURL(string: "http://twitter.com/gmargolariak") as! URL)
	}
	
	func didTapGoogle() {
		UIApplication.shared.openURL(NSURL(string: "https://plus.google.com/106661466029005469492") as! URL)
	}
	
	func didTapYoutube() {
		UIApplication.shared.openURL(NSURL(string: "https://www.youtube.com/user/GasteizkoMargolariak") as! URL)
	}
	
	func didTapInstagram() {
		UIApplication.shared.openURL(NSURL(string: "https://instagram.com/gmargolariak/") as! URL)
	}
	
	
}
