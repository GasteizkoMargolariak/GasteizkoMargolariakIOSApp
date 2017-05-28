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
@IBDesignable class RowLablancaOffer: UIView {
	
	// Outlets
	/*@IBOutlet weak var container: UIView!
	@IBOutlet weak var number: UILabel!
	@IBOutlet weak var month: UILabel!
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var price: UILabel!
	@IBOutlet weak var separator: UIView!*/
	@IBOutlet weak var vwContainer: UIView!
	@IBOutlet weak var lbName: UILabel!
	@IBOutlet weak var lbDescription: UILabel!
	@IBOutlet weak var lbPrice: UILabel!
	@IBOutlet weak var vwSeparator: UIView!
	
	
	
	
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
		
		self.frame = self.bounds
		self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.translatesAutoresizingMaskIntoConstraints = true
		
		self.vwContainer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.vwContainer.translatesAutoresizingMaskIntoConstraints = true
		
		self.vwContainer.frame = self.bounds
		self.addSubview(self.vwContainer)
		
	}
	
	/**
	Default constructor.
	:param: s Custom identifier
	:param: i Custom identifier
	*/
	init(s: String, i: Int) {
		NSLog(":ROWLABLANCAOFFER:DEBUG: Init \(s), \(i)")
		
		super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
		loadViewFromNib()
		self.frame = self.bounds
		self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.translatesAutoresizingMaskIntoConstraints = true
	}
	
	/**
	Default constructor for the interface builder
	*/
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	/**
	Sets the name of the offer.
	:param: name The name of the offer.
	*/
	func setName(name: String){
		self.lbName.text = name
	}
	
	/**
	Sets the description of the offer.
	:param: description The description of the offer.
	*/
	func setDescription(description: String){
		self.lbDescription.text = description
	}
	
	/**
	Sets the price of the offer.
	:param: price The description of the offer.
	*/
	func setPrice(price: Int){
		self.lbPrice.text = "\(price) €"
	}
	
	/**
	Hiddes the separator bar.
	*/
	func hidSeparator(){
		self.vwSeparator.alpha = 0
	}
	
}
