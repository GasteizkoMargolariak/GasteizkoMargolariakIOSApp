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
import CoreData
import UIKit


/**
Class to handle the La Blanca view.
*/
class LablancaView: UIView {

	@IBOutlet var container: UIView!			// Top container of the view.
	@IBOutlet weak var nfWindow: UIView!		// The section to show when no festivals.
	@IBOutlet weak var fWindow: UIView!			// The window to show while the festivals.
	@IBOutlet weak var fTitle: UILabel!			// The title of the year festivals.
	@IBOutlet weak var fImage: UIImageView!		// The festivals image
	@IBOutlet weak var fText: UILabel!			// The festivals description.
	@IBOutlet weak var fBtSchedule: UIButton!	// Button to show the city schedule.
	@IBOutlet weak var fBtGMSchedule: UIButton!	// Button to show the Margolari schedule
	@IBOutlet weak var fOfferList: UIStackView!	// Stack view to hold the offer list.
	@IBOutlet weak var fDayList: UIStackView!	// Stack view to hold the single days price list.
	
	// App delegate
	var delegate: AppDelegate? = nil
	
	
	/**
	Default constructor for the interface builder.
	:param: frame Window frame.
	*/
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	
	/**
	Run when the view is started.
	*/
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		
		Bundle.main.loadNibNamed("LablancaView", owner: self, options: nil)
		self.addSubview(container)
		self.container.frame = self.bounds
		
		// Get viewController from StoryBoard
		let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		_ = storyboard.instantiateViewController(withIdentifier: "GMViewController") as! ViewController
		
		// Read settings and show the required sections
		let defaults = UserDefaults.standard
		let festivals: Int = defaults.integer(forKey: "festivals")
		
		if festivals == 1{
			showFestivals()
		}
		else{
			showNoFestivals()
		}
	}


	/**
	Displays the section to be shown while (and near) the La Blanca festivals.
	*/	
	func showFestivals(){
		NSLog(":LABLANCA:LOG: Showing festivals section.")
		self.nfWindow.isHidden = true
		
		// TODO: Get current year
		let year = 2017
		
		let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let lang : String = getLanguage()
		context.persistentStoreCoordinator = appDelegate.persistentStoreCoordinator
		
		// Get info about festivals
		let fetchRequest: NSFetchRequest<Festival> = Festival.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "year = %i", year)
		
		do {
			
			// Get info from festivals
			let searchResults = try context.fetch(fetchRequest)
			
			if searchResults.count > 0 {
				let r = searchResults[0]
			
				// Set description
				self.fText.text = (r.value(forKey: "text_\(lang)") as! String?)?.decode().stripHtml()
				
				// Set image
				let filename: String = r.value(forKey: "img") as! String
				if (filename == ""){
					// Hide the imageview
					self.fImage.isHidden = true;
				}
				else{
					let path = "img/fiestas/thumb/\(filename)"
					self.fImage.setImage(localPath: path, remotePath: "https://margolariak.com/\(path)")
				}
			}

		}
		catch {
			NSLog(":LABLANCA:ERROR: Error getting festivals info: \(error)")
		}
		
		// Set up schedule buttons
		let tapRecognizerSchedule = UITapGestureRecognizer(target: self, action: #selector(openSchedule(_:)))
		fBtSchedule.isUserInteractionEnabled = true
		fBtSchedule.addGestureRecognizer(tapRecognizerSchedule)
		let tapRecognizerGMSchedule = UITapGestureRecognizer(target: self, action: #selector(openGMSchedule(_:)))
		fBtGMSchedule.isUserInteractionEnabled = true
		fBtGMSchedule.addGestureRecognizer(tapRecognizerGMSchedule)
		
		// Get info about the days and offers.
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		dateFormatter.locale = Locale.init(identifier: "en_GB")
		
		// First date of year
		var dateString = "\(year)-01-01"
		let sDate = dateFormatter.date(from: dateString)
		
		// Last date of year
		dateString = "\(year)-12-31"
		let eDate = dateFormatter.date(from: dateString)

		// Get offers
		let offerFetchRequest: NSFetchRequest<Festival_offer> = Festival_offer.fetchRequest()
		offerFetchRequest.predicate = NSPredicate(format: "year = %i", year)

		do {

			// Get info from festivals
			let offerSearchResults = try context.fetch(offerFetchRequest)
			
			var row: RowLablancaOffer
			var count: Int = 0

			for offer in offerSearchResults as [NSManagedObject]{

				let name: String = offer.value(forKey: "name_\(lang)")! as! String
				let price: Int = offer.value(forKey: "price")! as! Int
				let description: String = offer.value(forKey: "description_\(lang)")! as! String

				// Create the row and set data.
				row = RowLablancaOffer.init(s: "rowLablancaOffer\(count)", i: count)
				row.setName(name: name)
				row.setPrice(price: price)
				row.setDescription(description: description)

				// Add the row
				fOfferList.addArrangedSubview(row)
				row.setNeedsLayout()
				row.layoutIfNeeded()

				// Hide the separator of the last row
				if count == offerSearchResults.count - 1 {
					row.hidSeparator()
				}

				count = count + 1
			}

		}
		catch {
			NSLog(":LABLANCA:ERROR: Error getting festival offers: \(error)")
		}

		// Get days
		let dayFetchRequest: NSFetchRequest<Festival_day> = Festival_day.fetchRequest()
		dayFetchRequest.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", argumentArray: [sDate!, eDate!])
		
		do {
			
			// Get info from festivals
			let daySearchResults = try context.fetch(dayFetchRequest)
			
			var row: RowLablancaDay
			var count: Int = 0
			
			for day in daySearchResults as [NSManagedObject]{
				
				let date: NSDate = day.value(forKey: "date")! as! NSDate
				let dateString: String = dateFormatter.string(from: date as Date)
				let nDay: Int = Int(dateString.subStr(start: 8, end: 9))!
				let month: String = dateString.subStr(start: 5, end: 6)
				var nMonth: String = "Agosto" // TODO: Reference
				if month == "07"{
					nMonth = "Julio" // TODO: Reference
				}
				let name: String = day.value(forKey: "name_\(lang)")! as! String
				let price: Int = day.value(forKey: "price")! as! Int
				
				// Create the row and set data.
				row = RowLablancaDay.init(s: "rowLablancaDay\(count)", i: count)
				row.setDay(number: nDay, month: nMonth, name: name, price: price)
				
				// Add the row
				fDayList.addArrangedSubview(row)
				row.setNeedsLayout()
				row.layoutIfNeeded()
				
				// Hide the separator of the last row
				if count == daySearchResults.count - 1 {
					row.separator.isHidden = true
				}
				
				count = count + 1
			}
			
		}
		catch {
			NSLog(":LABLANCA:ERROR: Error getting festival days info: \(error)")
		}
	}
	

	/**
	Hides the view to be shown during (and near) the festivals.
	*/
	func showNoFestivals(){
		NSLog(":LABLANCA:LOG: Showing no festivals section.")
		self.fWindow.isHidden = true
	}
	

	/**
	Commands the view controller to show the city schedule view.
	*/
	func openSchedule(_ sender:UITapGestureRecognizer? = nil){
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showSchedule(margolari: false)
	}


	/**
	Commands the view controller to show the Gasteizko Margolariak schedule view.
	*/
	func openGMSchedule(_ sender:UITapGestureRecognizer? = nil){
		let delegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
		delegate.controller?.showSchedule(margolari: true)
	}

	
	/**
	Gets the device language. The only recognized languages are Spanish, English and Basque.
	If the device has another language, Spanish will be selected by default.
	:return: Two-letter language code.
	*/
	func getLanguage() -> String{
		let pre = NSLocale.preferredLanguages[0].subStr(start: 0, end: 1)
		if(pre == "es" || pre == "en" || pre == "eu"){
			return pre
		}
		else{
			return "es"
		}
	}
}
