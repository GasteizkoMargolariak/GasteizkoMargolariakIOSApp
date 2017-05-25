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
class LocationView: UIView {
	
	@IBOutlet var container: UIView!
	
	override init(frame: CGRect){
		super.init(frame: frame)
	}
	
	/**
	Run when the view is started.
	*/
	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
		NSLog(":LOCATION:DEBUG: init (coder).")
		
		// Load the contents of the HomeView.xib file.
		Bundle.main.loadNibNamed("LocationView", owner: self, options: nil)
		self.addSubview(self.container)
		self.container.frame = self.bounds
		/*self.postList = self.section.getContentStack()
		
		// Get viewController from StoryBoard
		self.storyboard = UIStoryboard(name: "Main", bundle: nil)
		self.controller = storyboard?.instantiateViewController(withIdentifier: "GMViewController") as? ViewController
		self.context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
		self.delegate = UIApplication.shared.delegate as? AppDelegate
		self.lang = getLanguage()
		self.context?.persistentStoreCoordinator = delegate?.persistentStoreCoordinator
		
		populate()*/
		
		NSLog(":LOCATION:DEBUG: Finished loading LocationView")
		
	}
}
