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

import UIKit
import CoreData

/**
The view controller of the app.
*/
class PostViewController: UIViewController, UIGestureRecognizerDelegate {
	
	@IBOutlet var postView: PostView!
	
	var id: Int = -1
	var delegate: AppDelegate?
	
	//Each of the sections of the app.
	
	var passId: Int = -1
	
	func getContext () -> NSManagedObjectContext {
		//let appDelegate = UIApplication.shared.delegate as! AppDelegate
		//return appDelegate.persistentContainer.viewContext
		return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
	}
	
	func showPost(id: Int){
		print("POSTCONTROLLER:DEBUG: showPost \(id)")
		self.postView.id = id
		self.postView.loadPost(id: id)
	}
	
	/**
	Run when the app loads.
	*/
	override func viewDidLoad() {
		
		print("POSTCONTROLLER:LOG: viewDidLoad()")
		
		super.viewDidLoad()
		self.postView.loadPost(id: id)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		let backButton: UIBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(back))
		self.navigationItem.leftBarButtonItem = backButton;
		super.viewWillAppear(animated);
	}
	
	func back() {
		self.dismiss(animated: true, completion: nil)
	}
	
	
	/**
	Dispose of any resources that can be recreated.
	*/
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
}

