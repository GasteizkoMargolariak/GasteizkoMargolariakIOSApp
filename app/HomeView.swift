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
 Class to handle the home view.
 */
class HomeView: UIView {
	
	//The main scroll view.
	@IBOutlet weak var scrollView: UIScrollView!
	
	//The container of the view.
	@IBOutlet weak var container: UIView!
	
	//Each of the sections of the view.
	@IBOutlet weak var locationSection: Section!
	@IBOutlet weak var lablancaSection: Section!
	@IBOutlet weak var futureActivitiesSection: Section!
	@IBOutlet weak var blogSection: Section!
	@IBOutlet weak var gallerySection: Section!
	@IBOutlet weak var pastActivitiesSection: Section!
	@IBOutlet weak var socialSection: Section!
	
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	/**
	 Run when the view is started.
	*/
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		
		//Load the contents of the HomeView.xib file.
		Bundle.main.loadNibNamed("HomeView", owner: self, options: nil)
		self.addSubview(container)
		container.frame = self.bounds
		

		
		//Set titles for each section
		locationSection.setTitle(text: "Encuentranos")
		lablancaSection.setTitle(text: "La Blanca")
		futureActivitiesSection.setTitle(text: "Proximas actividades")
		blogSection.setTitle(text: "Ultimos posts")
		gallerySection.setTitle(text: "Ultimas fotos")
		pastActivitiesSection.setTitle(text: "Ultimas actividades")
		socialSection.setTitle(text: "Siguenos")
		
		//Get info to populate sections
		let moc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let lang : String = getLanguage()
		
		//Populate sections
		setUpPastActivities(context: moc, delegate: appDelegate, lang: lang, parent: pastActivitiesSection.getContentStack())
		
		//Always at the end: update scrollview
		var h: Int = 0
		for view in scrollView.subviews {
			//contentRect = contentRect.union(view.frame);
			h = h + Int(view.frame.height) + 30 //Why 30?
			print("curh: \(h)")
		}
		self.scrollView.contentSize.height = CGFloat(h);
	}
	
	func getLanguage() -> String{
		let pre = NSLocale.preferredLanguages[0].subStr(start: 0, end: 1)
		print("Device language: \(pre)")
		if(pre == "es" || pre == "en" || pre == "eu"){
			return pre
		}
		else{
			return "es"
		}
	}
	
	func setUpPastActivities(context : NSManagedObjectContext, delegate: AppDelegate, lang: String, parent : UIStackView){
		
		context.persistentStoreCoordinator = delegate.persistentStoreCoordinator
		let fetchRequest: NSFetchRequest<Activity> = Activity.fetchRequest()
		let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
		let sortDescriptors = [sortDescriptor]
		fetchRequest.sortDescriptors = sortDescriptors
		//TODO Compare dates
		//fetchRequest.predicate = NSPredicate(format: "date < %@", sysdate)
		fetchRequest.fetchLimit = 1//2
		
		do {
			//go get the results
			let searchResults = try context.fetch(fetchRequest)
			
			//I like to check the size of the returned results!
			print ("Activities: \(searchResults.count)")
			
			var row : RowHomePastActivities
			var count = 0;
			var title : String
			
			//You need to convert to NSManagedObject to use 'for' loops
			for r in searchResults as [NSManagedObject] {
				count = count + 1
				//get the Key Value pairs (although there may be a better way to do that...
				print("Perm: \(r.value(forKey: "permalink"))")
				
				
				//Create a new row
				row = RowHomePastActivities.init(s: "rowHomePastActivities", i: count) //frame: CGRect(top: 0, left: 0, width: 200, height: 50)
				//row = RowHomePastActivities(frame: parent.bounds)
				//row = RowHomePastActivities.instanceFromNib() as! RowHomePastActivities
				//row.frame = CGRect(x: 15, y: 15, width: 100, height: 100)
				//row = RowHomePastActivities(frame: CGRect(x: 13, y: 0, width: 100, height: 100))
				title = r.value(forKey: "permalink")! as! String
				print(title)
				row.setTitle(text: title)
				//row.backgroundColor = UIColor.red
				//row.setBounds(rect: parent.bounds)
				
				parent.addArrangedSubview(row)
				//parent.addSubview(row)
				let lbl = UILabel()
				lbl.text = "ABBA"
				//view.addEntry(view: row)
				parent.addArrangedSubview(lbl)
				//var testView: UIView = UIView(frame: CGRect(x: 13, y: 13, width: 100, height: 100))
    //testView.backgroundColor = UIColor.blue
    //testView.alpha = 0.5
    //testView.tag = 100
    //testView.isUserInteractionEnabled = true
    //parent.addSubview(testView)
				
				//parent.addConstraint(NSLayoutConstraint(item: row, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: parent, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -10))
				//Íparent.addConstraint(NSLayoutConstraint(item: row, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: parent, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -10))
				//row = RowHomePastActivities(s: "rowHomePastActivities", i: count)//Bundle.mainBundle("RowPastActivities").loadNibNamed("", owner: nil, options: nil)[0] as! RowHomePastActivities
				//row.setupWithSuperView(superView: self)
				
			}
		} catch {
			print("Error with request: \(error)")
		}
	}
}
