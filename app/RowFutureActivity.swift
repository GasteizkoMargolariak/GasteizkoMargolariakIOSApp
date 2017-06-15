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
Extension of UIView to be formatted as future activity rows.
*/
@IBDesignable class RowFutureActivity: UIView {

	// Outlets.
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var image: UIImageView!
	@IBOutlet weak var descript: UILabel!
	@IBOutlet weak var date: UILabel!
	@IBOutlet weak var city: UILabel!
	@IBOutlet weak var price: UILabel!
	
	// Activity ID.
	var id = -1
	
	
	/**
	Default constructor
	:param: coder Coder.
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
		container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		container.translatesAutoresizingMaskIntoConstraints = true
		
		self.container.frame = self.bounds
		self.addSubview(self.container)
		
		// Set tap recognizer
		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (RowPastActivity.openActivity (_:)))
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
	Changes the title of the activity. Decodes HTML.
	:param: text The new title.
	*/
	func setTitle(text: String){
		self.title.text = text.decode().stripHtml()
	}
	
	
	/**
	Sets the city of the activity.
	:param: text The city.
	*/
	func setCity(text: String){
		self.city.text = text.decode().stripHtml()
	}
	
	
	/**
	Sets the price of the activity.
	:param: price The price, in Euros. If 0, nothing is shown.
	*/
	func setPrice(price: Int){
		if price != 0{
			self.price.text = "\(price) €"
		}
		else{
			self.price.text = ""
		}
	}
	
	
	/**
	Changes the description of the activity. Decodes HTML.
	:param: text The new text.
	*/
	func setText(text: String){
		self.descript.text = text.decode().stripHtml()
	}
	
	
	/**
	Sets the date of the activity in a human readable format.
	:param: text The date.
	:param: lang Device language.
	*/
	func setDate(date: NSDate, lang: String){
				
		let months_es = ["0index", "enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"]
		let months_en = ["0index", "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
		let months_eu = ["0index", "urtarrilaren", "otsailaren", "martxoaren", "abrilaren", "maiatzaren", "ekainaren", "ustailaren", "abustuaren", "irailaren", "urriaren", "azaroaren", "abenduaren"]
		let days_es = ["0index", "Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sábado", "Domingo"]
		let days_en = ["0index", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
		let days_eu = ["0index", "Astelehena", "Asteartea", "Asteazkena", "Osteguna", "Ostirala", "Larumbata", "Igandea"]
		
		let calendar = Calendar.current
		let day = calendar.component(.day, from: date as Date)
		let month = calendar.component(.month, from: date as Date)
		let weekday = calendar.component(.weekday, from: date as Date)
		var strDate = ""
		
		switch lang{
			case "en":
				
				var dayNum = ""
				switch day{
					case 1:
						dayNum = "1th"
						break
					case 2:
						dayNum = "2nd"
						break;
					case 3:
						dayNum = "3rd"
						break;
					default:
						dayNum = "\(weekday)th"
				}
				
				strDate = "\(days_en[weekday]), \(months_en[month]) \(dayNum)"
				break
			case "eu":
				strDate = "\(days_eu[weekday]) \(months_eu[month]) \(day)an"
				break
			default:
				strDate = "\(days_es[weekday]) \(day) de \(months_es[month])"
		}
		
		self.date.text = strDate
	}
	
	
	/**
	Changes the image of the activity.
	If null or empty, the igage is hidden.
	:param: path The new text.
	*/
	func setImage(filename: String){
		if (filename == ""){
			// Hide the imageview
			self.image.isHidden = true
		}
		else{
			let path = "img/actividades/thumb/\(filename)"
			self.image.setImage(localPath: path, remotePath: "https://margolariak.com/\(path)")
		}
	}
	
	
	/**
	Opens an activity.
	*/
	func openActivity(_ sender:UITapGestureRecognizer? = nil){
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showFutureActivity(id: self.id)
	}
}
